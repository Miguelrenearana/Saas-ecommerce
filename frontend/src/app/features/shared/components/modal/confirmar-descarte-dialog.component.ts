import { CommonModule } from '@angular/common';
import {
  Component,
  HostListener,
  input,
  output,
} from '@angular/core';

@Component({
  selector: 'app-confirmar-descarte-dialog',
  standalone: true,
  imports: [CommonModule],
  template: `
    @if (abierto()) {
      <div
        role="alertdialog"
        aria-modal="true"
        aria-labelledby="titulo-descarte"
        class="fixed inset-0 z-[70] flex items-center justify-center bg-slate-950/70 p-4 backdrop-blur-xs transition-opacity duration-150 animate-in fade-in"
        (click)="handleBackdropClick($event)"
      >
        <div
          class="w-full max-w-sm overflow-hidden rounded-2xl border border-slate-200 bg-white p-6 shadow-2xl transition-all duration-150 animate-in zoom-in-95"
          (click)="$event.stopPropagation()"
        >
          <div class="mb-4 flex h-12 w-12 items-center justify-center rounded-2xl bg-amber-50 text-amber-600 ring-8 ring-amber-50/50">
            <svg class="h-6 w-6 stroke-[2.2]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
          </div>

          <h3 id="titulo-descarte" class="text-base font-bold text-slate-900">
            {{ titulo() }}
          </h3>

          <p class="mt-2 text-xs leading-relaxed text-slate-600">
            {{ mensaje() }}
          </p>

          <div class="mt-6 flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
            <button
              type="button"
              (click)="onContinuar()"
              class="w-full rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-xs font-semibold text-slate-700 transition-colors hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-amber-500/20 sm:w-auto cursor-pointer"
            >
              Continuar editando
            </button>
            <button
              type="button"
              (click)="onDescartar()"
              class="w-full rounded-xl bg-rose-600 px-4 py-2.5 text-xs font-semibold text-white shadow-xs transition-colors hover:bg-rose-700 focus:outline-none focus:ring-2 focus:ring-rose-500/30 sm:w-auto cursor-pointer"
            >
              Descartar y salir
            </button>
          </div>
        </div>
      </div>
    }
  `,
})
export class ConfirmarDescarteDialogComponent {
  readonly abierto = input<boolean>(false);
  readonly titulo = input<string>('¿Descartar cambios sin guardar?');
  readonly mensaje = input<string>(
    'Has ingresado o modificado información en este formulario. Si sales ahora, todos los cambios se perderán.'
  );

  readonly continuar = output<void>();
  readonly descartar = output<void>();

  @HostListener('window:keydown', ['$event'])
  onKeydown(event: KeyboardEvent): void {
    if (!this.abierto()) return;
    if (event.key === 'Escape') {
      event.preventDefault();
      event.stopPropagation();
      this.onContinuar();
    }
  }

  handleBackdropClick(event: MouseEvent): void {
    if (event.target === event.currentTarget) {
      this.onContinuar();
    }
  }

  onContinuar(): void {
    this.continuar.emit();
  }

  onDescartar(): void {
    this.descartar.emit();
  }
}
