import { CommonModule } from '@angular/common';
import { Component, computed, input, output } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { NgIcon, provideIcons } from '@ng-icons/core';
import {
  lucideChevronLeft,
  lucideChevronRight,
  lucideChevronsLeft,
  lucideChevronsRight,
} from '@ng-icons/lucide';

export type PageItem = number | '...';

@Component({
  selector: 'app-table-pagination',
  standalone: true,
  imports: [CommonModule, FormsModule, NgIcon],
  providers: [
    provideIcons({
      lucideChevronLeft,
      lucideChevronRight,
      lucideChevronsLeft,
      lucideChevronsRight,
    }),
  ],
  template: `
    <nav
      class="flex flex-col sm:flex-row items-center justify-between gap-3.5 px-4 py-3 border-t border-slate-200 bg-white/70 text-xs text-slate-600 select-none"
      aria-label="Paginación de tabla"
    >
      <!-- Información del rango de datos -->
      <div class="flex items-center gap-3">
        @if (showTotalInfo()) {
          <p class="text-slate-600">
            Mostrando
            <strong class="font-semibold text-slate-900">{{ startItem() }}</strong>
            a
            <strong class="font-semibold text-slate-900">{{ endItem() }}</strong>
            de
            <strong class="font-semibold text-slate-900">{{ totalItems() }}</strong>
            {{ itemLabel() }}
          </p>
        }

        <!-- Selector de filas por página -->
        @if (showPageSize() && totalItems() > 0) {
          <div class="hidden md:flex items-center gap-1.5 pl-3 border-l border-slate-200">
            <label for="table-page-size-select" class="text-slate-500 text-[11px] font-medium">Filas por pág:</label>
            <select
              id="table-page-size-select"
              [ngModel]="pageSize()"
              (ngModelChange)="onPageSizeSelected($event)"
              class="h-7 rounded-md border border-slate-300 bg-white px-2 text-[11px] font-medium text-slate-800 shadow-2xs focus:border-slate-400 focus:outline-none focus:ring-1 focus:ring-slate-300 cursor-pointer"
            >
              @for (size of pageSizeOptions(); track size) {
                <option [value]="size">{{ size }}</option>
              }
            </select>
          </div>
        }
      </div>

      <!-- Controles de navegación de páginas -->
      <div class="flex items-center gap-1">
        <!-- Ir a la primera página -->
        <button
          type="button"
          (click)="firstPage()"
          [disabled]="isFirstPage()"
          class="inline-flex h-8 w-8 items-center justify-center rounded-lg border transition-all cursor-pointer disabled:opacity-40 disabled:cursor-not-allowed disabled:hover:bg-transparent"
          [ngClass]="isFirstPage() ? 'border-slate-200 text-slate-400 bg-slate-50/50' : 'border-slate-300 bg-white text-slate-700 hover:bg-slate-50 hover:text-slate-900 shadow-2xs active:scale-95'"
          aria-label="Primera página"
          title="Primera página"
        >
          <ng-icon name="lucideChevronsLeft" class="text-sm" />
        </button>

        <!-- Página anterior -->
        <button
          type="button"
          (click)="previousPage()"
          [disabled]="isFirstPage()"
          class="inline-flex h-8 w-8 items-center justify-center rounded-lg border transition-all cursor-pointer disabled:opacity-40 disabled:cursor-not-allowed disabled:hover:bg-transparent"
          [ngClass]="isFirstPage() ? 'border-slate-200 text-slate-400 bg-slate-50/50' : 'border-slate-300 bg-white text-slate-700 hover:bg-slate-50 hover:text-slate-900 shadow-2xs active:scale-95'"
          aria-label="Página anterior"
          title="Página anterior"
        >
          <ng-icon name="lucideChevronLeft" class="text-sm" />
        </button>

        <!-- Botones numéricos de página (ocultos en pantallas muy chicas) -->
        <div class="hidden sm:flex items-center gap-1 mx-1">
          @for (item of pageWindow(); track $index) {
            @if (item === '...') {
              <span class="inline-flex h-8 w-7 items-center justify-center text-slate-400 font-medium">…</span>
            } @else {
              <button
                type="button"
                (click)="goToPage(item)"
                class="inline-flex h-8 min-w-8 px-2 items-center justify-center rounded-lg text-xs font-medium transition-all cursor-pointer"
                [ngClass]="
                  item === currentPage()
                    ? 'bg-slate-900 text-white font-semibold shadow-xs'
                    : 'text-slate-700 hover:bg-slate-100 hover:text-slate-900'
                "
                [attr.aria-current]="item === currentPage() ? 'page' : null"
                [attr.aria-label]="'Página ' + item"
              >
                {{ item }}
              </button>
            }
          }
        </div>

        <!-- Indicador de página actual en móvil -->
        <span class="sm:hidden px-2 text-xs font-semibold text-slate-800">
          {{ currentPage() }} / {{ totalPages() }}
        </span>

        <!-- Página siguiente -->
        <button
          type="button"
          (click)="nextPage()"
          [disabled]="isLastPage()"
          class="inline-flex h-8 w-8 items-center justify-center rounded-lg border transition-all cursor-pointer disabled:opacity-40 disabled:cursor-not-allowed disabled:hover:bg-transparent"
          [ngClass]="isLastPage() ? 'border-slate-200 text-slate-400 bg-slate-50/50' : 'border-slate-300 bg-white text-slate-700 hover:bg-slate-50 hover:text-slate-900 shadow-2xs active:scale-95'"
          aria-label="Página siguiente"
          title="Página siguiente"
        >
          <ng-icon name="lucideChevronRight" class="text-sm" />
        </button>

        <!-- Ir a la última página -->
        <button
          type="button"
          (click)="lastPage()"
          [disabled]="isLastPage()"
          class="inline-flex h-8 w-8 items-center justify-center rounded-lg border transition-all cursor-pointer disabled:opacity-40 disabled:cursor-not-allowed disabled:hover:bg-transparent"
          [ngClass]="isLastPage() ? 'border-slate-200 text-slate-400 bg-slate-50/50' : 'border-slate-300 bg-white text-slate-700 hover:bg-slate-50 hover:text-slate-900 shadow-2xs active:scale-95'"
          aria-label="Última página"
          title="Última página"
        >
          <ng-icon name="lucideChevronsRight" class="text-sm" />
        </button>
      </div>
    </nav>
  `,
})
export class TablePaginationComponent {
  // Inputs requeridos y opcionales usando Angular Signals
  public readonly totalItems = input.required<number>();
  public readonly pageSize = input<number>(10);
  public readonly currentPage = input<number>(1);
  public readonly pageSizeOptions = input<number[]>([10, 25, 50, 100]);
  public readonly showPageSize = input<boolean>(true);
  public readonly showTotalInfo = input<boolean>(true);
  public readonly itemLabel = input<string>('registros');

