owner = eFACTION.PLAYER;
capital_number = 0;
frigate_number = 0;
escort_number = 0;
selected = 0;
/// @type {Id.Instance.obj_star}
orbiting = noone;
warp_able = true;
ii_check = choose(8, 9, 10, 11, 12);

point_breakdown = single_loc_point_data();
image_xscale = 1.25;
image_yscale = 1.25;

capital = [];
capital_num = [];
capital_sel = [];
capital_uid = [];

frigate = [];
frigate_num = [];
frigate_sel = [];
frigate_uid = [];

escort = [];
escort_num = [];
escort_sel = [];
escort_uid = [];

image_speed = 0;

fix = 2;

capital_health = 100;
frigate_health = 100;
escort_health = 100;

complex_route = [];
just_left = false;

action = "";
action_x = 0;
action_y = 0;
action_spd = 128;
action_eta = 0;
connected = 0;
acted = 0;
hurssy = 0;
hurssy_time = 0;
/// Called from save function to take all object variables and convert them to a json savable format and return it

problems = [];
/// @param {string} _name
/// @param {Real} _timer
/// @param {struct} _data
/// @returns {Struct.FleetProblem}
add_problem = function(_name, _timer, _data = {}){
    var _problem = new FleetProblem(_name, _timer, _data, self);
    if (_problem.delete_mission){
        return undefined;
    }
    array_push(problems, _problem);
    return _problem;
}

serialize = function() {
    var object_fleet = self;

    var save_data = {
        obj: object_get_name(object_index),
        x,
        y,
        point_breakdown: point_breakdown,
    };
    var excluded_from_save = [
        "temp",
        "serialize",
        "deserialize",
        "orbiting",
        "problems",
    ];

    copy_serializable_fields(object_fleet, save_data, excluded_from_save);

    save_data.problems = [];
    for (var i = 0; i < array_length(problems); i++) {
        array_push(save_data.problems, problems[i].save());
    }

    return save_data;
};

deserialize = function(save_data) {
    var exclusions = ["orbiting", "problems"]; // skip automatic setting of certain vars, handle explicitly later

    // Automatic var setting
    var all_names = struct_get_names(save_data);
    var _len = array_length(all_names);
    for (var i = 0; i < _len; i++) {
        var var_name = all_names[i];
        if (array_contains(exclusions, var_name)) {
            continue;
        }
        var loaded_value = struct_get(save_data, var_name);
        try {
            variable_struct_set(self, var_name, loaded_value);
        } catch (e) {
            LOGGER.exception("Deserialization failed", e);
        }
    }

    // Problems, old saves won't have this key
    problems = [];
    if (struct_exists(save_data, "problems")) {
        for (var i = 0; i < array_length(save_data.problems); i++) {
            try {
                // empty p_id stops __init from running, load() then restores the real p_id and timer
                var _problem = new FleetProblem("", 0, {}, self);
                _problem.load(save_data.problems[i]);
                _problem.fleet = self;
                array_push(problems, _problem);
            } catch (e) {
                LOGGER.exception("Fleet problem deserialization failed", e);
            }
        }
    }

    set_player_fleet_image();
};