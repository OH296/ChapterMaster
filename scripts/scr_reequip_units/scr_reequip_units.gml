/// @self Asset.GMObject.obj_controller
function set_up_equip_popup() {
    if (!instance_exists(obj_popup)) {
        var _units_selected_for_change = 0;
        var vih = 0, _unit;
        var company = managing <= 10 ? managing : 10;
        var prev_role;
        var allow = true;

        var _current_equipment = ["","","","",""];

        var _unchangeable_armour = false;
        // Need to make sure that group selected is all the same type
        for (var f = 0; f < array_length(display_unit); f++) {
            // Set different vih depending on _unit type
            if (man_sel[f] != 1) {
                continue;
            }
            if (vih == 0) {
                if (man[f] == "man" && is_struct(display_unit[f])) {
                    _unit = display_unit[f];
                    vih = _unit.is_dreadnought() ? 6 : 1;
                    if (vih == 6) {
                        _unchangeable_armour = true;
                    }
                } else if (man[f] == "vehicle") {
                    if (ma_role[f] == "Land Raider") {
                        vih = 50;
                    } else if (ma_role[f] == "Rhino") {
                        vih = 51;
                    } else if (ma_role[f] == "Predator") {
                        vih = 52;
                    } else if (ma_role[f] == "Land Speeder") {
                        vih = 53;
                    } else if (ma_role[f] == "Whirlwind") {
                        vih = 54;
                    }
                    prev_role = ma_role[f];
                }
            } else {
                if (vih == 1 || vih == 6) {
                    if (man[f] == "vehicle") {
                        allow = false;
                        break;
                    } else if (man[f] == "man" && is_struct(display_unit[f])) {
                        _unit = display_unit[f];
                        var _is_dread = _unit.is_dreadnought();
                        if (_is_dread && vih == 1) {
                            allow = false;
                            break;
                        } else if (!_is_dread && vih == 6) {
                            allow = false;
                            break;
                        }
                    }
                } else if (vih >= 50) {
                    if (man[f] == "man") {
                        allow = false;
                        break;
                    } else if (man[f] == "vehicle") {
                        if (prev_role != ma_role[f]) {
                            allow = false;
                            break;
                        }
                    }
                }
            }

            if (vih > 0) {
                _units_selected_for_change += 1;
                var _unit_equipment = display_unit[f].unit_equipment_data();

                for (var i = 0; i < STANDARD_EQUIP_SLOT_COUNT; i++){
                    var _item_name = _unit_equipment.item_names[i];

                    var _no_item = _item_name == "";

                    if (_no_item && _current_equipment[i] == "" ){
                        continue;
                    }

                    var _is_assortment = _current_equipment[i] == "Assortment";

                    if (_is_assortment){
                        continue;
                    }

                    if (_current_equipment[i] == ""){
                        _current_equipment[i] = _item_name;
                    } else if (_current_equipment[i] != _item_name){
                        _current_equipment[i] = "Assortment"
                    }
                }
            }
        }

        if (vih > 0 && man_size > 0 && allow) {
            var pip = instance_create(0, 0, obj_popup);
            pip.type = ePOPUP_TYPE.EQUIP;
            pip.current_equipment = _current_equipment
            pip.needed_equipment = array_create(5, "");
            pip.equipment_found_and_valid = array_create(5,false);
            pip.company = managing;
            pip.unit_count = _units_selected_for_change;

            //Forwards vih selection to the vehicle_equipment variable used in mouse_50 obj_popup and weapons_equip script
            pip.vehicle_equipment = vih;
            with (pip) {
                equipment_area = -1;
                cancel_button = new UnitButtonObject({
                    x1: 1061,
                    y1: 591,
                    style: "pixel",
                    label: "Cancel",
                });
                equip_button = new UnitButtonObject({
                    x1: 1450,
                    y1: 591,
                    style: "pixel",
                    label: "Equip",
                });

                main_slate = new DataSlate({
                    style: "decorated",
                    XX: 1006,
                    YY: 143,
                    set_width: true,
                    width: 571,
                    height: 450,
                });

                var _quality_options = [
                    {
                        str1: "Standard",
                        font: fnt_40k_14b,
                        val: 0,
                    },
                    {
                        str1: "Master Crafted",
                        font: fnt_40k_14b,
                        val: 1,
                    },
                ];
                quality_radio = new RadioSet(_quality_options, "", {
                    max_width: 500,
                    x1: 1040,
                    y1: 318,
                });

                range_melee_radio = new RadioSet([
                    {
                        str1: "Ranged",
                        font: fnt_40k_14b,
                        val: eENGAGEMENT.RANGED,
                    },
                    {
                        str1: "Melee",
                        font: fnt_40k_14b,
                        val: eENGAGEMENT.MELEE,
                    },
                ], "", {
                    max_width: 500,
                    x1: 1040,
                    y1: 343,
                });

                weapon1_select = new UnitButtonObject({
                    x1: 1300,
                    y1: 215,
                    label: "",
                    font: fnt_40k_12,
                });
                weapon2_select = new UnitButtonObject({
                    x1: 1300,
                    y1: 235,
                    label: "",
                    font: fnt_40k_12,
                });
                armour_select = new UnitButtonObject({
                    x1: 1300,
                    y1: 255,
                    label: "",
                    font: fnt_40k_12,
                });
                if (_unchangeable_armour) {
                    armour_select.inactive_col = CM_RED_COLOR;
                    armour_select.tooltip = "One or more Marine has Dreadnought armour and cannot be changed";
                    armour_select.active = false;
                }
                gear_select = new UnitButtonObject({
                    x1: 1300,
                    y1: 275,
                    label: "",
                    font: fnt_40k_12,
                });
                mobility_select = new UnitButtonObject({
                    x1: 1300,
                    y1: 295,
                    label: "",
                    font: fnt_40k_12,
                });
                selectors = [weapon1_select , weapon2_select, armour_select, gear_select, mobility_select];
            }
        }
    }
}

