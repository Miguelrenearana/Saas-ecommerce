import { CommonModule } from '@angular/common';
import { Component, ElementRef, EventEmitter, HostListener, Input, Output } from '@angular/core';
import { NgIcon, provideIcons } from '@ng-icons/core';
import {
  lucideMoreVertical,
  lucidePencil,
  lucidePower,
  lucideTrash2,
  lucidePackageSearch,
  lucideEye,
  lucideClipboardList,
} from '@ng-icons/lucide';

@Component({
  selector: 'app-admin-action-menu',
  standalone: true,
  imports: [CommonModule, NgIcon],
  providers: [
    provideIcons({
      lucideMoreVertical,
      lucidePencil,
      lucidePower,
      lucideTrash2,
      lucidePackageSearch,
      lucideEye,
      lucideClipboardList,
    }),
  ],
  template: `
    <div class="relative inline-block text-left" (click)="$event.stopPropagation()">
      <button
        type="button"
        class="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-slate-300 bg-white text-slate-700 hover:bg-slate-50 hover:text-slate-900 transition shadow-xs focus:outline-none focus:ring-2 focus:ring-slate-400 cursor-pointer"
        (click)="toggle($event)"
        [attr.aria-expanded]="isOpen"
        aria-haspopup="true"
        aria-label="Abrir acciones"
      >
        <ng-icon name="lucideMoreVertical" class="text-base" />
      </button>

      @if (isOpen) {
        <div
          class="absolute right-0 z-50 min-w-44 rounded-xl border border-slate-200 bg-white py-1 shadow-xl ring-1 ring-black/5 text-slate-700 focus:outline-none"
          [ngClass]="openAbove ? 'bottom-full mb-1.5 origin-bottom-right' : 'top-full mt-1.5 origin-top-right'"
          role="menu"
        >
          @if (showEdit) {
            <button
              type="button"
              class="flex w-full items-center gap-2.5 px-3.5 py-2 text-left text-xs font-medium text-slate-700 hover:bg-slate-50 hover:text-slate-900 transition cursor-pointer"
              (click)="run(edit, $event)"
              role="menuitem"
            >
              <ng-icon name="lucidePencil" class="size-3.5 text-slate-500" />
              <span>{{ editLabel }}</span>
            </button>
          }
          @if (showActive) {
            <button
              type="button"
              class="flex w-full items-center gap-2.5 px-3.5 py-2 text-left text-xs font-medium text-slate-700 hover:bg-slate-50 hover:text-slate-900 transition cursor-pointer"
              (click)="run(toggleActive, $event)"
              role="menuitem"
            >
              <ng-icon name="lucidePower" class="size-3.5 text-slate-500" />
              <span>{{ activeLabel }}</span>
            </button>
          }
          @if (showProducts) {
            <button
              type="button"
              class="flex w-full items-center gap-2.5 px-3.5 py-2 text-left text-xs font-medium text-slate-700 hover:bg-slate-50 hover:text-slate-900 transition cursor-pointer"
              (click)="run(viewProducts, $event)"
              role="menuitem"
            >
              <ng-icon name="lucidePackageSearch" class="size-3.5 text-slate-500" />
              <span>Ver productos</span>
            </button>
          }
          @if (showView) {
            <button
              type="button"
              class="flex w-full items-center gap-2.5 px-3.5 py-2 text-left text-xs font-medium text-slate-700 hover:bg-slate-50 hover:text-slate-900 transition cursor-pointer"
              (click)="run(view, $event)"
              role="menuitem"
            >
              <ng-icon name="lucideEye" class="size-3.5 text-slate-500" />
              <span>Ver</span>
            </button>
          }
          @if (showRequest) {
            <button
              type="button"
              class="flex w-full items-center gap-2.5 px-3.5 py-2 text-left text-xs font-medium text-slate-700 hover:bg-slate-50 hover:text-slate-900 transition cursor-pointer"
              (click)="run(request, $event)"
              role="menuitem"
            >
              <ng-icon name="lucideClipboardList" class="size-3.5 text-slate-500" />
              <span>Solicitar</span>
            </button>
          }
          @if (showDelete) {
            <button
              type="button"
              class="flex w-full items-center gap-2.5 px-3.5 py-2 text-left text-xs font-medium text-rose-600 hover:bg-rose-50 hover:text-rose-700 transition cursor-pointer"
              (click)="run(delete, $event)"
              role="menuitem"
            >
              <ng-icon name="lucideTrash2" class="size-3.5 text-rose-500" />
              <span>Eliminar</span>
            </button>
          }
        </div>
      }
    </div>
  `,
})
export class AdminActionMenuComponent {
  @Input() isOpen = false;
  @Input() activeLabel = 'Activar';
  @Input() editLabel = 'Editar';
  @Input() showEdit = true;
  @Input() showActive = true;
  @Input() showProducts = false;
  @Input() showView = false;
  @Input() showDelete = true;
  @Input() showRequest = false;

  @Output() toggleMenu = new EventEmitter<void>();
  @Output() edit = new EventEmitter<void>();
  @Output() toggleActive = new EventEmitter<void>();
  @Output() delete = new EventEmitter<void>();
  @Output() viewProducts = new EventEmitter<void>();
  @Output() view = new EventEmitter<void>();
  @Output() request = new EventEmitter<void>();

  protected openAbove = false;

  constructor(private readonly element: ElementRef<HTMLElement>) {}

  @HostListener('document:click', ['$event'])
  protected onDocumentClick(event: MouseEvent): void {
    const target = event.target as Node | null;
    if (this.isOpen && target && !this.element.nativeElement.contains(target)) {
      this.toggleMenu.emit();
    }
  }

  protected run(action: EventEmitter<void>, event?: MouseEvent): void {
    if (event) {
      event.stopPropagation();
    }
    this.toggleMenu.emit();
    action.emit();
  }

  protected toggle(event?: MouseEvent): void {
    if (event) {
      event.stopPropagation();
      const rect = (event.currentTarget as HTMLElement)?.getBoundingClientRect();
      if (rect) {
        const spaceBelow = window.innerHeight - rect.bottom;
        this.openAbove = spaceBelow < 220 && rect.top > 220;
      }
    }
    this.toggleMenu.emit();
  }
}
