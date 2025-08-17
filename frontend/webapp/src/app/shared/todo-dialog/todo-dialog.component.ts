import { Component, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { provideNativeDateAdapter } from '@angular/material/core';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatTimepickerModule } from '@angular/material/timepicker';

@Component({
  selector: 'app-todo-dialog',
  providers: [provideNativeDateAdapter()],
  imports: [
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatTimepickerModule,
    MatDatepickerModule,
    MatButtonModule,
    MatIconModule,
  ],
  templateUrl: './todo-dialog.component.html',
  styleUrl: './todo-dialog.component.scss',
})
export class TodoDialog {
  readonly dialogRef = inject(MatDialogRef<TodoDialog>);

  onNoClick(): void {
    this.dialogRef.close();
  }
}