/// @self Asset.GMObject.obj_popup
function reload_items() {
    item_name = [];
    scr_get_item_names(
        item_name,
        vehicle_equipment, // eROLE
        equipment_area, // slot
        range_melee_radio.selection_val("val"),
        false, // include company standard
        true, // limit to available equipment
        quality_radio.selection_val("val"),
    );
}

/// @self Asset.GMObject.obj_popup
function draw_popup_equip() {
    main_slate.draw_with_dimensions();
    draw_set_color(CM_GREEN_COLOR);
    draw_text(1302, 150, "Change Equipment");

    draw_set_font(fnt_40k_12);
    var comp = "";
    if (company <= 10 && company > 0) {
        comp = int_to_roman(company);
    } else if (company > 10) {
        comp = "HQ";
    }

    if (vehicle_equipment < 6) {
        draw_text(1292, 175, $"{comp} Company, {unit_count} Marines");
    } else if (vehicle_equipment == 6) {
        draw_text(1292, 175, $"{comp} Company, {unit_count} Dreadnoughts");
    } else {
        draw_text(1292, 175, $"{comp} Company, {unit_count} Vehicles");
    }

    draw_set_halign(fa_left);
    draw_set_color(CM_GREEN_COLOR);

    var show_name = "";
    // Need to not show the artifact tags here somehow

    draw_text_outline(1010, 195, "Before");

    for (var i = 0; i < STANDARD_EQUIP_SLOT_COUNT; i++){
        var _current = current_equipment[i]
        if (_current == "") {
            _current = ITEM_NAME_NONE;    
        }
        draw_text(1014, 215 + (i * 20), _current);
    }

    draw_text_outline(1296, 195, "After");

    for (var i = 0; i < STANDARD_EQUIP_SLOT_COUNT; i++){
        var _selector = selectors[i];
        var _needed = needed_equipment[i];
        _needed = _needed != "" ? _needed : ITEM_NAME_NONE;
        var _colour = equipment_found_and_valid[i] ?  CM_GREEN_COLOR : CM_RED_COLOR;
        _selector.update({label: _needed, color: _colour});
    }

    draw_set_color(CM_GREEN_COLOR);

    var _area_change = false;
    for (var i = 0; i < STANDARD_EQUIP_SLOT_COUNT; i++){
        var _button = selectors[i];
        if (_button.draw(equipment_area != i)) {
            equipment_area = i;
            _area_change = true;
        }
        if (equipment_area == i) {
            draw_text(1292, 195 + (20 * (i + 1)), "->");
        }
    }

    draw_set_alpha(1);

    if (equipment_area != -1) {
        var check = " ";
        var mct = master_crafted == 1 ? 0.7 : 1;
        var column = 0;
        var row = 0;
        var item_string;
        var box = [];
        var box_x;
        var box_y;
        var top = -1;

        for (var o = 0; o < array_length(item_name); o++) {
            box_x = 1016 + (row * 154);
            box_y = 380 + (column * 20);
            box = [
                box_x,
                box_y,
                box_x + 144,
                box_y + 20,
            ];
            check = needed_equipment[equipment_area] == item_name[o] ? "x" : " ";
            item_string = $"[{check}] {item_name[o]}";
            draw_text_transformed(box_x, box_y, item_string, mct, 1, 0);
            if (scr_hit(box)) {
                tooltip_draw(gen_item_tooltip(item_name[o]));
                if (mouse_button_clicked()) {
                    top = o;
                }
            }
            column++;
            if (column > 7) {
                column = 0;
                row++;
            }
        }

        if (top != -1) {
            warning = "";
            needed_equipment[equipment_area] = item_name[top]
        }

        equipment_found_and_valid[equipment_area] = needed_equipment[equipment_area] == ITEM_NAME_NONE || needed_equipment[equipment_area] == "";

        var _equip_data = new UnitEquipment(needed_equipment);
        var _results = _equip_data.check_set_is_equipable();

        equipment_found_and_valid = _results.equipment_found_and_valid;
        warning = _results.warning;

    }

    //draw_set_halign(fa_center);
    if ((equipment_area == eEQUIPMENT_SLOT.WEAPON_ONE) || (equipment_area == eEQUIPMENT_SLOT.WEAPON_TWO)) {
        range_melee_radio.draw();
    }

    if (equipment_area != -1) {
        quality_radio.draw();
    }

    if (quality_radio.changed || range_melee_radio.changed || _area_change) {
        reload_items();
    }

    draw_set_color(255);
    draw_set_halign(fa_center);
    draw_text(1292, 570, warning);

    if (cancel_button.draw()) {
        instance_destroy();
    }

    var _valid = true;
        for (var i = 0; i < STANDARD_EQUIP_SLOT_COUNT; i++){
            if (!equipment_found_and_valid[i]){
                _valid = false;
                break;
            }
        }

    if (equip_button.draw(_valid)) {
        reequip_selection();
    }
}

