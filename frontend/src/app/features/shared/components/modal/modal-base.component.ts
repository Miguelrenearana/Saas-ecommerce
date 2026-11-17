import { CommonModule } from '@angular/common';
import {
  Component,
  HostListener,
  OnDestroy,
  computed,
  effect,
  input,
  output,
  signal,
  untracked,
} from '@angular/core';

export type AnchoModal = 'sm' | 'md' | 'lg' | 'xl' | '2xl' | '3xl' | 'full';

export const ANCHOS_MODAL: Record<AnchoModal, string> = {
  sm: 'max-w-md',
  md: 'max-w-lg',
  lg: 'max-w-2xl',
  xl: 'max-w-3xl',
  '2xl': 'max-w-5xl',
  '3xl': 'max-w-6xl',
  full: 'max-w-7xl',
};

@Component({
  selector: 'app-modal-base',
  standalone: true,
  imports: [CommonModule],
  template: `
    @if (isOpen()) {
      <div
        class="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-4 md:p-6 bg-slate-950/70 backdrop-blur-xs transition-opacity duration-150 animate-in fade-in"
        (mousedown)="alHacerClicFondo($event)"
      >
        <div
          #cajaModal
          role="dialog"
          aria-modal="true"
          class="w-full {{ anchoClase() }} max-h-[92vh] flex flex-col rounded-2xl border border-slate-200 bg-white shadow-2xl transition-all duration-150 ease-out text-slate-800 animate-in zoom-in-95 {{ className() }}"
          [ngClass]="{
            'scale-[1.015] ring-4 ring-primary/30 transition-transform duration-100': sacudiendo()
          }"
          (mousedown)="$event.stopPropagation()"
        >
          <!-- CABECERA DEL MODAL (FIJA) -->
          @if (tieneCabecera()) {
            <header class="flex items-start justify-between gap-4 border-b border-slate-100 px-6 py-4.5 bg-slate-50/50 rounded-t-2xl shrink-0">
              <div class="flex items-center gap-3.5 min-w-0">
                <ng-content select="[modal-header-icon]" />
                <div class="min-w-0">
                  @if (titulo()) {
                    <h2 class="text-lg font-bold text-slate-900 truncate tracking-tight">
                      {{ titulo() }}
                    </h2>
                  }
                  @if (subtitulo()) {
                    <p class="text-xs text-slate-500 mt-0.5 truncate">
                      {{ subtitulo() }}
                    </p>
                  }
                </div>
              </div>

              @if (!sinCerrar()) {
                <button
                  type="button"
                  (click)="solicitarCierre()"
                  aria-label="Cerrar modal"
                  class="-mr-1 -mt-1 rounded-xl p-2 text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors cursor-pointer focus:outline-none focus:ring-2 focus:ring-primary/20"
                >
                  <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              }
            </header>
          }

          <!-- CABECERA PERSONALIZADA OPCIONAL -->
          <ng-content select="[modal-header-custom]" />

          <!-- CUERPO SCROLLEABLE INDEPENDIENTE -->
          <div class="overflow-y-auto px-6 py-5 flex-1 {{ cuerpoClassName() }}">
            <ng-content />
          </div>

          <!-- PIE DE ACCIONES (FIJO) -->
          <ng-content select="[modal-footer]" />
        </div>
      </div>
    }
  `,
})
export class ModalBaseComponent implements OnDestroy {
  readonly isOpen = input<boolean>(false);
  readonly titulo = input<string | null>(null);
  readonly subtitulo = input<string | null>(null);
  readonly ancho = input<AnchoModal>('md');
  readonly sinCerrar = input<boolean>(false);
  readonly backdropEstatico = input<boolean>(false);
  readonly bloquearScroll = input<boolean>(true);
  readonly className = input<string>('');
  readonly cuerpoClassName = input<string>('');
  readonly interceptorCierre = input<(() => boolean | void) | null>(null);

  readonly cerrar = output<void>();

  readonly sacudiendo = signal<boolean>(false);

  readonly anchoClase = computed(() => ANCHOS_MODAL[this.ancho()] ?? ANCHOS_MODAL.md);
  readonly tieneCabecera = computed(() => !!this.titulo() || !!this.subtitulo());

  private scrollPrevio = '';
  private timerSacudida: any = null;

  constructor() {
    effect(() => {
      const open = this.isOpen();
      untracked(() => {
        if (open) {
          this.bloquearScrollBody();
        } else {
          this.restaurarScroll();
        }
      });
    });
  }

  ngOnDestroy(): void {
    this.restaurarScroll();
    if (this.timerSacudida) clearTimeout(this.timerSacudida);
  }

  private bloquearScrollBody(): void {
    if (this.bloquearScroll() && typeof document !== 'undefined') {
      this.scrollPrevio = document.body.style.overflow;
      document.body.style.overflow = 'hidden';
    }
  }

  private restaurarScroll(): void {
    if (this.bloquearScroll() && typeof document !== 'undefined') {
      document.body.style.overflow = this.scrollPrevio || '';
    }
  }

  solicitarCierre(): void {
    const interceptor = this.interceptorCierre();
    if (interceptor) {
      const permiso = interceptor();
      if (permiso === false) {
        return; // El interceptor bloqueó el cierre (por ejemplo, form sucio)
      }
    }
    this.restaurarScroll();
    this.cerrar.emit();
  }

  alHacerClicFondo(event: MouseEvent): void {
    if (event.target !== event.currentTarget) return;

    if (this.backdropEstatico()) {
      // Feedback visual háptico: sacudida suave
      this.sacudiendo.set(true);
      if (this.timerSacudida) clearTimeout(this.timerSacudida);
      this.timerSacudida = setTimeout(() => {
        this.sacudiendo.set(false);
      }, 250);
    } else if (!this.sinCerrar()) {
      this.solicitarCierre();
    }
  }

  @HostListener('window:keydown', ['$event'])
  manejarTeclado(event: KeyboardEvent): void {
    if (!this.isOpen() || this.sinCerrar()) return;
    if (event.key === 'Escape') {
      event.preventDefault();
      event.stopPropagation();
      this.solicitarCierre();
    }
  }
}
