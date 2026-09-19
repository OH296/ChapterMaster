function MissionHandler(planet, system) : PlanetData(planet, system) constructor {}

function location_out_of_player_control(unit_loc) {
    static _locs = [
        "Terra",
        "Mechanicus Vessel",
        "Lost",
        "Mars",
    ];
    return array_contains(_locs, unit_loc);
}

global.planet_problem_keys = [
    "meeting_trap",
    "meeting",
    "succession",
    "mech_raider",
    "mech_bionics",
    "mech_mars",
    "mech_tomb",
    "fallen",
    "great_crusade",
    "harlequins",
    "fund_elder",
    "provide_garrison",
    "hunt_beast",
    "protect_raiders",
    "join_communion",
    "join_parade",
    "recover_artifacts",
    "train_forces",
    "spyrer",
    "inquisitor",
    "recon",
    "cleanse",
    "purge",
    "tyranid_org",
    "artifact_loan",
    "necron",
    "ethereal",
    "demon_world",
];

function mission_name_key(mission) {
    static mission_key = {
        "meeting_trap": "Chaos Lord Meeting",
        "meeting": "Chaos Lord Meeting",
        "succession": "War of succession",
        "mech_raider": "Provide Land Raider to Mechanicus",
        "mech_bionics": "Provide Bionic Augmented marines to study",
        "mech_mars": "Send Techmarines to mars",
        "mech_tomb": "Explore Mechanicus Tomb",
        "fallen": "Find Chapter Fallen",
        "great_crusade": "Answer Crusade Muster Call",
        "harlequins": "Harlequin presence Report",
        "fund_elder": "provide assistance to Eldar",
        "provide_garrison": "Provision Garrison",
        "hunt_beast": "Hunt Beasts",
        "protect_raiders": "Protect From Raiders",
        "join_communion": "Join Planetary Religious Celebration",
        "join_parade": "Join Parade on Planet Surface",
        "recover_artifacts": "Recover Artifacts",
        "train_forces": "Train Planet Forces",
        // Inquisition missions
        "spyrer": "Kill Spyrer for Inquisitor",
        "inquisitor": "Radical Inquisitor Arriving",
        "recon": "Recon Mission for Inquisitor",
        "cleanse": "Cleanse Planet for Inquisitor",
        "purge": "Purge Leadership for Inquisitor",
        "tyranid_org": "Capture Tyranid for Inquisitor",
        // "bomb" : "Bombard World for Inquisitor",
        "artifact_loan": "Safeguard Artifact for the Inquisition",
        "necron": "Bomb Necron Tomb for Inquisitor",
        "ethereal": "Capture Ethereal for Inquisitor",
        "demon_world": "Clear Demon World for Inquisitor",
    };
    if (struct_exists(mission_key, mission)) {
        return mission_key[$ mission];
    } else {
        return "none";
    }
}

