function MissionHelper() constructor{

}

function SystemProblem(name, timer, data){}

function PlanetProblem(name, timer, data, planet) constructor{
timer = timer;
uid = scr_uuid_generate();
p_id = name;
data = data;
p_data = planet;
planet = p_data.planet;
system = p_data.system;
f_type = eP_FEATURES.MISSION;
static refresh_p_data = function(){
	p_data = system.get_planet_data(planet);
}
stage_id = "";
if (struct_exists(data, "stage")){
	stage_id = data.stage;
}
extend_timer_for_warp_storm = true;
remove = false;
zero_timer_checks = true;
per_turn_checks = true;

static basic_turn_end = function(){
	refresh_p_data();
	if (p_data.system.storm - 1 > 0){
		timer--;
	}
	if ((timer > -1) && per_turn_checks) {
		var _func = undefined;
		switch(p_id){
			case "mech_raider";
				_func = per_turn_check_raider_failed;
				break;
			case "mech_bionics":
				_func = per_turn_check_mech_bionics;
				break;
			case "mech_bionics":
				switch(stage_id):
						break;
					case "exploring":
						_func = per_turn_check_mech_tomb2;
						break;
					case "awaiting_player";
					default:
						_func = per_turn_check_mech_tomb1;
					break;
            case "spyrer":
                _func = per_turn_check_spyrer;
		}
		if (!is_undefined(_func)){
            try {
                _func();
            } catch (_exception) {
                ERROR_HANDLER.handle_exception(_exception);
            }
		}

	}
	if ((timer == 0) && zero_timer_checks) {
		var _func = undefined;
		switch(p_id){
			case "hunt_beast":
				_func = resolve_hunt_beast;
				break;
			case "train_forces":
				_func = complete_train_forces_mission;
				break;
			case "succession":
				_func = resolve_succession;
				break;
			case "recon":
				_func = resolve_recon;
				break;
			case "great_crusade":
				_func = resolve_great_crusade;
				break;
			case "necron":
				_func = resolve_necron;
				break;
			case "spyrer":
				_func = resolve_spyrer;
				break;
			case "fallen":
				_func = resolve_fallen;
				break;
			case "mech_raider";
				_func = resolve_mech_raider_failed;
				break;
			case "mech_bionics":
				_func = resolve_mech_bionics;
				break;
			case "mech_tomb";
				_func = resolve_mech_tomb1_failed;
				break;
			case "mech_mars":
				_func = resolve_mech_mars;
                break;
            case "provide_garrison":
                _func =  complete_garrison_mission;
		}
		if (!is_undefined(_func)){
            try {
                _func();
            } catch (_exception) {
                ERROR_HANDLER.handle_exception(_exception);
            }
		}
	}
}

static mark = function(colour){
	refresh_p_data();
	with (p_data.system){
		new_star_event_marker(colour)
	}
}

static description = function(){
	return mission_name_key(p_id);
}

static increment_mission_completion =  function() {
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

static new_end_turn_battle = function(battle_opponent_id, special_id = p_id){
    var _battle_index = obj_turn_end.battles++;
    obj_turn_end.battle[_battle_index] = 1;
    obj_turn_end.battle_world[_battle_index] = planet;
    obj_turn_end.battle_opponent[_battle_index] = battle_opponent_id;
    obj_turn_end.battle_location[_battle_index] = system.name;
    obj_turn_end.battle_object[_battle_index] = system;
    obj_turn_end.battle_special[_battle_index] = {
        special_id : special_id,
        special_feature : self
    };
}

static __init(){
	switch(p_id){
		case "necron":
	        mark("green");
	        break;
	    case "meeting":
            var rando = choose(1, 2);
            if (rando == 1) {
                obj_controller.diplo_text += $"A proposal that needs further consideration and some negotiation.  Meet me at {p_data.name()} and we shall resolve this.";
            }
            if (rando == 2) {
                obj_controller.diplo_text += $"Interesting. I shall be at {p_data.name()} and, if you are sincere, you will come to me and we can take this proposal to its logical conclusion.";
            }
            scr_event_log("", $"Chaos Lord {obj_controller.faction_leader[eFACTION.CHAOS]} agrees to meet with you on {p_data.name()} to discuss an alliance.");
            mark("purple");
            break;
        case "fallen":
            break;
        case "harlequins":
            var _text = $"Eldar Harlequins have been seen on planet {p_data.name()}. Their purposes are unknown.";
            scr_popup("Harlequin Troupe", _text, "harlequin", "");
            mark("green");
            break;
        default:
            mark("green");

	}
}
__init();


static init_beast_hunt_mission = function() {
    refresh_p_data();
    if (stage_id == "preliminary") {
        var _numeral_name = p_data.name()
        stage_id = "active";
        var _mission_length = irandom_range(2, 5);
        timer[planet][mission_slot] = _mission_length;
        var _gar_pop = instance_create(0, 0, obj_popup);
        //TODO some new MissonHelper methods for popups
        _gar_pop.title = $"Marines assigned to hunt beasts around {_numeral_name}";
        _gar_pop.text = $"The govornor of {_numeral_name} Thanks you for the participation of your elite warriors in your execution of such a menial task.";
        _gar_pop.add_option("Happy Hunting");
        _gar_pop.image = "";
        _gar_pop.cooldown = 8;
        obj_controller.cooldown = 20;
        scr_event_log("", $"Beast hunters deployed to {_numeral_name} for {_mission_length} months.", p_data.system.name);
    }
}

static complete_beast_hunt_mission = function() {
    refresh_p_data();
    var _hunters = collect_role_group("all", [system.name, planet, 0], false, man_conditions);
    if (stage_id == "active") {
        var _mission_string = "";
        var man_conditions = {
            "job": "hunt_beast",
            "max": 3,
        };
        var _success = false;
        var _tester = global.character_tester;
        var _unit_pass;
        var _unit;
        var _unit_report_string = "";
        var _deaths = 0;
        var _successful_hunters = [];

        if (!array_length(_hunters)) {
            return;
        }

        for (var i = 0; i < array_length(_hunters); i++) {
            _unit = _hunters[i];
            _unit_pass = _tester.standard_test(_unit, "weapon_skill", 10, ["beast"]);
            if (_unit_pass[0]) {
                if (!_success) {
                    _success = true;
                }
                _unit_report_string += _unit.add_trait("beast_slayer", true, true);
                array_push(_successful_hunters, _unit);
            } else {
                var _tough_check = _tester.standard_test(_unit, "constitution", _unit.luck);
                if (!_tough_check[0]) {
                    if (_tough_check[1] < -10) {
                        _unit_report_string += $"{_unit.name_role()} Was mauled to death\n";
                        _unit.kill(true, false);
                        _deaths++;
                    } else {
                        if (irandom(100) < _unit.luck) {
                            _unit.add_or_sub_health(-100);
                            _unit_report_string += $"{_unit.name_role()} Was injured (health - 100)\n";
                        } else {
                            _unit.add_or_sub_health(-250);
                            _unit_report_string += $"{_unit.name_role()} Was Badly injured, it is unknown if he will recover (health - 250)\n";
                        }
                    }
                }
            }
            _unit.job = "none";
        }

        if (_success) {
            _mission_string = $"The mission was a success and a great number of beasts rounded up and slain, your marines were able to gain great skills and the prestige of your chapter has increased greatly across the planets populace.";
            if (_deaths) {
                _mission_string += $"Unfortunatly {_deaths} of your marines died.";
            }
            _mission_string += $"\n{_unit_report_string}";
        } else {
            _mission_string = $"The mission was a failiure. The governor is disapointed and the legend of your chapter has undoubtedly been diminished";
            _mission_string += $"\n{_unit_report_string}";
        }

        scr_popup($"Beast Hunt on {p_data.name()}", _mission_string, "", "");
    }
    for (var i = 0; i < array_length(_hunters); i++) {
    	_hunters[i].job = "none";
    }
}


stati init_train_forces_mission = fuction(marine) {
    refresh_p_data();
    if (stage_id != "preliminary") {
        exit;
    }
    var _numeral_name = p_data.name();
    stage_id = "active";
    var _mission_length = irandom_range(3, 12);
    timer = _mission_length;
    //pop.image="ancient_ruins";
    var _gar_pop = instance_create(0, 0, obj_popup);
    //TODO some new universal methods for popups
    _gar_pop.title = $"Training forces on {_numeral_name} begins";
    _gar_pop.text = $"{marine.name_role()} Has taken leave of his current post in order to aid the governor of {_numeral_name} and his pdf commanders with training local forces and bolstering defences.";
    var _is_cap = marine.has_role(eROLE.CAPTAIN);

    if (_is_cap) {
        _gar_pop.text += "the governor seems to be impressed that such a high ranking officer has been assigned to his request (disp +3)";
        p_data.add_disposition(3);
    }

    data.assigned_unit = marine.uid;

    //pip.image="event_march"
    _gar_pop.add_option($"Good luck {marine.name()}");
    _gar_pop.image = "";
    _gar_pop.cooldown = 500;
    obj_controller.cooldown = 500;
    scr_event_log("", $"{marine.name_role()} deployed to {_numeral_name} for {_mission_length} months.", p_data.system.name);
}

static complete_train_forces_mission = function() {
    refresh_p_data();
    if (stage_id == "active") {
        var _mission_string = "";
        var _trainer = fetch_unit_uid(data.assigned_unit);
        if (is_struct(_trainer)) {
            var _unit_report_string = "";
            var _tester = global.character_tester;
            var _wis_test_difficulty = -20;
            var _tyannic_vet = _trainer.has_trait("tyrannic_vet");
            if (_tyannic_vet) {
                _wis_test_difficulty += 10;
                if (p_data.has_feature(eP_FEATURES.GENE_STEALER_CULT)) {
                    var _cult = p_data.get_features(eP_FEATURES.GENE_STEALER_CULT)[0];
                    if (_cult.hiding) {
                        p_data.delete_feature(eP_FEATURES.GENE_STEALER_CULT);
                        _mission_string += $"Fortune has smiled on this mission, {_trainer.name_role()}'s abilities as a Veteran of dealing with the Tyranids came in handy and in a short period was able to discern the existencee of a _cult. He was able to organise those  he considered to be still loyal to rally an extermiation of the _cult, reeports suggest he was so successful as to have completely wiped the genestealer presence from the planet";
                    }
                }
            }
            var _siege_master = _trainer.has_trait("siege_master");
            if (_siege_master) {
                _wis_test_difficulty += 10;
            }
            var _brute = _trainer.has_trait("brute");
            if (_brute) {
                _wis_test_difficulty -= 10;
            }

            var _leader = _trainer.has_trait("natural_leader");
            if (_leader) {
                _wis_test_difficulty += 10;
            }

            var _unit_pass = _tester.standard_test(_trainer, "wisdom", _wis_test_difficulty);
            if (_unit_pass[0]) {
                var _new_pdf = p_data.recruit_pdf((_unit_pass[1] / 10)); //this will approximate podf improvement for the time being
                _mission_string += $"Training of the Pdf went well and improved the quality of the pdf as well as providing sizeable big recruitment improvement for the planet {_new_pdf} new pdf were recruited";
                if (_leader) {
                    var _disp_gain = 10;
                    p_data.add_disposition(_disp_gain);
                    _mission_string += $"\n{_trainer.name_role()}s reputation a natural and confident leader proved well earned as he also made excellent diplomatic headway with the governor and his generals (disposition +{_disp_gain})";
                }
                if (_siege_master) {
                    _mission_string += $"{_trainer.name()}s trained eye as a Siege Master also allowed him to make several improvements to the planets fortifications (fortification +1)";
                    p_data.alter_fortification(1);
                } else {
                    if (roll_dice(1, 100) > 75 && _trainer.intelligence > 45) {
                        _mission_string += $"{_trainer.name()} has proven themselves a great strategist when it comes to defensive structures beyond previousy known ";
                        var _start_stats = variable_clone(_trainer.get_stat_line());
                        _trainer.add_trait("siege_master");
                        var end_stat = _trainer.get_stat_line();
                        var _stat_diff = compare_stats(end_stat, _start_stats);
                        _unit_report_string += $"{_trainer.name_role()} Has gained the trait {global.trait_list.siege_master.display_name}, {print_stat_diffs(_stat_diff)}\n";
                        _mission_string += "The new insights have allowed for minor improvements to planetary fortifications (fortification +1)";
                        p_data.alter_fortification(1);
                    }
                }
            } else {
                var disp_loss = -5;
                _mission_string += "The orgional training mission was a failiure";
                if (_brute) {
                    _mission_string += "in no short part due to his brutish nature";
                }
                _mission_string += ".";

                _mission_string += "He failed to work effectively with the existing chain of command";

                if (_unit_pass[1] < -20) {
                    var _hard_loss_traits = [
                        "harshborn",
                        "feral",
                        "zealous_faith",
                        "blood_for_blood",
                        "blunt",
                        "brute",
                        "brawler",
                    ];
                    var _hard_loss = false;
                    for (var i = 0; i < array_length(_hard_loss_traits); i++) {
                        if (array_contains(_trainer.traits, _hard_loss_traits[i])) {
                            _hard_loss = true;
                        }
                    }
                    if (_hard_loss) {
                        _mission_string += $"His particularly grueling regimes and standards imposed upon the senior officers of the pdf caused friction with physical injury being caused to one officer";
                        disp_loss = -25;
                        _mission_string += "(disposition -25)";
                    }
                }
                p_data.add_disposition(disp_loss);
            }
            _mission_string += $"\n{_unit_report_string}";
            scr_popup($"Training Forces on {p_data.name()}", _mission_string, "", "");
        }
        _trainer.job = "none";
    }
}

static resolve_succession = function() {
    refresh_p_data();
    var _result, _alert_text;
    var _dice1 = roll_dice(1, 100);
    var _dice2 = roll_dice(1, 100);

    _result = eFACTION.IMPERIUM;
    _alert_text = "";
    if (_dice1 <= (p_data.corruption * 2)) {
        _result = eFACTION.CHAOS;
    }
    if (_dice2 <= (p_data.population_influences[eFACTION.TAU] * 2)) {
        _result = eFACTION.TAU;
    }

    if (p_data.current_owner == eFACTION.IMPERIUM && _result != eFACTION.IMPERIUM) {
        p_data.edit_pdf(p_data.guardsmen);
        p_data.edit_guardsmen(-p_data.guardsmen);
        p_data.set_new_owner(_result);
    }

    _alert_text = $"War of Succession on {p_data.name()} has ended";

    if (_result == eFACTION.CHAOS) {
        _alert_text += " with Chaos in control.";
        p_data.set_player_disposition(0);
        scr_alert("red", "succession", _alert_text, p_data.system.x, p_data.system.y);
        scr_event_log("purple", _alert_text);
    } else if (_result == eFACTION.TAU) {
        _alert_text += " with a Tau sympathizer in control.";
        p_data.set_player_disposition(10 + choose(1, 2, 3, 4, 5, 6));
        p_data.add_forces(eFACTION.TAU, 2);
        scr_alert("red", "succession", _alert_text, p_data.system.x, p_data.system.y);
        scr_event_log("red", _alert_text);
    } else if (_result == eFACTION.IMPERIUM) {
        _alert_text += " The resultant governor is the most staunch pillar of the imperium.";
        _alert_text += ".";
        scr_alert("green", "succession", _alert_text, p_data.system.x, p_data.system.y);
        scr_event_log("", _alert_text);
    } else {
        //At the moment does not fire but a worty flavour option for down the line
        _alert_text += " Word is the new Governor has Heretical leanings and sympathises with xenos.";
    }

    p_data.delete_feature(eP_FEATURES.SUCCESSION_WAR);
}

static resolve_recon = function() {
    refresh_p_data();
    var _alert_text = "Inquisition Mission Failed: Investigate ";
    alter_disposition(eFACTION.INQUISITION, -5);
    _alert_text += $"{p_data.name()}.";
    scr_alert("red", "mission_failed", _alert_text, 0, 0);
    scr_event_log("red", _alert_text);
}

static resolve_great_crusade = function() {
    refresh_p_data();
    var _crusade_direction;
    var _join_crusade = false;
    var _player_fleet = instance_nearest(p_data.system.x, p_data.system.y, obj_p_fleet);

    if (_player_fleet.action == "") {
        if (point_distance(p_data.system.x, p_data.system.y, _player_fleet.x, _player_fleet.y) < 10) {
            _join_crusade = true;
        }
    }

    if (_join_crusade) {
        _crusade_direction = point_direction(room_width / 2, room_height / 2, p_data.system.x, p_data.system.y);
        with (_player_fleet) {
            action_x = x + lengthdir_x(1200, _crusade_direction);
            action_y = y + lengthdir_y(1200, _crusade_direction);
            set_fleet_movement(false, "crusade1");
        }

        scr_alert("green", "crusade", "Fleet embarks upon Crusade.", p_data.system.x, p_data.system.y);
        scr_event_log("", "Fleet embarks upon Crusade.");
    } else {
        // hit loyalty here
        alter_dispositions([[eFACTION.INQUISITION, -10], [eFACTION.IMPERIUM, -5]]);
        var _string = $"No ships designated for Crusade.";
        if (obj_controller.penitent == 1) {
            obj_controller.penitent_current = 0;
            _string += "Your penitence crusade has been lengthened for your failings";
        }

        scr_alert("red", "crusade", _string, p_data.system.x, p_data.system.y);
        scr_loyalty("Refusing to Crusade", "+");
        scr_event_log("red", "No ships designated for Crusade.");
    }
}

static resolve_necron = function() {
    refresh_p_data();
    alter_disposition(eFACTION.INQUISITION, -8);
    var _alert_text = $"The Necron Tomb of planet {p_data.name()} has not been deactivated in time.  It has awakened, rank upon rank of Necrons pouring out to the planet's surface.  The Inquisition is not pleased with your failure.";
    scr_popup("Inquisition Mission Failed", _alert_text, "necron_army", "");
    scr_event_log("red", $"Inquisition Mission Failed: Bombing run failed; the Necron Tomb on {p_data.name()} has become active.");

    p_data.add_forces(eFACTION.NECRONS, 4);
    if (awake_tomb_world(p_data.features) == 0) {
        awaken_tomb_world(p_data.features);
    }
}

static resolve_spyrer = function() {
    refresh_p_data();
    var _planet_name = p_data.name();
    alter_disposition(eFACTION.INQUISITION, -3);
    var _alert_text = $"The Spyrer on {_planet_name} has been left unchecked.  In the ensuing carnage some high-ranking officials have been killed, along with several Nobles.  Panic is running amock in several parts of the hives and the Inquisition is less than pleased.";
    var _text = "Inquisition Mission Failed: The Spyrer on {_planet_name} was not removed.";
    scr_popup("Inquisition Mission Failed", _alert_text, "spyrer", "");
    scr_event_log("red", _text);
}

static per_turn_check_spyrer = function() {
    refresh_p_data();
    if (p_data.player_forces > 20) {
        var tixt = "The Spyrer on " + planet_numeral_name(run, id) + " seems to have vanished, presumably gone into hiding.";
        scr_popup("Spyrer Rampage", tixt, "spyrer", "");
    } else if (p_data.player_forces <= 20) {
        new_end_turn_battle(30, "spyrer");
    }
}

static per_turn_check_fallen = function() {
    refresh_p_data();
    if (p_data.player_forces > 0){
        if (choose(true, false)) {
            new_end_turn_battle(10, choose(true, false) ?  "fallen1" : "fallen2");
        } else {
            if (remove_planet_problem(run, "fallen")) {
                var tixt = "Your marines have scoured " + planet_numeral_name(run, id) + " in search of the Fallen.  Despite their best efforts, and meticulous searching, none have been found.  It appears as though the information was faulty or out of date.";
                scr_popup("Hunt the Fallen", tixt, "fallen", "");
                scr_event_log("", $"Mission Successful: No Fallen located upon {planet_numeral_name(run, id)}");
            }
        }
    }
}

static resolve_fallen = function() {
    //TODO marker point for cohesion mechanics
    refresh_p_data();
    var _alert_text = "";
    if (irandom(100) > 33) {
        // Give all marines +3d6 corruption and reduce loyalty by 20*/
        for (var _co = 0; _co <= obj_ini.companies; _co++) {
            for (var _me = 0; _me < company_length(_co); _me++) {
                var _unit = fetch_unit([_co, _me]);
                if (_unit.base_group != "astartes") {
                    continue;
                }
                _unit.edit_corruption(irandom_range(3, 6));
                _unit.alter_loyalty(-10);
            }
        }
    }
    _alert_text = $"Any Fallen that may have been on {p_data.name()} ";
    _alert_text += "have been given sufficient time to escape.  Morale within your chapter has plummeted; some of your battle brothers have become restless and speak among eachother in hushed tones.";
    scr_popup("Hunt the Fallen Failed", _alert_text + "\n\n(Chapter wide loyalty: -10)\nChaplains note marked changes in behaviour of some brothers", "fallen", "");
    obj_controller.loyalty -= 10;
    obj_controller.loyalty_hidden -= 10;
    scr_event_log("red", $"Mission Failed: Any Fallen within the {system.name} system have been given time to escape.");
}

static per_turn_check_mech_raider = function() {
    refresh_p_data();
    var _techs = collect_role_group(SPECIALISTS_TECHS, [system.name, planet, -1]);
    var _lr_count = scr_vehicle_count("Land Raider", [system.name, planet, -1]);
    if ((array_length(_techs) >= 6) && (_lr_count >= 1)) {
        var _percent_complete = increment_mission_completion(data);
        scr_alert("", "mission", $"Mechanicus Mission on {p_data.name()} is {floor(_percent_complete)}% complete.", 0, 0);
        if (_percent_complete >= 100) {
            p_data.remove_problem(p_id);
            scr_mission_reward("mech_raider", system, planet);
            timer = -1
            per_turn_checks = false;
            zero_timer_checks = false;
        }
    }
}

static resolve_mech_raider_failed = function() {
    refresh_p_data();
    var _alert_text = $"Mechanicus Mission Failed: Land Raider testing at {p_data.name()}.";
    scr_alert("red", "mission_failed", _alert_text, 0, 0);
    scr_event_log("red", _alert_text);
    p_data.alter_disposition(eFACTION.MECHANICUS, -6);
    p_data.remove_problem(p_id);
}

static per_turn_check_mech_bionics = function() {
    refresh_p_data();
    var _units = p_data.collect_planet_group();
    var _bionics = _units.tally_attr("bionics");
    if (_bionics >= 10) {
        var _percent_complete = increment_mission_completion(data);
        scr_alert("", "mission", $"Mechanicus Mission on {p_data.name()} is {floor(_percent_complete)}% complete.", 0, 0);
        if (_percent_complete >= 100) {
            p_data.remove_problem(p_id);
            scr_mission_reward("mech_bionics", id, planet);
            timer = -1
            per_turn_checks = false;
            zero_timer_checks = false;
        }
    }
}

static resolve_mech_bionics_failed = function() {
    refresh_p_data();
    var _alert_text = $"Mechanicus Mission Failed: bionics testing at {p_data.name()}.";
    scr_alert("red", "mission_failed", _alert_text, 0, 0);
    scr_event_log("red", _alert_text);
    p_data.alter_disposition(eFACTION.MECHANICUS, -6);
    p_data.remove_problem(p_id);
}

static per_turn_check_mech_tomb2 = function() {
    refresh_p_data();
    data.turns++;
    var _battli = 0;
    var _roll1 = roll_dice_chapter(1, 100 + data.turns, "low");

    if (_roll1 > 98) {
        if ((_roll1 >= 90) && (_roll1 < 98)) {
            _battli = 1;
        } // oops
        if (_roll1 >= 98) {
            _battli = 2;
        } // very oops, much necron, wow

        if ((_battli > 0) && (p_player[planet] > 0)) {
            // Queue the battle
            var _special = _battli == 1 ? "study2a" : "study2b";
            //currently inaccessible 
            if (obj_turn_end.battle_opponent[obj_turn_end.battles] == 11) {
                if (p_data.has_feature(eP_FEATURES.CHAOSWARBAND)) {
                    _special = "ChaosWarband";
                }
            }
            new_end_turn_battle(13, _special);
        }
        if ((_battli > 0) && (p_player[planet] <= 0)) {
            // XDDDDD
            scr_popup("Mechanicus Mission Failed", $"The Mechanicus Research team on planet {p_data.name()} have been killed by Necrons in the absence of your astartes.  The Mechanicus are absolutely livid, doubly so because of the promised security they did not recieve.", "", "");
            obj_controller.turns_ignored[3] += choose(8, 10, 12, 14, 16, 18, 20, 22, 24);
            p_data.alter_disposition(eFACTION.MECHANICUS, -25);
            p_data.remove_problem(p_id);
        }
    } else {
        if (_roll1 > 20) {
            scr_alert("", "mission", $"Adeptus Mechanicus research within the Necron Tomb of {p_data.name()} continues.", 0, 0);
        } else if (_roll1 <= 20) {
            var _text, _reward = choose(1, 1, 2);
            if (scr_has_adv("Tech-Brothers")) {
                _reward = choose(1, 2);
            }

            if (_reward == 1) {
                obj_controller.requisition += 400;
                _text = $"The Mechanicus Research team on planet {p_data.name()} have completed their work without any major setbacks.  Pleased with your astartes' work, they have granted you 400 Requisition to be used as you see fit.";
                scr_event_log("", $"Mechanicus Mission Completed: The Mechanicus research team on {p_data.name()} have completed their work.");
            } else if (_reward == 2) {
                var _last_artifact = scr_add_artifact("random", "", 0);
                _text = $"The Mechanicus Research team on planet {p_data.name()} have completed their work without any major setbacks.  Pleased with your astartes' work, they have granted your Chapter an artifact, to be used as you see fit.";
                scr_event_log("", $"Mechanicus Mission Completed: The Mechanicus research team on {p_data.name()} have completed their work.");
                scr_event_log("", "Artifact gifted from Mechanicus.");
            }
            _text += "\n" + add_disposition(eFACTION.MECHANICUS, 1);
            scr_popup("Mechanicus Mission Completed", _text, "mechanicus", "");
            p_data.remove_problem(p_id);
            timer = -1
            per_turn_checks = false;
            zero_timer_checks = false;
        }
    }
}

static per_turn_check_mech_tomb1 = function() {
    refresh_p_data();
    var _marines = collect_role_group("all", [system.name, planet, -1]);
    if (array_length(_marines) >= 20) {
        stage_id = "exploring";
        timer = 999;
        data.turns : 0;
        scr_popup("Mechanicus Research", $"The Mechanicus Research team on planet {p_data.name()} has taken note of your Astartes and are now prepared to begin their research.  Your marines are to stay on the planet until further notice.", "necron_cave", "");
    }
}

static resolve_mech_tomb1_failed = function() {
    refresh_p_data();
    var _alert_text = $"Mechanicus Mission Failed: Necron Tomb Study at {p_data.name()}.";
    scr_alert("red", "mission_failed", _alert_text, 0, 0);
    scr_event_log("red", _alert_text, system.name);
    p_data.alter_disposition(eFACTION.MECHANICUS, -15);
    p_data.remove_problem(p_id);
}

static resolve_mech_mars = function() {
    refresh_p_data();
    mechanicus_mars_mission_target_time_elapsed(planet);
}


static init_garrison_mission = function() {
    refresh_p_data();
    var mission_data = problems_data[mission_slot];
    if (stage_id != "preliminary") {
        exit;
    }
    var _numeral_name = p_data.name();
    stage_id = "active";
    var _garrison_length = 10 + irandom(6);
    timer = _garrison_length;
    var _gar_pop = instance_create(0, 0, obj_popup);
    //TODO some new universal methods for popups
    _gar_pop.title = $"Requested Garrison Provided to {_numeral_name}";
    _gar_pop.text = $"The governor of {_numeral_name} Thanks you for considering his request for a garrison, you agree that the garrison will remain for at least {_garrison_length} months.";
    _gar_pop.add_option("Commence Garrison");
    _gar_pop.image = "";
    _gar_pop.cooldown = 8;
    obj_controller.cooldown = 8;
    scr_event_log("", $"Garrison committed to {_numeral_name} for {_garrison_length} months.", p_data.system.name);
}

static complete_garrison_mission= function() {
    refresh_p_data();
    if (stage_id != "active"){
        exit;
    }

    p_data.garrisons.update();
    if (p_data.current_owner != eFACTION.IMPERIUM || !p_data.garrisons.garrison_force) {
        p_data.add_disposition(-20);
        scr_popup($"Agreed Garrison of {name()}", $"your agreed garrison of  {name()} was cut short by your chapter the planetary governor has expressed his displeasure (disposition -20)", "", "");
        return;
    }

    var _mission_string = $"The garrison on {name()} has finished the period of garrison support agreed with the planetary governor.";
    var _result = p_data.garrisons.garrison_disposition_change();
    if (!p_data.garrisons.garrison_leader) {
        p_data.garrisons.find_leader();
    }

    var _effect = 0;
    if (_result == "none") {
        //TODO make a dedicated plus minus string function if there isn't one already
    } else if (_result < 0) {
        _effect = _result * irandom_range(1, 5);
        _mission_string += $"A number of diplomatic incidents occured over the period which had considerable negative effects on our disposition with the planetary governor (disposition -{_effect})";
    } else {
        _effect = _result * irandom_range(1, 5);
        _mission_string += $"As a diplomatic mission the duration of the stay was a success with our political position with the planet being enhanced greatly (disposition +{_effect})";
    }

    p_data.add_disposition(_effect);
    var _tester = global.character_tester;
    var _widom_test = _tester.standard_test(garrisons.garrison_leader, "wisdom", 0, ["siege"]);

    if (_widom_test[0]) {
        p_data.alter_fortification(1);
        _mission_string += $"while stationed {garrisons.garrison_leader.name_role()} makes several notable observations and is able to instruct the planets defense core leaving the world better defended (fortifications+1).";
    }
    //TODO just generall apply this each turn with a garrison to see if a cult is found
    if (has_feature(eP_FEATURES.GENE_STEALER_CULT)) {
        var _cult = get_features(eP_FEATURES.GENE_STEALER_CULT)[0];
        if (_cult.hiding) {
            _widom_test = _tester.standard_test(garrisons.garrison_leader, "wisdom", 0, ["tyranids"]);
            if (_widom_test[0]) {
                _cult.hiding = false;
                _mission_string += "Most alarmingly signs of a genestealer _cult are noted by the garrison. how far the rot has gone will now need to be investigated and the xenos taint purged.";
            }
        }
    }
    scr_popup($"Agreed Garrison of {name()} complete", _mission_string, "", "");
}
}