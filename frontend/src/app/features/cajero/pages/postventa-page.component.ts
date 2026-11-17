import { CommonModule } from '@angular/common';
import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { firstValueFrom } from 'rxjs';

import { toast } from '@spartan-ng/brain/sonner';
import { NgIcon, provideIcons } from '@ng-icons/core';
import {
  lucideRefreshCw,
  lucideRotateCcw,
  lucideArrowRightLeft,
  lucideUndo2,
  lucidePrinter,
  lucideSearch,
  lucideCheckCircle2,
  lucideAlertCircle,
  lucideShieldCheck,
  lucideReceipt,
  lucideBadgePercent,
  lucideTag,
} from '@ng-icons/lucide';

import { HlmButton } from '../../../components/button/src';
import { CatalogProduct } from '../../shared/models/catalog.model';
import {
  ExchangeQuoteResponse,
  GarmentExchange,
  GarmentReturn,
  ReturnQuoteResponse,
  Sale,
} from '../../shared/models/sale.model';
import { CatalogApiService } from '../../shared/services/catalog-api.service';
import { SalesApiService } from '../../shared/services/sales-api.service';
import { SessionService } from '../../shared/services/session.service';
import { ModalFormularioComponent } from '../../shared/components/modal';

@Component({
  selector: 'app-postventa-page',
  standalone: true,
  imports: [CommonModule, FormsModule, NgIcon, HlmButton, ModalFormularioComponent],
  providers: [
    provideIcons({
      lucideRefreshCw,
      lucideRotateCcw,
      lucideArrowRightLeft,
      lucideUndo2,
      lucidePrinter,
      lucideSearch,
      lucideCheckCircle2,
      lucideAlertCircle,
      lucideShieldCheck,
      lucideReceipt,
      lucideBadgePercent,
      lucideTag,
    }),
  ],
  templateUrl: './postventa-page.component.html',
})
export class PostventaPageComponent implements OnInit {
  private readonly salesApi = inject(SalesApiService);
  private readonly catalogApi = inject(CatalogApiService);
  private readonly session = inject(SessionService);

  protected readonly branchId = computed(() => this.session.user()?.branch_id ?? undefined);
  protected readonly tenantId = computed(() => this.session.user()?.tenant_id ?? undefined);

  // Catálogo disponible para cambios
  protected readonly products = signal<CatalogProduct[]>([]);

  // =========================================================================
  // SEÑALES Y ESTADOS: DEVOLUCIÓN DE PRENDA (CU18 - POLÍTICA 2)
  // =========================================================================
  protected readonly showReturnModal = signal(false);
  protected readonly returnSaleIdInput = signal('');
  protected readonly foundSaleForReturn = signal<Sale | null>(null);
  protected readonly loadingSaleLookup = signal(false);
  protected readonly selectedReturnVariantId = signal<string | null>(null);
  protected readonly returnCondition = signal<'good_with_tags' | 'damaged_or_no_tags'>('good_with_tags');
  protected readonly refundMethod = signal<'NOTA_CREDITO' | 'EFECTIVO'>('NOTA_CREDITO');
  protected readonly returnReason = signal('');
  protected readonly returnQuote = signal<ReturnQuoteResponse | null>(null);
  protected readonly loadingReturnQuote = signal(false);
  protected readonly submittingReturn = signal(false);
  protected readonly lastProcessedReturn = signal<GarmentReturn | null>(null);
  protected readonly showReturnReceiptModal = signal(false);

  // =========================================================================
  // SEÑALES Y ESTADOS: CAMBIO DE PRENDA POR TALLA / MODELO (CU17 - POLÍTICA 1)
  // =========================================================================
  protected readonly showExchangeModal = signal(false);
  protected readonly exchangeSaleIdInput = signal('');
  protected readonly foundSaleForExchange = signal<Sale | null>(null);
  protected readonly loadingSaleLookupExchange = signal(false);
  protected readonly selectedOriginalVariantId = signal<string | null>(null);
  protected readonly selectedNewVariantId = signal<string | null>(null);
  protected readonly loadingExchangeQuote = signal(false);
  protected readonly exchangeQuote = signal<ExchangeQuoteResponse | null>(null);
  protected readonly differencePaid = signal(false);
  protected readonly exchangePaymentMethod = signal<'efectivo' | 'tarjeta'>('efectivo');
  protected readonly exchangeCondition = signal<'good_with_tags' | 'damaged_or_no_tags'>('good_with_tags');
  protected readonly exchangeNotes = signal('');
  protected readonly submittingExchange = signal(false);
  protected readonly lastProcessedExchange = signal<GarmentExchange | null>(null);
  protected readonly lastExchangeQuote = signal<ExchangeQuoteResponse | null>(null);
  protected readonly showExchangeReceiptModal = signal(false);

