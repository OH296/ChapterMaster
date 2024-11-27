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
                        new_combat.veh_fighting[company][v] = 1;

                        var col = 1, targ = 0;

                        switch (obj_ini.veh_role[company][v]){
                            case "Rhino":
                                col = obj_controller.bat_rhino_column;
                                new_combat.rhinos++;
                                break;
                            case "Predator":
                                col = obj_controller.bat_predator_column;
                                new_combat.predators++;
                                break;
                             case "Land Raider":
                                col = obj_controller.bat_landraider_column;
                                new_combat.land_raiders++;
                                break;
                             case "Whirlwind":
                                col = 1;
                                new_combat.whirlwinds++;
                                break;                                    
                        }

                        targ = instance_nearest(col * 10, 240 / 2, obj_pnunit);
                        targ.veh++;
                        targ.veh_co[targ.veh] = company;
                        targ.veh_id[targ.veh] = v;
                        targ.veh_type[targ.veh] = obj_ini.veh_role[company][v];
                        targ.veh_wep1[targ.veh] = obj_ini.veh_wep1[company][v];
                        targ.veh_wep2[targ.veh] = obj_ini.veh_wep2[company][v];
                        targ.veh_wep3[targ.veh] = obj_ini.veh_wep3[company][v];
                        targ.veh_upgrade[targ.veh] = obj_ini.veh_upgrade[company][v];
                        targ.veh_acc[targ.veh] = obj_ini.veh_acc[company][v];
                        if (vokay = 2) then targ.veh_local[targ.veh] = 1;


    					if (obj_ini.veh_role[company][v] = "Land Speeder") {
    					targ.veh_hp[targ.veh] = obj_ini.veh_hp[company][v] * 3;
                            targ.veh_hp_multiplier[targ.veh] = 3;
                            targ.veh_ac[targ.veh] = 30;
                        }
                        if (obj_ini.veh_role[company][v] = "Rhino") or(obj_ini.veh_role[company][v] = "Whirlwind") {
                            targ.veh_hp[targ.veh] = obj_ini.veh_hp[company][v] * 5;
                            targ.veh_hp_multiplier[targ.veh] = 5;
                            targ.veh_ac[targ.veh] = 40;
                        }
                        if (obj_ini.veh_role[company][v] = "Predator") {
                            targ.veh_hp[targ.veh] = obj_ini.veh_hp[company][v] * 6;
                            targ.veh_hp_multiplier[targ.veh] = 6;
                            targ.veh_ac[targ.veh] = 45;
                        }
                        if (obj_ini.veh_role[company][v] = "Land Raider") {
                            targ.veh_hp[targ.veh] = obj_ini.veh_hp[company][v] * 8;
                            targ.veh_hp_multiplier[targ.veh] = 8;
                            targ.veh_ac[targ.veh] = 50;
                        }

                        // STC Bonuses
                        if (targ.veh_type[targ.veh] != "") {
                            if (obj_controller.stc_bonus[3] = 1) {
                                targ.veh_hp[targ.veh] = round(targ.veh_hp[targ.veh] * 1.1);
                                targ.veh_hp_multiplier[targ.veh] = targ.veh_hp_multiplier[targ.veh] * 1.1;
                            }
                            if (obj_controller.stc_bonus[3] = 2) {
                                //TODO reimplement STC bonus for ranged vehicle weapons
                                //veh ranged isn't a thing sooooo.... oh well
                                //targ.veh_ranged[targ.veh] = targ.veh_ranged[targ.veh] * 1.05;
                            }
                            if (obj_controller.stc_bonus[3] = 5) {
                                targ.veh_ac[targ.veh] = round(targ.veh_ac[targ.veh] * 1.1);
                            }
                            if (obj_controller.stc_bonus[4] = 1) {
                                targ.veh_hp[targ.veh] = round(targ.veh_hp[targ.veh] * 1.1);
                                targ.veh_hp_multiplier[targ.veh] = targ.veh_hp_multiplier[targ.veh] * 1.1;
                            }
                            if (obj_controller.stc_bonus[4] = 2) {
                                targ.veh_ac[targ.veh] = round(targ.veh_ac[targ.veh] * 1.1);
                            }
                        }
                    }
                }

            }
        }
    }

    try_and_report_loop("battle roster collection",func, false,[required_location, _target_location, _is_planet]);
}