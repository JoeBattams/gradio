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

		[GtkChild]
		private Box SearchBox;
		[GtkChild]
		private Stack ContentStack;
		[GtkChild]
		private Box SidebarBox;

		private DiscoverSidebar sidebar;

		public signal void overview_showed();
		public signal void overview_hided();

		public DiscoverBox(){

			sidebar = new DiscoverSidebar(this);
			SidebarBox.pack_start(sidebar);

			connect_signals();
			load_data();

			show_overview_page();
		}

		private void connect_signals(){

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
		}

		public void show_list_view(){
		}
	}
}
