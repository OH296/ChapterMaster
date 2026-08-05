/// @self Asset.GMObject.obj_controller
function scr_kill_unit(company, unit_slot) {
    try {
        var _unit = fetch_unit([company, unit_slot]);
        if (!is_struct(_unit)){
            LOGGER.debug($"company: {company}, unit_slot: {unit_slot}");
            return;
        }
        if (_unit.role() == "Forge Master") {
            array_push(obj_ini.previous_forge_masters, _unit.name());
        }

        if (role_compare(_unit, eROLE.CHAPTERMASTER)) {
            tek = "c";
            alarm[7] = 5;
            global.defeat = 1;
        }

        if (is_struct(_unit)) {
            if (_unit.weapon_one() == "Company Standard" || _unit.weapon_two() == "Company Standard") {
                scr_loyalty("Lost Standard", "+");
            }
            _unit.remove_from_squad();

            // Drop equipped artifacts at the _unit's location before the slots are wiped.
            var _equipped = _unit.equipped_artifacts();
            for (var _e = 0; _e < array_length(_equipped); _e++) {
                var _art = fetch_artifact(_equipped[_e]);
                if (is_struct(_art)) {
                    _art.clear_bearer();
                }
            }
        }

        array_delete(obj_ini.TTRPG[company], unit_slot, 1);
    } catch (ex) {
        LOGGER.error($"company: {company}, unit_slot: {unit_slot}");
        ERROR_HANDLER.handle_exception(ex);
    }
}

function scr_wipe_unit(company, unit_slot) {
    array_set(obj_ini.TTRPG[company], unit_slot, undefined);
}

function kill_and_recover(company, unit_slot, equipment = true, gene_seed_collect = true) {
    var _unit = obj_ini.TTRPG[company][unit_slot];
    if (equipment) {
        var strip = {
            "wep1": "",
            "wep2": "",
            "mobi": "",
            "armour": "",
            "gear": "",
        };
        _unit.alter_equipment(strip, false, true);
    }

    var _is_astartes = _unit.base_group == "astartes";
    if (gene_seed_collect && _is_astartes) {

        obj_controller.gene_seed += _unit.recoverable_geneseed();
    }
    if (_is_astartes) {
        if (_unit.IsSpecialist()) {
            obj_controller.command -= 1;
        } else {
            obj_controller.marines -= 1;
        }
    }
    scr_kill_unit(company, unit_slot);
}
