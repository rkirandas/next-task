import { Component } from '@angular/core';
import { ToolbarComponent } from './toolbar/toolbar.component';
import { TodoListComponent } from './todo-list/todo-list.component';

@Component({
  selector: 'app-home',
  imports: [ToolbarComponent,TodoListComponent],
  templateUrl: './home.component.html',
  styleUrl: './home.component.scss'
})
export class HomeComponent {

}
