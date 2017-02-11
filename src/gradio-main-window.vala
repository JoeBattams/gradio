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
		private Stack MainStack;

		[GtkChild]
		private Box Bottom;
		[GtkChild]
		private MenuButton MenuButton;
		[GtkChild]
		private VolumeButton VolumeButton;
		[GtkChild]
		private Button BackButton;

		[GtkChild]
		private ToggleButton DiscoverToggleButton;
		[GtkChild]
		private ToggleButton LibraryToggleButton;

		private int height;
		private int width;

		private int pos_x;
		private int pos_y;

		private StatusIcon trayicon;
		public signal void toggle_view();
		public signal void tray_activate();

		PlayerToolbar player_toolbar;

		DiscoverPage discover_page;
		SearchPage search_page;
		LibraryPage library_page;
		StationDetailPage station_detail_page;

		private GradioMode current_page;

		Queue<GradioMode> back_entry_stack = new Queue<GradioMode>();

		public enum GradioMode {
			MODE_UNKNOWN,
			MODE_LIBRARY,
			MODE_DISCOVER,
			MODE_SEARCH,
			MODE_DETAILS,
			MODE_LOADING,
			MODE_CATEGORY,
			MODE_EDIT,
			MODE_EXTRAS,
			MODE_LAST
		}

		private App app;

		public MainWindow (App appl) {
	       		GLib.Object(application: appl);

			app = appl;

			var builder = new Gtk.Builder.from_resource ("/de/haecker-felix/gradio/ui/app-menu.ui");
			var app_menu = builder.get_object ("app-menu") as GLib.MenuModel;
			MenuButton.set_menu_model(app_menu);


			// Hide menu button if desktop = gnome. (else show it)
 			if(GLib.Environment.get_variable("XDG_CURRENT_DESKTOP") == "gnome")
				MenuButton.set_visible (false);
			else
				MenuButton.set_visible (true);
			message("Desktop session is %s.", GLib.Environment.get_variable(" XDG_CURRENT_DESKTOP"));

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

			station_detail_page = new StationDetailPage();
			MainStack.add_named(station_detail_page, "station_detail_page");

			library_page = new LibraryPage();
			MainStack.add_titled(library_page, "library_page", "Library");

			discover_page = new DiscoverPage();
			MainStack.add_titled(discover_page, "discover_page", "Discover");

			// showing library on startup
			set_page(GradioMode.MODE_LIBRARY);

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

			//Load css
			Util.add_stylesheet("gradio.css");

	       		Bottom.pack_end(player_toolbar);
		}

		private void connect_signals(){
			this.size_allocate.connect((a) => {
				width = a.width;
				height = a.height;
			});
		}

		public void show_no_connection_message (){
			VolumeButton.set_visible(false);
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

		public void set_page(GradioMode mode, bool writehistory = true){
			if(mode != current_page){

				// set correct page switcher button
				if(mode == GradioMode.MODE_DISCOVER){
					DiscoverToggleButton.set_active(true);
					LibraryToggleButton.set_active(false);
				}else if(mode == GradioMode.MODE_LIBRARY){
					DiscoverToggleButton.set_active(false);
					LibraryToggleButton.set_active(true);
				}else{
					DiscoverToggleButton.set_active(false);
					LibraryToggleButton.set_active(false);
				}

				// show or hide the search bar
				if(mode == GradioMode.MODE_SEARCH){
					SearchBar.set_search_mode(true);
					SearchButton.set_active(true);
				}else{
					SearchBar.set_search_mode(false);
					SearchButton.set_active(false);
				}


				// Hide Back button and if discover or library -> erase the history
				if(mode != GradioMode.MODE_LIBRARY && mode != GradioMode.MODE_DISCOVER){
					BackButton.set_visible(true);
				}else{
					BackButton.set_visible(false);
					back_entry_stack.clear();
					message("History is nulled");
				}


				// push the old page into the history :)
				if(writehistory)
					back_entry_stack.push_tail(current_page);
				else
					back_entry_stack.pop_tail();


				// actual switching here ->
				switch(mode){
					case GradioMode.MODE_SEARCH:{
						MainStack.set_visible_child_name("search_page");
						current_page = GradioMode.MODE_SEARCH;
						break;
					};
					case GradioMode.MODE_DISCOVER: {
						MainStack.set_visible_child_name("discover_page");
						current_page = GradioMode.MODE_DISCOVER;
						break;
					};
					case GradioMode.MODE_LIBRARY: {
						MainStack.set_visible_child_name("library_page");
						current_page = GradioMode.MODE_LIBRARY;
						break;
					};
					case GradioMode.MODE_DETAILS: {
						MainStack.set_visible_child_name("station_detail_page");
						current_page = GradioMode.MODE_DETAILS;
						break;
					};
				}
			}
		}

		private void show_previous_page(){
			switch(back_entry_stack.peek_tail()){
				case GradioMode.MODE_SEARCH: set_page(GradioMode.MODE_SEARCH, false); break;
				case GradioMode.MODE_LIBRARY: set_page(GradioMode.MODE_LIBRARY, false); break;
				case GradioMode.MODE_DISCOVER: set_page(GradioMode.MODE_DISCOVER, false); break;
				case GradioMode.MODE_DETAILS: set_page(GradioMode.MODE_DETAILS, false); break;
			}
		}

		public void show_station_detail_page(RadioStation station){
			station_detail_page.set_station(station);
			set_page(GradioMode.MODE_DETAILS);
		}

		[GtkCallback]
		private void SearchButton_toggled (){
			if(SearchButton.get_active())
				SearchBar.set_search_mode(true);
			else
				SearchBar.set_search_mode(false);
		}

		[GtkCallback]
		private void DiscoverToggleButton_toggled (){
			set_page(GradioMode.MODE_DISCOVER);
		}

		[GtkCallback]
		private void LibraryToggleButton_toggled (){
			set_page(GradioMode.MODE_LIBRARY);
		}

		[GtkCallback]
		public void BackButton_clicked (Gtk.Button button) {
			show_previous_page();
		}

		[GtkCallback]
		private void SearchEntry_search_changed(){
			string search_term = SearchEntry.get_text();

			if(search_term != "" && search_term.length >= 3){
				search_page.search(SearchEntry.get_text());
				set_page(GradioMode.MODE_SEARCH);
			}
		}

		[GtkCallback]
        	private void VolumeButton_value_changed (double value) {
			App.player.set_volume(value);
			Settings.volume_position = value;
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
					show_previous_page();
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
