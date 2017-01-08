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


		private bool no_stations = true;

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
		private Stack StationsStack;

		[GtkChild]
		private Box GridItems;
		[GtkChild]
		private Box ListItems;

		private FlowBox GridViewFlowBox;
		private ListBox ListViewListBox;

		public StationsView(){
			GridViewFlowBox = new FlowBox();
			ListViewListBox = new ListBox();

			GridItems.add(GridViewFlowBox);
			ListItems.add(ListViewListBox);

			show_loading();
			connect_signals();
		}

		private void connect_signals(){
			GridViewFlowBox.bind_model (this.model, (obj) => {
     				assert (obj is RadioStation);

				weak RadioStation station = (RadioStation)obj;
				GridItem item = new GridItem(station);

				show_correct_view();
      				return item;
			});

			ListViewListBox.bind_model (this.model, (obj) => {
     				assert (obj is RadioStation);

     				weak RadioStation station = (RadioStation)obj;
				var item = new ListItem(station);

				show_correct_view();
      				return item;
			});

		}

		private void show_correct_view(){
			if(Settings.use_grid_view){
				show_grid_view();
			}else{
				show_list_view();
			}
		}

		public void show_list_view(){
			if(model.get_n_items() != 0)
				StationsStack.set_visible_child_name("list-view");

			LoadMoreBox.reparent(ListViewBox);

		}

		public void show_grid_view(){
			if(model.get_n_items() != 0)
				StationsStack.set_visible_child_name("grid-view");

			LoadMoreBox.reparent(GridViewBox);
		}


		public void show_no_results(){
			StationsStack.set_visible_child_name("no-results");
		}

		public void show_empty_library(){
			StationsStack.set_visible_child_name("empty-library");
		}

		public void show_loading(){
			StationsStack.set_visible_child_name("loading");
		}


		[GtkCallback]
		private void LoadMoreButton_clicked(Button button){

		}
	}
}
