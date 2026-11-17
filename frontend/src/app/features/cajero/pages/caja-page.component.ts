import { CommonModule } from '@angular/common';
import { Component, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { firstValueFrom } from 'rxjs';

import { toast } from '@spartan-ng/brain/sonner';

import { HlmBadgeImports } from '../../../components/badge/src';
import { HlmButton } from '../../../components/button/src';
import { HlmCardImports } from '../../../components/card/src';
import { HlmInputImports } from '../../../components/input/src';
import { NetworkStatusService } from '../../../core/offline/network-status.service';
import { IdbSalesService, PendingOfflineSale } from '../../../core/offline/idb-sales.service';
import { IdbCatalogService } from '../../../core/offline/idb-catalog.service';
import { IdbReservationsService, PendingOfflineReservation } from '../../../core/offline/idb-reservations.service';
import { ReservationApiService } from '../../shared/services/reservation-api.service';
import { CreateReservationRequest } from '../../shared/models/reservation.model';
import { getErrorMessage } from '../../../core/utils/http-error.util';
import { requestWithToast } from '../../../core/utils/request-toast.util';
import { CatalogProduct, CatalogProductVariant } from '../../shared/models/catalog.model';
import {
  BatchSyncItemResult,
  BatchSyncOperation,
  BatchSyncRequest,
  BatchSyncSummary,
  CreateSaleRequest,
  ExchangeQuoteResponse,
  GarmentExchange,
  GarmentReturn,
  ReturnQuoteResponse,
  Sale,
} from '../../shared/models/sale.model';
import { CatalogApiService } from '../../shared/services/catalog-api.service';
import { SalesApiService } from '../../shared/services/sales-api.service';
import { SessionService } from '../../shared/services/session.service';

type SelectedSaleItem = {
  variant_id: string;
  product_name: string;
  variant_sku: string;
  size_name: string | null;
  color_name: string | null;
  unit_price: string;
  original_unit_price: string;
  quantity: number;
  image_url: string | null;
};

@Component({
  selector: 'app-cajero-caja-page',
  standalone: true,
  imports: [CommonModule, FormsModule, HlmButton, ...HlmBadgeImports, ...HlmCardImports, ...HlmInputImports],
  templateUrl: './caja-page.component.html',
})
export class CajaPageComponent {
  private readonly catalogApi = inject(CatalogApiService);
  private readonly salesApi = inject(SalesApiService);
  private readonly reservationApi = inject(ReservationApiService);
  private readonly session = inject(SessionService);
  private readonly router = inject(Router);
  protected readonly network = inject(NetworkStatusService);
  protected readonly idbSales = inject(IdbSalesService);
  protected readonly idbCatalog = inject(IdbCatalogService);
  protected readonly idbReservations = inject(IdbReservationsService);

  protected readonly syncingCatalog = signal(false);
  protected readonly searchTerm = signal('');
  protected readonly products = signal<CatalogProduct[]>([]);
  protected readonly selectedItems = signal<SelectedSaleItem[]>([]);
  protected readonly lastSale = signal<Sale | null>(null);
  protected readonly lastOfflineSale = signal<PendingOfflineSale | null>(null);
  protected readonly showReceiptModal = signal(false);

  protected readonly loadingProducts = signal(false);
  protected readonly submitting = signal(false);
  protected readonly cashReference = signal('');
  protected readonly cashReceived = signal<number | null>(null);
  protected readonly Number = Number;

  // Simulación de modo desconectado para pruebas operativas
  protected readonly simulatedOffline = signal(false);

  protected readonly isOfflineEffective = computed(() => !this.network.isOnline() || this.simulatedOffline());
  protected readonly pendingOutboxCount = computed(() => this.idbSales.getPendingCount());

  protected readonly branchId = computed(() => this.session.user()?.branch_id ?? null);
  protected readonly branchName = computed(() => (this.session.user() as any)?.branch_name ?? 'Sucursal Central');
  protected readonly cashierName = computed(() => this.session.user()?.name ?? 'Cajero en Turno');

  protected readonly subtotal = computed(() =>
    this.selectedItems().reduce((sum, item) => sum + Number(item.original_unit_price) * item.quantity, 0).toFixed(2)
  );
  protected readonly discount = computed(() =>
    this.selectedItems().reduce((sum, item) => sum + (Number(item.original_unit_price) - Number(item.unit_price)) * item.quantity, 0).toFixed(2)
  );
  protected readonly total = computed(() =>
    (Number(this.subtotal()) - Number(this.discount())).toFixed(2)
  );

  protected readonly changeAmount = computed(() => {
    const received = this.cashReceived();
    const tot = Number(this.total());
    if (received === null || received < tot) return '0.00';
    return (received - tot).toFixed(2);
  });

  // =========================================================================
  // LOGICA DEL CU14 Y CU15: Bandeja Local y Sincronización en Lote Centralizada
  // =========================================================================
  protected readonly activeTab = signal<'tpv' | 'reservas' | 'outbox'>('tpv');
  protected readonly outboxSales = signal<PendingOfflineSale[]>([]);
  protected readonly syncingOutbox = signal(false);
  protected readonly verifyingOutbox = signal(false);
  protected readonly retryingSaleId = signal<string | null>(null);
  protected readonly lastBatchSyncSummary = signal<BatchSyncSummary | null>(null);
  protected readonly lastBatchSyncDetails = signal<BatchSyncItemResult[]>([]);
  protected readonly showBatchSyncSummary = signal(false);

  // =========================================================================
  // LOGICA DEL CU11: Registrar Reserva de Prendas Offline en Mostrador
  // =========================================================================
  protected readonly offlineReservations = signal<PendingOfflineReservation[]>([]);
  protected readonly pendingReservationsCount = computed(() => this.offlineReservations().filter((r) => !r.synced).length);
  protected readonly resCustomerName = signal('');
  protected readonly resCustomerPhone = signal('');
  protected readonly resCustomerEmail = signal('');
  protected readonly resVisitDate = signal(new Date().toISOString().slice(0, 10));
  protected readonly resSelectedProduct = signal<CatalogProduct | null>(null);
  protected readonly resSelectedVariant = signal<CatalogProductVariant | null>(null);
  protected readonly resQuantity = signal(1);
  protected readonly resNotes = signal('');
  protected readonly resApartando = signal(false);
  protected readonly resSyncing = signal(false);
  protected readonly lastOfflineReservation = signal<PendingOfflineReservation | null>(null);
  protected readonly showResReceiptModal = signal(false);

  protected readonly pendingSales = computed(() => this.outboxSales().filter((s) => !s.synced));
  protected readonly syncedSales = computed(() => this.outboxSales().filter((s) => s.synced));
  protected readonly failedSales = computed(() =>
    this.outboxSales().filter((s) => !s.synced && (Boolean(s.sync_error) || Boolean(s.error) || (s.retry_count ?? 0) > 0))
  );
  protected readonly totalPendingCash = computed(() =>
    this.pendingSales().reduce((sum, s) => sum + s.total_amount, 0).toFixed(2)
  );

  protected switchTab(tab: 'tpv' | 'reservas' | 'outbox'): void {
    this.activeTab.set(tab);
    if (tab === 'outbox') {
      this.refreshOutbox();
    } else if (tab === 'reservas') {
      this.refreshReservations();
    }
  }

  protected refreshReservations(): void {
    this.offlineReservations.set(this.idbReservations.getPending());
  }

  protected refreshOutbox(): void {
    this.outboxSales.set(this.idbSales.getPending());
  }

  protected openSaleDetail(sale: PendingOfflineSale): void {
    this.lastOfflineSale.set(sale);
    this.lastSale.set(null);
    this.showReceiptModal.set(true);
  }

  protected removeSaleFromOutbox(clientSaleId: string): void {
    this.idbSales.removePending(clientSaleId);
    this.refreshOutbox();
    toast.success('Comprobante descartado de la bandeja local.');
  }

  protected clearSyncedFromOutbox(): void {
    this.idbSales.clearSynced();
    this.refreshOutbox();
    toast.success('Comprobantes sincronizados purgados de la memoria local.');
  }

  protected async syncSingleSale(sale: PendingOfflineSale): Promise<void> {
    if (this.isOfflineEffective()) {
      toast.error('No se puede sincronizar: el terminal está en modo desconectado.');
      return;
    }

    this.retryingSaleId.set(sale.client_sale_id);

    try {
      const payload: CreateSaleRequest = {
        branch_id: sale.branch_id,
        payment_method: 'cash',
        cash_reference: `Sincronización Outbox - Ticket ${sale.sale_code}`,
        client_sale_id: sale.client_sale_id,
        is_offline: true,
        items: sale.items.map((i) => ({ variant_id: i.variant_id, quantity: i.quantity })),
      };

      await firstValueFrom(this.salesApi.createSale(payload));
      this.idbSales.markAsSynced(sale.client_sale_id);
      this.refreshOutbox();
      toast.success(`Ticket ${sale.sale_code} sincronizado exitosamente con el servidor.`);
    } catch (error) {
      const msg = getErrorMessage(error, 'Fallo al sincronizar venta.');
      this.idbSales.incrementRetry(sale.client_sale_id, msg);
      this.refreshOutbox();
      toast.error(msg);
    } finally {
      this.retryingSaleId.set(null);
    }
  }

  protected async retryFailedSales(): Promise<void> {
    if (this.isOfflineEffective()) {
      toast.error('No se puede sincronizar: el terminal está en modo desconectado.');
      return;
    }
    const failed = this.failedSales();
    if (failed.length === 0) {
      toast.info('No hay operaciones fallidas pendientes de reintentar.');
      return;
    }
    for (const sale of failed) {
      this.idbSales.resetError(sale.client_sale_id);
    }
    await this.syncAllPending();
  }

  protected navigateToConflicts(): void {
    this.closeBatchSyncSummary();
    void this.router.navigate(['/app/encargado/sale-conflicts']);
  }

  // =========================================================================
  // CU15: Sincronización de Lotes con Idempotencia Central (/api/sales/offline/batch-sync)
  // =========================================================================
  protected async syncAllPending(): Promise<void> {
    if (this.isOfflineEffective()) {
      toast.error('No se puede sincronizar: el terminal está en modo desconectado.');
      return;
    }

    const pending = this.pendingSales();
    if (pending.length === 0) {
      toast.info('No hay operaciones pendientes de sincronizar.');
      return;
    }

    const activeBranchId = this.branchId() || pending[0]?.branch_id;
    if (!activeBranchId) {
      toast.error('No se determinó la sucursal activa para sincronizar el lote.');
      return;
    }

    this.syncingOutbox.set(true);

    try {
      const operations: BatchSyncOperation[] = pending.map((sale) => ({
        client_sale_id: sale.client_sale_id,
        cashier_id: sale.cashier_id || null,
        created_at: sale.created_at || null,
        total_amount: Number(sale.total_amount),
        cash_received: sale.cash_received != null ? Number(sale.cash_received) : null,
        change_amount: sale.change_amount != null ? Number(sale.change_amount) : null,
        payment_method: 'cash',
        is_offline: true,
        items: sale.items.map((i) => ({
          variant_id: i.variant_id,
          quantity: i.quantity,
          unit_price: i.unit_price != null ? Number(i.unit_price) : null,
        })),
      }));

      const payload: BatchSyncRequest = {
        branch_id: activeBranchId,
        operations,
      };

      const resp = await firstValueFrom(this.salesApi.batchSyncSales(payload));
      const data = resp.data;

      if (data) {
        // 1. Marcar como sincronizadas las que el backend procesó (incluyendo duplicados o resoluciones)
        for (const uuid of data.processed_uuids) {
          this.idbSales.markAsSynced(uuid);
        }

        // 2. Si hubo detalles específicos, marcar mensajes de conflicto o error
        for (const item of data.details) {
          if (item.status === 'conflict') {
            this.idbSales.markAsError(
              item.client_sale_id,
              item.message || 'Conflicto registrado: stock insuficiente por concurrencia.'
            );
          } else if (item.status === 'error') {
            this.idbSales.markAsError(
              item.client_sale_id,
              item.message || 'Error en validación de ítem al sincronizar.'
            );
          }
        }

        // 3. Registrar resultados para la vista de auditoría en outbox
        this.lastBatchSyncSummary.set(data.summary);
        this.lastBatchSyncDetails.set(data.details);
        this.showBatchSyncSummary.set(true);

        const summary = data.summary;
        if (summary.conflicts > 0) {
          toast.warning(
            `Lote procesado: ${summary.applied} aplicadas, ${summary.duplicates_ignored} duplicadas ignoradas, ${summary.conflicts} en conflicto de inventario.`
          );
        } else {
          toast.success(
            `Todas las operaciones sincronizadas con éxito (${summary.applied} aplicadas, ${summary.duplicates_ignored} duplicadas descartadas con idempotencia).`
          );
        }
      }
    } catch (err) {
      toast.error(getErrorMessage(err, 'Fallo la sincronización en lote con el servidor central.'));
    } finally {
      this.syncingOutbox.set(false);
      this.refreshOutbox();
    }
  }

  protected closeBatchSyncSummary(): void {
    this.showBatchSyncSummary.set(false);
  }

  protected async checkOutboxStatusWithServer(): Promise<void> {
    if (this.isOfflineEffective()) {
      toast.error('Se requiere conexión activa para verificar con el servidor.');
      return;
    }

    const all = this.outboxSales();
    if (all.length === 0) {
      toast.info('No hay comprobantes locales para verificar.');
      return;
    }

    this.verifyingOutbox.set(true);
    try {
      const ids = all.map((s) => s.client_sale_id);
      const res = await firstValueFrom(this.salesApi.checkOfflineStatus(ids));
      const syncedIds = res.data?.synced_ids ?? [];

      let updated = 0;
      for (const id of syncedIds) {
        const local = all.find((s) => s.client_sale_id === id);
        if (local && !local.synced) {
          this.idbSales.markAsSynced(id);
          updated++;
        }
      }

      this.refreshOutbox();
      if (updated > 0) {
        toast.success(`Verificación completa: ${updated} ventas fueron confirmadas por el servidor.`);
      } else {
        toast.info('Verificación completa: No se encontraron ventas previamente asentadas.');
      }
    } catch (err) {
      toast.error(getErrorMessage(err, 'No se pudo contactar al servidor para verificar estado.'));
    } finally {
      this.verifyingOutbox.set(false);
    }
  }

  constructor() {
    void this.searchProducts();
    this.refreshOutbox();
  }

  protected toggleSimulatedOffline(): void {
    this.simulatedOffline.update((v) => !v);
    if (this.simulatedOffline()) {
      toast.info('Simulación de Modo Offline Activada: Conexión forzada a almacenamiento local.');
    } else {
      toast.success('Simulación de Modo Offline Desactivada: Conexión normal restaurada.');
    }
  }

  protected setCashReceived(value: any): void {
    const num = Number(value);
    this.cashReceived.set(!isNaN(num) && value !== null && value !== '' ? num : null);
  }

  protected setExactCash(): void {
    this.cashReceived.set(Number(this.total()));
  }

  protected addCash(amount: number): void {
    const current = this.cashReceived() ?? 0;
    this.cashReceived.set(current + amount);
  }

  protected async syncCatalog(): Promise<void> {
    this.syncingCatalog.set(true);
    try {
      const branchId = this.branchId();
      const resp = await firstValueFrom(
        this.catalogApi.getOfflineCatalogPack(branchId ?? undefined)
      );
      if (resp.data) {
        await this.idbCatalog.saveOfflinePack(resp.data);
        this.products.set(resp.data.products);
        toast.success('Catálogo local sincronizado con éxito');
      }
    } catch (err) {
      toast.error('No se pudo sincronizar el catálogo local.');
    } finally {
      this.syncingCatalog.set(false);
    }
  }

  protected async searchProducts(): Promise<void> {
    const branchId = this.branchId();
    this.loadingProducts.set(true);
    try {
      if (this.isOfflineEffective()) {
        const offlineProds = await this.idbCatalog.getOfflineProducts({ q: this.searchTerm() || undefined });
        this.products.set(offlineProds);
      } else {
        const response = await firstValueFrom(
          this.catalogApi.listProducts({
            q: this.searchTerm() || undefined,
            branch_id: branchId ?? undefined,
            tenant_id: this.session.user()?.tenant_id ?? undefined,
          })
        );
        this.products.set((response.data ?? []) as CatalogProduct[]);
      }
    } catch (error) {
      try {
        const offlineProds = await this.idbCatalog.getOfflineProducts({ q: this.searchTerm() || undefined });
        if (offlineProds.length > 0) {
          this.products.set(offlineProds);
          return;
        }
      } catch {}
      toast.error(getErrorMessage(error, 'No se pudieron cargar los productos.'));
      this.products.set([]);
    } finally {
      this.loadingProducts.set(false);
    }
  }


  protected addVariant(product: CatalogProduct, variant: CatalogProductVariant): void {
    const items = [...this.selectedItems()];
    const existing = items.find((item) => item.variant_id === variant.id);
    if (existing) {
      existing.quantity += 1;
      this.selectedItems.set(items);
      return;
    }
    const finalPrice = product.has_discount ? product.discounted_price ?? variant.price : variant.price;
    items.push({
      variant_id: variant.id,
      product_name: product.name,
      variant_sku: variant.sku,
      size_name: variant.size_name ?? null,
      color_name: variant.color_name ?? null,
      unit_price: String(finalPrice),
      original_unit_price: String(variant.price),
      quantity: 1,
      image_url: variant.image_url || product.image_url || null,
    });
    this.selectedItems.set(items);
  }

  protected removeItem(variantId: string): void {
    this.selectedItems.update((items) => items.filter((item) => item.variant_id !== variantId));
  }

  protected decreaseItem(variantId: string): void {
    const items = [...this.selectedItems()];
    const index = items.findIndex((item) => item.variant_id === variantId);
    if (index >= 0) {
      if (items[index].quantity > 1) {
        items[index].quantity -= 1;
        this.selectedItems.set(items);
      } else {
        this.removeItem(variantId);
      }
    }
  }

  protected increaseItem(variantId: string): void {
    const items = [...this.selectedItems()];
    const index = items.findIndex((item) => item.variant_id === variantId);
    if (index >= 0) {
      items[index].quantity += 1;
      this.selectedItems.set(items);
    }
  }

  protected updateQuantity(index: number, quantity: number): void {
    const items = [...this.selectedItems()];
    if (quantity <= 0) {
      items.splice(index, 1);
    } else {
      items[index].quantity = quantity;
    }
    this.selectedItems.set(items);
  }

  protected clearSale(): void {
    this.selectedItems.set([]);
    this.cashReference.set('');
    this.cashReceived.set(null);
  }

  protected async submitSale(): Promise<void> {
    const branchId = this.branchId();
    if (!branchId) {
      toast.error('No se identificó la sucursal del cajero.');
      return;
    }

    if (this.selectedItems().length === 0) {
      toast.error('Debes seleccionar al menos un producto.');
      return;
    }

    const received = this.cashReceived();
    const tot = Number(this.total());
    if (received !== null && received < tot) {
      toast.error(`Monto recibido insuficiente. Faltan Bs ${(tot - received).toFixed(2)}`);
      return;
    }

    this.submitting.set(true);

    if (this.isOfflineEffective()) {
      try {
        const clientSaleId = crypto.randomUUID();
        const shortCode = clientSaleId.slice(0, 8).toUpperCase();
        const pendingSale: PendingOfflineSale = {
          client_sale_id: clientSaleId,
          sale_code: `TCK-OFF-${shortCode}`,
          branch_id: branchId,
          branch_name: this.branchName(),
          cashier_id: this.session.user()?.id ?? 'offline-user',
          cashier_name: this.cashierName(),
          payment_method: 'cash',
          cash_received: received ?? Number(this.total()),
          change_amount: Number(this.changeAmount()),
          subtotal: Number(this.subtotal()),
          discount_amount: Number(this.discount()),
          total_amount: Number(this.total()),
          currency: 'BOB',
          created_at: new Date().toISOString(),
          synced: false,
          items: this.selectedItems().map((item) => ({
            variant_id: item.variant_id,
            product_name: item.product_name,
            variant_sku: item.variant_sku,
            size_name: item.size_name,
            color_name: item.color_name,
            unit_price: Number(item.unit_price),
            quantity: item.quantity,
            line_total: Number(item.unit_price) * item.quantity,
          })),
        };

        this.idbSales.savePending(pendingSale);
        this.refreshOutbox();

        this.lastOfflineSale.set(pendingSale);
        this.lastSale.set(null);
        this.showReceiptModal.set(true);

        toast.success(`Venta de contingencia guardada localmente (Ticket #${shortCode}).`);
        this.selectedItems.set([]);
        this.cashReference.set('');
        this.cashReceived.set(null);
      } catch {
        toast.error('Error al guardar la venta de contingencia en almacenamiento local.');
      } finally {
        this.submitting.set(false);
      }
      return;
    }

    try {
      const clientSaleId = crypto.randomUUID();
      const payload: CreateSaleRequest = {
        branch_id: branchId,
        payment_method: 'cash',
        cash_reference: this.cashReference() || (received ? `Efectivo Bs ${received} - Vuelto Bs ${this.changeAmount()}` : null),
        client_sale_id: clientSaleId,
        is_offline: false,
        items: this.selectedItems().map((item) => ({ variant_id: item.variant_id, quantity: item.quantity })),
      };

      const response = await requestWithToast(this.salesApi.createSale(payload), {
        loading: 'Registrando venta en caja...',
        success: 'Venta registrada exitosamente.',
        error: 'No se pudo registrar la venta en servidor.',
      });

      this.lastSale.set(response.data ?? null);
      this.lastOfflineSale.set(null);
      this.showReceiptModal.set(true);

      this.selectedItems.set([]);
      this.cashReference.set('');
      this.cashReceived.set(null);
      await this.searchProducts();
    } catch {
      // Toast gestionado por requestWithToast
    } finally {
      this.submitting.set(false);
    }
  }

  protected closeReceiptModal(): void {
    this.showReceiptModal.set(false);
  }

  protected printReceipt(): void {
    window.print();
  }

  protected lineTotal(item: SelectedSaleItem): string {
    return (Number(item.unit_price) * item.quantity).toFixed(2);
  }

  // =========================================================================
  // =========================================================================
  // MÉTODOS DEL CU11: Registrar Reserva de Prendas Offline en Mostrador
  // =========================================================================
  protected selectResProduct(prod: CatalogProduct): void {
    this.resSelectedProduct.set(prod);
    if (prod.variants && prod.variants.length > 0) {
      this.resSelectedVariant.set(prod.variants[0]);
    } else {
      this.resSelectedVariant.set(null);
    }
  }

  protected selectResVariant(variant: CatalogProductVariant): void {
    this.resSelectedVariant.set(variant);
  }

  protected async apartarPrendaLocalmente(): Promise<void> {
    const customer = this.resCustomerName().trim();
    if (!customer) {
      toast.error('Ingresa los datos del cliente presencial (Nombre completo).');
      return;
    }

    const prod = this.resSelectedProduct();
    const variant = this.resSelectedVariant();
    if (!prod || !variant) {
      toast.error('Selecciona una prenda y talla para apartar.');
      return;
    }

    const qty = Math.max(1, Number(this.resQuantity()) || 1);
    const branchId = this.branchId() || '8ba6f37b-10d8-4fde-8b39-a1eee44f1922';
    const clientReservationId = crypto.randomUUID();
    const code = 'RES-OFF-' + Math.random().toString(16).substring(2, 10).toUpperCase();

    const visitDate = this.resVisitDate() || new Date().toISOString().slice(0, 10);
    const visitDateObj = new Date(visitDate);
    visitDateObj.setDate(visitDateObj.getDate() + 1);
    const expiresAt = visitDateObj.toISOString().slice(0, 10);

    const price = Number(variant.price) || 0;
    const totalEst = price * qty;

    const reservationPayload: CreateReservationRequest = {
      branch_id: branchId,
      visit_date: visitDate,
      items: [{ variant_id: variant.id, quantity: qty }],
      client_reservation_id: clientReservationId,
    };

    const offlineItem: PendingOfflineReservation = {
      client_reservation_id: clientReservationId,
      payload: reservationPayload,
      reservation_code: code,
      branch_id: branchId,
      branch_name: this.branchName(),
      customer_name: customer,
      customer_phone: this.resCustomerPhone().trim() || undefined,
      customer_email: this.resCustomerEmail().trim() || undefined,
      visit_date: visitDate,
      expires_at: expiresAt,
      items_summary: `${qty}x ${prod.name} (${variant.size_name || 'Talla Única'})`,
      total_estimated: totalEst,
      status: 'PENDIENTE_SYNC',
      created_at: new Date().toISOString(),
      synced: false,
      items: [
        {
          variant_id: variant.id,
          product_name: prod.name,
          variant_sku: variant.sku,
          size_name: variant.size_name,
          color_name: variant.color_name,
          unit_price: price,
          quantity: qty,
        },
      ],
    };

    this.resApartando.set(true);
    try {
      // 1. Guardar en la cola local de IndexedDB
      this.idbReservations.savePending(offlineItem);
      this.lastOfflineReservation.set(offlineItem);
      this.showResReceiptModal.set(true);

      toast.success(
        `Prenda apartada localmente con éxito (Código: ${code}, UUIDv4: ${clientReservationId}). Guardada en cola local de IndexedDB.`
      );

      this.refreshReservations();

      // Limpiar formulario parcial
      this.resCustomerName.set('');
      this.resCustomerPhone.set('');
      this.resCustomerEmail.set('');

      // 2. Si la conexión está restablecida (Online), intentar sincronizar automáticamente
      if (!this.isOfflineEffective()) {
        void this.syncOfflineReservations();
      }
    } finally {
      this.resApartando.set(false);
    }
  }

  protected async syncOfflineReservations(): Promise<void> {
    if (this.isOfflineEffective()) {
      toast.error('No se puede sincronizar: el terminal está en modo desconectado.');
      return;
    }

    const pending = this.offlineReservations().filter((r) => !r.synced);
    if (pending.length === 0) {
      toast.info('No hay reservas de mostrador pendientes de sincronización.');
      return;
    }

    this.resSyncing.set(true);
    let syncedCount = 0;
    try {
      for (const item of pending) {
        try {
          await firstValueFrom(this.reservationApi.createReservation(item.payload));
          this.idbReservations.markAsSynced(item.client_reservation_id);
          syncedCount++;
        } catch (err) {
          this.idbReservations.markAsError(
            item.client_reservation_id,
            getErrorMessage(err, 'Error al consolidar reserva')
          );
        }
      }

      this.refreshReservations();
      if (syncedCount > 0) {
        toast.success(
          `Sincronización completada: ${syncedCount} reserva(s) consolidada(s) con el servidor central.`
        );
      }
    } finally {
      this.resSyncing.set(false);
    }
  }

  protected removeOfflineReservation(clientReservationId: string): void {
    this.idbReservations.removePending(clientReservationId);
    this.refreshReservations();
    toast.success('Reserva local descartada.');
  }

  protected closeResReceiptModal(): void {
    this.showResReceiptModal.set(false);
  }
}
