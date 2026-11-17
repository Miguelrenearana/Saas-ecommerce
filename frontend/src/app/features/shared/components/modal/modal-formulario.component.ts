import { CommonModule } from '@angular/common';
import { Component, ViewChild, input, output, signal } from '@angular/core';

import { AnchoModal, ModalBaseComponent } from './modal-base.component';
import { ConfirmarDescarteDialogComponent } from './confirmar-descarte-dialog.component';

@Component({
  selector: 'app-modal-formulario',
  standalone: true,
  imports: [CommonModule, ModalBaseComponent, ConfirmarDescarteDialogComponent],
  template: `
    <app-modal-base
      #baseModal
      [isOpen]="isOpen()"
      [titulo]="titulo()"
      [subtitulo]="subtitulo()"
      [ancho]="ancho()"
      [sinCerrar]="sinCerrar()"
      [backdropEstatico]="true"
      [className]="className()"
      [cuerpoClassName]="cuerpoClassName()"
      [interceptorCierre]="interceptorCierre"
      (cerrar)="onCerrarDefinitivo()"
    >
      <!-- PROYECCIÓN DE CABECERA PERSONALIZADA O ÍCONO -->
      <div modal-header-icon>
        <ng-content select="[modal-header-icon]" />
      </div>
      <div modal-header-custom>
        <ng-content select="[modal-header-custom]" />
      </div>

      <!-- CUERPO PRINCIPAL DEL FORMULARIO -->
      <ng-content />

      <!-- PIE DE ACCIONES (BOTONES GUARDAR / CANCELAR) -->
      <div modal-footer>
        <ng-content select="[modal-footer]" />
      </div>
    </app-modal-base>

    <!-- DIÁLOGO DE SEGURIDAD CONTRA PÉRDIDA ACCIDENTAL DE DATOS -->
    <app-confirmar-descarte-dialog
      [abierto]="mostrarDescarte()"
      [titulo]="tituloDescarte()"
      [mensaje]="mensajeDescarte()"
      (continuar)="cancelarDescarte()"
      (descartar)="confirmarDescarte()"
    />
  `,
})
export class ModalFormularioComponent {
  @ViewChild('baseModal') baseModal?: ModalBaseComponent;

  readonly isOpen = input<boolean>(false);
  readonly titulo = input<string | null>(null);
  readonly subtitulo = input<string | null>(null);
  readonly ancho = input<AnchoModal>('md');
  readonly tieneCambios = input<boolean>(false);
  readonly guardando = input<boolean>(false);
  readonly tituloDescarte = input<string>('¿Descartar cambios sin guardar?');
  readonly mensajeDescarte = input<string>(
    'Has comenzado a ingresar o modificar información en este formulario. Si sales ahora, todos los cambios se perderán.'
  );
  readonly sinCerrar = input<boolean>(false);
  readonly className = input<string>('');
  readonly cuerpoClassName = input<string>('');

  readonly cerrar = output<void>();

  readonly mostrarDescarte = signal<boolean>(false);
  private forzarCierre = false;

  // Interceptor invocado por la 'X', tecla Escape o backdrop
  readonly interceptorCierre = (): boolean => {
    if (this.forzarCierre) {
      this.forzarCierre = false;
      return true; // Cierre explícitamente autorizado (ej. tras confirmar descarte)
    }

    if (this.guardando()) {
      return false; // Operación de guardado en curso: bloquear salida
    }

    if (this.tieneCambios()) {
      this.mostrarDescarte.set(true);
      return false; // Detiene el cierre inmediato para solicitar confirmación
    }

    return true; // Formulario sin cambios: permitir cierre
  };

  /**
   * Método público invocable desde la vista hija (ej. botón "Cancelar")
   */
  solicitarCierre(): void {
    if (this.guardando()) return;

    if (this.tieneCambios()) {
      this.mostrarDescarte.set(true);
    } else {
      this.baseModal?.solicitarCierre();
    }
  }

  cancelarDescarte(): void {
    this.mostrarDescarte.set(false);
  }

  confirmarDescarte(): void {
    this.mostrarDescarte.set(false);
    this.forzarCierre = true;
    if (this.baseModal) {
      this.baseModal.solicitarCierre();
    } else {
      this.onCerrarDefinitivo();
    }
  }

  onCerrarDefinitivo(): void {
    this.cerrar.emit();
  }
}
