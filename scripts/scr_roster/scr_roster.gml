function Roster() constructor{
    full_roster_units = [];
    selected_units = [];
    full_roster = {};
    selected_roster = {};
    ships = [];
    roster_location = "";
    roster_planet = 0;
    roster_string = "";
    squad_buttons = [];
    roster_local_string = "";
    local_button = new ToggleButton();
        local_button.str1 = "Local Forces";
        local_button.text_halign = fa_center;
        local_button.text_color = CM_GREEN_COLOR;
        local_button.button_color = CM_GREEN_COLOR;
        local_button.width = string_width(local_button.str1)+10;
        local_button.active = false;

    static format_roster_string = function(){
        roster_string = "";
        var _roster_types = struct_get_names(selected_roster);
        for (var i=0;i<array_length(_roster_types);i++){
            var _roster_type_name = _roster_types[i];
            if (selected_roster[$_roster_type_name] == 1){
                roster_string += $"1 {_roster_type_name}{i==array_length(_roster_types)-1?"":", "}";
            } else {
            	roster_string += $"{selected_roster[$_roster_type_name]} {string_plural(_roster_type_name)}{i==array_length(_roster_types)-1?"":", "}";
            }
        }
    }
     static add_role_to_roster = function(role){
        if (struct_exists(full_roster, role)){
            full_roster[$role]++;
        } else {
            full_roster[$role] = 1;
        }
    }
     static add_role_to_selected_roster = function(role){
        if (struct_exists(selected_roster, role)){
            selected_roster[$role]++;
        } else {
            selected_roster[$role] = 1;
        }
    }

    static update_roster = function(){
    	selected_roster = {};
    	for (var i=0;i<array_length(selected_units);i++){
    		array_push(full_roster_units, selected_units[i]);
    	}
    	selected_units = [];
    	var _valid_ship = [];
    	for (var i=0;i<array_length(ships);i++){
    		if (ships[i].active){
    			array_push(_valid_ship, ships[i].ship_id);
    		}
    	}	
    	var _valid_squad_types = [];
    	for (var i=0;i<array_length(squad_buttons);i++){
    		if (squad_buttons[i].active){
    			array_push(_valid_squad_types, squad_buttons[i].squad);
    		}
    	}
    	for (var i=array_length(full_roster_units)-1;i>=0;i--){
    		var _add = false;
    		var _unit = full_roster_units[i];
    		var _valid_type = true;
    		var is_unit = is_struct(_unit);
    		if (is_unit){
	    		if (_unit.squad_type()!= "none"){
	    			var _valid_type = array_contains(_valid_squad_types,_unit.squad_type());
	    		}

	    		if (_unit.ship_location>-1){
		    	 	if (array_contains(_valid_ship ,_unit.ship_location) && _valid_type){
		    	 		_add = true;  	 		
		    	 	}
		    	 } else if (local_button.active && _valid_type){
		    	 	_add = true;
		    	 }
		   	} else {
		   		var _vehic_lid = obj_ini.veh_lid[_unit[0]][_unit[1]];
		   		if (_vehic_lid>-1){
		    	 	if (array_contains(_valid_ship ,_vehic_lid)){
		    	 		_add = true;  	 		
		    	 	} else if (local_button.active){
		    	 		_add = true;
		    	 	}
		   		}
		   	}


			 if (_add){
			    array_push(selected_units,_unit);
			    array_delete(full_roster_units, i, 1);
			    if (is_unit){
			    	add_role_to_selected_roster(_unit.role());
			    } else {
			    	add_role_to_selected_roster(obj_ini.veh_role[_unit[0]][_unit[1]]);
			    }
			 }

    	 }

    	format_roster_string();
    }

    static new_squad_button = function(display, squad_id){
        var _button = new ToggleButton();
        display = string_replace(display, " Squad", "");
        if (display != "Command"){
        	display = string_plural(display);
        }
        _button.str1 = display;
        _button.text_halign = fa_center;
        _button.text_color = CM_GREEN_COLOR;
        _button.button_color = CM_GREEN_COLOR;
        _button.width = string_width(display) + 10;
        _button.active = true;
        _button.squad = squad_id;
        array_push(squad_buttons, _button);
    }
    static new_ship_button = function(display, ship_id){
        var _button = new ToggleButton();
        _button.str1 = display;
        _button.text_halign = fa_center;
        _button.text_color = CM_GREEN_COLOR;
        _button.button_color = CM_GREEN_COLOR;
        _button.width = string_width(display)+10;
        _button.active = false;
        _button.ship_id = ship_id;
        array_push(ships, _button);
    }

    static update_local_string  = function(ship_id){
    	var selected_local_roster = {};
    	var possible_local_roster = {};
    	for (var i=0;i<array_length(selected_units);i++){
    		var _unit = selected_units[i];
    		var _ship_loc = (is_struct(_unit)) ? _unit.ship_location : obj_ini.veh_lid[_unit[0]][_unit[1]];
    		if (_ship_loc == ship_id){
	    		var _role =  (is_struct(_unit)) ? _unit.role() : obj_ini.veh_role[_unit[0]][_unit[1]];
		        if (struct_exists(selected_local_roster, _role)){
		            selected_local_roster[$_role]++;
		        } else {
		            selected_local_roster[$_role] = 1;
		        }
		    }  		
    	}
    	for (var i=0;i<array_length(full_roster_units);i++){
    		var _unit = full_roster_units[i];
    		var _ship_loc = (is_struct(_unit)) ? _unit.ship_location : obj_ini.veh_lid[_unit[0]][_unit[1]];
    		if (_ship_loc == ship_id){
	    		var _role =  (is_struct(_unit)) ? _unit.role() : obj_ini.veh_role[_unit[0]][_unit[1]];
		        if (struct_exists(possible_local_roster, _role)){
		            possible_local_roster[$_role]++;
		        } else {
		            possible_local_roster[$_role] = 1;
		        }
		    } 		
    	} 
        roster_local_string = "Selected\n";
        var _roster_types = struct_get_names(selected_local_roster);
        for (var i=0;i<array_length(_roster_types);i++){
            var _roster_type_name = _roster_types[i];
            if (selected_roster[$_roster_type_name] == 1){
                roster_local_string += $"1 {_roster_type_name}{i==array_length(_roster_types)-1?"":", "}";
            } else {
            	roster_local_string += $"{selected_local_roster[$_roster_type_name]} {string_plural(_roster_type_name)}{i==array_length(_roster_types)-1?"":", "}";
            }
        }
        roster_local_string+="\n"
        roster_local_string += "Remaining\n";
        var _roster_types = struct_get_names(possible_local_roster);
        for (var i=0;i<array_length(_roster_types);i++){
            var _roster_type_name = _roster_types[i];
            if (selected_roster[$_roster_type_name] == 1){
                roster_local_string += $"1 {_roster_type_name}{i==array_length(_roster_types)-1?"":", "}";
            } else {
            	roster_local_string += $"{possible_local_roster[$_roster_type_name]} {string_plural(_roster_type_name)}{i==array_length(_roster_types)-1?"":", "}";
            }
        }          	
    }

    vehicle_buttons = [];

    static new_vehicle_button = function(display, vehicle_type){
        var _button = new ToggleButton();
        _button.str1 = display;
        _button.text_halign = fa_center;
        _button.text_color = CM_GREEN_COLOR;
        _button.button_color = CM_GREEN_COLOR;
        _button.width = string_width(display)+10;
        _button.active = false;
        _button.vehic_id = vehicle_type;
        array_push(vehicle_buttons, _button);
    }
    static determine_full_roster  = function(){
        var _squads = [];
        var _vehicles = [];
        for (var co=0;co<obj_ini.companies;co++){
            for (var i=0;i<array_length(obj_ini.role[co]);i++){
                var _allow = false;
                var _unit = fetch_unit([co, i]);
                if (_unit.name() == "" || _unit.role() == "") then continue;
                if (_unit.hp()<=0 || _unit.in_jail()) then continue;
                if (_unit.is_at_location(roster_location)){
                    _allow = true;
                    if (_unit.planet_location>0){
                    	_allow = _unit.planet_location ==roster_planet;
                    }
               
                }
                if (_allow){
                    array_push(full_roster_units, _unit);
                    add_role_to_roster(_unit.role());
                    if (_unit.squad!="none"){
                        var _squad_type = _unit.squad_type();
                        if (_squad_type!="none"){
                            if (!array_contains(_squads, _squad_type)){
                                array_push(_squads, _squad_type);
                                new_squad_button(obj_ini.squads[_unit.squad].display_name, _squad_type);
                            }
                         }
                    }
                }
            }
            for (var i=0;i<array_length(obj_ini.veh_race[co]);i++){
            	var _allow = false;
            	 if (obj_ini.veh_race[co][i] == 0) then continue;
            	 if (obj_ini.veh_loc[co][i] == roster_location){
            	 	 if (obj_ini.veh_wid[co][i]>0){
            	 	 	 if (obj_ini.veh_wid[co][i] ==roster_planet){
            	 	 	 	_allow=true;
            	 	 	 }
            	 	 }
            	 }
				if (obj_ini.veh_lid[co][i]>-1){
        	 	 	if (obj_ini.veh_lid[co][i]>= array_length(obj_ini.ship_location)){
        	 	 		obj_ini.veh_lid[co][i] = 0;
        	 	 	}
        	 	 	if (obj_ini.ship_location[obj_ini.veh_lid[co][i]] == roster_location){
        	 	 		_allow=true;
        	 	 	}
        	 	}
        	 	if (_allow){
        	 		array_push(full_roster_units, [co, i]);
        	 		if (!array_contains(_vehicles, obj_ini.veh_role[co][i])){
        	 			new_vehicle_button(obj_ini.veh_role[co][i],obj_ini.veh_role[co][i]);
        	 		}
        	 	}
            }
        }
        var _ships = get_player_ships(roster_location);
        for (var s=0;s<array_length(_ships);s++){
        	new_ship_button(obj_ini.ship[_ships[s]],_ships[s]);
        }
    }

}