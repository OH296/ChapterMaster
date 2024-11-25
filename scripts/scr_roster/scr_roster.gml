function Roster() constructor{
    full_roster_units = [];
    selected_unit = [];
    full_roster = {};
    selected_roster = {};
    ships = [];
    roster_location = "";
    roster_planet = 0;
    roster_string = "";
    select_buttons = []
    static format_roster_string = function(){
        roster_string = "";
        var _roster_types = struct_get_names(selected_roster);
        for (var i=0;i<array_length(_roster_types);i++){
            var _roster_type_name = _roster_types[i];
            if (selected_roster[$_roster_type_name] == 1){
                roster_string += $"1 {_roster_type_name}{i==array_length(_roster_types)-1?"":","}";
            }
        }
    }

    static alter_by_ship = function(ship_id, add){
        if (add){
            for (var i=array_length(full_roster_units)-1;i>=0;i--){
                var _unit = full_roster_units[i];
                if (_unit.squad_type() == squad_id){
                    array_push(selected_unit,_unit[i]);
                    array_delete(_unit, i, 1);
                }
            }
        } else {
            for (var i=array_length(selected_unit)-1;i>=0;i--){
                var _unit = selected_unit[i];
                if (selected_unit.squad_type() == squad_id){
                    array_push(_unit,selected_unit[i]);
                    array_delete(selected_unit, i, 1);
                }
            }            
        }
    }

    static alter_by_squad = function(squad_id, add){
        if (add){
            for (var i=array_length(full_roster_units)-1;i>=0;i--){
                var _unit = full_roster_units[i];
                if (_unit.squad_type() == squad_id){
                    array_push(selected_unit,_unit[i]);
                    array_delete(_unit, i, 1);
                }
            }
        } else {
            for (var i=array_length(selected_unit)-1;i>=0;i--){
                var _unit = selected_unit[i];
                if (selected_unit.squad_type() == squad_id){
                    array_push(_unit,selected_unit[i]);
                    array_delete(selected_unit, i, 1);
                }
            }            
        }
    }
    static new_select_button = function(display, squad_id){
        var _button = new ToggleButton();
        _button.str1 = display;
        _button.text_halign = fa_center;
        _button.text_color = CM_GREEN_COLOR;
        _button.button_color = CM_GREEN_COLOR;
        _button.width = string_width(display);
        _button.active = true;
        _button.squad = squad_id;
        array_push(select_buttons, _button);
    }
    static new_ship_button = function(display, ship_id){
        var _button = new ToggleButton();
        _button.str1 = display;
        _button.text_halign = fa_center;
        _button.text_color = CM_GREEN_COLOR;
        _button.button_color = CM_GREEN_COLOR;
        _button.width = string_width(display);
        _button.active = true;
        _button.squad = ship_id;
        array_push(ships, _button);
    }

    static add_role_to_roster = function(role){
        if (struct_exists(full_roster, role)){
            full_roster[$role]++;
        } else {
            full_roster[$role] = 1;
        }
    }
    static determine_full_roster  = function(){
        var _squads = [];
        for (var co=0;co<obj_ini.companies;co++){
            for (var i=0;i<array_length(obj_ini.role[co]);i++){
                var _allow = false;
                var _unit = fetch_unit([co, i]);
                if (_unit.name() == "" || _unit.role() == "") then continue;
                if (_unit.is_at_location(roster_location)){
                    _allow = true;
                }
                if (_allow){
                    array_push(full_roster_units, _unit);
                    add_role_to_roster(_unit.role());
                    if (_unit.squad!="none"){
                        var _squad_type = _unit.squad_type();
                        if (_squad_type!="none"){
                            if (!array_contains(_squads, _squad_type)){
                                array_push(_squads, _squad_type);
                                new_select_button(obj_ini.squads[_unit.squad].display_name);
                            }
                         }
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