function scr_mission_reward(mission, star, planet) {
    // mission: mission designation
    // star: target star system
    // planet: planet number

    // "mech_bionics",id,i
    // "mech_raider",id,i

    var cleanup = array_create(11, 0);

    if (mission == "mars_spelunk") {
        var roll1 = roll_dice_chapter(1, 100, "high"); // For the first STC
        var found_stc = 0, found_artifact = 0, found_requisition = 0;
        var techs_lost = 0, techs_alive = 0;

        var _conditions = {
            job: "mecanicus mission",
        };
        var _techs = collect_role_group(SPECIALISTS_TECHS, star.name, false, _conditions);

        var _tech_point_gain = 0;

        for (var i = 0; i < array_length(_techs); i++) {
            var _tech = _techs[i];
            var _tech_roll = global.character_tester.standard_test(_tech, "technology", -10)[1];
            var _wep_test = global.character_tester.standard_test(_tech, "weapon_skill", 10);
            if (!_wep_test[0]) {
                _tech.kill(true, false);
                techs_lost++;
                cleanup[_tech.company] = true;
            } else {
                star.p_player[planet] += _tech.get_unit_size();
                _tech.location_string = star.name;

                _tech.planet_location = planet;

                _tech.ship_location = -1;

                _tech.job = "none";
                techs_alive += 1;

                _tech.add_experience(irandom_range(3, 18));
                var gain = irandom(2);

                _tech.technology += gain;
                _tech_point_gain += gain;
                if (_tech_roll < 10 && _tech_roll > 0) {
                    found_requisition += irandom_range(5, 40);
                }
            }
            if ((_tech_roll >= 10) && (_tech_roll < 15)) {
                found_requisition += 100;
            }
            if ((_tech_roll >= 15) && (_tech_roll < 25)) {
                var last_artifact = scr_add_artifact("random", "", 4);
                found_artifact += 1;
            }
            if (_tech_roll >= 25) {
                scr_add_stc_fragment(); // STC here
                found_stc += 1;
            }
        }

        obj_controller.requisition += found_requisition;
        if ((techs_alive + techs_lost >= 2) && (techs_alive > 0)) {
            if (roll1 >= (40 + (techs_alive + techs_lost) * 5)) {
                scr_add_stc_fragment(); // STC here
                found_stc += 1;
            }
        }

        var tixt = $"The journey into the Mars Catacombs was a success.  Your {techs_alive} remaining {obj_ini.player_role_data[eROLE.TECHMARINE].role}s were useful to the Mechanicus force and return with a bounty.  They await retrieval at {star.name} {scr_roman(planet)}.\n";
        tixt += $"\n{found_requisition} Requisition from salvage";
        if (found_artifact > 0) {
            tixt += $"\n{string_plural("Unidentified Artifacts", found_artifact)}  recovered";
        }
        if (found_stc > 0) {
            tixt += $"\n{string_plural("STC Fragment", found_stc)}  recovered";
        }

        if (_tech_point_gain) {
            tixt += $"\n{string_plural("Tech Point", _tech_point_gain)}  recovered";
        }

        scr_popup("Mechanicus Mission Completed", tixt, "mechanicus", "");
        tixt = "Mechanicus Mission Completed: {techs_alive}/{techs_alive+techs_lost} of your {obj_ini.player_role_data[eROLE.TECHMARINE].role}s return with ";
        tixt += string(found_requisition) + " Requisition, ";
        if (found_artifact > 0) {
            tixt += $"\n{found_artifact} : {string_plural("Unidentified Artifacts", found_artifact)}  recovered";
        }
        if (found_stc > 0) {
            tixt += $"\n{found_stc} : {string_plural("STC Fragment", found_stc)}  recovered";
        }
        if (_tech_point_gain) {
            tixt += $"\n{_tech_point_gain} {string_plural("Tech Point", _tech_point_gain)}  gained";
        }
        scr_event_log("green", tixt);

        sort_all_companies_to_map(cleanup);
    }

    cleanup = array_create(11, 0);
}
