import { CommonModule } from '@angular/common';
import { Component, input, output } from '@angular/core';

import { AnchoModal, ModalBaseComponent } from './modal-base.component';

@Component({
  selector: 'app-modal-lectura',
  standalone: true,
  imports: [CommonModule, ModalBaseComponent],
  template: `
    <app-modal-base
      [isOpen]="isOpen()"
      [titulo]="titulo()"
      [subtitulo]="subtitulo()"
      [ancho]="ancho()"
      [sinCerrar]="sinCerrar()"
      [backdropEstatico]="false"
      [className]="className()"
      [cuerpoClassName]="cuerpoClassName()"
      (cerrar)="cerrar.emit()"
    >
      <!-- PROYECCIÓN DE CABECERA PERSONALIZADA O ÍCONO -->
      <div modal-header-icon>
        <ng-content select="[modal-header-icon]" />
      </div>
      <div modal-header-custom>
        <ng-content select="[modal-header-custom]" />
      </div>

      <!-- CUERPO DE CONSULTA O DETALLE -->
      <ng-content />

      <!-- PIE DE ACCIONES (IMPRIMIR / EXPORTAR / CERRAR) -->
      <div modal-footer>
        <ng-content select="[modal-footer]" />
      </div>
    </app-modal-base>
  `,
})
export class ModalLecturaComponent {
  readonly isOpen = input<boolean>(false);
  readonly titulo = input<string | null>(null);
  readonly subtitulo = input<string | null>(null);
  readonly ancho = input<AnchoModal>('lg');
  readonly sinCerrar = input<boolean>(false);
  readonly className = input<string>('');
  readonly cuerpoClassName = input<string>('');

  readonly cerrar = output<void>();
}
