function drop_select_draw(){
	with (obj_drop_select){
	if (!purge) {
        w = 660;
        h = 520;
        // Center of the screen
        var _x_center = main_slate.XX;
        var _y_center = main_slate.YY;
        var x1 = _x_center
        var y1 = _y_center;
        var x2 = x1 + w;
        var y2 = y1 + h;
        var x3 = (x1 + x2) / 2;
        var y3 = (y1 + y2) / 2;

        draw_set_font(fnt_40k_30b);

        // var xx,yy;
        // xx=view_xview[0]+545;yy=view_yview[0]+212;
        draw_set_halign(fa_left);
        draw_set_color(c_gray);
        var attack_type = attack ? "Attacking" : "Raiding"
        draw_text_transformed(x1 + 40, y1 + 38, $"{attack_type} ({planet_numeral_name(planet_number, p_target)} )", 0.6, 0.6, 0);
        var _offset = x1 + 40;
        draw_set_font(fnt_40k_14);
        for (var i=0;i<array_length(roster.company_buttons);i++){
            var _button = roster.company_buttons[i];
            _button.x1 = _offset
            _button.y1 = y1 + 60;
            _button.update();
            _button.draw();
            if (_button.company_present) {
                if (_button.clicked()) {               
                    roster.update_roster();
                }
            }
            _offset+=_button.width;
        }

        // Planet icon here
        // draw_rectangle(xx+1084,yy+215,xx+1142,yy+273,0);

        // Formation
        formation.x1 = x1 + 420;
        formation.y1 = y1 + 80;
        formation.str1 = $"Formation: {obj_controller.bat_formation[formation_possible[formation_current]]}";
        formation.update();
        formation.draw();
        if (formation.clicked()) {
            formation_current++;
            if (formation_current>=array_length(formation_possible)){
                formation_current = 0;
            }
        }

        // Ships Are Up, Fuck Me
        draw_set_color(c_gray);
        draw_text(x1 + 40, 273, "Available Forces:");

        var column, row, e, x8, y8, sigh, sip;
        e = 0;
        sigh = 0;
        sip = 1;
        column = 1;
        row = 1;
        x8 = 552;
        y8 = 299;
        e = 500;

        var add_ground = 0;

        // Local force button;

        // Ship buttons;
        var _local_button = roster.local_button;
        _local_button.x1 = x8
        _local_button.y1 = y8
        _local_button.update();
        _local_button.draw();
        if (_local_button.clicked()) {
            roster.update_roster();
        }        
        y8 += 21;

        for (var e=0;e<array_length(roster.ships);e++) {
            var _ship_button = roster.ships[e];
            _ship_button.x1 = x8
            _ship_button.y1 = y8
            _ship_button.update();
            _ship_button.draw();           
            if (_ship_button.clicked()) {
                roster.update_roster();
            }
            if (_ship_button.hover()){
                roster.update_local_string(_ship_button.ship_id);
            }
            y8 += 21;
            if (e%9 == 0 && e!=0){
                y8 = 320;
                x8 = 700;
            }
        }

        draw_set_font(fnt_40k_14);
        draw_set_color(c_gray);
        draw_set_alpha(1);

        // Unit types buttons;
        var _squads_box = {
            header: "Selected Squads:",
            x1: x1 + 40,
            y1: y2 - 180
        };
        draw_text(_squads_box.x1, _squads_box.y1, _squads_box.header);
        var _x_offset = 0;
        var _row = 0;
        var loop_cycle = array_length(roster.squad_buttons) +  array_length(roster.vehicle_buttons)-1;
        var _squad_length = array_length(roster.squad_buttons);
        var _button;
        for (var i = 0; i < loop_cycle; i++){

            if (i<_squad_length){
                _button = roster.squad_buttons[i];
            } else {
                _button = roster.vehicle_buttons[i-_squad_length];
            }

            if (_x_offset + _button.width > 590){
                _row++;
                _x_offset = 0;
            }
            _button.x1 = (_squads_box.x1) + _x_offset;
            _button.y1 = (_squads_box.y1 + string_height(_squads_box.header) + 10) + _row * 28;
            _button.update();
            _button.draw();

            if (_button.clicked()) {               
                roster.update_roster();
            }

            _x_offset += _button.width +10;
        }

        // draw_text(x2 + 14, y2 + 352, string_hash_to_newline("Selection: " + string(smin) + "/" + string(smax)));

        // Target
        var target_race = "",
            target_threat = "",
            race_quantity = 0;
        var races = ["", "Ecclesiarchy", "Eldar", "Orks", "Tau", "Tyranids", "Heretics", "CSMs", "Daemons", "Necrons"];
        var threat_levels = ["", "Negligible", "Minor", "Moderate", "High", "Very High", "Overwhelming"];
        var race_quantities = [0, sisters, eldar, ork, tau, tyranids, traitors, csm, demons, necrons];

        if (attacking >= 5 && attacking <= 13) {
            race_quantity = race_quantities[attacking - 4];
            target_race = races[attacking - 4];
        }

        if (race_quantity >= 1 && race_quantity <= 6) {
            target_threat = threat_levels[race_quantity];
        } else if (race_quantity >= 6) {
            target_threat = threat_levels[6];
        }
        target.x1 = formation.x1;
        target.y1 = formation.y2 + 10;
        target.str1 = "Target: ";
        if (race_quantity != 0) {
            target.str1 += target_race + " (" + string(target_threat) + " Threat)";
        } else {
            target.str1 += "None";
        }
        target.update();
        target.draw();
        draw_sprite(spr_faction_icons, attacking, x2 - 100, y1 + 40);
        var q = 0;
        repeat(20) {
            q += 1;
            if (target.clicked() && force_present[q] != 0) {
                if (attacking != force_present[q] && force_present[q] > 0) {
                    attacking = force_present[q];
                }
            }
        }
        target.locked = (force_present[q] == 0);

        // Back / Purge buttons
        btn_back.x1 = x3 - 100;
        btn_back.y1 = y2 - 60;
        btn_back.update();
        btn_back.draw();
        if (btn_back.clicked()) {
            menu = 0;
            purge = 0;
            instance_destroy();
        }

        // Attack / Raid buttons
        btn_attack.x1 = btn_back.x1 + btn_attack.width + 10;
        btn_attack.y1 = btn_back.y1;
        if (attack = 0) then btn_attack.str1 = "RAID!";
        if (attack = 1) then btn_attack.str1 = "ATTACK!";
        btn_attack.active = (array_length(roster.selected_units) > 0 && race_quantity > 0);
        btn_attack.update();
        btn_attack.draw();
        if (btn_attack.clicked()) {
            combating = 1; // Start battle here

            if (attack = 1) then obj_controller.last_attack_form = formation_possible[formation_current];
            if (attack = 0) then obj_controller.last_raid_form = formation_possible[formation_current];

            instance_deactivate_all(true);
            instance_activate_object(obj_controller);
            instance_activate_object(obj_ini);
            instance_activate_object(obj_drop_select);

            // 135 ; temporary balancing
            if (sh_target != -50) {
                sh_target.acted += 1;
            }

            if (attacking == 10) or (attacking == 11) {
                remove_planet_problem(planet_number, "meeting", p_target);
                remove_planet_problem(planet_number, "meeting_trap", p_target);
            }

            instance_create(0, 0, obj_ncombat);
            obj_ncombat.battle_object = p_target;
            obj_ncombat.battle_loc = p_target.name;
            obj_ncombat.battle_id = planet_number;
            obj_ncombat.dropping = 1 - attack;
            obj_ncombat.attacking = attack;
            obj_ncombat.enemy = attacking;
            obj_ncombat.formation_set = formation_possible[formation_current];
            obj_ncombat.defending = false;
            obj_ncombat.local_forces = roster.local_button.active

            var _planet = obj_ncombat.battle_object.p_feature[obj_ncombat.battle_id]
            if (obj_ncombat.battle_object.space_hulk = 1) then obj_ncombat.battle_special = "space_hulk";
            if (planet_feature_bool(_planet, P_features.Warlord6) == 1) and(obj_ncombat.enemy = 6) and(obj_controller.faction_defeated[6] = 0) then obj_ncombat.leader = 1;
            if (obj_ncombat.enemy = 7) and(obj_controller.faction_defeated[7] <= 0) {
                if (planet_feature_bool(_planet, P_features.OrkWarboss)) {
                    obj_ncombat.leader = 1;
                    obj_ncombat.Warlord = _planet[search_planet_features(_planet, P_features.OrkWarboss)[0]];
                }
            }

            if (obj_ncombat.enemy = 9) and(obj_ncombat.battle_object.space_hulk = 0) {
                if (has_problem_planet(planet_number, "tyranid_org", p_target)) then obj_ncombat.battle_special = "tyranid_org";
            }

            if (obj_ncombat.enemy = 11) {
                if (planet_feature_bool(obj_ncombat.battle_object.p_feature[obj_ncombat.battle_id], P_features.World_Eaters) == 1) {
                    obj_ncombat.battle_special = "world_eaters";
                    obj_ncombat.leader = 1;
                }
            }

            if (obj_ncombat.enemy = 5) then obj_ncombat.threat = sisters;
            if (obj_ncombat.enemy = 6) then obj_ncombat.threat = eldar;
            if (obj_ncombat.enemy = 7) then obj_ncombat.threat = ork;
            if (obj_ncombat.enemy = 8) then obj_ncombat.threat = tau;
            if (obj_ncombat.enemy = 9) then obj_ncombat.threat = tyranids;
            if (obj_ncombat.enemy = 10) then obj_ncombat.threat = traitors;
            if (obj_ncombat.enemy = 11) then obj_ncombat.threat = csm;
            if (obj_ncombat.enemy = 12) then obj_ncombat.threat = demons;
            if (obj_ncombat.enemy = 13) then obj_ncombat.threat = necrons;

            if (obj_ncombat.enemy = 8) {
                var eth;
                eth = 0;
                eth = scr_quest(4, "ethereal_capture", 8, 0);
                if (eth > 0) and(obj_ncombat.battle_object.p_owner[obj_ncombat.battle_id] = 8) {
                    var rolli;
                    rolli = floor(random(100)) + 1;
                    if (obj_ncombat.threat = 6) and(rolli <= 80) then obj_ncombat.ethereal = 1;
                    if (obj_ncombat.threat = 5) and(rolli <= 65) then obj_ncombat.ethereal = 1;
                    if (obj_ncombat.threat = 4) and(rolli <= 50) then obj_ncombat.ethereal = 1;
                    if (obj_ncombat.threat = 3) and(rolli <= 35) then obj_ncombat.ethereal = 1;
                }
                // show_message("Ethereal Quest?: "+string(eth)+"#Ethereal?: "+string(obj_ncombat.ethereal));
            }

            // if (obj_ncombat.threat>1) and (obj_ncombat.enemy!=13) then obj_ncombat.threat-=1;
            if (obj_ncombat.threat > 1) and(obj_ncombat.battle_special != "world_eaters") and(attack = 0) then obj_ncombat.threat -= 1;
            if (obj_ncombat.threat < 1) then obj_ncombat.threat = 1;
            if (obj_ncombat.enemy = 10) and(obj_ncombat.battle_object.p_type[obj_ncombat.battle_id] = "Daemon") then obj_ncombat.threat = 7;

            if ((attacking = 0) or(attacking = 10) or(attacking = 11)) and(obj_ncombat.battle_object.p_traitors[obj_ncombat.battle_id] = 0) and(obj_ncombat.battle_object.p_chaos[obj_ncombat.battle_id] = 0) {
                if (planet_feature_bool(obj_ncombat.battle_object.p_feature[obj_ncombat.battle_id], P_features.Warlord10) == 1) and(obj_controller.known[eFACTION.Chaos] = 0) and(obj_controller.faction_gender[10] = 1) and(obj_controller.turn >= obj_controller.chaos_turn) {
                    var pop;
                    pop = instance_create(0, 0, obj_popup);
                    pop.image = "chaos_symbol";
                    pop.title = "Concealed Heresy";
                    pop.text = "Your astartes set out and begin to cleanse " + string(obj_ncombat.battle_object.name) + " " + scr_roman(obj_ncombat.battle_id) + " of possible heresy.  The general populace appears to be devout in their faith, but a disturbing trend appears- the odd citizen cursing your forces, frothing at the mouth, and screaming out heresy most foul.  One week into the cleansing a large hostile force is detected approaching and encircling your forces.";
                    with(obj_pnunit) {
                        instance_destroy();
                    }
                    with(obj_enunit) {
                        instance_destroy();
                    }
                    with(obj_nfort) {
                        instance_destroy();
                    }
                    with(obj_ncombat) {
                        instance_destroy();
                    }
                    combating = 0;
                    instance_activate_all();
                    exit;
                    exit;
                }
                if (planet_feature_bool(obj_ncombat.battle_object.p_feature[obj_ncombat.battle_id], P_features.Warlord10) == 1) and(obj_controller.known[eFACTION.Chaos] >= 2) and(obj_controller.faction_gender[10] = 1) and(obj_controller.turn >= obj_controller.chaos_turn) then with(obj_drop_select) {
                    obj_ncombat.enemy = 11;
                    obj_ncombat.threat = 0;
                    alarm[6] = 1;
                    with(obj_pnunit) {
                        instance_destroy();
                    }
                    with(obj_enunit) {
                        instance_destroy();
                    }
                    with(obj_nfort) {
                        instance_destroy();
                    }
                    with(obj_ncombat) {
                        instance_destroy();
                    }
                    combating = 0;
                    instance_activate_all();
                    exit;
                    exit;
                }
            }

            scr_battle_allies();

            roster.add_to_battle();
            for (var company_i = 0; company_i <= 10; company_i++) {
                for (var unit_i = 0; unit_i <= 300; unit_i++) {
                    if (fighting[company_i][unit_i] != 0) {
                        obj_ncombat.fighting[company_i][unit_i] = 1;
                    }
        
                    if ((attack == 1) && (unit_i <= 100)) {
                        if (veh_fighting[company_i][unit_i] != 0) {
                            obj_ncombat.veh_fighting[company_i][unit_i] = 1;
                        }
                    }
        
                    if ((attack == 1) && (ship_all[500] == 1)) {
                        if ((obj_ini.loc[company_i][unit_i] == p_target.name) && (obj_ini.TTRPG[company_i][unit_i].planet_location == planet_number) && (fighting[company_i][unit_i] == 1)) {
                            obj_ncombat.fighting[company_i][unit_i] = 1;
                        }
                        if (unit_i <= 100) {
                            if ((obj_ini.veh_loc[company_i][unit_i] == p_target.name) && (obj_ini.veh_wid[company_i][unit_i] == planet_number)) {
                                obj_ncombat.veh_fighting[company_i][unit_i] = 1;
                            }
                        }
                    }
                }
            }
        
            // Iterates through all selected "ships", including the planet (Local on the drop menu),
            // and fills the battle roster with any marines found.
            ships_selected = 0;
            var _ships_len = array_length(ship_all);
            for (var ship_i = 0; ship_i < _ships_len; ship_i++) {
                if (ship_all[ship_i] != 0) {
                    scr_battle_roster(ship[ship_i], ship_ide[ship_i], false);
                }
            }
            //ship_all[500] equals "Local" status on the drop menu
            if ((ship_all[500] == 1) && (attack == 1)) {
                scr_battle_roster(p_target.name, planet_number, true);
            }
        }
    }


    // Purge shit happens bellow;
    // God, save us;
    if (menu == 0) {
        if (purge == 1) {
            draw_sprite(spr_purge_panel, 0, 535, 200);
            draw_set_halign(fa_center);
            draw_set_font(fnt_40k_30b);

            draw_set_color(c_gray);
            draw_rectangle(740, 558, 860, 585, 0);
            draw_set_color(0);
            draw_text_transformed(800, 559, string_hash_to_newline("Cancel"), 0.75, 0.75, 0);
            if (scr_hit(740, 558, 860, 585)) {
                draw_set_alpha(0.2);
                draw_set_color(0);
                draw_rectangle(740, 558, 860, 585, 0);
                draw_set_alpha(1);
                if (scr_click_left()) {
                    instance_destroy();
                }
            }

            var hih, x5, y5, iy, r, nup;
            hih = 0;
            r = 0;
            iy = 0;
            nup = false;

            x5 = 535;
            y5 = 200;
            x5 += 89;
            y5 += 31;

            if (instance_exists(p_target)) {
                if (p_target.p_type[planet_number] = "Shrine") then nup = true;
            }

            // 89,31

            repeat(4) {
                iy += 1;
                r = 0;
                draw_set_alpha(1);
                if (iy = 1) and(purge_a <= 0) then draw_set_alpha(0.35);
                if (iy = 2) and(purge_b <= 0) and(purge_d = 0) then draw_set_alpha(0.35);
                if (iy = 3) and(purge_c <= 0) and(purge_d = 0) then draw_set_alpha(0.35);
                if (iy = 4) and((purge_d + purge_b = 0) or(p_target.dispo[planet_number] < 0)) then draw_set_alpha(0.35);
                if (iy = 4) and(nup = true) then draw_set_alpha(0.35);

                if (scr_hit(x5, y5 + ((iy - 1) * 73), x5 + 351, y5 + ((iy - 1) * 73) + 63) = true) {
                    r = 4;
                    if (scr_click_left()) {
                        if (iy = 1) and(purge_a > 0) {
                            purge = 2;
                            alarm[4] = 1;
                            purge_score = 0;
                            ships_selected = 0;
                            all_sel = 0;
                        }
                        if (iy = 2) and((purge_b > 0) or(purge_d != 0)) {
                            purge = 3;
                            alarm[2] = 1;
                            purge_score = 0;
                            ships_selected = 0;
                            all_sel = 0;
                        }
                        if (iy = 3) and((purge_c > 0) or(purge_d != 0)) {
                            purge = 4;
                            alarm[2] = 1;
                            purge_score = 0;
                            ships_selected = 0;
                            all_sel = 0;
                        }
                        if (iy = 4) and(purge_d + purge_b != 0) and(p_target.dispo[planet_number] >= 0) and(nup = false) {
                            purge = 5;
                            alarm[2] = 1;
                            purge_score = 0;
                            ships_selected = 0;
                            all_sel = 0;
                        }

                    }
                }

                // draw_sprite(spr_purge_buttons,(iy-1)+r,x5,y5+((iy-1)*73));
                scr_image("purge", (iy - 1) + r, x5, y5 + ((iy - 1) * 73), 351, 63);
            }
        } else if (purge >= 2) {
            draw_sprite(spr_purge_panel, 0, 535, 200);
            draw_set_halign(fa_center);
            draw_set_font(fnt_40k_30b);

            // 2 is bombardment

            var x2, y2;
            x2 = 535;
            y2 = 200;

            draw_set_halign(fa_left);
            draw_set_color(c_gray);
            if (purge = 2) then draw_text_transformed(x2 + 14, y2 + 12, string_hash_to_newline("Bombard Purging " + string(p_target.name) + " " + scr_roman(planet_number)), 0.6, 0.6, 0);
            if (purge = 3) then draw_text_transformed(x2 + 14, y2 + 12, string_hash_to_newline("Fire Cleansing " + string(p_target.name) + " " + scr_roman(planet_number)), 0.6, 0.6, 0);
            if (purge = 4) then draw_text_transformed(x2 + 14, y2 + 12, string_hash_to_newline("Selective Purging " + string(p_target.name) + " " + scr_roman(planet_number)), 0.6, 0.6, 0);
            if (purge = 5) then draw_text_transformed(x2 + 14, y2 + 12, string_hash_to_newline("Assassinate Governor (" + string(p_target.name) + " " + scr_roman(planet_number) + ")"), 0.6, 0.6, 0);

            // Disposition here
            var succession = 0,
                pp = planet_number

            var succession = has_problem_planet(pp, "succession", p_target);

            if ((p_target.dispo[pp] >= 0) and(p_target.p_owner[pp] <= 5) and(p_target.p_population[pp] > 0)) and(succession = 0) {
                var wack;
                wack = 0;
                draw_set_color(c_blue);
                draw_rectangle(x2 + 12, y2 + 53, x2 + 12 + max(0, (min(100, p_target.dispo[pp]) * 4.37)), y2 + 71, 0);
            }
            draw_set_color(c_gray);
            draw_rectangle(x2 + 12, y2 + 53, x2 + 449, y2 + 71, 1);
            draw_set_color(c_white);

            draw_set_font(fnt_40k_14b);
            draw_set_halign(fa_center);
            if (succession = 0) {
                if (p_target.dispo[pp] >= 0) and(p_target.p_first[pp] <= 5) and(p_target.p_owner[pp] <= 5) and(p_target.p_population[pp] > 0) then draw_text(x2 + 231, y2 + 54, string_hash_to_newline("Disposition: " + string(min(100, p_target.dispo[pp])) + "/100"));
                if (p_target.dispo[pp] > -30) and(p_target.dispo[pp] < 0) and(p_target.p_owner[pp] <= 5) and(p_target.p_population[pp] > 0) then draw_text(x2 + 231, y2 + 54, string_hash_to_newline("Disposition: ???/100"));
                if ((p_target.dispo[pp] >= 0) and(p_target.p_first[pp] <= 5) and(p_target.p_owner[pp] > 5)) or(p_target.p_population[pp] <= 0) then draw_text(x2 + 231, y2 + 54, string_hash_to_newline("-------------"));
                if (p_target.dispo[pp] <= -3000) then draw_text(x2 + 231, y2 + 54, "Chapter Rule");
            }
            if (succession = 1) then draw_text(x2 + 231, y2 + 54, string_hash_to_newline("War of Succession"));

            draw_set_color(c_gray);
            draw_set_font(fnt_40k_14);
            draw_set_halign(fa_left);

            // Planet icon here
            draw_rectangle(x2 + 459, y2 + 14, x2 + 516, y2 + 71, 0);

            // Ships Are Up, Fuck Me
            draw_text(x2 + 13, y2 + 80, string_hash_to_newline("Available Forces:"));

            var column, row, e, x8, y8, sigh, sip;
            e = 0;
            sigh = 0;
            sip = 1;
            column = 1;
            row = 1;
            x8 = x2 + 17;
            y8 = y2 + 105;
            e = 500;

            var add_ground;
            add_ground = 0;

            if (purge_d > 0) and(purge != 2) {
                if (ship_all[e] = 0) then draw_set_alpha(0.35);
                draw_set_color(c_gray);
                draw_rectangle(x8, y8, x8 + 160, y8 + 16, 0);
                draw_set_color(c_black);
                draw_text(x8 + 2, y8, string_hash_to_newline("Local (" + string(ship_use[e]) + "/" + string(ship_max[e]) + ")"))
                if (point_and_click([x8, y8, x8 + 160, y8 + 16])) {
                    var onceh;
                    onceh = 0;
                    if (ship_all[e] = 0) then add_ground = 1;
                    if (ship_all[e] = 1) then add_ground = -1;
                }
                y8 += 16;
                sip += 1;
            }
            e = 1;

            if (purge = 2) { // Bombard
                repeat(50) {
                    if (ship[e] != "") and(ship_size[e] > 1) {
                        draw_set_alpha(1);
                        if (ship_all[e] = 0) then draw_set_alpha(0.35);
                        draw_set_color(c_gray);
                        draw_rectangle(x8, y8, x8 + 160, y8 + 16, 0); // 160
                        draw_set_color(c_black);
                        draw_text_transformed(x8 + 2, y8, string_hash_to_newline(string(ship[e]) + " (" + string(ship_size[e]) + ")"), 0.8, 0.8, 0);
                        if (point_and_click([x8, y8, x8 + 160, y8 + 16])) {
                            var onceh;
                            onceh = 0;
                            if (onceh = 0) and(ship_all[e] = 0) {
                                onceh = 1;
                                ship_all[e] = 1;
                                ships_selected += 1;
                            }
                            if (onceh = 0) and(ship_all[e] = 1) {
                                onceh = 1;
                                ship_all[e] = 0;
                                ships_selected -= 1;
                            }
                        }
                        y8 += 18;
                        sip += 1;

                        if (y8 >= y2 + 105 + 180) {
                            y8 = y2 + 105;
                            x8 += 168;
                        }
                    }
                    e += 1;
                }
            }

            if (purge >= 3) { // Anything not bombardment
                repeat(50) {
                    if (ship[e] != "") and(ship_max[e] > 0) {
                        draw_set_alpha(1);
                        if (ship_all[e] = 0) then draw_set_alpha(0.35);
                        draw_set_color(c_gray);
                        draw_rectangle(x8, y8, x8 + 160, y8 + 16, 0); // 160
                        draw_set_color(c_black);
                        draw_text_transformed(x8 + 2, y8, string_hash_to_newline(string(ship[e]) + " (" + string(ship_use[e]) + "/" + string(ship_max[e]) + ")"), 0.8, 0.8, 0);
                        if (point_and_click([x8, y8, x8 + 160, y8 + 16])) {
                            var onceh;
                            onceh = 0;
                            if (onceh = 0) and(ship_all[e] = 0) {
                                onceh = 1;
                                scr_drop_fiddle(ship_ide[e], true, e, attack);
                            }
                            if (onceh = 0) and(ship_all[e] = 1) {
                                onceh = 1;
                                scr_drop_fiddle(ship_ide[e], false, e, attack);
                            }
                        }
                        y8 += 18;
                        sip += 1;

                        if (y8 >= y2 + 105 + 180) {
                            y8 = y2 + 105;
                            x8 += 168;
                        }
                    }
                    e += 1;
                }
            }

            draw_set_font(fnt_40k_14);
            draw_set_color(c_gray);
            draw_set_alpha(1);

            var hers, influ, poppy;
            hers = p_target.p_heresy[planet_number] + p_target.p_heresy_secret[planet_number];
            influ = p_target.p_influence[planet_number];
            if (p_target.p_large[planet_number] = 1) then poppy = string(p_target.p_population[planet_number]) + "B";
            if (p_target.p_large[planet_number] = 0) then poppy = string(scr_display_number(p_target.p_population[planet_number]));
            draw_text(x2 + 14, y2 + 312, "Heresy: " + string(max(hers, influ[eFACTION.Tau])) + "%");
            draw_text(x2 + 14, y2 + 332, "Population: " + string(poppy));

            if (purge = 2) { // Bombardment select all
                draw_set_alpha(1);
                yar = 2;
                if (all_sel = 1) then yar = 3;
                draw_sprite(spr_creation_check, yar, x2 + 233, y2 + 75);
                yar = 0;
                if (point_and_click([x2 + 233, y2 + 75, x2 + 233 + 32, y2 + 75 + 32])) {
                    var onceh;
                    onceh = 0;
                    var onceh;
                    once = 0;
                    i = 0;
                    if (all_sel = 0) and(onceh = 0) {
                        repeat(60) {
                            i += 1;
                            if (ship[i] != "") and(ship_all[i] = 0) {
                                ship_all[i] = 1;
                                ships_selected += 1;
                            }
                        }
                        onceh = 1;
                        all_sel = 1;
                    }
                    if (all_sel = 1) and(onceh = 0) {
                        repeat(60) {
                            i += 1;
                            if (ship[i] != "") and(ship_all[i] = 1) {
                                ship_all[i] = 0;
                                ships_selected -= 1;
                            }
                        }
                        onceh = 1;
                        all_sel = 0;
                    }
                }
                draw_text_transformed(x2 + 233 + 30, y2 + 75 + 4, string_hash_to_newline("Select All"), 1, 1, 0);
            }

            if (purge >= 3) { // Anything not bombardment, select all
                draw_set_alpha(1);
                yar = 2;
                if (all_sel = 1) then yar = 3;
                draw_sprite(spr_creation_check, yar, x2 + 233, y2 + 75);
                yar = 0;
                if (point_and_click([x2 + 233, y2 + 75, x2 + 233 + 32, y2 + 75 + 32])) {
                    var onceh;
                    onceh = 0;
                    var onceh;
                    once = 0;
                    i = 0;
                    if (all_sel = 0) and(onceh = 0) {
                        repeat(60) {
                            i += 1;
                            if (ship[i] != "") and(ship_all[i] = 0) {
                                ship_all[i] = 1;
                                scr_drop_fiddle(ship_ide[i], true, i, attack);
                            }
                            if (ship_all[500] = 0) then add_ground = 1;
                            if (ship_all[500] = 1) then add_ground = -1;
                        }
                        onceh = 1;
                        all_sel = 1;
                    }
                    if (all_sel = 1) and(onceh = 0) {
                        repeat(60) {
                            i += 1;
                            if (ship[i] != "") and(ship_all[i] = 1) {
                                ship_all[i] = 0;
                                scr_drop_fiddle(ship_ide[i], false, i, attack);
                            }
                            if (ship_all[500] = 0) then add_ground = 1;
                            if (ship_all[500] = 1) then add_ground = -1;
                        }
                        onceh = 1;
                        all_sel = 0;
                    }
                }
                draw_text_transformed(x2 + 233 + 30, y2 + 75 + 4, string_hash_to_newline("Select All"), 1, 1, 0);
            }

            var smin, smax;
            var w;
            w = -1;
            smin = 0;
            smax = 0;

            if (purge = 2) {
                repeat(61) {
                    w += 1;
                    if (ship[w] != "") and(ship_size[w] > 1) {
                        smax += 1;
                        if (ship_all[w] > 0) then smin += 1;
                    }
                }
            }

            if (purge >= 3) {
                repeat(61) {
                    w += 1;
                    if (ship[w] != "") {
                        smax += ship_max[w];
                        if (ship_all[w] > 0) then smin += ship_use[w];
                    }
                }
                if (ship_max[500] > 0) and(ship_all[500] > 0) {
                    smax += ship_max[500];
                    smin += ship_max[500];
                }

                if (add_ground = 1) {
                    master += local_forces.master;
                    honor += local_forces.honor;
                    capts += local_forces.captains;
                    mahreens += l_mahreens;
                    veterans += l_veterans;
                    terminators += l_terminators;
                    dreads += l_dreads;
                    chaplains += l_chaplains;
                    psykers += l_psykers;
                    apothecaries += l_apothecaries;
                    techmarines += l_techmarines;
                    champions += l_champions;
                }
                if (add_ground = -1) {
                    master -= local_forces.master;
                    honor -= local_forces.honor;
                    capts -= local_forces.captains;
                    mahreens -= l_mahreens;
                    veterans -= l_veterans;
                    terminators -= l_terminators;
                    dreads -= l_dreads;
                    chaplains -= l_chaplains;
                    psykers -= l_psykers;
                    apothecaries -= l_apothecaries;
                    techmarines -= l_techmarines;
                    champions -= l_champions;
                }
            }

            draw_text(x2 + 14, y2 + 352, string_hash_to_newline("Selection: " + string(smin) + "/" + string(smax)));

            var sel;
            sel = "";
            if (purge > 2) {
                if (master = 1) then sel += "Chapter Master " + string(obj_ini.master_name) + ", ";
                if (honor > 1) then sel += string(honor) + " " + string(obj_ini.role[100][2]) + "s, ";
                if (honor = 1) then sel += "1 " + string(obj_ini.role[100][2]) + ", ";
                if (capts > 1) then sel += string(capts) + " " + string(obj_ini.role[100][5]) + "s, ";
                if (champions > 1) then sel += string(capts) + " Champions, ";
                if (champions = 1) then sel += "1 Champion, ";
                if (capts = 1) then sel += "1 " + string(obj_ini.role[100][5]) + ", ";
                if (chaplains > 1) then sel += string(chaplains) + " " + string(obj_ini.role[100][14]) + "s, ";
                if (chaplains = 1) then sel += "1 " + string(obj_ini.role[100][14]) + ", ";
                if (apothecaries > 1) then sel += string(apothecaries) + " " + string(obj_ini.role[100][15]) + "s, ";
                if (apothecaries = 1) then sel += "1 " + string(obj_ini.role[100][15]) + ", ";
                if (psykers > 1) then sel += string(psykers) + " Psykers, ";
                if (psykers = 1) then sel += "1 Psyker, ";
                if (techmarines > 1) then sel += string(techmarines) + " " + string(obj_ini.role[100][16]) + "s, ";
                if (techmarines = 1) then sel += "1 " + string(obj_ini.role[100][16]) + ", ";
                if (terminators > 1) then sel += string(terminators) + " " + string(obj_ini.role[100][4]) + "s, ";
                if (terminators = 1) then sel += "1 " + string(obj_ini.role[100][4]) + ", ";
                if (veterans > 1) then sel += string(veterans) + " " + string(obj_ini.role[100][3]) + "s, ";
                if (veterans = 1) then sel += "1 " + string(obj_ini.role[100][3]) + ", ";
                if (mahreens > 1) then sel += string(mahreens) + " Marines, ";
                if (mahreens = 1) then sel += "1 Marine, ";
                if (dreads > 1) then sel += string(dreads) + " " + string(obj_ini.role[100][6]) + ", ";
                if (dreads = 1) then sel += "1 " + string(obj_ini.role[100][6]) + ", ";
                sel = string_delete(sel, string_length(sel) - 1, 2);
            }
            // draw_text_ext(xx+310,yy+234,string(sel),-1,206);

            // Back / Purge buttons

            draw_set_color(c_gray);
            draw_rectangle(852, 556, 921, 579, 0);
            draw_set_color(0);
            draw_text_transformed(x2 + 320, y2 + 358, string_hash_to_newline("BACK"), 1.25, 1.25, 0);
            if (scr_hit(852, 556, 921, 579) = true) {
                draw_set_alpha(0.2);
                draw_rectangle(852, 556, 921, 579, 0);
                draw_set_alpha(1);
                if (scr_click_left()) {
                    purge = 1;
                }
            }

            draw_set_color(c_gray);
            draw_rectangle(954, 556, 1043, 579, 0);
            draw_set_color(0);
            draw_text_transformed(x2 + 423, y2 + 358, "PURGE!", 1.25, 1.25, 0);
            if (scr_hit(954, 556, 1043, 579) = true) {
                draw_set_alpha(0.2);
                draw_rectangle(954, 556, 1043, 579, 0);
                draw_set_alpha(1);
                if (scr_click_left()) {
                    if (purge = 2) {
                        var i;
                        i = 0;
                        repeat(50) {
                            i += 1;
                            if (ship[i] != "") and(ship_all[i] > 0) {
                                if (obj_ini.ship_class[ship_ide[i]] = "Gloriana") then purge_score += 4;
                                if (obj_ini.ship_class[ship_ide[i]] = "Battle Barge") then purge_score += 3;
                                if (obj_ini.ship_class[ship_ide[i]] = "Strike Cruiser") then purge_score += 1;
                            }
                        }
                    }
                    if (purge >= 3) {
                        var i;
                        i = -1;
                        purge_score = 0;
                        repeat(51) {
                            i += 1;
                            if (ship_all[i] != 0) then purge_score += ship_use[i];
                        }
                    }

                    scr_purge_world(p_target, planet_number, purge - 1, purge_score);
                }
            }

            if (scr_hit(x2 + 14, y2 + 351, x2 + 300, y2 + 373) = true) and(string_length(sel) > 0) and(purge > 2) {
                // if (scr_hit(xx+546,yy+551,xx+680,yy+570)=true){
                draw_set_alpha(1);
                draw_set_font(fnt_40k_14);
                draw_set_halign(fa_left);
                draw_set_color(0);
                draw_rectangle(mouse_x + 18, mouse_y + 20, mouse_x + string_width_ext(string_hash_to_newline(sel), -1, 500) + 24, mouse_y + 24 + string_height_ext(string_hash_to_newline(sel), -1, 500), 0);
                draw_set_color(c_gray);
                draw_set_font(fnt_40k_14);
                draw_text_ext(mouse_x + 22, mouse_y + 22, string_hash_to_newline(string(sel)), -1, 500);
                draw_rectangle(mouse_x + 18, mouse_y + 20, mouse_x + string_width_ext(string_hash_to_newline(sel), -1, 500) + 24, mouse_y + 24 + string_height_ext(string_hash_to_newline(sel), -1, 500), 1);
            }
        }
    }
}
}