  ngOnInit(): void {
    this.loadCatalog();
  }

  private async loadCatalog(): Promise<void> {
    try {
      const tenantId = this.tenantId();
      const resp = await firstValueFrom(this.catalogApi.listProducts({ tenant_id: tenantId }));
      this.products.set(resp.data ?? []);
    } catch {
      // Catálogo opcional para cambios
    }
  }

  // =========================================================================
  // MÉTODOS: DEVOLUCIÓN DE PRENDA (CU18)
  // =========================================================================
  protected openReturnModal(): void {
    this.returnSaleIdInput.set('');
    this.foundSaleForReturn.set(null);
    this.selectedReturnVariantId.set(null);
    this.returnQuote.set(null);
    this.returnReason.set('');
    this.refundMethod.set('NOTA_CREDITO');
    this.returnCondition.set('good_with_tags');
    this.showReturnModal.set(true);
  }

  protected closeReturnModal(): void {
    this.showReturnModal.set(false);
  }

  protected async lookupSaleForReturn(): Promise<void> {
    const saleId = this.returnSaleIdInput().trim();
    if (!saleId) {
      toast.error('Ingresa el identificador o UUID de la venta.');
      return;
    }

    this.loadingSaleLookup.set(true);
    try {
      const resp = await firstValueFrom(this.salesApi.getSale(saleId, this.branchId()));
      if (!resp.data) {
        toast.error('No se localizó la venta con el ID suministrado.');
        this.foundSaleForReturn.set(null);
        return;
      }
      this.foundSaleForReturn.set(resp.data);
      this.selectedReturnVariantId.set(null);
      this.returnQuote.set(null);
      toast.success('Venta localizada correctamente.');
    } catch (err: any) {
      toast.error(err?.error?.message ?? 'Error al buscar el comprobante de venta.');
      this.foundSaleForReturn.set(null);
    } finally {
      this.loadingSaleLookup.set(false);
    }
  }

  protected async onSelectReturnVariant(variantId: string): Promise<void> {
    this.selectedReturnVariantId.set(variantId);
    await this.calculateReturnQuote(variantId);
  }

  private async calculateReturnQuote(variantId: string): Promise<void> {
    const sale = this.foundSaleForReturn();
    if (!sale) return;

    this.loadingReturnQuote.set(true);
    try {
      const resp = await firstValueFrom(
        this.salesApi.quoteReturn(
          {
            sale_id: sale.id,
            variant_id: variantId,
          },
          this.branchId(),
        ),
      );
      this.returnQuote.set(resp.data ?? null);
    } catch (err: any) {
      toast.error(err?.error?.message ?? 'No se pudo cotizar la retención de devolución.');
      this.returnQuote.set(null);
    } finally {
      this.loadingReturnQuote.set(false);
    }
  }

  protected async processReturnSubmit(): Promise<void> {
    const sale = this.foundSaleForReturn();
    const variantId = this.selectedReturnVariantId();
    const quote = this.returnQuote();

    if (!sale || !variantId || !quote) {
      toast.error('Datos incompletos para procesar la devolución.');
      return;
    }

    if (this.returnCondition() !== 'good_with_tags') {
      toast.error('Política 2: La prenda debe contar con su etiqueta intacta para autorizar la devolución.');
      return;
    }

    this.submittingReturn.set(true);
    try {
      const resp = await firstValueFrom(
        this.salesApi.processReturn(
          {
            sale_id: sale.id,
            variant_id: variantId,
            refund_method: this.refundMethod(),
            condition: this.returnCondition(),
            reason: this.returnReason().trim() || undefined,
          },
          this.branchId(),
        ),
      );

      this.lastProcessedReturn.set(resp.data ?? null);
      this.showReturnModal.set(false);
      this.showReturnReceiptModal.set(true);
      toast.success('Devolución consolidada exitosamente.');
    } catch (err: any) {
      toast.error(err?.error?.message ?? 'Error al procesar la devolución de prenda.');
    } finally {
      this.submittingReturn.set(false);
    }
  }

  protected printReturnReceipt(): void {
    window.print();
  }

  protected closeReturnReceiptModal(): void {
    this.showReturnReceiptModal.set(false);
    this.lastProcessedReturn.set(null);
  }

  // =========================================================================
  // MÉTODOS: CAMBIO DE PRENDA (CU17)
  // =========================================================================
  protected openExchangeModal(): void {
    this.exchangeSaleIdInput.set('');
    this.foundSaleForExchange.set(null);
    this.selectedOriginalVariantId.set(null);
    this.selectedNewVariantId.set(null);
    this.exchangeQuote.set(null);
    this.differencePaid.set(false);
    this.exchangePaymentMethod.set('efectivo');
    this.exchangeCondition.set('good_with_tags');
    this.exchangeNotes.set('');
    this.showExchangeModal.set(true);
  }

