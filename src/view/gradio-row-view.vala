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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/view/row-view.ui")]
	public class RowView : Gtk.ListBox, View{

		public StationModel model;

		public RowView(ref StationModel m){
			model = m;

			connect_signals();
		}

		private void connect_signals(){
			this.bind_model (this.model, (obj) => {
     				assert (obj is RadioStation);

				weak RadioStation station = (RadioStation)obj;
				Row item = new Row(station);

      				return item;
			});

			this.row_activated.connect((t,a) => {
				Gradio.App.window.set_page(Gradio.App.window.GradioMode.MODE_DETAILS);
			});
		}
	}
}
