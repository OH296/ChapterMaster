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
static refresh_p_data = function(){
	p_data = system.get_planet_data(planet);
}
stage_id = "";
extend_timer_for_warp_storm = true;

static basic_turn_end = function(){
	refresh_p_data();
	if (p_data.system.storm - 1 > 0){
		timer--;
	}
	if (timer == 0){
		var _func = undefined;
		switch(p_id){
			case "hunt_beast":
				_func = resolve_hunt_beast;
				break;
			case "train_forces":
				_func = resolve_train_forces;
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

	}
}
__init();

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

static complete_train_forces_mission = function() {
    refresh_p_data();
    if (stage_id == "active") {
        var man_conditions = {
            "job": "train_forces",
            "max": 1,
        };
        var _mission_string = "";
        var _trainer = collect_role_group("all", [system.name, planet, 0], false, man_conditions);
        if (array_length(_trainer)) {
            var _unit_report_string = "";
            var _tester = global.character_tester;
            var _wis_test_difficulty = -20;
            _trainer = _trainer[0];
            var _tyannic_vet = _trainer.has_trait("tyrannic_vet");
            if (_tyannic_vet) {
                _wis_test_difficulty += 10;
                if (p_data.has_feature(eP_FEATURES.GENE_STEALER_CULT)) {
                    var _cult = p_data.get_features(eP_FEATURES.GENE_STEALER_CULT)[0];
                    if (_cult.hiding) {
                        p_data.delete_feature(eP_FEATURES.GENE_STEALER_CULT);
                        _mission_string += $"Fortune has smiled on this mission, {_trainer.name_role()}'s abilities as a Veteran of dealing with the Tyranids came in handy and in a short period was able to discern the existencee of a cult. He was able to organise those  he considered to be still loyal to rally an extermiation of the cult, reeports suggest he was so successful as to have completely wiped the genestealer presence from the planet";
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
}