  protected closeExchangeModal(): void {
    this.showExchangeModal.set(false);
  }

  protected async lookupSaleForExchange(): Promise<void> {
    const saleId = this.exchangeSaleIdInput().trim();
    if (!saleId) {
      toast.error('Ingresa el identificador o ticket de venta original.');
      return;
    }

    this.loadingSaleLookupExchange.set(true);
    try {
      const resp = await firstValueFrom(this.salesApi.getSale(saleId, this.branchId()));
      if (!resp.data) {
        toast.error('No se localizó la venta original.');
        this.foundSaleForExchange.set(null);
        return;
      }
      this.foundSaleForExchange.set(resp.data);
      this.selectedOriginalVariantId.set(null);
      this.selectedNewVariantId.set(null);
      this.exchangeQuote.set(null);
      toast.success('Ticket original encontrado.');
    } catch (err: any) {
      toast.error(err?.error?.message ?? 'Error al buscar el comprobante para cambio.');
      this.foundSaleForExchange.set(null);
    } finally {
      this.loadingSaleLookupExchange.set(false);
    }
  }

  protected onSelectExchangeOriginalVariant(variantId: string): void {
    this.selectedOriginalVariantId.set(variantId);
    if (this.selectedNewVariantId()) {
      this.calculateExchangeQuote();
    }
  }

  protected onSelectExchangeNewVariant(variantId: string): void {
    this.selectedNewVariantId.set(variantId);
    if (this.selectedOriginalVariantId()) {
      this.calculateExchangeQuote();
    }
  }

  private async calculateExchangeQuote(): Promise<void> {
    const sale = this.foundSaleForExchange();
    const origVarId = this.selectedOriginalVariantId();
    const newVarId = this.selectedNewVariantId();
    if (!sale || !origVarId || !newVarId) return;

    this.loadingExchangeQuote.set(true);
    try {
      const resp = await firstValueFrom(
        this.salesApi.quoteExchange(
          {
            sale_id: sale.id,
            original_variant_id: origVarId,
            new_variant_id: newVarId,
          },
          this.branchId(),
        ),
      );
      const quote = resp.data ?? null;
      this.exchangeQuote.set(quote);
      if (quote && !quote.requires_payment) {
        this.differencePaid.set(true);
      } else {
        this.differencePaid.set(false);
      }
    } catch (err: any) {
      toast.error(err?.error?.message ?? 'No se pudo calcular la diferencia de precio.');
      this.exchangeQuote.set(null);
    } finally {
      this.loadingExchangeQuote.set(false);
    }
  }

  protected async processExchangeSubmit(): Promise<void> {
    const sale = this.foundSaleForExchange();
    const origVarId = this.selectedOriginalVariantId();
    const newVarId = this.selectedNewVariantId();
    const quote = this.exchangeQuote();

    if (!sale || !origVarId || !newVarId || !quote) {
      toast.error('Completa todos los pasos antes de consolidar el cambio.');
      return;
    }

    if (this.exchangeCondition() !== 'good_with_tags') {
      toast.error('Política 1: La prenda debe contar con su etiqueta textil intacta para autorizar el cambio.');
      return;
    }

    if (quote.requires_payment && !this.differencePaid()) {
      toast.error('Política 1 Inviolable: El cliente debe abonar la diferencia en mostrador.');
      return;
    }

    this.submittingExchange.set(true);
    try {
      const resp = await firstValueFrom(
        this.salesApi.processExchange(
          {
            sale_id: sale.id,
            original_variant_id: origVarId,
            new_variant_id: newVarId,
            condition: this.exchangeCondition(),
            difference_paid: this.differencePaid(),
            payment_method: quote.requires_payment ? this.exchangePaymentMethod() : null,
            notes: this.exchangeNotes().trim() || undefined,
          },
          this.branchId(),
        ),
      );

      this.lastExchangeQuote.set(quote);
      this.lastProcessedExchange.set(resp.data ?? null);
      this.showExchangeModal.set(false);
      this.showExchangeReceiptModal.set(true);
      toast.success('Cambio de prenda consolidado exitosamente.');
    } catch (err: any) {
      toast.error(err?.error?.message ?? 'Error al procesar el cambio de prenda.');
    } finally {
      this.submittingExchange.set(false);
    }
  }

  protected printExchangeReceipt(): void {
    window.print();
  }

  protected closeExchangeReceiptModal(): void {
    this.showExchangeReceiptModal.set(false);
    this.lastProcessedExchange.set(null);
    this.lastExchangeQuote.set(null);
  }
}