/// @self Asset.GMObject.obj_popup
function reequip_selection() {
    for (var i = 0; i < STANDARD_EQUIP_SLOT_COUNT; i++){
        if (needed_equipment[i] == ITEM_NAME_NONE){
            needed_equipment[i] = "";
        }
    }

    for (var i = 0; i < array_length(obj_controller.display_unit); i++) {
        var endcount = 0;
        if (obj_controller.man[i] == "" || !obj_controller.man_sel[i] || vehicle_equipment == -1){
            continue;
        }
        var check = 0, scout_check = 0;
        var unit = obj_controller.display_unit[i];
        var standard = master_crafted == 1 ? "master_crafted" : "any";
        if (is_struct(unit)) {
            unit.alter_unit_equipment(needed_equipment ,true, true, standard);
            update_man_manage_array(i);
            continue;
        } else if (is_array(unit)) {
            var _n_wep1 = needed_equipment[eEQUIPMENT_SLOT.WEAPON_ONE];
            var _n_wep2 = needed_equipment[eEQUIPMENT_SLOT.WEAPON_TWO];
            var _n_armour = needed_equipment[eEQUIPMENT_SLOT.ARMOUR];
            var _n_gear = needed_equipment[eEQUIPMENT_SLOT.GEAR];
            var _n_mobi = needed_equipment[eEQUIPMENT_SLOT.MOBILITY];
            // NOPE
            if ((check == 0) && (_n_armour != obj_controller.ma_armour[i]) && (_n_armour != "Assortment") && (vehicle_equipment != 1) && (vehicle_equipment != 6)) {
                //vehicle wep3
                if (obj_controller.ma_armour[i] != "") {
                    scr_add_item(obj_controller.ma_armour[i], 1);
                }
                obj_controller.ma_armour[i] = "";
                obj_ini.veh_wep3[unit[0]][unit[1]] = "";

                if ((_n_armour != ITEM_NAME_NONE) && (_n_armour != "")) {
                    obj_controller.ma_armour[i] = _n_armour;
                    obj_ini.veh_wep3[unit[0]][unit[1]] = _n_armour;
                    if (_n_armour != "") {
                        scr_add_item(_n_armour, -1);
                    }
                }
            }
            check = 0;
            if ((_n_wep1 == obj_controller.ma_wep1[i]) || (_n_wep1 == "Assortment")) {
                check = 1;
            }

            if (check == 0) {
                if ((_n_wep1 != obj_controller.ma_wep1[i]) && (_n_wep1 != "Assortment") && (vehicle_equipment != 1) && (vehicle_equipment != 6)) {
                    // vehicle wep1
                    if ((obj_controller.ma_wep1[i] != "") && (obj_controller.ma_wep1[i] != _n_wep1)) {
                        scr_add_item(obj_controller.ma_wep1[i], 1);
                        obj_controller.ma_wep1[i] = "";
                        obj_ini.veh_wep1[unit[0]][unit[1]] = "";
                    }
                    if (_n_wep1 != "") {
                        scr_add_item(_n_wep1, -1);
                        obj_controller.ma_wep1[i] = _n_wep1;
                        obj_ini.veh_wep1[unit[0]][unit[1]] = _n_wep1;
                    }
                }
            }
            // End swap weapon1

            check = 0;

            if ((_n_wep2 == obj_controller.ma_wep2[i]) || (_n_wep2 == "Assortment")) {
                check = 1;
            }

            if ((check == 0) && (_n_wep2 != obj_controller.ma_wep2[i]) && (_n_wep2 != "Assortment") && (vehicle_equipment != 1) && (vehicle_equipment != 6)) {
                // vehicle wep2
                if ((obj_controller.ma_wep2[i] != "") && (obj_controller.ma_wep2[i] != _n_wep2)) {
                    scr_add_item(obj_controller.ma_wep2[i], 1);
                    obj_controller.ma_wep2[i] = "";
                    obj_ini.veh_wep2[unit[0]][unit[1]] = "";
                }
                if (_n_wep2 != "") {
                    scr_add_item(_n_wep2, -1);
                    obj_controller.ma_wep2[i] = _n_wep2;
                    obj_ini.veh_wep2[unit[0]][unit[1]] = _n_wep2;
                }
            }
            // End swap weapon2

            check = 0;

            if ((check == 0) && (_n_gear != obj_controller.ma_gear[i]) && (_n_gear != "Assortment") && (vehicle_equipment != 1) && (vehicle_equipment != 6)) {
                //vehicle upgrade item
                if (obj_controller.ma_gear[i] != "") {
                    scr_add_item(obj_controller.ma_gear[i], 1);
                }
                obj_controller.ma_gear[i] = "";
                obj_ini.veh_upgrade[unit[0]][unit[1]] = "";
                if ((_n_gear != ITEM_NAME_NONE) && (_n_gear != "")) {
                    obj_controller.ma_gear[i] = _n_gear;
                    obj_ini.veh_upgrade[unit[0]][unit[1]] = _n_gear;
                }
                if (_n_gear != "") {
                    scr_add_item(_n_gear, -1);
                }
            }
            // End gear and upgrade

            check = 0;
            if ((check == 0) && (_n_mobi != obj_controller.ma_mobi[i]) && (_n_mobi != "Assortment") && (vehicle_equipment != 1) && (vehicle_equipment != 6)) {
                //vehicle accessory item
                if (obj_controller.ma_mobi[i] != "") {
                    scr_add_item(obj_controller.ma_mobi[i], 1);
                }
                obj_controller.ma_mobi[i] = "";
                obj_ini.veh_acc[unit[0]][unit[1]] = "";
                obj_controller.ma_mobi[i] = _n_mobi;
                obj_ini.veh_acc[unit[0]][unit[1]] = _n_mobi;
                if (_n_mobi != "") {
                    scr_add_item(_n_mobi, -1);
                }
            }
            // End mobility and accessory
        }
    } // End repeat

    obj_controller.cooldown = 10;
    instance_destroy();
    exit;
}
