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
using Gst;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/main-window.ui")]
	public class MainWindow : Gtk.ApplicationWindow {

		[GtkChild]
		private Entry SearchEntry;
		[GtkChild]
		private SearchBar SearchBar;
		[GtkChild]
		private ToggleButton SearchButton;


		[GtkChild]
		private Image GridImage;
		[GtkChild]
		private Image ListImage;
		[GtkChild]
		private Stack MainStack;
		[GtkChild]
		private Box Bottom;
		[GtkChild]
		private MenuButton MenuButton;
		[GtkChild]
		private StackSwitcher StackSwitcher;
		[GtkChild]
		private ToggleButton MiniPlayerButton;
		[GtkChild]
		private Button GridListButton;
		[GtkChild]
		private VolumeButton VolumeButton;

		private int height;
		private int width;

		private int pos_x;
		private int pos_y;

		PlayerToolbar player_toolbar;
		DiscoverBox discover_box;
		LibraryBox library_box;

		private StatusIcon trayicon;

		public signal void toggle_view();
		public signal void tray_activate();

		SearchPage search_page;


		private App app;

		public MainWindow (App appl) {
	       		GLib.Object(application: appl);

			app = appl;

			var builder = new Gtk.Builder.from_resource ("/de/haecker-felix/gradio/ui/app-menu.ui");
			var app_menu = builder.get_object ("app-menu") as GLib.MenuModel;
			MenuButton.set_menu_model(app_menu);

 			if(GLib.Environment.get_variable("DESKTOP_SESSION") == "gnome")
				MenuButton.set_visible (false);
			else
				MenuButton.set_visible (true);
			message("Desktop session is %s.", GLib.Environment.get_variable("DESKTOP_SESSION"));

			setup_tray_icon();
			setup_view();
			restore_geometry();
			connect_signals();
		}

		private void setup_tray_icon(){
			trayicon = new StatusIcon.from_icon_name("de.haeckerfelix.gradio-symbolic");
      			trayicon.set_tooltip_text ("Click to restore...");
      			trayicon.set_visible(false);

      			trayicon.activate.connect(() => tray_activate());
		}

		public void show_tray_icon(){
			trayicon.set_visible(true);
		}

		public void hide_tray_icon(){
			trayicon.set_visible(false);
		}

		private void setup_view(){
			search_page = new SearchPage();
			MainStack.add_named(search_page, "search_page");

			VolumeButton.set_relief(ReliefStyle.NORMAL);
			VolumeButton.set_value(Settings.volume_position);

			var gtk_settings = Gtk.Settings.get_default ();
			if (Settings.enable_dark_design) {
				gtk_settings.gtk_application_prefer_dark_theme = true;
			} else {
				gtk_settings.gtk_application_prefer_dark_theme = false;
			}

	        	player_toolbar = new PlayerToolbar();
	       		player_toolbar.set_visible(false);
	      		discover_box = new DiscoverBox();
			library_box = new LibraryBox();

			MainStack.add_titled(library_box, "library_box", "Library");
	        	MainStack.add_titled(discover_box, "discover_box", "Discover");

			//Load css
			Util.add_stylesheet("gradio.css");

			if(!(Settings.use_grid_view)){
				GridImage.set_visible(true);
				ListImage.set_visible(false);
				library_box.show_list_view();
				discover_box.show_list_view();
				Settings.use_grid_view = false;
			}else{
				GridImage.set_visible(false);
				ListImage.set_visible(true);
				library_box.show_grid_view();
				Settings.use_grid_view = true;
			}
	       		Bottom.pack_end(player_toolbar);
		}

		private void connect_signals(){
			this.size_allocate.connect((a) => {
				width = a.width;
				height = a.height;
			});
		}

		public void show_mini_player(){
			StackSwitcher.set_visible(false);
			GridListButton.set_visible(false);

			this.set_size_request (10,10);
			this.resize(10,10);
			this.set_resizable(false);
			MainStack.set_visible_child_name("miniplayer");
		}

		public void show_no_connection_message (){
			VolumeButton.set_visible(false);
			MiniPlayerButton.set_visible(false);
			StackSwitcher.set_visible(false);
			GridListButton.set_visible(false);
			MainStack.set_visible_child_name("no_connection");
		}

		public void save_geometry (){
			this.get_position (out pos_x, out pos_y);
			this.get_size (out width, out height);

			Settings.window_height = height;
			Settings.window_width = width;

			Settings.window_position_x = pos_x;
			Settings.window_position_y = pos_y;

			this.move(pos_x, pos_y);
		}

		public void restore_geometry(){
			width = Settings.window_width;
			height = Settings.window_height;
			this.set_default_size(width, height);
			pos_x = Settings.window_position_x;
			pos_y = Settings.window_position_y;
		}

		[GtkCallback]
		private void SearchEntry_activate(Gtk.Entry entry){
			string search_term = SearchEntry.get_text();

			if(search_term != "" && search_term.length >= 3){
				search_page.search(SearchEntry.get_text());
				MainStack.set_visible_child_name("search_page");
			}
		}

		[GtkCallback]
        	private void VolumeButton_value_changed (double value) {
			App.player.set_volume(value);
			Settings.volume_position = value;
		}

		[GtkCallback]
		private void GridListButton_clicked(Gtk.Button button){
			if(ListImage.get_visible()){
				GridImage.set_visible(true);
				ListImage.set_visible(false);
				Settings.use_grid_view = false;

				search_page.show_list_view();
			}else{
				GridImage.set_visible(false);
				ListImage.set_visible(true);
				Settings.use_grid_view = true;

				search_page.show_grid_view();
			}
		}

		[GtkCallback]
		private void SearchButton_toggled (){
			if(SearchButton.get_active())
				SearchBar.set_search_mode(true);
			else
				SearchBar.set_search_mode(false);
		}

		[GtkCallback]
		public bool on_key_pressed (Gdk.EventKey event) {
		var default_modifiers = Gtk.accelerator_get_default_mod_mask ();

			// Quit
			if ((event.keyval == Gdk.Key.q || event.keyval == Gdk.Key.Q) && (event.state & default_modifiers) == Gdk.ModifierType.CONTROL_MASK) {
				app.quit_application();

				return true;
			}

			// Play / Pause
			if ((event.keyval == Gdk.Key.space) && (event.state & default_modifiers) == Gdk.ModifierType.CONTROL_MASK) {
				App.player.toggle_play_stop();

				return true;
			}

			// Toggle Search
			if ((event.keyval == Gdk.Key.f) && (event.state & default_modifiers) == Gdk.ModifierType.CONTROL_MASK) {
				if(SearchBar.get_search_mode()){
					SearchBar.set_search_mode(false);
					SearchButton.set_active(false);
				}else{
					SearchBar.set_search_mode(true);
					SearchButton.set_active(true);
				}
			}


			return false;
		}


	}
}
