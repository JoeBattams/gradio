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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/stations-view.ui")]
	public class StationsView : Gtk.Box{

		public signal void clicked(RadioStation s);

		private bool discover_mode = false;
		private bool library_mode = false;
		private bool no_stations = true;
		private bool list_view = false;

		private int results_chunk = 50;
		private int results_loaded = 0;
		private int max_results = 0;

		public StationModel model = new StationModel();

		[GtkChild]
		private Box LoadMoreBox;
		[GtkChild]
		private Button LoadMoreButton;
		[GtkChild]
		private Box GridViewBox;
		[GtkChild]
		private Box ListViewBox;
		[GtkChild]
		private FlowBox GridViewFlowBox;
		[GtkChild]
		private ListBox ListViewListBox;
		[GtkChild]
		private Stack StationsStack;

		public StationsView(){

			this.expand = true;

			GridViewBox.add(LoadMoreBox);
			StationsStack.set_visible_child_name("empty-box");

			connect_signals();
		}

		private void connect_signals(){

			//TODO: Is this neccessary?
			ListViewListBox.row_activated.connect((t,a) => {
				ListItem item = (ListItem)a;
				clicked(item.station);
			});

			GridViewFlowBox.child_activated.connect((t,a) => {
				GridItem item = (GridItem)a;
				clicked(item.station);
			});

			GridViewFlowBox.bind_model (this.model, (obj) => {
     				assert (obj is RadioStation);
				var item = new GridItem((RadioStation)obj);

      				return item;
			});

			ListViewListBox.bind_model (this.model, (obj) => {
     				assert (obj is RadioStation);
				var item = new ListItem((RadioStation)obj);


				StationsStack.set_visible_child_name("list-view");
				item.fade_in ();
      				return item;
			});

		}

		public void show_list_view(){
			if(!no_stations)
				StationsStack.set_visible_child_name("list-view");

			LoadMoreBox.reparent(ListViewBox);
			list_view = true;

		}

		public void show_grid_view(){
			if(!no_stations)
				StationsStack.set_visible_child_name("grid-view");

			LoadMoreBox.reparent(GridViewBox);
			list_view = false;
		}

		private void reset (){
			reset_data();
			reset_view();
		}

		private void reset_data(){
			results_loaded = 0;
		}

		private void reset_view(){
			StationsStack.set_visible_child_name("empty-box");
			Util.remove_all_items_from_flow_box((Gtk.FlowBox) GridViewFlowBox);
			Util.remove_all_items_from_list_box((Gtk.ListBox) ListViewListBox);
		}

		private void disable_load_more(){
			LoadMoreBox.set_visible(false);
			LoadMoreButton.set_visible(false);
		}

		private void enable_load_more(){
			LoadMoreBox.set_visible(true);
			LoadMoreButton.set_visible(true);
		}

		[GtkCallback]
		private void LoadMoreButton_clicked(Button button){
		}
	}
}
