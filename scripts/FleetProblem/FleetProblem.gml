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
static __trigger_with_event = function(trigger_string, _event_data = {}){
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
    var _func = undefined;
    if ((timer > -1) && per_turn_checks) {
        var _func = find_func("per_turn");
    }
    __handle_triggered_mission_func(_func);
}

static on_waypoint_arrival = function(){
    __trigger_with_event("on_waypoint_arrival");
}

static on_final_arrival = function(){
    __trigger_with_event("on_final_arrival");
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

static __great_crusade_init(){
    var _crusade_direction = point_direction(room_width / 2, room_height / 2, system.x, system.y);
    fleet.action_x = x + lengthdir_x(1200, _crusade_direction);
    fleet.action_y = y + lengthdir_y(1200, _crusade_direction);
    fleet.set_fleet_movement(false, p_id);
    stage_id = "travel_to_crusade";
}

static __great_crusade_on_final_arrival(){
	if (stage_id == "travel_to_crusade"){
        var dr = point_direction(room_width / 2, room_height / 2, x, y);
        fleet.action_x = x + lengthdir_x(600, dr);
        fleet.action_y = y + lengthdir_y(600, dr);
        set_fleet_movement(false, p_id);
        stage_id = "crusading"
	} else if (stage_id == "crusading"){
        with (obj_star) {
            if (owner > 5) {
                instance_deactivate_object(id);
            }
            var enemies = false;
            for (var i = 6; i < 13; i++) {
                if (scr_orbiting_fleet(i) != noone) {
                    enemies = true;
                    break;
                }
            }
            if (enemies) {
                instance_deactivate_object(id);
            }
        }
        var ret = instance_nearest(x, y, obj_star);
        action_x = ret.x;
        action_y = ret.y;
        action = "crusade3";
        set_fleet_movement(false, "crusade3");
        instance_activate_object(obj_star);		
        stage_id = "returning_home"
	} else if (stage_id == "returning_home"){
        __great_crusade_results();
        
	}
}

static __great_crusade_results = function(){
   	var _apoth = 0, _death_determination = 0, _death_determination_2 = 0, _roll3 = 0, _type = "", _artifacts = 0;
    var _seed = 0;
    var _marines_lost = 0;
    var _heroics_strings = [];
    var _clean = [];

    //index 1: death_determine 1 //index 2: death_determine 2 /index 3: apoth_recovery
    //index 3 exp_gains irandom + static
    var death_sets = {
        normal: [
            80,
            90,
            40,
            [
                5,
                10,
            ],
        ],
        hard: [
            60,
            80,
            30,
            [
                20,
                20,
            ],
        ],
        brutal: [
            20,
            65,
            20,
            [
                40,
                20,
            ],
        ],
    };

    _death_determination = floor(random(100)) + 1;
    _roll3 = irandom(99) + 1;

    if (_death_determination <= 50) {
        _type = "normal";
        _artifacts = choose(0, 0, 0, 0, 0, 1);
    } else if (_death_determination > 50 && _death_determination <= 80) {
        _type = "hard";
        _artifacts = choose(0, 0, 1);
    } else if (_death_determination > 80) {
        _type = "brutal";
        _artifacts = choose(1, 2, 3);
    }

    var death_data = death_sets[$ _type];

    for (var co = 0; co <= obj_ini.companies; co++) {
        _clean[co] = 0;
    }
    var total_ship_id = array_concat(fleet.capital_num, fleet.frigate_num, fleet.escort_num);

    var _units = collect_role_group("all", ["", 0 , total_ship_id],false, {}, true);
    for (var i = 0; i < _units.number(); i++){
    	var _unit = _units.units[i];

        _death_determination = floor(random(100)) + 1;
        //specialist trait greatly reduces death risk
        //TODO figure out how to quantify and present these risks so the player knows to protect dudes with trait
        if (_unit.has_trait("very_hard_to_kill")) {
            _death_determination -= 20;
        }
        _death_determination_2 = _death_determination;
        _death_determination -= _unit.experience / 2;

        //more generalised trait bonus mainly linked to chapter advantage of same name
        if (_unit.has_trait("slow_and_purposeful")) {
            _death_determination -= 10;
        }

        var _dead = false;
        if (_death_determination > death_data[0] || _death_determination_2 > death_data[1]) {
            _dead = true;
            if (_unit.has_role(eROLE.CAPTAIN)) {
                if (irandom(20) < _unit.luck) {
                    _dead = false;
                } else {
                    if (irandom(100) < _unit.weapon_skill) {
                        var _heroic_deed = choose("holding a breach in imperial defenses allowing allied forces to regroup,", "slaying the enemy leader in glorious combat, while victorious he ultimately succumbed to his wounds,", "leading an imortant boarding mission,");
                        //TODO figure out a blance in reward for captains or high rnaking death on crusade
                        //adds dynamacism as itt creates reward for the potential loss of men and talent during crusades
                        //var consolations = ["ship", "req",""]
                        //var consolation_prize = irandom(2)
                        var heroic_death = $"{_unit.full_title()} died {_heroic_deed} {_unit.name()} dies a hero of the {global.chapter_name}";
                        array_push(_heroics_strings, heroic_death);
                    }
                }
            } else if (_unit.has_role(eROLE.ANCIENT) || _unit.has_role(eROLE.CHAPTERMASTER])) {
                _dead = false;
            }
        }
        if (_dead) {
            obj_ini.ship_carrying[_unit.ship_location] -= _unit.get_unit_size();
            if (_unit.IsSpecialist(SPECIALISTS_STANDARD, true)) {
                obj_controller.command--;
            } else {
                obj_controller.marines--;
            }

            _clean[co] = 1;
            _marines_lost++;
            _unit.kill(false, true);
        } else {
            if (_unit.IsSpecialist(SPECIALISTS_APOTHECARIES) && (_unit.gear() == "Narthecium")) {
                _apoth++;
            }
            _unit.add_exp(irandom(death_data[3][0]) + death_data[3][1]);

            if (irandom(99) == 1 && irandom(20) < _unit.luck) {
                var _heroic_deed = choose("still_standing", "lone_survivor", "beast_slayer");
                _unit.add_trait(_heroic_deed);
                array_push(_heroics_strings, string(global.trait_list[$ _heroic_deed].flavour_text, _unit.full_title()));
            }
        }
    }

    if (obj_ini.doomed == 0) {
        if (_apoth > 0) {
            _seed = min(_seed, _apoth * death_data[2]);
        }
        if (_apoth == 0) {
            _seed = floor(_seed * 0.2);
        }
        obj_controller.gene_seed += _seed;
    }

    with (obj_ini) {
        for (var _c = 0; _c <= obj_ini.companies; _c++) {
            scr_company_order(_c);
        }
    }

    if (_roll3 <= 10) {
        _artifacts += 1;
    }
    if (_artifacts > 0) {
        repeat (_artifacts) {
            if (obj_ini.fleet_type == ePLAYER_BASE.HOME_WORLD) {
                scr_add_artifact("random", "", 4, obj_ini.home_name, -1);
            }
            if (obj_ini.fleet_type != ePLAYER_BASE.HOME_WORLD) {
                scr_add_artifact("random", "", 4, obj_ini.ship[0], 0);
            }
        }
    }

    var tixt = "Your ships have returned from the Crusade.  ";
    if (_type == "normal") {
        tixt += "The combat was as could be expected- ";
    }
    if (_type == "hard") {
        tixt += "The combat was fairly grueling- ";
    }
    if (_type == "brutal") {
        tixt += "The combat was absolutely brutal- your marines were the first into the fray, and as a result ";
    }

    tixt += $"{_marines_lost} of your battle brothers fell in combat.";

    var _apoth_role = obj_ini.player_role_data[eROLE.APOTHECARY].role;
    if (obj_ini.doomed == 0) {
        if ((_apoth > 0) && (_seed > 0)) {
            tixt += $"  The {_apoth} surviving {_apoth_role} were able to recover {_seed} Gene-Seed.";
        }
        if ((_apoth == 0) && (_seed > 0)) {
            tixt += $"  You had no able-bodied {_apoth_role}, or all of them perished in the Crusade.  Foreign Apothecaries were able to recover " + string(_seed) + " of your Gene-Seed.";
        }
    }
    if (obj_ini.doomed == 1) {
        tixt += "  Due to fatal mutations in your marines none of the fallen Gene-Seed was recoverable.";
    }

    if (_artifacts > 0) {
        tixt += $"  {_artifacts} Artifacts were granted to your Chapter or looted.";
    }
    if ((_roll3 <= 10) && (_artifacts > 1)) {
        tixt += "  One of them were given as a bonus for exceptional valor.";
    }

    if (array_length(_heroics_strings) == 1) {
        tixt += " A heroic deed was recorded";
    } else if (array_length(_heroics_strings) > 1) {
        tixt += " Several deeds were recorded";
    }
    // title / text / image / speshul
    scr_popup("Crusade Results", tixt, "crusade", "");
    for (i = 0; i < array_length(_heroics_strings); i++) {
        scr_popup("Heroic Deed", _heroics_strings[i], "crusade", "");
    }

    delete_mission = true;
    fleet.action = "";
}	
}
}






