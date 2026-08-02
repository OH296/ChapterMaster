var co = 0, i = 0, o = 0, unit;

for (o = 0; o < array_length(origin.board_co); o++) {
    co = origin.board_co[o];
    i = origin.board_id[o];
    unit = fetch_unit([co, i]);
    if (!is_struct(unit)) {
        continue;
    }
    if (unit.hp() <= -15 && obj_ini.race[co][i] == 1) {
        var seed_lost = 0;
        if (apothecary <= 0) {
            if (unit.IsSpecialist(SPECIALISTS_STANDARD)) {
                obj_fleet.fallen_command += 1;
            } else {
                obj_fleet.fallen += 1;
            }

            if (apothecary_had > 0) {
                if (unit.base_group == "astartes") {
                    seed_lost = unit.recoverable_geneseed();
                }
            }

            // obj_fleet.marines_lost+=1;
            if (unit.role() == obj_ini.role[100][eROLE.CHAPTERMASTER]) {
                obj_controller.alarm[7] = 1;
                if (global.defeat <= 1) {
                    global.defeat = 1;
                }
            }
            if (unit.weapon_one() == "Company Standard" || unit.weapon_two() == "Company Standard") {
                scr_loyalty("Lost Standard", "+");
            }

            scr_kill_unit(co, i);

            if (obj_fleet.capital + obj_fleet.frigate + obj_fleet.escort > 0) {
                obj_controller.gene_seed += seed_lost;
            }
        } else if (apothecary > 0) {
            unit.add_or_sub_health(irandom_range(9, 14));
            apothecary -= 0.5;
        }
    }
}

/* */
/*  */
