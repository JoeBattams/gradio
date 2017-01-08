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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/search-page.ui")]
	public class SearchPage : Gtk.Box, Page{

		private StationsView stationsview;
		private StationProvider provider;

		private string search_text;

		public SearchPage(){
			stationsview = new StationsView();
			provider = new StationProvider(ref stationsview.model);

			stationsview.model.null_items.connect(() => {
				stationsview.show_no_results();
			});



			this.add(stationsview);
		}

		public void search(string txt){
			string address = RadioBrowser.radio_stations_by_name + txt;

			message("Searching for \"%s\".", txt);
			provider.set_address(address);
		}

		public void show_grid_view(){
			stationsview.show_grid_view();
		}

		public void show_list_view(){
			stationsview.show_list_view();
		}
	}
}
