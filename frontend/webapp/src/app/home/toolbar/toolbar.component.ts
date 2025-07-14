import { Component } from '@angular/core';
import { MatToolbarModule } from '@angular/material/toolbar';
import { SearchComponent } from './search/search.component';

@Component({
  selector: 'toolbar',
  imports: [MatToolbarModule, SearchComponent],
  templateUrl: './toolbar.component.html',
  styleUrl: './toolbar.component.scss',
})
export class ToolbarComponent {}
