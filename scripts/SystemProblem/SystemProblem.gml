/// @param {sring} name
/// @param {struct} data
function SystemProblem(_name, _system, _data = {}) constructor{
timer = -1;
f_type = eP_FEATURES.MISSION;
p_id = _name;
data = _data;
stage_id = "";
system = _system;
zero_timer_checks = true;
per_turn_checks = true;
delete_mission = false;
members = [];
if (struct_exists(data, "stage")){
    stage_id = data.stage;
}
if (struct_exists(data, "members")){
    members = data.members;
}

static description = function(){
    var _n = mission_name_key(p_id);
    _n = _n == "" ? p_id : _n;
    return _n;
}


static __handle_triggered_mission_func = function(func){
    if (!is_undefined(func)){
        try {
            func();
        } catch (_exception) {
            ERROR_HANDLER.handle_exception(_exception);
        }
    }
    if (timer == -1 || (delete_mission)){
        var _prob = -1;
        for (var i = 0; i < array_length(system.problems); i++){
            if (system.problems[i] == self){
                _prob = i;
            }
        }
        if (_prob > -1){
            array_delete(system.problems, _prob,1);
        }
    }
}

static basic_turn_end = function(){
	if (system.storm <= 0){
		timer--;
	}
	if ((timer > -1) && per_turn_checks) {
		var _func = find_func("per_turn");
        __handle_triggered_mission_func(_func);
	}
	if ((timer == 0) && zero_timer_checks && !delete_mission) {
		var _func = find_func("resolve");
		__handle_triggered_mission_func(_func);
	}
}

static find_func_ref = function(trigger_string){
    var _func_string = "__" + p_id + "_" + trigger_string;
    if (stage_id != ""){
        _func_string += "S" + stage_id;
    }
    return _func_string;
}
static find_func = function(trigger_string){
    var _func_string = find_func_ref(trigger_string);
    if (struct_exists(self,_func_string)){
        return self[$ _func_string]
    }
    return undefined;
}

static mark = function(colour){
    with (system){
        new_star_event_marker(colour)
    }
}

static __init = function(){
    var _func = find_func("init");
    if (!is_undefined(_func)){
        __handle_triggered_mission_func(_func);
    }  
}

__init();

static __great_crusade_init = function(){
    //TODO decide the target/purpose of the crusade to create more variety and to help with post crusade rewards
    var _nearest_player_fleet = data.nearest_player_fleet;
    var _travel_leeway = 10;
    if (_nearest_player_fleet.action == "move") {
        _travel_leeway += _nearest_player_fleet.action_eta;
    }
    timer = get_viable_travel_time(_travel_leeway, _nearest_player_fleet.x, _nearest_player_fleet.y, system.x, system.y, _nearest_player_fleet, false);
    scr_popup("Crusade", $"Fellow Astartes legions are preparing to embark on a Crusade to a nearby sector.  Your forces are expected at {system.name}; {timer} months from now your ships there shall begin their journey.", "crusade", "");
    mark("green")
    scr_event_log("", $"A Crusade is called; our forces are expected at {system.name} in {timer} months.", system.name);
}

static __great_crusade_resolve = function() {
    var _player_fleet = system.get_orbiting_player_fleet();

    if (_player_fleet != noone) {
        _player_fleet.add_problem("great_crusade",infinte, {});

        scr_alert("green", "crusade", "Fleet embarks upon Crusade.", system.x, system.y);
        scr_event_log("", "Fleet embarks upon Crusade.");
    } else {
        // hit loyalty here
        alter_dispositions([[eFACTION.INQUISITION, -10], [eFACTION.IMPERIUM, -5]]);
        var _string = $"No ships designated for Crusade.";
        if (obj_controller.penitent == 1) {
            obj_controller.penitent_current = 0;
            _string += "Your penitence crusade has been lengthened for your failings";
        }

        scr_alert("red", "crusade", _string, system.x, system.y);
        scr_loyalty("Refusing to Crusade", "+");
        scr_event_log("red", "No ships designated for Crusade.");
    }
    delete_mission = true;
}

}