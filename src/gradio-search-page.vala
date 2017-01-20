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

		private StationView station_view;
		private StationModel station_model;
		private StationProvider station_provider;

		private string search_text;

		// wait 1,3 seconds before spawning a new search thread
		private int search_delay = 1000;
		private uint delayed_changed_id;

		public SearchPage(){
			station_model =  new StationModel();
			station_view = new StationView(ref station_model);
			station_provider = new StationProvider(ref station_model);

			station_model.null_items.connect(() => {
				station_view.show_no_results();
			});

			this.add(station_view);
		}

		public void search(string txt){
			search_text = txt;
			reset_timeout();
		}

		public void show_grid_view(){
			station_view.show_grid_view();
		}

		public void show_list_view(){
			station_view.show_list_view();
		}


		private void reset_timeout(){
			if(delayed_changed_id > 0)
				Source.remove(delayed_changed_id);
			delayed_changed_id = Timeout.add(search_delay, timeout);
		}

		private bool timeout(){
			string address = RadioBrowser.radio_stations_by_name + search_text;

			message("Searching for \"%s\".", search_text);
			station_provider.set_address(address);

			delayed_changed_id = 0;

			return false;
		}
	}
}
