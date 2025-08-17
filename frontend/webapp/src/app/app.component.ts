import { Component } from '@angular/core';
import { TodoListComponent } from "../app/todo-list/todo-list.component";
import { ToolbarComponent } from "../app/toolbar/toolbar.component";

@Component({
  selector: 'app-home',
  templateUrl: './app.component.html',
  imports: [ToolbarComponent,TodoListComponent]
})
export class App {}