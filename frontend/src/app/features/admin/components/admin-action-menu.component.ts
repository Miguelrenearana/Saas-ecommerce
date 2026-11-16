import { CommonModule } from '@angular/common';
import { Component, ElementRef, EventEmitter, HostListener, Input, Output, ViewChild } from '@angular/core';
import { NgIcon, provideIcons } from '@ng-icons/core';
 import { lucideMoreVertical, lucidePencil, lucidePower, lucideTrash2, lucidePackageSearch, lucideEye, lucideClipboardList } from '@ng-icons/lucide';

@Component({
  selector: 'app-admin-action-menu',
  standalone: true,
  imports: [CommonModule, NgIcon],
  providers: [provideIcons({ lucideMoreVertical, lucidePencil, lucidePower, lucideTrash2, lucidePackageSearch, lucideEye, lucideClipboardList })],
  template: `
    <div class="relative flex w-full items-center justify-end">
      <button
        #triggerButton
        type="button"
        class="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-slate-300 bg-white text-slate-700 hover:bg-slate-50 hover:text-slate-900 transition shadow-xs focus:outline-none focus:ring-2 focus:ring-slate-400 cursor-pointer"
        (click)="toggle($event)"
        (pointerdown)="$event.stopPropagation()"
        aria-label="Abrir acciones"
      >
        <ng-icon name="lucideMoreVertical" class="text-base" />
      </button>

      @if (isOpen) {
        <div
          class="fixed z-[100] min-w-44 overflow-y-auto rounded-xl border border-slate-200 bg-white shadow-xl ring-1 ring-black/5 py-1 text-slate-700"
          [style.top.px]="menuPosition.top"
          [style.left.px]="menuPosition.left"
          [style.max-height.px]="menuPosition.maxHeight"
          (pointerdown)="$event.stopPropagation()"
          (click)="$event.stopPropagation()"
        >
          @if (showEdit) {
            <button type="button" class="flex w-full items-center gap-2.5 px-3.5 py-2 text-left text-xs font-medium text-slate-700 hover:bg-slate-50 hover:text-slate-900 transition cursor-pointer" (click)="run(edit, $event)">
              <ng-icon name="lucidePencil" class="size-3.5 text-slate-500" />
              <span>{{ editLabel }}</span>
            </button>
          }
          @if (showActive) {
            <button type="button" class="flex w-full items-center gap-2.5 px-3.5 py-2 text-left text-xs font-medium text-slate-700 hover:bg-slate-50 hover:text-slate-900 transition cursor-pointer" (click)="run(toggleActive, $event)">
              <ng-icon name="lucidePower" class="size-3.5 text-slate-500" />
              <span>{{ activeLabel }}</span>
            </button>
          }
          @if (showProducts) {
            <button type="button" class="flex w-full items-center gap-2.5 px-3.5 py-2 text-left text-xs font-medium text-slate-700 hover:bg-slate-50 hover:text-slate-900 transition cursor-pointer" (click)="run(viewProducts, $event)">
              <ng-icon name="lucidePackageSearch" class="size-3.5 text-slate-500" />
              <span>Ver productos</span>
            </button>
          }
          @if (showView) {
            <button type="button" class="flex w-full items-center gap-2.5 px-3.5 py-2 text-left text-xs font-medium text-slate-700 hover:bg-slate-50 hover:text-slate-900 transition cursor-pointer" (click)="run(view, $event)">
              <ng-icon name="lucideEye" class="size-3.5 text-slate-500" />
              <span>Ver</span>
            </button>
          }
          @if (showRequest) {
            <button type="button" class="flex w-full items-center gap-2.5 px-3.5 py-2 text-left text-xs font-medium text-slate-700 hover:bg-slate-50 hover:text-slate-900 transition cursor-pointer" (click)="run(request, $event)">
              <ng-icon name="lucideClipboardList" class="size-3.5 text-slate-500" />
              <span>Solicitar</span>
            </button>
          }
          @if (showDelete) {
            <button type="button" class="flex w-full items-center gap-2.5 px-3.5 py-2 text-left text-xs font-medium text-rose-600 hover:bg-rose-50 hover:text-rose-700 transition cursor-pointer" (click)="run(delete, $event)">
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
  @ViewChild('triggerButton') private triggerButton?: ElementRef<HTMLButtonElement>;

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

  protected menuPosition = { top: 0, left: 0, maxHeight: 0 };

  constructor(private readonly element: ElementRef<HTMLElement>) {}

  @HostListener('document:pointerdown', ['$event'])
  protected onDocumentPointerDown(event: PointerEvent): void {
    if (this.isOpen && !this.element.nativeElement.contains(event.target as Node)) {
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
    }

    if (!this.isOpen) {
      const rect = this.triggerButton?.nativeElement.getBoundingClientRect();
      if (rect) {
        const estimatedHeight = 220;
        const spaceBelow = window.innerHeight - rect.bottom - 8;
        const openAbove = spaceBelow < estimatedHeight && rect.top > estimatedHeight;
        const top = openAbove ? Math.max(8, rect.top - estimatedHeight) : rect.bottom + 8;
        const width = 180;
        const left = Math.max(10, Math.min(window.innerWidth - width - 10, rect.right - width));

        this.menuPosition = {
          top,
          left,
          maxHeight: Math.min(320, Math.max(120, openAbove ? rect.top - 16 : window.innerHeight - top - 16)),
        };
      }
    }

    this.toggleMenu.emit();
  }
}
