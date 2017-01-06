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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/discover-box.ui")]
	public class DiscoverBox : Gtk.Box{

		public StationsView stations_view_results;

		private StationsView grid_view_recently_clicked;
		private StationsView grid_view_most_votes;
		private StationsView grid_view_recently_changed;

		private StationsViewButton button_recently_clicked;
		private StationsViewButton button_recently_changed;
		private StationsViewButton button_most_votes;

		[GtkChild]
		private Box SearchBox;
		[GtkChild]
		private Stack ContentStack;
		[GtkChild]
		private Box most_votes;
		[GtkChild]
		private Box recently_changed;
		[GtkChild]
		private Box recently_clicked;
		[GtkChild]
		private Box SidebarBox;

		private DiscoverSidebar sidebar;

		public signal void overview_showed();
		public signal void overview_hided();

		public DiscoverBox(){
			stations_view_results = new StationsView();
			grid_view_recently_changed = new StationsView();
			grid_view_recently_clicked = new StationsView();
			grid_view_most_votes = new StationsView();

			most_votes.add(grid_view_most_votes);
			recently_changed.add(grid_view_recently_changed);
			recently_clicked.add(grid_view_recently_clicked);

			SearchBox.add(stations_view_results);

			sidebar = new DiscoverSidebar(this);
			SidebarBox.pack_start(sidebar);

			connect_signals();
			load_data();

			show_overview_page();
		}

		private void connect_signals(){
			button_recently_clicked.clicked.connect(() => show_recently_clicked());
			button_recently_changed.clicked.connect(() => show_recently_changed());
			button_most_votes.clicked.connect(() => show_most_votes());
		}

		public void show_results(){
			ContentStack.set_visible_child_name("results");
			overview_hided();
		}

		public void show_overview_page(){
			ContentStack.set_visible_child_name("overview");
			sidebar.show_categories();
			overview_showed();
		}

		private void load_data(){

		}

		private void show_recently_changed(){
			show_results();
		}

		private void show_recently_clicked(){
			show_results();
		}

		private void show_most_votes(){
			show_results();
		}

		public void reload(){
			load_data();
		}

		public void add_station(){
			Util.open_website("http://www.radio-browser.info");
		}

		// Switch
		public void show_grid_view(){
			stations_view_results.show_grid_view();
		}

		public void show_list_view(){
			stations_view_results.show_list_view();
		}
	}
}
