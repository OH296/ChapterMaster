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

    static add_to_battle = function(){

    }



}



function setup_battle_formations(){
          // Formation here
    obj_controller.bat_devastator_column = obj_controller.bat_deva_for[new_combat.formation_set];
    obj_controller.bat_assault_column = obj_controller.bat_assa_for[new_combat.formation_set];
    obj_controller.bat_tactical_column = obj_controller.bat_tact_for[new_combat.formation_set];
    obj_controller.bat_veteran_column = obj_controller.bat_vete_for[new_combat.formation_set];
    obj_controller.bat_hire_column = obj_controller.bat_hire_for[new_combat.formation_set];
    obj_controller.bat_librarian_column = obj_controller.bat_libr_for[new_combat.formation_set];
    obj_controller.bat_command_column = obj_controller.bat_comm_for[new_combat.formation_set];
    obj_controller.bat_techmarine_column = obj_controller.bat_tech_for[new_combat.formation_set];
    obj_controller.bat_terminator_column = obj_controller.bat_term_for[new_combat.formation_set];
    obj_controller.bat_honor_column = obj_controller.bat_hono_for[new_combat.formation_set];
    obj_controller.bat_dreadnought_column = obj_controller.bat_drea_for[new_combat.formation_set];
    obj_controller.bat_rhino_column = obj_controller.bat_rhin_for[new_combat.formation_set];
    obj_controller.bat_predator_column = obj_controller.bat_pred_for[new_combat.formation_set];
    obj_controller.bat_landraider_column = obj_controller.bat_land_for[new_combat.formation_set];
    obj_controller.bat_scout_column = obj_controller.bat_scou_for[new_combat.formation_set];  
}

