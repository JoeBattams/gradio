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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/list-item.ui")]
	public class ListItem : Gtk.Box{

		[GtkChild]
		private Label ChannelNameLabel;
		[GtkChild]
		private Label ChannelLocationLabel;
		[GtkChild]
		private Label ChannelTagsLabel;
		[GtkChild]
		private Label LikesLabel;
		[GtkChild]
		private Image ChannelLogoImage;

		[GtkChild]
		private Image InLibraryImage;
		[GtkChild]
		private Image IsPlayingImage;

		[GtkChild]
		private Box PlayBox;
		[GtkChild]
		private Box StopBox;
		[GtkChild]
		private Box AddBox;
		[GtkChild]
		private Box RemoveBox;
		[GtkChild]
		private Stack ListStack;

		public RadioStation station;

		public ListItem(RadioStation s){
			station = s;
			connect_signals();

			// Set information
			if(App.player.is_playing_station(station)){
				StopBox.set_visible(true);
				PlayBox.set_visible(false);
				IsPlayingImage.set_visible(true);
			}else{
				StopBox.set_visible(false);
				PlayBox.set_visible(true);
				IsPlayingImage.set_visible(false);
			}
			if(App.library.contains_station(station.ID)){
				RemoveBox.set_visible(true);
				AddBox.set_visible(false);
				InLibraryImage.set_visible(true);
			}else{
				RemoveBox.set_visible(false);
				AddBox.set_visible(true);
				InLibraryImage.set_visible(false);
			}
			LikesLabel.set_text(station.Votes.to_string());

			// Load basic information
			set_logo();
			ChannelNameLabel.set_text(station.Title);
			ChannelLocationLabel.set_text(station.Country + " " + station.State);
			ChannelTagsLabel.set_text(station.Tags);
		}

		private void connect_signals(){
			station.played.connect(() => {
				StopBox.set_visible(true);
				PlayBox.set_visible(false);
				IsPlayingImage.set_visible(true);
			});

			station.stopped.connect(() => {
				StopBox.set_visible(false);
				PlayBox.set_visible(true);
				IsPlayingImage.set_visible(false);
			});

			station.added_to_library.connect(() => {
				AddBox.set_visible(false);
				RemoveBox.set_visible(true);
				InLibraryImage.set_visible(true);
			});

			station.removed_from_library.connect(() => {
				AddBox.set_visible(true);
				RemoveBox.set_visible(false);
				InLibraryImage.set_visible(false);
			});
		}

		private void set_logo(){
			Gdk.Pixbuf icon = null;
			Gradio.App.imgprovider.get_station_logo.begin(station, 32, (obj, res) => {
		        	icon = Gradio.App.imgprovider.get_station_logo.end(res);

				if(icon != null){
					ChannelLogoImage.set_from_pixbuf(icon);
				}
        		});
		}

		private void show_menu(bool b){
			if(ListStack != null){
				if(b){
					ListStack.set_visible_child_name("actions");
				}else{
					ListStack.set_visible_child_name("info");
				}
			}else{
				warning("Caught crash of Gradio.");
			}
		}

		[GtkCallback]
		private void LikeButton_clicked(Button b){
			station.vote();
			LikesLabel.set_text(station.Votes.to_string());

			show_menu(false);
		}

		[GtkCallback]
        	private void PlayStopButton_clicked (Button button) {
			if(App.player.current_station != null && App.player.current_station.ID == station.ID)
				App.player.toggle_play_stop();
			else
				App.player.set_radio_station(station);

			show_menu(false);
		}

		[GtkCallback]
		private void AddRemoveButton_clicked(Button button){
			if(App.library.contains_station(station.ID))
				App.library.remove_radio_station(station);
			else
				App.library.add_radio_station(station);
			show_menu(false);
		}

		[GtkCallback]
		private void BackButton_clicked(Button b){
			show_menu(false);
		}

		[GtkCallback]
		private bool GradioListItem_clicked(Gdk.EventButton b){
			//right-click
			if(b.button == 3){
				show_menu(true);
			}else{

				App.player.set_radio_station(station);
			}


			return false;
		}

		//
		// Animation
		//
		const int TRANSITION_DURATION = 200 * 1000;

  		private int64 start_time;
  		private int64 end_time;

		inline double ease_out_cubic (double t) {
  			double p = t - 1;
  			return p * p * p +1;
		}

		public void fade_in () {
    			if (this.get_realized ()) {
      				this.show ();
    	  			return;
    			}

    			ulong realize_id = 0;
    			realize_id = this.realize.connect (() => {
	      			this.start_time = this.get_frame_clock ().get_frame_time ();
	      			this.end_time = start_time + TRANSITION_DURATION;
	      			this.add_tick_callback (anim_tick);
	      			this.disconnect (realize_id);
    			});

    			this.show ();
  		}

  		private bool anim_tick (Gtk.Widget widget, Gdk.FrameClock frame_clock) {
    			int64 now = frame_clock.get_frame_time ();

    			if (now > end_time) {
      				this.opacity = 1.0;
      				return false;
    			}

    			double t = (now - start_time) / (double)(end_time - start_time);

    			t = ease_out_cubic (t);

    			this.opacity = t;

    			return true;
  		}

	}

}


