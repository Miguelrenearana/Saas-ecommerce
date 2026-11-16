import { CommonModule } from '@angular/common';
import {
  Component,
  ElementRef,
  HostListener,
  OnChanges,
  OnDestroy,
  OnInit,
  Renderer2,
  SimpleChanges,
  computed,
  inject,
  input,
  output,
  signal,
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
    @if (isOpen() || animandoSalida()) {
      <div
        class="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-4 md:p-6 transition-all duration-200"
        [ngClass]="{
          'bg-slate-950/70 backdrop-blur-xs opacity-100': animandoEntrada() && !animandoSalida(),
          'bg-slate-950/0 backdrop-blur-none opacity-0': !animandoEntrada() || animandoSalida()
        }"
        (mousedown)="alHacerClicFondo($event)"
      >
        <div
          #cajaModal
          role="dialog"
          aria-modal="true"
          class="w-full {{ anchoClase() }} max-h-[92vh] flex flex-col rounded-2xl border border-slate-200 bg-white shadow-2xl transition-all duration-200 ease-out text-slate-800 {{ className() }}"
          [ngClass]="{
            'scale-100 opacity-100 translate-y-0': animandoEntrada() && !animandoSalida(),
            'scale-95 opacity-0 translate-y-2': !animandoEntrada() || animandoSalida(),
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
export class ModalBaseComponent implements OnInit, OnChanges, OnDestroy {
  private readonly elementRef = inject(ElementRef);
  private readonly renderer = inject(Renderer2);

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

  readonly animandoEntrada = signal<boolean>(false);
  readonly animandoSalida = signal<boolean>(false);
  readonly sacudiendo = signal<boolean>(false);

  readonly anchoClase = computed(() => ANCHOS_MODAL[this.ancho()] ?? ANCHOS_MODAL.md);
  readonly tieneCabecera = computed(() => !!this.titulo() || !!this.subtitulo());

  private scrollPrevio = '';
  private timerSalida: any = null;
  private timerSacudida: any = null;

  ngOnInit(): void {
    // Escape del Stacking Context: trasladar este elemento directamente al <body>
    if (typeof document !== 'undefined') {
      this.renderer.appendChild(document.body, this.elementRef.nativeElement);
    }
    if (this.isOpen()) {
      this.iniciarEntrada();
    }
  }

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['isOpen']) {
      if (this.isOpen()) {
        this.iniciarEntrada();
      } else if (!changes['isOpen'].firstChange) {
        this.iniciarSalida();
      }
    }
  }

  ngOnDestroy(): void {
    this.restaurarScroll();
    if (this.timerSalida) clearTimeout(this.timerSalida);
    if (this.timerSacudida) clearTimeout(this.timerSacudida);
    if (typeof document !== 'undefined' && this.elementRef.nativeElement.parentNode) {
      this.renderer.removeChild(this.elementRef.nativeElement.parentNode, this.elementRef.nativeElement);
    }
  }

  private iniciarEntrada(): void {
    if (this.timerSalida) clearTimeout(this.timerSalida);
    this.animandoSalida.set(false);

    if (this.bloquearScroll() && typeof document !== 'undefined') {
      this.scrollPrevio = document.body.style.overflow;
      document.body.style.overflow = 'hidden';
    }

    // Pequeño delay de frame para que la clase de transición de Tailwind anime con fluidez
    requestAnimationFrame(() => {
      this.animandoEntrada.set(true);
    });
  }

  private iniciarSalida(): void {
    this.animandoSalida.set(true);
    this.timerSalida = setTimeout(() => {
      this.animandoEntrada.set(false);
      this.animandoSalida.set(false);
      this.restaurarScroll();
      this.cerrar.emit();
    }, 190);
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
    this.iniciarSalida();
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
