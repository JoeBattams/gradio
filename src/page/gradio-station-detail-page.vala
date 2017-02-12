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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/page/station-detail-page.ui")]
	public class StationDetailPage : Gtk.Box, Page{

		[GtkChild]
		private Label StationTitleLabel;
		[GtkChild]
		private Label StationLocationLabel;
		[GtkChild]
		private Box StationTagsBox;
		[GtkChild]
		private Label StationDescriptionLabel;

		private TagBox tbox;

		[GtkChild]
		private Box RemoveBox;
		[GtkChild]
		private Box AddBox;

		[GtkChild]
		private Box PlayBox;
		[GtkChild]
		private Box StopBox;

		[GtkChild]
		private Box InformationBox;

		[GtkChild]
		private Box StationDescriptionBox;

		[GtkChild]
		private Label StationLikesLabel;

		private RadioStation station;

		public StationDetailPage(){
			setup_view();
			connect_signals();
		}

		private void connect_signals(){
			station.played.connect(show_stop_box);

			station.stopped.connect(show_play_box);

			station.added_to_library.connect(show_remove_box);

			station.removed_from_library.connect(show_add_box);
		}

		private void setup_view(){
			tbox = new TagBox();
			StationTagsBox.add(tbox);
		}

		public void set_station(RadioStation s){
			station = s;

			reset_view();
			set_data();
		}

		private void set_data(){
			// Disconnect old signals
			if(station != null){
				station.played.disconnect(show_stop_box);
				station.stopped.disconnect(show_play_box);
				station.added_to_library.disconnect(show_remove_box);
				station.removed_from_library.disconnect(show_add_box);
			}

			//connect new signals
			connect_signals();


			// Title
			StationTitleLabel.set_text(station.Title);

			// Tags
			tbox.set_tags(station.Tags);

			// Play / Stop Button
			if(App.player.is_playing_station(station)){
				StopBox.set_visible(true);
				PlayBox.set_visible(false);
			}else{
				StopBox.set_visible(false);
				PlayBox.set_visible(true);
			}

			// Add / Remove Button
			if(App.library.contains_station(station)){
				RemoveBox.set_visible(true);
				AddBox.set_visible(false);
			}else{
				RemoveBox.set_visible(false);
				AddBox.set_visible(true);
			}

			// Location
			StationLocationLabel.set_text(station.Country + ", " + station.State);

			// Likes
			StationLikesLabel.set_text(station.Votes.to_string());

			// Description
			AdditionalDataProvider.get_description.begin(station, (obj,res) => {
				string desc = AdditionalDataProvider.get_description.end(res);

				if(desc != ""){
					StationDescriptionLabel.set_text(desc);
					StationDescriptionBox.set_visible(true);
				}

			});

			// Show warning if some information is missing
			if(station.Tags == "" || station.Homepage == "" || station.Icon == "" || station.Title == "" || station.State == "" || station.Country == "")
				InformationBox.set_visible(true);
		}

		private void reset_view(){
			StationTitleLabel.set_text("");
			StationDescriptionBox.set_visible(false);
			StationDescriptionLabel.set_text("");
			StationLocationLabel.set_text("");
			tbox.set_tags("");

			InformationBox.set_visible(false);
		}

		private void show_add_box(){
			AddBox.set_visible(true);
			RemoveBox.set_visible(false);
		}

		private void show_remove_box(){
			AddBox.set_visible(false);
			RemoveBox.set_visible(true);
		}

		private void show_play_box(){
			StopBox.set_visible(false);
			PlayBox.set_visible(true);
		}

		private void show_stop_box(){
			StopBox.set_visible(true);
			PlayBox.set_visible(false);
		}

		[GtkCallback]
		private void LikeButton_clicked(Button b){
			station.vote();
			StationLikesLabel.set_text(station.Votes.to_string());
		}

		[GtkCallback]
        	private void PlayStopButton_clicked (Button button) {
			if(App.player.current_station != null && App.player.current_station.ID == station.ID)
				App.player.toggle_play_stop();
			else
				App.player.set_radio_station(station);
		}

		[GtkCallback]
		private void AddRemoveButton_clicked(Button button){
			if(App.library.contains_station(station)){
				App.library.remove_radio_station(station);
			}else{
				App.library.add_radio_station(station);
			}
		}

		[GtkCallback]
		private void OpenHomepageButton_clicked(Button button){
			Util.open_website(station.Homepage);
		}

		[GtkCallback]
		private void EditButton_clicked(Button button){
			Util.open_website("http://www.radio-browser.info/gui/#/edit/" + station.ID.to_string());
		}
	}
}		
