import { Component, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import {
  MatDialog
} from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatMenuModule } from '@angular/material/menu';
import { TodoDialog } from '../../shared/todo-dialog/todo-dialog.component';

@Component({
  selector: 'search',
  imports: [MatFormFieldModule, MatInputModule, MatIconModule, MatButtonModule, MatMenuModule],
  templateUrl: './search.component.html',
  styleUrl: './search.component.scss',
})
export class SearchComponent {
  readonly dialog = inject(MatDialog);

  openDialog(): void {
    const dialogRef = this.dialog.open(TodoDialog, {
      disableClose: true,
    });

    dialogRef.backdropClick().subscribe(() => {});
    dialogRef.afterClosed().subscribe((result) => {
      console.log('The dialog was closed');
    });
  }
}
