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
	public class SearchPage : Gtk.Box{

		[GtkChild]
		private Box sview_box;

		private StationsView stationsview;
		private StationProvider provider;

		public SearchPage(){
			stationsview = new StationsView();
			provider = new StationProvider(ref stationsview.model);

			sview_box.add(stationsview);
			sview_box.show_all();
		}

		public void search(string txt){
			message("Searching for \"%s\".", txt);

			string address = RadioBrowser.radio_stations_by_name + txt;
			provider.set_address(address);
		}
	}
}
