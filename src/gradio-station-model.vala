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

namespace Gradio{

	public class StationModel : GLib.Object, GLib.ListModel {

		// <STATION_ID, INDEX>
		private GLib.HashTable<int, int>  index = new GLib.HashTable<int, int>(direct_hash, direct_equal);

		// STATIONS ITSELF
  		private GLib.GenericArray<RadioStation> stations = new GLib.GenericArray<RadioStation> ();
		private int64 min_id = int64.MAX;
		private int64 max_id = int64.MIN;

		public signal void null_items();
		public signal void items_cleared();

		public StationModel(){

			// Detect if array is empty
			this.items_changed.connect(() => {
				if(stations.length == 0)
					null_items();
			});
		}

		public int64 lowest_id {
    			get {
      				return min_id;
    			}
  		}

  		public int64 greatest_id {
    			get {
      				return max_id;
    			}
  		}

  		public GLib.Object? get_item (uint index) {
    			assert (index >= 0);
    			assert (index <  stations.length);

    			return stations.get ((int)index);
  		}

 		public uint get_n_items () {
    			return stations.length;
  		}


  		private void remove_at_pos (int pos) {
    			int64 id = this.stations.get (pos).ID;

    			this.stations.remove_index (pos);


    			// Now we just need to update the min_id/max_id fields
    			if (id == this.max_id) {
      				if (this.stations.length > 0) {
        				int p = int.max (pos - 1, 0);
        				this.max_id = this.stations.get (p).ID;
      				} else {
        				this.max_id = int64.MIN;
      				}
    			}

    			if (id == this.min_id) {
      				if (this.stations.length > 0) {
        				int p = int.min (pos + 1, this.stations.length - 1);
        				this.min_id = this.stations.get (p).ID;
      				} else {
        				this.min_id = int64.MAX;
      				}
    			}
  		}

  		public GLib.Type get_item_type () {
    			return typeof (RadioStation);
  		}

	  	public void add (RadioStation station) {
	    		assert (station.ID > 0);

			int insert_pos = stations.length;
			stations.insert (insert_pos, station);
			index.insert(station.ID, insert_pos);

			message("Added station!");
			message("Index Pos: " + insert_pos.to_string());
			message("Station ID: " + station.ID.to_string());

			this.items_changed (insert_pos, 0, 1);

	      		if (station.ID > this.max_id)
				this.max_id = station.ID;

	      		if (station.ID < this.min_id)
				this.min_id = station.ID;

	  	}

	  	public void clear () {
	  		items_cleared();

	    		int s = this.stations.length;
	    		this.stations.remove_range (0, stations.length);
	    		this.min_id = int64.MAX;
	    		this.max_id = int64.MIN;
	    		this.items_changed (0, s, 0);


	  	}

	  	public void remove (RadioStation station) {
	  		//message("Removed station!");
			//message("Station ID: " + station.ID.to_string());

	      		int pos = index[station.ID];

	      		message("=> Index Pos: " + pos.to_string());

	   //    		for (int i = 0; i < stations.length; i ++) {
				// RadioStation station = stations.get (i);
				// if (t == station) {
		  // 			pos = i;
		  // 			break;
				// }
	   //    		}

	      		this.remove_at_pos (pos);
	     		this.items_changed (pos, 1, 0);
	  	}


	  	public bool contains_id (int station_id) {
	  		if(index[station_id] != 0)
	  			return true;

	    // 		for (int i = 0; i < stations.length; i ++) {
	    //   			RadioStation station = stations.get (i);
	    //   			if (station.ID == station_id)
					// return true;
	    // 		}

	    		return false;
	  	}

	  	public RadioStation? get_from_id (int64 id, int diff = -1) {
	    		for (int i = 0; i < stations.length; i ++) {
	      			if (stations.get (i).ID == id) {
					if (i + diff < stations.length && i + diff >= 0)
		  				return stations.get (i + diff);
					return null;
	      			}
	    		}
	    		return null;
	  	}

	  	public bool delete_id (int64 id) {
	    		for (int i = 0; i < stations.length; i ++) {
	      			RadioStation t = stations.get (i);
	      			if (t.ID == id) {
					return true;
	    			}

	    			return false;
	  		}
	  		return false;
	  	}

	}
}

