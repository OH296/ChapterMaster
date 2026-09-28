//All missions that run on a fleet need their own FleetProblem instance
//missions for the most part can only run from predefined points in the code
// to run from each of these points each mission must have a registered function these functions are then called implicitly
//each function follows the format  `__<p_id>_<entry_flag>`
/* the current entry points for the code are
    "per_turn" - runs every end turn to check for certain conditions often contains reactions to actions player has done last turn
        - runs via basic_turn_end

    "init" - runs immediately after problem is created often used to populate initial popup or stack popup for turn end

    "on_arrival" - runs when the fleet arrives at a star, event_data holds {star}
    "on_load" - runs when units are loaded onto the fleet, event_data holds {units}
    "on_unload" - runs when units are unloaded from the fleet, event_data holds {units}
    "on_split" - runs on the original fleet when it splits, event_data holds {new_fleet}
    "on_merge" - runs on the receiving fleet when another fleet merges into it, event_data holds {merged_fleet}
    "on_destruction" - runs when the fleet is destroyed, the mission is deleted after this function has run
        - must be triggered BEFORE the fleet instance is destroyed

- other than these entry points and any other later defined positions mission specific code should not run outside of the FleetProblem container

- to set an entry point up simply register the function as a static e.g
    if i create static __example_per_turn once an "example" problem is registered on a fleet the per turn check will run
    no other code is required

other info
    - the owning fleet must have a `problems = []` array in its create event
    - entry points that receive extra information read it from event_data, which only exists for the duration of the call
    - set a mission for deletion by setting delete_mission = true; this will delete the mission after the current function
    has finished executing
    - functions prefixed with `__` are only accessible from within the FleetProblem's internal scope
*/

//ANYTIME an exception is caught on a entry point for a mission the mission is prematurely deleted this ensures the player is not unfairly penalised for errors

/// @param {string} _name
/// @param {Real} _timer
/// @param {struct} _data
/// @param {Id.Instance.obj_p_fleet} _fleet
function FleetProblem(_name, _timer, _data, _fleet) constructor{
timer = _timer;
uid = scr_uuid_generate();
p_id = _name;
data = _data;
fleet = _fleet;
delete_mission = false;

static __refresh_data = function(){
    if (!instance_exists(fleet)){
        delete_mission = true;
    }
}

stage_id = "";
if (struct_exists(data, "stage")){
    stage_id = data.stage;
}

remove = false;
per_turn_checks = true;

static has_data = function(key){
    return struct_exists(data, key);
}

static save = function(){
    var _save_copy = variable_clone(self);
    struct_remove(_save_copy, "fleet");
    return _save_copy;
}

//the owning fleet must re-attach itself after loading (problem.fleet = self)
static load = function(data){
    move_data_to_current_scope(data);
}

static description = function(){
    var _n = mission_name_key(p_id);
    _n = _n == "" ? p_id : _n;
    return _n;
}

//requires the completion and required_months flag to be in the data struct
static __increment_mission_completion =  function() {
    if (!struct_exists(data, "completion")) {
        data.completion = 0;
    }
    data.completion++;
    if (!struct_exists(data, "required_months") || data.required_months <= 0) {
        LOGGER.error("Invalid required_months in mission_data");
        return 0;
    }
    return (data.completion / data.required_months) * 100;
}

static __popup_delete = function(){
    with(obj_popup){
        popup_default_close();
    }
    __check_delete();
}

static __check_delete = function(){
    if (timer == -1 || (delete_mission)){
        if (!instance_exists(fleet)){
            exit;
        }
        var _prob = -1;
        for (var i = 0; i < array_length(fleet.problems); i++){
            if (fleet.problems[i] == self){
                _prob = i;
            }
        }
        if (_prob > -1){
            array_delete(fleet.problems, _prob, 1);
        }
    }
}

static __handle_triggered_mission_func = function(func){
    if (!is_undefined(func)){
        __refresh_data();
        try {
            func();
        } catch (_exception) {
            delete_mission = true;
            ERROR_HANDLER.handle_exception(_exception);
        }
    }
    __check_delete();
    obj_controller.location_viewer.update_mission_log();
}

static find_func_ref = function(trigger_string){
    var _func_string = "__" + p_id + "_" + trigger_string;
    return _func_string;
}

static has_func = function(trigger_string){
    var _func_string = find_func_ref(trigger_string);
    return struct_exists(self,_func_string);
}

static find_func = function(trigger_string){
    var _func_string = find_func_ref(trigger_string);
    if (struct_exists(self,_func_string)){
        return self[$ _func_string]
    }
    return undefined;
}

//runs the entry point with event_data available for the duration of the call
static __trigger_with_event = function(trigger_string, _event_data){
    var _func = find_func(trigger_string);
    if (is_undefined(_func)){
        exit;
    }
    event_data = _event_data;
    __handle_triggered_mission_func(_func);
    struct_remove(self, "event_data");
}

static basic_turn_end = function(){
    timer--;
    if ((timer > -1) && per_turn_checks) {
        var _func = find_func("per_turn");
        __handle_triggered_mission_func(_func);
    }
}

/// @param {Id.Instance.obj_star} star
static on_arrival = function(star){
    __trigger_with_event("on_arrival", {star});
}

/// @param {array} units
static on_load = function(units){
    __trigger_with_event("on_load", {units});
}

/// @param {array} units
static on_unload = function(units){
    __trigger_with_event("on_unload", {units});
}

/// @param {Id.Instance.obj_p_fleet} new_fleet
static on_split = function(new_fleet){
    __trigger_with_event("on_split", {new_fleet});
}

/// @param {Id.Instance.obj_p_fleet} merged_fleet
static on_merge = function(merged_fleet){
    __trigger_with_event("on_merge", {merged_fleet});
}

//call this before the fleet instance is destroyed
static on_destruction = function(){
    __trigger_with_event("on_destruction", {});
    delete_mission = true;
    __check_delete();
}

static __init = function(){
    if (p_id == ""){
        exit;
    }
    var _func = find_func("init");
    if (!is_undefined(_func)){
        __handle_triggered_mission_func(_func);
    }
}
__init();
}