  // Outputs tipados usando la API moderna de Angular
  public readonly pageChange = output<number>();
  public readonly pageSizeChange = output<number>();

  // Señales computadas reactivas
  public readonly totalPages = computed(() => {
    const total = this.totalItems();
    const size = Math.max(1, this.pageSize());
    return Math.max(1, Math.ceil(total / size));
  });

  public readonly startItem = computed(() => {
    if (this.totalItems() === 0) return 0;
    return (this.currentPage() - 1) * this.pageSize() + 1;
  });

  public readonly endItem = computed(() => {
    return Math.min(this.currentPage() * this.pageSize(), this.totalItems());
  });

  public readonly isFirstPage = computed(() => this.currentPage() <= 1);
  public readonly isLastPage = computed(() => this.currentPage() >= this.totalPages());

  // Ventana inteligente de números de página con elipses
  public readonly pageWindow = computed<PageItem[]>(() => {
    const total = this.totalPages();
    const current = this.currentPage();

    if (total <= 7) {
      return Array.from({ length: total }, (_, i) => i + 1);
    }

    if (current <= 4) {
      return [1, 2, 3, 4, 5, '...', total];
    }

    if (current >= total - 3) {
      return [1, '...', total - 4, total - 3, total - 2, total - 1, total];
    }

    return [1, '...', current - 1, current, current + 1, '...', total];
  });

  // Métodos de navegación
  public goToPage(page: number): void {
    if (page >= 1 && page <= this.totalPages() && page !== this.currentPage()) {
      this.pageChange.emit(page);
    }
  }

  public nextPage(): void {
    if (!this.isLastPage()) {
      this.pageChange.emit(this.currentPage() + 1);
    }
  }

  public previousPage(): void {
    if (!this.isFirstPage()) {
      this.pageChange.emit(this.currentPage() - 1);
    }
  }

  public firstPage(): void {
    if (!this.isFirstPage()) {
      this.pageChange.emit(1);
    }
  }

  public lastPage(): void {
    if (!this.isLastPage()) {
      this.pageChange.emit(this.totalPages());
    }
  }

  public onPageSizeSelected(newSize: number | string): void {
    const numericSize = Number(newSize);
    if (!isNaN(numericSize) && numericSize > 0 && numericSize !== this.pageSize()) {
      this.pageSizeChange.emit(numericSize);
    }
  }
}