function add_unit_to_battle(unit,meeting){
     var man_size = 1;

    //Same as co/company and v, but with extra comprovations in case of a meeting (meeting?) 
    var cooh, va;
    cooh = 0;
    va = 0;

    var company = company.company;
    if (!meeting) {
        cooh = company;
        va = v;
    }else {
        if (v <= obj_temp_meeting.dudes) {
            cooh = obj_temp_meeting.company[v];
            va = obj_temp_meeting.ide[v];
        }
    }

    var col = 0,targ = 0,moov = 0;
    _u_role = unit.role();

    if (new_combat.battle_special == "space_hulk") then new_combat.player_starting_dudes++;
    if (unit.role() = obj_ini.role[100][18]) {
        col = obj_controller.bat_tactical_column;                   //sergeants
        new_combat.sgts++;
    }else if (unit.role() = obj_ini.role[100, 19]){
        col = obj_controller.bat_veteran_column;
        new_combat.vet_sgts++;                        
    }
    if (unit.role() = obj_ini.role[100, 12]) {              //scouts
        col = obj_controller.bat_scout_column;
        new_combat.scouts++;

    }else if (array_contains( [obj_ini.role[100][8], $"{obj_ini.role[100, 15]} Aspirant", $"{obj_ini.role[100, 14]} Aspirant"] , unit.role())) {
        col = obj_controller.bat_tactical_column;                   //tactical_marines
        new_combat.tacticals++;
    }else if (unit.role() = obj_ini.role[100, 3]){          //veterans and veteran sergeants
        col = obj_controller.bat_veteran_column;
        new_combat.veterans++;
    }else if (unit.role() = obj_ini.role[100, 9]) {         //devastators
        col = obj_controller.bat_devastator_column;
        new_combat.devastators++;
    }else if(unit.role() = obj_ini.role[100, 10]){          //assualt marines
        col = obj_controller.bat_assault_column;
        new_combat.assaults++;

        //librarium roles

    }else if (unit.IsSpecialist("libs",true)){
        col = obj_controller.bat_librarian_column;                  //librarium
        new_combat.librarians++;
        moov = 1;
    }else if (unit.role() = obj_ini.role[100, 16]) {            //techmarines
        col = obj_controller.bat_techmarine_column;
        new_combat.techmarines++;
        moov = 2;
    } else if (unit.role() = obj_ini.role[100, 2]) {            //honour guard
        col = obj_controller.bat_honor_column;
        new_combat.honors++;

    } else if (unit.IsSpecialist("dreadnoughts")){
        col = obj_controller.bat_dreadnought_column;                //dreadnoughts
        new_combat.dreadnoughts++;
    }else if (unit.role() = obj_ini.role[100][4]) {         //terminators
        col = obj_controller.bat_terminator_column;
        new_combat.terminators++;
    }

    if (moov > 0) {
        if ((moov = 1) and(obj_controller.command_set[8] = 1)) or((moov = 2) and(obj_controller.command_set[9] = 1)) {
            if (company >= 2) then col = obj_controller.bat_tactical_column;
            if (company = 10) then col = obj_controller.bat_scout_column;
            if (obj_ini.mobi[cooh][va] = "Jump Pack") {
                col = obj_controller.bat_assault_column;
            }
        }
    }

    if (unit.role() = obj_ini.role[100, 15]) or(unit.role() = obj_ini.role[100, 14]) or(string_count("Aspirant", unit.role()) > 0) {
        if (unit.role() = string(obj_ini.role[100, 14]) + " Aspirant") {
            col = obj_controller.bat_tactical_column;
            new_combat.tacticals++;
        }

        if (unit.role() = obj_ini.role[100, 15]) then new_combat.apothecaries++;
        if (unit.role() = obj_ini.role[100, 14]) {
            new_combat.chaplains++;
            if (new_combat.big_mofo > 5) then new_combat.big_mofo = 5;
        }

        col = obj_controller.bat_tactical_column;
        if (obj_ini.armour[cooh][va] = "Terminator Armour") or(obj_ini.armour[cooh][va] = "Tartaros Armour") {
            col = obj_controller.bat_terminator_column;
        }
        if (company = 10) then col = obj_controller.bat_scout_column;
    }

    if (unit.role() = obj_ini.role[100, 5]) or(unit.role() = obj_ini.role[100][11]) or(unit.role() = obj_ini.role[100, 7]) {
        if (unit.role() = obj_ini.role[100, 5]) {
            new_combat.captains++;
            if (new_combat.big_mofo > 5) then new_combat.big_mofo = 5;
        }
        if (unit.role() = obj_ini.role[100][11]) then new_combat.standard_bearers++;
        if (unit.role() = obj_ini.role[100, 7]) then new_combat.champions++;

        //if (company = 1) {
        //    col = obj_controller.bat_veteran_column;
        //    if (obj_ini.armour[cooh][va] = "Terminator Armour") then col = obj_controller.bat_terminator_column;
        //    if (obj_ini.armour[cooh][va] = "Tartaros Armour") then col = obj_controller.bat_terminator_column;
        //}
        if (company >= 2) then col = obj_controller.bat_tactical_column;
        if (company = 10) then col = obj_controller.bat_scout_column;
        if (obj_ini.mobi[cooh][va] = "Jump Pack") then col = obj_controller.bat_assault_column;
    }

    if (unit.role() = "Chapter Master") {
        col = obj_controller.bat_command_column;
        new_combat.important_dudes++;
        new_combat.big_mofo = 1;
        if (string_count("0", obj_ini.spe[cooh][va]) > 0) then new_combat.chapter_master_psyker = 1;
        else {
            new_combat.chapter_master_psyker = 0;
        }
    }
    if (unit.IsSpecialist("heads")){
        col = obj_controller.bat_command_column;
        new_combat.important_dudes++;                       
    };
    if (new_combat.big_mofo > 2) then new_combat.big_mofo = 2;
    if (new_combat.big_mofo > 3) then new_combat.big_mofo = 3;
    if (unit.squad!="none"){
        squad = obj_ini.squads[unit.squad];
        switch(squad.formation_place){
            case "assault":
                col = obj_controller.bat_assault_column;
                column_decided=true;
                break;
            case "veteran":
                col = obj_controller.bat_veteran_column;
                column_decided=true;
                break;
             case "tactical":
                col = obj_controller.bat_tactical_column;
                column_decided=true; 
                break;
             case "devastator":
                col = obj_controller.bat_devastator_column;
                column_decided=true; 
                break;
             case "terminator":
                col = obj_controller.bat_terminator_column;
                column_decided=true; 
                break;
            case "command":
                col = obj_controller.bat_command_column;
                column_decided=true; 
                break;                                                                                                                      
        }
    }
    if (col = 0) then col = obj_controller.bat_hire_column;
    if (unit.role() = "Death Company") { // Ahahahahah
        var really;
        really = false;
        if (string_count("Dreadnought", targ.marine_armour[targ.men]) > 0) then really = true;
        if (really = false) then new_combat.thirsty++;
        if (really = true) then new_combat.really_thirsty++;
        col = max(obj_controller.bat_assault_column, obj_controller.bat_command_column, obj_controller.bat_honor_column, obj_controller.bat_dreadnought_column, obj_controller.bat_veteran_column);
    }

    targ = instance_nearest(col * 10, 240, obj_pnunit);

    with (targ){
        scr_add_unit_to_roster(unit);
    }

    // info for ai targetting armour and what they think is best. TODO find out what marine_ranged and attack does

    // marine_attack[i]=1;
    // marine_ranged[i]=1;
    // marine_defense[i]=1;

    if (obj_ini.mobi[cooh][va] = "Bike") {
        man_Size = 3;
    }
    if (obj_ini.mobi[cooh][va] = "Jump Pack") {
        man_Size = 2;
    }

    //evaluates if there is a limit on the size of men that can be in a battle and only adds the allowable number to roster
    if (new_combat.man_size_limit == 0) {
        new_combat.fighting[cooh][va] = 1;
        sofar++;
    } else {
        if (man_size_count + man_size <= new_combat.man_size_limit) {
            new_combat.fighting[cooh][va] = 1;
            sofar++;
            man_size_count += man_size;
            if (man_size_count == new_combat.man_size_limit) {
                man_limit_reached = true;
            }
        }
    }
}   