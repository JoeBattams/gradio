/* This file is part of Gradio.
 *
 * Gradio is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Gradio is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Gradio.  If not, see <http://www.gnu.org/licenses/>.
 */

using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/library-page.ui")]
	public class LibraryPage : Gtk.Box, Page{

		private StationView station_view;
		private StationModel station_model;

		public LibraryPage(){
			station_model = Library.library_model;
			station_view = new StationView(ref station_model);

			station_model.null_items.connect(() => {
				station_view.show_empty_library();
			});

			this.add(station_view);
		}

		public void show_grid_view(){
			station_view.show_grid_view();
		}

		public void show_list_view(){
			station_view.show_list_view();
		}
	}
}
