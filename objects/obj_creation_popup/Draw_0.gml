try {
    tooltip = "";
    tooltip2 = "";

    if (type == ePOPUP_TYPE.LIVERYPICK && target_role > 0) {
        assign_picked_liveries();

    } else if (type == ePOPUP_TYPE.EQUIP) {
        LOGGER.info($"{target_role}")
        draw_set_font(fnt_40k_30b);

        var _role_data = obj_creation.player_role_data[target_role];
        var _role_name = _role_data.role;

        role_name_input.tooltip = $"Astartes Role Name/nThe name of this Astartes Role.  The plural form will be ''{_role_name}s''.""
        _role_data.role = role_name_input.draw(_role_name);

        var _spacing = 22;
        var x5 = 594;
        var y5 = 597 - _spacing;

        for (var _slot_count = 0; _slot_count <= 4; _slot_count++) {
            y5 += _spacing;

            draw_set_halign(fa_right);
            draw_set_color(CM_GREEN_COLOR);

            var _title = $"{get_slot_name(target_role , _slot_count)}: ";
            _title = string_hash_to_newline(_title);
            var _title_width = string_width(_title);
            var _title_height = string_height(_title) - 2;

            draw_rectangle(x5, y5, x5 - _title_width, y5 + _title_height, 1);
            draw_text(x5, y5, _title);

            if (scr_hit(x5 - _title_width, y5, x5, y5 + _title_height)) {
                draw_set_color(c_white);
                draw_set_alpha(0.2);
                draw_rectangle(x5, y5, x5 - _title_width, y5 + _title_height, 0);

                if (mouse_button_clicked()) {
                    var _unit_type = target_role ;
                    var _is_invalid = _unit_type == eROLE.DREADNOUGHT && _slot_count > eEQUIPMENT_SLOT.WEAPON_TWO;

                    if (!_is_invalid) {
                        tab = 1;
                        target_gear = _slot_count;
                        item_name = [];
                        scr_get_item_names(item_name, _unit_type, _slot_count, eENGAGEMENT.RANGED, false, false);
                    }
                }
            }

            var _equipment = _role_data[$ global.unit_equip_slots[_slot_count]]

            draw_set_alpha(1);
            draw_set_color(CM_GREEN_COLOR);
            draw_set_halign(fa_left);
            draw_text(600, y5, _equipment);
        }

        var _confirm_gear_button = {
            alpha: 1,
            rects: [],
        };
        _confirm_gear_button.alpha = target_gear > -1 ? 0.5 : 1;
        _confirm_gear_button.rects = draw_unit_buttons([614, 716], "CONFIRM", [1, 1], CM_GREEN_COLOR, undefined, fnt_40k_14b, _confirm_gear_button.alpha);

        if (target_gear == -1 && point_and_click(_confirm_gear_button.rects)) {
            var _role_id = target_role;
            for (var i = 0; i < array_length(possible_custom_roles); i++) {
                var _role_pair = possible_custom_roles[i];
                if (_role_pair[1] == _role_id) {
                    var _p_role_data = obj_creation.player_role_data[_role_id];
                    variable_struct_set(obj_creation.custom_roles, _role_pair[0], _p_role_data);
                    break;
                }
            }

            instance_destroy();
            with (obj_creation) {
                update_creation_roles_radio(2);
            }
        }

        draw_set_halign(fa_left);
        if (scr_hit(434, 591, 594, 709)) {
            tooltip = "Gear";
            tooltip2 = "The equipment this Astartes Role defaults to.  Note that if defaults are set to expensive items the Astartes may instead be provided with more usual equipment.";
        }
    }

    if (target_gear > -1) {
        draw_set_valign(fa_top);
        tab = 1;
        item_name = [];
        scr_get_item_names(
            item_name,
            target_role , // eROLE
            target_gear, // slot
            tab, // eEngagement
            false, // no company standard
            false, // don't limit to available items
        );

        draw_set_color(0);
        draw_rectangle(851, 210, 1168, 749, 0);

        draw_set_color(CM_GREEN_COLOR);
        draw_rectangle(844, 200, 1166, 748, 1);
        draw_rectangle(845, 201, 1165, 747, 1);
        draw_rectangle(846, 202, 1164, 746, 1);

        draw_set_font(fnt_40k_30b);
        var slot_name = get_slot_name(target_role , target_gear);
        draw_text_transformed(862, 215, $"Select {slot_name}", 0.6, 0.6, 0);
        draw_set_font(fnt_40k_14b);

        var x3 = 862;
        var y3 = 245;
        var space = 18;

        for (var h = 0; h < array_length(item_name); h++) {
            draw_set_color(CM_GREEN_COLOR);
            var scale = string_width(item_name[h]) >= 140 ? 0.75 : 1;
            draw_text_transformed(x3, y3, item_name[h], scale, 1, 0);
            y3 += space;

            if (scr_hit(x3, y3 - space, x3 + 143, y3 + 17 - space)) {
                draw_set_color(c_white);
                draw_set_alpha(0.2);
                draw_text_transformed(x3, y3 - space, string_hash_to_newline(item_name[h]), scale, 1, 0);
                draw_set_alpha(1);

                if (mouse_button_clicked()) {
                    var buh = item_name[h] == ITEM_NAME_NONE ? "" : item_name[h];
                    var _player_data = obj_creation.player_role_data[target_role];

                    _player_data[$ global.unit_equip_slots[target_gear]] = buh;
                }
            }
        }

        if (target_gear == eEQUIPMENT_SLOT.WEAPON_ONE || target_gear == eEQUIPMENT_SLOT.WEAPON_TWO) {
            tab = 2;
            item_name = [];
            scr_get_item_names(
                item_name,
                target_role , // eROLE
                target_gear, // slot
                tab, // eEngagement
                false, // no company standard
                false, // don't limit to available items
            );

            x3 = 862 + 146;
            y3 = 245;

            for (var h = 0; h < array_length(item_name); h++) {
                draw_set_color(CM_GREEN_COLOR);
                var scale = string_width(item_name[h]) >= 140 ? 0.75 : 1;
                var _button = draw_unit_buttons([x3, y3], item_name[h], [scale, scale], CM_GREEN_COLOR);
                y3 += space;

                if (point_and_click(_button)) {
                    var buh = item_name[h] == ITEM_NAME_NONE ? "" : item_name[h];
                    var _player_data = obj_creation.player_role_data[target_role];
                    _player_data[$ global.unit_equip_slots[target_gear]] = buh;
                }
            }
            tab = 1;
        }

        if (point_and_click(draw_unit_buttons([980, 716], "CLOSE", [1, 1], CM_GREEN_COLOR,, fnt_40k_14b, 1))) {
            target_gear = -1;
        }
    }

    if ((tooltip != "") && (obj_creation.change_slide <= 0)) {
        draw_set_alpha(1);
        draw_set_font(fnt_40k_14);
        draw_set_halign(fa_left);
        draw_set_color(0);
        draw_rectangle(mouse_x + 18, mouse_y + 20, mouse_x + string_width_ext(string_hash_to_newline(tooltip2), -1, 500) + 24, mouse_y + 44 + string_height_ext(string_hash_to_newline(tooltip2), -1, 500), 0);
        draw_set_color(CM_GREEN_COLOR);
        draw_rectangle(mouse_x + 18, mouse_y + 20, mouse_x + string_width_ext(string_hash_to_newline(tooltip2), -1, 500) + 24, mouse_y + 44 + string_height_ext(string_hash_to_newline(tooltip2), -1, 500), 1);
        draw_set_font(fnt_40k_14b);
        draw_text(mouse_x + 22, mouse_y + 22, string_hash_to_newline(string(tooltip)));
        draw_set_font(fnt_40k_14);
        draw_text_ext(mouse_x + 22, mouse_y + 42, string_hash_to_newline(string(tooltip2)), -1, 500);
    }
} catch (ex) {
    ERROR_HANDLER.handle_exception(ex);
    instance_destroy();
}
