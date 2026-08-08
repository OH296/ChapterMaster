type = ePOPUP_TYPE.LIVERYPICK;
target_gear = -1;
tab = 1;
badname = 0;

rows = 0;

picker = new ColourPicker(20, 550, 350);
picker.disable_textures = true;
start_colour = -1;
col_shift = false;
bulk_buttons = [];

tooltip = "";
tooltip2 = "";
item_name = [];
role_names_all = "";

type_names = {
    "1": "Primary Color",
    "2": "Secondary Color",
    "3": "Pauldron 1 Color",
    "4": "Pauldron 2 Color",
    "5": "Trim Color",
    "6": "Lens Color",
    "7": "Weapon Color",
    "sgt_helm_primary": "Sgt Helm Primary",
    "sgt_helm_secondary": "Sgt Helm Secondary",
};

type_fields = [
    "",
    "main_color",
    "secondary_color",
    "left_pauldron",
    "right_pauldron",
    "main_trim",
    "lens_color",
    "weapon_color",
];

possible_custom_roles = [
    [
        "chapter_master",
        eROLE.CHAPTERMASTER,
    ],
    [
        "honour_guard",
        eROLE.HONOURGUARD,
    ],
    [
        "veteran",
        eROLE.VETERAN,
    ],
    [
        "terminator",
        eROLE.TERMINATOR,
    ],
    [
        "captain",
        eROLE.CAPTAIN,
    ],
    [
        "dreadnought",
        eROLE.DREADNOUGHT,
    ],
    [
        "champion",
        eROLE.CHAMPION,
    ],
    [
        "tactical",
        eROLE.TACTICAL,
    ],
    [
        "devastator",
        eROLE.DEVASTATOR,
    ],
    [
        "assault",
        eROLE.ASSAULT,
    ],
    [
        "ancient",
        eROLE.ANCIENT,
    ],
    [
        "scout",
        eROLE.SCOUT,
    ],
    [
        "chaplain",
        eROLE.CHAPLAIN,
    ],
    [
        "apothecary",
        eROLE.APOTHECARY,
    ],
    [
        "techmarine",
        eROLE.TECHMARINE,
    ],
    [
        "librarian",
        eROLE.LIBRARIAN,
    ],
    [
        "sergeant",
        eROLE.SERGEANT,
    ],
    [
        "veteran_sergeant",
        eROLE.VETERANSERGEANT,
    ],
];


if (type == ePOPUP_TYPE.LIVERYPICK){
    assign_picked_liveries = function(){
        var _colour_area_chosen = colour_area != "";
        draw_set_font(fnt_40k_30b);
        var _type_key = string(target_role);
        var _colour_type = struct_exists(type_names, _type_key) ? type_names[$ _type_key] : "";

        picker.title = _colour_type;

        var _action = picker.draw();
        if (_action == "destroy") {
            instance_destroy();
            exit;
        } else {
            var _col = picker.chosen;
            if (start_colour == -1) {
                if (!_colour_area_chosen && target_role >= 1 && target_role <= 7) {
                    start_colour = variable_instance_get(obj_creation, type_fields[target_role]);
                } else if (_colour_area_chosen) {
                    var role_data = obj_creation.complex_livery_data[$ target_role];
                    if (is_struct(role_data) && struct_exists(role_data, colour_area)) {
                        start_colour = role_data[$ colour_area];
                    }
                }
            }

            if (is_array(_col)) {
                if (_colour_area_chosen) {
                    obj_creation.complex_livery_data[$ target_role][$ colour_area] = _col;
                }
            } else {
                if (_col == -1) {
                    _col = start_colour;
                }

                if (!_colour_area_chosen && target_role >= 1 && target_role <= 7) {
                    variable_instance_set(obj_creation, type_fields[target_role], _col);
                }

                with (obj_creation) {
                    bulk_selection_buttons_setup();
                }

                if (_colour_area_chosen) {
                    obj_creation.complex_livery_data[$ target_role][$ colour_area] = _col;
                    with (obj_creation) {
                        set_complex_livery_buttons();
                    }
                }
            }
        }

    }
} else if (type == ePOPUP_TYPE.EQUIP) {
    role_name_input = new TextBarArea(444, 550, 380, true);

    var _blocked_names = []

if (!is_string(type)) {
    var z = (type >= 100) ? type - 100 : type;

    if (type >= 100) {
        for (var i = 1; i <= 13; i++) {
            var idd = 0;
            if (i == 1) {
                idd = 15;
            }
            if (i == 2) {
                idd = 14;
            }
            if (i == 3) {
                idd = 17;
            }
            if (i == 4) {
                idd = 16;
            }
            if (i == 5) {
                idd = 5;
            }
            if (i == 6) {
                idd = 2;
            }
            if (i == 7) {
                idd = 4;
            }
            if (i == 8) {
                idd = 3;
            }
            if (i == 9) {
                idd = 6;
            }
            if (i == 10) {
                idd = 8;
            }
            if (i == 11) {
                idd = 9;
            }
            if (i == 12) {
                idd = 10;
            }
            if (i == 13) {
                idd = 12;
            }
            role_names_all += string(obj_creation.player_role_data[idd].role) + "|";
        }

        role_names_all += "Chapter Master|";
        role_names_all += "Master of Sanctity|";
        role_names_all += "Master of the Apothecarion|";
        role_names_all += "Forge Master|";

        var _r_name = obj_creation.player_role_data[z].role;
        if (_r_name != "") {
            badname = string_count(_r_name, role_names_all) > 1;
        }
    }
}

}

