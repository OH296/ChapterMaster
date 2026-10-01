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
/// @param {Id.Instance.obj_en_fleet} _fleet
function AiFleetProblem(_name, _timer = -1, _data ={}, _fleet = noone) : FleetProblem(_name, _timer, _data, _fleet) constructor{
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

static __radical_inquisitor_init = function(){
    if (!instance_exists(obj_popup)){
        scr_popup("","","","");
    }
    obj_popup.title = "Inquisition Mission Accepted";
    obj_popup.text = $"{global.chapter_name} will intercept the radical Inquisitor {data.inquisitor_name} at {data.target_name}, expected within {timer} months.";
}

static __radical_inquisitor_mission_log_entry = function(){
    var _mission = "Intercept Radical Inquisitor";
    var _sys = fleets_next_location();
    var _mission_data = {
        mission: self,
        system: data.target_name,
        system_id: find_star_by_name(data.target_name),
        time: timer,
    };

    _mission_data.click_left = method(_mission_data, function() {
        set_map_pan_to_loc(mission.fleet);
    });

    _mission_data.hover = method(_mission_data, function() {
        tooltip_draw($"intercept the radical Inquisitor {mission.data.inquisitor_name} at {mission.data.target_name}, expected within {mission.timer} months.");
    });
}

static __radical_inquisitor_on_arrival = function(){
    if (!orbiting.has_orbiting_player_fleet()) {
        with (fleet){
            random_sector_exit_point();
            action_spd = 256;
            action = "";
            set_fleet_movement();
            instance_destroy();
        }
        alter_disposition(eFACTION.INQUISITION, -15);
        scr_popup("Inquisitor Mission Failed", "The radical Inquisitor has departed from the planned intercept coordinates.  They will now be nearly impossible to track- the mission is a failure.", "inquisition", "");
        scr_event_log("red", "Inquisition Mission Failed: The radical Inquisitor has departed from the planned intercept coordinates.");
        delete_mission = true;
        exit;
    }

    action = "";
    var _gender = string_gender_third_person(data.inquisitor_gender);

    var _tixt = $"You have located the radical Inquisitor.  As you prepare to destroy their ship, and complete the mission, you recieve a hail- it appears as though {_gender} wishes to speak.";
    var _options = [
        {
            str1: "Destroy their vessel",
            choice_func: method(self, radical_inquisitor_destroy_inquisitor_ship),
        },
        {
            str1: "Hear them out",
            choice_func: method(self, radical_inquisitor_hear_them_out),
        },
    ];
    scr_popup("Inquisitor Located", _tixt, "inquisition", {mission:self, options : _options});
    exit;   
}

/// @self Asset.GMObject.obj_popup
static __radical_inquisitor_destroy_inquisitor_ship = function() {
    LOGGER.debug("mission_hunt_inquisitor_destroy_inquisitor_ship");
    var _final_disp_mod = 0;

    if (obj_controller.demanding == 0) {
        _final_disp_mod += 1;
    } else if (obj_controller.demanding == 1) {
        _final_disp_mod += choose(0, 0, 1);
    }

    if ((obj_popup.title == "Artifact Offered") || (obj_popup.title == "Mercy Plea")) {
        _final_disp_mod -= choose(0, 1);
    }

    alter_disposition(eFACTION.INQUISITION, _final_disp_mod);

    obj_popup.title = "Inquisition Mission Completed";
    obj_popup.image = "exploding_ship";
    obj_popup.text = "The Inquisitor's ship begans to bank and turn, to flee, but is immediately fired upon by your fleet.  The ship explodes, taking the Inquisitor with it.  The mission has been accomplished.";
    reset_popup_options();
    scr_event_log("", "Inquisition Mission Completed: The radical Inquisitor has been purged.");
    delete_mission = true;
    __check_delete();
    exit;
}


/// @self Asset.GMObject.obj_popup
static __radical_inquisitor_hear_them_out = function() {
    var _offer = choose(1, 1, 2, 2, 3);

    var _gender = data.inquisitor_gender;
    var _gender_third = string_gender_third_person(_gender);
    var gender_pronoun = string_gender_pronouns(_gender);

    if (_offer == 1) {
        replace_options([
            {
                str1: "Destroy their vessel",
                choice_func: method(self, __popup_choice("inquisitor_ship")),
            }, 
            {
                str1: "Take the artifact and then destroy them", 
                choice_func: method(self, __popup_choice("artifact_double_cross"))
            },
            {
                str1: "Take the artifact and spare them", 
                choice_func: __popup_choice("take_artifact_bribe")
            }
        ]);
        obj_popup.title = "Artifact Offered";
        obj_popup.text = $"The Inquisitor claims that this is a massive misunderstanding, and {_gender_third} wishes to prove {gender_pronoun} innocence.  If {global.chapter_name} allow their ship to leave {_gender_third} will give {global.chapter_name} an artifact.";
        exit;
    } else if (_offer == 2) {
        replace_options(
            [
                {
                    str1: "Destroy their vessel", 
                    choice_func: __popup_choice("destroy_inquisitor_ship"),
                },
                {
                    str1: "Search their ship", 
                    //choice_func : instance_destroy, // TODO: Implement proper ship search logic
                },
                {
                    str1: "Spare them", 
                    choice_func: __popup_choice("show_mercy"),
                },
            ],
        );
        title = "Mercy Plea";
        text = $"The Inquisitor claims that {_gender_third} has key knowledge that would grant the Imperium vital power over the forces of Chaos.  If {global.chapter_name} allow {gender_pronoun} ship to leave the forces of Chaos within this sector will be weakened.";
        exit;
    } else if (_offer == 3) {
        with (fleet) {
            with (instance_nearest(fleet.x, fleet.y, obj_p_fleet)) {
                scr_add_corruption(true, "1d3");
            }
            instance_destroy();
        }
        obj_popup.title = "Inquisition Mission Completed";
        obj_popup.image = "exploding_ship";
        obj_popup.text = $"{global.chapter_name} allow communications.  As soon as the vox turns on {global.chapter_name} hear a sickly, hateful voice.  They begin to speak of the inevitable death of your marines, the fall of all that is and ever shall be, and " + string(gender_pronoun) + " Lord of Decay.  Their ship is fired upon and destroyed without hesitation.";
        reset_popup_options();
        scr_event_log("", "Inquisition Mission Completed: The radical Inquisitor has been purged.");
    }
    delete_mission = true;
    __check_delete();
}

static __radical_inquisitor_show_mercy() {
    with (fleet) {
        random_sector_exit_point();
        trade_goods = "|DELETE|";
        action_spd = 256;
        set_fleet_movement(false, 8);
    }

    obj_popup.title = "Inquisition Mission Completed";
    obj_popup.text = $"{global.chapter_name} allow the Inquisitor to leave, trusting in their words.  If they truly do have key information it is a risk {global.chapter_name} are willing to take.  What's the worst that could happen?";
    obj_popup.image = "artifact_recovered";
    reset_popup_options();
    scr_event_log("", "Inquisition Mission Completed?: The radical Inquisitor has been allowed to flee in order to weaken the forces of Chaos, as they promised.");
    add_event({e_id: "inquisitor_spared", duration: irandom_range(6, 18) + 1, variation: 2});
    delete_mission = true;
    __check_delete();
}

static __radical_inquisitor_artifact_double_cross function() {
    with (fleet) {
        instance_destroy();
    }
    var last_artifact = scr_add_artifact("random", "", 4);

    reset_popup_options();

    obj_popup.title = "Inquisition Mission Completed";
    obj_popup.text = "Your ship sends over a boarding party, who retrieve the offered artifact- ";
    obj_popup.text += $" some form of {fetch_artifact(last_artifact).get_type_name()}.  Once it is safely stowed away your ship is then ordered to fire.  The Inquisitor's own seems to hesitate an instant before banking away, but is quickly destroyed.";
    obj_popup.image = "exploding_ship";
    scr_event_log("", "Artifact recovered from radical Inquisitor.");
    scr_event_log("", "Inquisition Mission Completed: The radical Inquisitor has been purged.");
    delete_mission = true;
    __check_delete();
}

/// @self Asset.GMObject.obj_popup
function radical_inquisitor_take_artifact_bribe() {
    with (fleet) {
        random_sector_exit_point();
        trade_goods = "|DELETE|";
        action_spd = 256;
        set_fleet_movement(false);
    }
    var last_artifact = scr_add_artifact("random", "", 4);

    reset_popup_options();

    obj_popup.title = "Inquisition Mission Completed";
    obj_popup.text = "Your ship sends over a boarding party, who retrieve the offered artifact- ";
    obj_popup.text += $" some form of {fetch_artifact(last_artifact).get_type_name()}.  As promised {global.chapter_name} allow the Inquisitor to leave, hoping for the best.  What's the worst that could happen?";
    obj_popup.image = "artifact_recovered";
    scr_event_log("", "Artifact Recovered from radical Inquisitor.");
    scr_event_log("", "Inquisition Mission Completed: The radical Inquisitor has been purged.");
    add_event({e_id: "inquisitor_spared", duration: irandom_range(6, 18) + 1, variation: 1});
}

}







