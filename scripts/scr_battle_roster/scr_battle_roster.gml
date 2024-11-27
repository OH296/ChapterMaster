function scr_battle_roster(required_location, _target_location, _is_planet, overide_list) {

    // Determines who all will be present for the battle

    // argument 0 : planet or ship name
    // argument 1 : world number (wid)
    // argument 2 : is it a planet?  boolean

    //--------------------------------------------------------------------------------------------------------------------
    // Global objects used.
    //--------------------------------------------------------------------------------------------------------------------
    var func = function(required_location, _target_location, _is_planet){
        new_combat = obj_ncombat;
        //???=obj_drop_select;
        //???=obj_controller
        //--------------------------------------------------------------------------------------------------------------------

        // show_message("Container:"+string(_battle_loci)+", number:"+string(_loci_specific)+", planet?:"+string(_is_planet));

        var stop, okay, sofar, man_limit_reached, man_size_count, unit, unit_location, _u_role,column_decided,squad;
        stop = 0;
        okay = 0;
        sofar = 0;
        man_limit_reached = false;
        man_size_count = 0;


        // Formation here
        setup_battle_formations();

        var v = 0;
        var meeting = false;

        instance_activate_object(obj_pnunit);

        //For each company and the HQ
        for (var company=0;company<=10;company++){
            if (man_limit_reached) {
                break;
            }
    		for (v=0;v<array_length(obj_ini.TTRPG[company]);v++){
                column_decided=false;
                okay = 0;
    			unit = obj_ini.TTRPG[company][v];
    			if (unit.name() == ""){continue}
                if (man_limit_reached) {
                    break;
                }
                if (unit.hp()<=0 || unit.in_jail()) then continue;
                unit_location =  unit.marine_location();
                //array[0] set to 0, so the proper array starts at array[1], for some reason


                //Special (okay -1) battle cases go here
                var _not_dread_advised = (string_count("spyrer", new_combat.battle_special) > 0) or(new_combat.battle_special == "space_hulk") or(string_count("chaos_meeting", new_combat.battle_special) > 0);
                if (_not_dread_advised) {
                    var _u_armour = unit.armour_data();
                    if (is_struct(_u_armour)){
                        if (_u_armour.has_tag("dreadnought")){
                            okay = -1;
                        }
                    }
                }
                if (string_count("spyrer", new_combat.battle_special) > 0) {
                    if (okay == 1) and(sofar > 2) then okay = -1;
                }
                if (okay <= -1) then new_combat.fighting[company][v] = 0;

                //Normal and other battle cases checks go here
                else if (okay >= 0) {
                    if (instance_exists(obj_ground_mission)) { //Exploring ruins ambush case
                        if (obj_ini.loc[company][v] == required_location) and(unit.planet_location == _target_location) {
                            okay = 1;
                        } else {
                            continue;
                        }
                    } else if (!instance_exists(obj_drop_select)) { // Only when attacked, normal battle
                        if (_is_planet) and(obj_ini.loc[company][v] == required_location) and(unit.planet_location == _target_location)  then okay = 1;
                        else if (!_is_planet) and(unit.ship_location == _target_location) then okay = 1;

                        if (instance_exists(obj_temp_meeting)) {
                            meeting = true;
                            if (company == 0) and(v <= obj_temp_meeting.dudes) and(obj_temp_meeting.present[v] == 1) then okay = 1;
                            else if (company > 0) or(v > obj_temp_meeting.dudes) then okay = 0;
                        }
                    } else if (instance_exists(obj_drop_select)) { // When attacking, normal battle
                        //If not fighting (obj_drop_select pre-check), we skip the unit
                        if (obj_drop_select.fighting[company][v] == 0) then okay = 0;

                        else if (obj_drop_select.attack == 1) {
                            if (_is_planet) and(obj_ini.loc[company][v] == required_location) and(unit.planet_location == _target_location)   then okay = 1;
                            else if (!_is_planet) and(unit.ship_location == _target_location) then okay = 1;
                        } else if (obj_drop_select.attack != 1) {
                            //Related to defensive battles (¿?). Without the above check, it duplicates marines on offensive ones.
                            if (obj_drop_select.fighting[company][v] == 1) and(unit.ship_location == _target_location) then okay = 1;
                        }
                    }
                }

                // Start adding unit to battle
                if (okay >= 1) {

                    add_unit_to_battle(unit, meeting);
                // Vehicle checks
                }
            }
            for (v=0;v<array_length(obj_ini.veh_race[company]);v++){
                if (v <= 100) and(string_count("spyrer", new_combat.battle_special) = 0) and(company <= 10) and(meeting = false) {
                    var vokay;
                    vokay = 0;

                    if (obj_ini.veh_race[company][v] != 0) and(obj_ini.veh_loc[company][v] = required_location) and(obj_ini.veh_wid[company][v] = _target_location) then vokay = 1;

                    if (_is_planet) and(new_combat.local_forces = 1) {
                        var world_name, p_num;
                        world_name = "";
                        p_num = obj_controller.selecting_planet;
                        if (instance_exists(obj_drop_select)) {
                            world_name = obj_drop_select.p_target.name;
                        }
                        if (obj_ini.veh_race[company][v] != 0) and(obj_ini.veh_loc[company][v] = world_name) and(obj_ini.veh_wid[company][v] = p_num) then vokay = 2;
                    }
                    if (!_is_planet) and(obj_ini.veh_lid[company][v] = _target_location) and(obj_ini.veh_hp[company][v] > 0) then vokay = 1;

                    if (instance_exists(obj_drop_select)) {
                        if (obj_drop_select.attack = 0) then vokay = 0;
                    }


                    // if (obj_ncombat.veh_fighting[company,v]=1) then vokay=2;// Fuck on me, AI

                    if (vokay >= 1) and(new_combat.dropping = 0) {
                        add_vehicle_to_battle(company, v)
                    }
                }

            }
        }
    }

    try_and_report_loop("battle roster collection",func, false,[required_location, _target_location, _is_planet]);
}