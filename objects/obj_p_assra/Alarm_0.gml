var co = 0, i = 0, o = 0, _unit;

for (o = 0; o < array_length(origin.board_co); o++) {
    co = origin.board_co[o];
    i = origin.board_id[o];
    _unit = fetch_unit([co, i]);
    if (!is_struct(_unit)) {
        continue;
    }
    var _recover_gene = obj_fleet.capital + obj_fleet.frigate + obj_fleet.escort > 0;
    if (_unit.hp() <= -15 && _unit.base_group == "astartes") {
        var seed_lost = 0;
        if (apothecary <= 0) {
            if (_unit.IsSpecialist(SPECIALISTS_STANDARD)) {
                obj_fleet.fallen_command += 1;
            } else {
                obj_fleet.fallen += 1;
            }

            if (apothecary_had > 0) {
                if (_unit.base_group == "astartes") {
                    seed_lost = _unit.recoverable_geneseed();
                }
            }

            // obj_fleet.marines_lost+=1;
            if (role_compare(_unit, eROLE.CHAPTERMASTER)) {
                obj_controller.alarm[7] = 1;
                if (global.defeat <= 1) {
                    global.defeat = 1;
                }
            }
            if (_unit.weapon_one() == "Company Standard" || _unit.weapon_two() == "Company Standard") {
                scr_loyalty("Lost Standard", "+");
            }

            _unit.kill(false, _recover_gene);

        } else if (apothecary > 0) {
            _unit.add_or_sub_health(irandom_range(9, 14));
            apothecary -= 0.5;
        }
    }
}

/* */
/*  */