/// @self Struct.PlanetData
function problem_end_turn_checks() {


/// @self Asset.GMObject.obj_star
function scr_new_governor_mission(planet, problem = "") {
    if (p_owner[planet] != eFACTION.IMPERIUM) {
        exit;
    }
    var planet_type = p_type[planet];
    if (problem == "") {
        if (planet_type == "Death") {
            problem = choose("hunt_beast", "provide_garrison");
        } else if (planet_type == "Hive") {
            problem = choose("show_of_power", "provide_garrison", "purge_enemies", "raid_black_market");
        } else if (planet_type == "Temperate") {
            problem = choose("provide_garrison", "train_forces", "join_parade");
        } else if (planet_type == "Shrine") {
            problem = choose("provide_garrison", "join_communion");
        } else if (planet_type == "Ice") {
            problem = choose("provide_garrison", "hunt_beast");
        } else if (planet_type == "Lava") {
            problem = choose("provide_garrison", "protect_raiders");
        } else if (planet_type == "Agri") {
            problem = choose("provide_garrison", "protect_raiders", "recover_artifacts");
        } else if (planet_type == "Desert") {
            problem = choose("provide_garrison", "protect_raiders", "recover_artifacts");
        } else if (planet_type == "Feudal") {
            problem = choose("hunt_beast", "protect_raiders");
        }
    }
    var mission_data = {
        stage: "preliminary",
        applicant: "Governor",
    };
    if (problem != "") {
        if (problem == "provide_garrison") {
            if (get_garrison(planet).garrison_force) {
                exit;
            }
            mission_data.reason = choose("stability", "importance");
        } else if (problem == "purge_enemies") {
            var enemy = 0;
            if (planets > 1) {
                for (var i = 1; i <= planets; i++) {
                    if (i == planet) {
                        continue;
                    }
                    if (p_owner[i] == eFACTION.IMPERIUM) {
                        enemy = i;
                        break;
                    }
                }
            }
            mission_data.target = enemy;
            if (!enemy) {
                exit;
            }
        }
        add_new_problem(planet, problem, 20 + irandom(20),, mission_data);
    }
}

function init_marine_acting_strange() {
    var marine_and_company = scr_random_marine("", 0);
    if (marine_and_company == "none") {
        LOGGER.error("RE: Strange Behavior, couldn't pick a space marine");
        exit;
    }

    var unit = fetch_unit(marine_and_company);
    if (!is_struct(unit)) {
        exit;
    }
    var role = unit.role();
    var text = unit.name_role();
    var company_text = scr_convert_company_to_string(unit.company);
    if (company_text != "") {
        company_text = $"({company_text})";
        text += company_text;
    }
    text += " is behaving strangely.";
    scr_alert("color", "lol", text, 0, 0);
    scr_event_log("color", text);
}

function init_protect_raider_mission(squad) {
    var _squad_units = squad.members;
    var _squad_wisdom = stat_average(_squad_units, "wisdom");
    var _squad_dex = stat_average(_squad_units, "dexterity");
    var _tester = global.character_tester;

    var _pdata = selection_data.system.get_planet_data(selection_data.planet);
    var _mod = _squad_wisdom + _squad_dex / 20;
    if (scr_has_adv("Ambushers")) {
        _mod += 10;
    }

    var _leader = squad.determine_leader();
    if (!is_struct(_leader)) {
        return;
    }
    var _wis_test = _tester.standard_test(_leader, "wisdom", _mod, ["ambush"]);

    if (!_wis_test[0]) {
        if (_wis_test[1] < -25) {
            scr_toggle_manage();
            var gar_pop = instance_create(0, 0, obj_popup);
            gar_pop.title = $"Strange Disappearance";
            gar_pop.pdata = _pdata;
            gar_pop.text = $"Your Marines make planet fall and are directed to report to the governor for the duration of the operation after a period of reconnaissance dig in for their ambush. After a two weeks have passed A message from the governor reaches your astropaths that your marines have not been heard of for some time, The raiders also were not noted to have arrived onor left the planet";
            var _dead_marine = array_random_index(_squad_units);
            for (var i = 0; i < array_length(_dead_marine); i++) {
                if (i == _dead_marine) {
                    continue;
                }

                var _marine = _dead_marine[i];

                _marine.location_string = "Lost";
                _marine.ship_location = -1;
                _marine.planet_location = 0;
            }
            gar_pop.text += $"After eventual investigation it appears the eldar anticipated the would be ambushers and turned the tides. {_squad_units[_dead_marine].name_role()}s body is eventually discovered some way off from the main battle his rent armour and body showing the extent of combat that must have occured";

            gar_pop.text += "\nThe total loss of a squad in what was meant to be a routine operation is bad for moral and your chapters reputation you must now decide how to proceed";

            gar_pop.add_option({str1: "Suppress the Information", choice_func: protect_raiders_suppress_information});

            gar_pop.add_option({str1: "Hold a Memorial", choice_func: protect_raiders_hold_memorial});
        } else {
            scr_toggle_manage();
            var gar_pop = instance_create(0, 0, obj_popup);
            gar_pop.title = $"Ineffective Ambush";
            gar_pop.text = $"Your Marines Are ineffective at setting up an ambush the assailants clearly got wind of the operation or the plan was otherwise so ill thought out that by the time your forces arrived there was little that could be done to intercept them";
            gar_pop.text += $"";
            gar_pop.pathway = "protect_raiders_ineffective";
            gar_pop.pdata = _pdata;
            _pdata.add_disposition(-10);
            gar_pop.text += "\nThe governor is unhappy and it has done little to improve your reputation with the planets populace but otherwise very little harm has been done. It is likely the raiders will choose better targets without the possible threat of space marine presence for the foreseeable future\nGovernor Disposition : -10";

            gar_pop.add_option("continue");
        }
    } else {
        instance_create(0, 0, obj_ncombat);
        obj_ncombat.enemy = eFACTION.ELDAR;
        obj_ncombat.battle_object = selection_data.system;
        obj_ncombat.battle_loc = selection_data.system.name;
        obj_ncombat.battle_id = selection_data.planet;
        obj_ncombat.battle_special = "protect_raiders";
        _roster = new Roster();
        with (_roster) {
            selected_units = _squad_units;
            setup_battle_formations();
            add_to_battle();
        }
        exit_adhoc_manage();
        delete _roster;
    }
}

/// @self Asset.GMObject.obj_popup
function protect_raiders_suppress_information() {
    title = "Captains Disgruntled";
    options1 = "continue";
    pathway = "";
    var _caps = scr_role_count(obj_ini.player_role_data[eROLE.CAPTAIN].role);
    var _worst = -1;
    var _worst_hit = -1;
    for (var i = 0; i < array_length(_caps); i++) {
        if (!irandom(2)) {
            var _cap = _caps[i];
            var _loyalty_hit = irandom(6);
            if (_loyalty_hit > _worst_hit) {
                _worst_hit = _loyalty_hit;
                _worst = i;
            }
        }
    }

    if (_worst == -1) {
        text = $"You are able to convince your captains of the strategic need to cover up the incidence, various excuses are made and fake logs that cover up the disaster of the mission";
    } else {
        text = $"Not all of your captains are convinced of the need to use deceit and a none have breached the order but it has soured your relations with a few namely {_caps[_worst].name_role()}";
    }
}

/// @self Asset.GMObject.obj_popup
function protect_raiders_hold_memorial() {
    reset_popup_options();
    options1 = "continue";
    _pdata.add_disposition(-30);
    text = $"You prepare to have a large public memorial for your fallen marines on the planet surface as a show of defiance. The chapter are pleased by such an act and the population of the planet are mesmerized by the spectacle. The governor is furious not only has his incompetence to deal with the planets xenos issue been made public in such a way that the sector commander has now heard about it but he perceives his failures are being paraded in font of him\n nGovernor Disposition : -30";
}


//TODO allow most of these functions to be condensed and allow arrays of problems or planets and maybe increase filtering options
//filtering options could be done via universal methods that all the filters to be passed to many other game systems
/// @self Asset.GMObject.obj_star
function has_any_problem_planet(planet, star = noone) {
    if (star == noone) {
        for (var i = 0; i < array_length(p_problem[planet]); i++) {
            if (p_problem[planet][i] != "") {
                return true;
            }
        }
    } else {
        with (star) {
            return has_any_problem_planet(planet);
        }
    }
    return false;
}

// returns a bool for if any planet on a given star has the given problem
/// @self Asset.GMObject.obj_star
function has_problem_star(problem, star = noone) {
    var has_problem = false;
    if (star == noone) {
        for (var i = 1; i <= planets; i++) {
            has_problem = has_problem_planet(i, problem);
            if (has_problem) {
                has_problem = true;
                break;
            }
        }
    } else {
        with (star) {
            has_problem = has_problem_star(problem);
        }
    }
    return has_problem;
}

//returns a bool for if a planet has a given problem
/// @self Asset.GMObject.obj_star
function has_problem_planet(planet, problem, star = noone) {
    if (star == noone) {
        return array_contains(p_problem[planet], problem);
    } else {
        with (star) {
            return has_problem_planet(planet, problem);
        }
    }
}

//returns the array position of a given problem on a given planet if the specfied time is given
/// @self Asset.GMObject.obj_star
function has_problem_planet_and_time(planet, problem, time, star = noone) {
    var _had_problem = -1;
    if (star == noone) {
        for (var i = 0; i < array_length(p_problem[planet]); i++) {
            if (p_problem[planet][i] == problem) {
                if (p_timer[planet][i] == time) {
                    _had_problem = i;
                }
            }
        }
    } else {
        with (star) {
            _had_problem = has_problem_planet_and_time(planet, problem, time);
        }
    }
    return _had_problem;
}

//returns the array position of a given problem on a given planet if the specfied time is above 0
/// @self Asset.GMObject.obj_star
function has_problem_planet_with_time(planet, problem, star = noone) {
    var _had_problem = -1;
    if (star == noone) {
        for (var i = 0; i < array_length(p_problem[planet]); i++) {
            var _problem = p_problem[planet][i];
            if (_problem.p_id == problem) {
                if (_problem.timer > 0) {
                    _had_problem = i;
                }
            }
        }
    } else {
        with (star) {
            _had_problem = has_problem_planet_with_time(planet, problem);
        }
    }
    return _had_problem;
}

//returns the array position of a gien problem on a given planet
/// @self Asset.GMObject.obj_star
function find_problem_planet(planet, problem, star = noone) {
    if (star == noone) {
        for (var i = 0; i < array_length(p_problem[planet]); i++) {
            if (p_problem[planet][i].p_id == problem) {
                return i;
            }
        }
    } else {
        with (star) {
            return find_problem_planet(planet, problem);
        }
    }
    return -1;
}

///removie all of a given problem from a planet
/// @self Asset.GMObject.obj_star
function remove_planet_problem(planet, problem, star = noone) {
    var _had_problem = false;
    if (star == noone) {
        for (var i = 0; i < array_length(p_problem[planet]); i++) {
            if (p_problem[planet][i] == problem) {
                p_problem[planet][i] = "";
                p_timer[planet][i] = -1;
                p_problem_other_data[planet][i] = {};
                _had_problem = true;
            }
        }
    } else {
        with (star) {
            _had_problem = remove_planet_problem(planet, problem);
        }
    }
    return _had_problem;
}

//find an open problem slot on a given planet
/// @self Asset.GMObject.obj_star
function open_problem_slot(planet, star = noone) {
    if (star == noone) {
        for (var i = 0; i < array_length(p_problem[planet]); i++) {
            if (p_problem[planet][i] == "") {
                return i;
            }
        }
    } else {
        with (star) {
            return open_problem_slot(planet);
        }
    }
    return -1;
}

//remove all of a given problem types from a star
/// @self Asset.GMObject.obj_star
function remove_star_problem(problem, star = noone) {
    if (star == noone) {
        for (var i = 1; i <= planets; i++) {
            remove_planet_problem(i, problem);
        }
    } else {
        with (star) {
            remove_star_problem(problem);
        }
    }
}

//add a new problem
/// @self Asset.GMObject.obj_star
function add_new_problem(planet, problem, timer, star = noone, other_data = {}) {
    var problem_added = false;
    if (star == noone) {
        for (var i = 0; i < array_length(p_problem[planet]); i++) {
            array_push
            if (p_problem[planet][i] == "") {
                p_problem[planet][i] = problem;
                p_problem_other_data[planet][i] = other_data;
                p_timer[planet][i] = timer;
                problem_added = true;
                break;
            }
        }
    } else {
        with (star) {
            problem_added = add_new_problem(planet, problem, timer, noone, other_data);
        }
    }
    return problem_added;
}


/// @desc Compares two location arrays to determine if they represent the same place.
/// @param {array} _first_loc
/// @param {array} _second_loc
/// @returns {bool}
function locations_are_equal(_first_loc, _second_loc) {
    if (!is_array(_first_loc) || !is_array(_second_loc) || array_length(_first_loc) < 3 || array_length(_second_loc) < 3) {
        LOGGER.error("Attempted to compare non-array or broken location data.");
        return false;
    }

    var _first_type = _first_loc[2];
    var _second_type = _second_loc[2];
    var _not_lost = (_first_type != "Warp" && _first_type != "Lost") && (_second_type != "Warp" && _second_type != "Lost");

    if (_not_lost && (_first_type == _second_type)) {
        return true;
    }

    return (_first_loc[1] == _second_loc[1]) && (_first_loc[0] == _second_loc[0]);
}
