//All missions that run on a fleet need their own FleetProblem instance
//missions for the most part can only run from predefined points in the code
// to run from each of these points each mission must have a registered function these functions are then called implicitly
//each function follows the format  `__<p_id>_<entry_flag>`
/* the current entry points for the code are
    "per_turn" - runs every end turn to check for certain conditions often contains reactions to actions player has done last turn
        - runs via basic_turn_end

    "init" - runs immediately after problem is created often used to populate initial popup or stack popup for turn end

    "on_arrival" - runs when the fleet arrives at a star, fleet_event_data holds {star}
    "on_load" - runs when units are loaded onto the fleet, fleet_event_data holds {units}
    "on_unload" - runs when units are unloaded from the fleet, fleet_event_data holds {units}
    "on_split" - runs on the original fleet when it splits, fleet_event_data holds {new_fleet}
    "on_merge" - runs on the receiving fleet when another fleet merges into it, fleet_event_data holds {merged_fleet}
    "on_destruction" - runs when the fleet is destroyed, the mission is deleted after this function has run
        - must be triggered BEFORE the fleet instance is destroyed

    "mission_log_entry" - runs to provide a data row for the mission log

- other than these entry points and any other later defined positions mission specific code should not run outside of the FleetProblem container

- to set an entry point up simply register the function as a static e.g
    if i create static __example_per_turn once an "example" problem is registered on a fleet the per turn check will run
    no other code is required

other info
    - the owning fleet must have a `problems = []` array in its create event
    - entry points that receive extra information read it from fleet_event_data, which only exists for the duration of the call
    - set a mission for deletion by setting delete_mission = true; this will delete the mission after the current function
    has finished executing
    - functions prefixed with `__` are only accessible from within the FleetProblem's internal scope
*/

//ANYTIME an exception is caught on a entry point for a mission the mission is prematurely deleted this ensures the player is not unfairly penalised for errors

/// @param {string} _name
/// @param {Real} _timer
/// @param {struct} _data
/// @param {Id.Instance.obj_p_fleet} _fleet
function FleetProblem(_name, _timer, _data, _fleet) : Problem(_name, _timer, _data) constructor{
fleet = _fleet;

per_turn_checks = true;

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

__init();

static __deliver_hunt_trophy_mission_log_entry = function(){
    var _mission = localize("Deliver Trophy Guard");
    var _sys = fleets_next_location();
    var _mission_data = {
        mission: self,
        system: _sys.name,
        system_id: _sys.id,
        target: self,
        important_person: _event.data.trophy_owner,
        person_name: _event.data.delivering_marine,
        planet: 0,
        start_system: _event.data.system,
        time: timer,
    };

    _mission_data.click_left = method(_mission_data, function() {
        set_map_pan_to_loc(system_id);
    });

    _mission_data.hover = method(_mission_data, function() {
        tooltip_draw(localize("You are to have {0} deliver trophy hunted on {1} to the {1} regiments\n\nLeft click to see target fleet intercept system right click to view the trophy bearing marine {0}", [person_name, start_system]));
    });

    _mission_data.click_right = method(_mission_data, function() {
        var _unit = fetch_unit_uid(important_person);
        if (is_struct(_unit)) {
            var _unit_l = [_unit];
            group_selection(_unit_l);
        }
    });
    return _mission_data;   
}
}