function collect_local_units(){
		//
	// I think this script is used to count local forces. l_ meaning local.
	//
	ship_use[500]=0;
	ship_max[500]=l_size;
	purge_d=ship_max[500];

	if (purge==1)
	{




	if (sh_target!=-50){
	    
	    max_ships=sh_target.capital_number+sh_target.frigate_number+sh_target.escort_number;
	    
	    
	    if (sh_target.acted>=1) then instance_destroy();
	    
	    var tump;tump=0;
	    
	    var i, q, b;i=-1;q=-1;b=-1;
	    repeat(sh_target.capital_number){
	        b+=1;
	        if (sh_target.capital[b]!=""){
	            i+=1;
	            ship[i]=sh_target.capital[i];
	            
	            ship_use[i]=0;
	            tump=sh_target.capital_num[i];
	            ship_max[i]=obj_ini.ship_carrying[tump];
	            ship_ide[i]=tump;
	            
	            ship_size[i]=3;
	            
	            purge_a+=3;
	            purge_b+=ship_max[i];purge_c+=ship_max[i];purge_d+=ship_max[i];
	        }
	    }
	    q=-1;
	    repeat(sh_target.frigate_number){
	        q+=1;
	        if (sh_target.frigate[q]!=""){
	            i+=1;
	            ship[i]=sh_target.frigate[q];
	            
	            ship_use[i]=0;
	            tump=sh_target.frigate_num[q];
	            ship_max[i]=obj_ini.ship_carrying[tump];
	            ship_ide[i]=tump;
	            
	            ship_size[i]=2;
	            
	            purge_a+=1;
	            purge_b+=ship_max[i];purge_c+=ship_max[i];purge_d+=ship_max[i];
	        }
	    }
	    q=-1;
	    repeat(sh_target.escort_number){
	        q+=1;
	        if (sh_target.escort[q]!="") and (obj_ini.ship_carrying[sh_target.escort_num[q]]>0){
	            i+=1;
	            ship[i]=sh_target.escort[q];
	            
	            ship_use[i]=0;
	            tump=sh_target.escort_num[q];
	            ship_max[i]=obj_ini.ship_carrying[tump];
	            ship_ide[i]=tump;
	            
	            ship_size[i]=1;
	            
	            purge_b+=ship_max[i];purge_c+=ship_max[i];purge_d+=ship_max[i];
	        }
	    }

	}

	if (p_target.p_player[planet_number]>0) then max_ships+=1;
	var pp=planet_number;
	purge_d = p_target.p_type[pp]!="Dead";

	if (has_problem_planet(pp,"succession",p_target)) then purge_d=0

	if (p_target.dispo[pp]<-2000) then purge_d=0;

	if (planet_feature_bool(p_target.p_feature[pp],P_features.Monastery)==1) and (obj_controller.homeworld_rule!=1) then purge_d=0;

	if (p_target.p_type[pp]="Dead") then purge_d=0;


	}
}


