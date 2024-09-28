function scr_cheatcode(argument0) {
	try{
		if (argument0 == "") {
			return;
		}

		var input_string = string_split(argument0, " ");
		
		if (!is_array(input_string)) {
			input_string = array_create(4);
			input_string[0] = argument0;
		} else if (array_length(input_string) < 4) {
			for (var i = array_length(input_string); i < 4; i++) {
				array_push(input_string, "1");
			}
		}

		var cheat_name = string_lower(input_string[0]);

		if (cheat_name!= "") {
			switch (cheat_name) {
				case "finishforge":
					with (obj_controller) {
						forge_points = 1000000;
						forge_queue_logic();
					}
					break;
				case "newapoth":
					obj_controller.apothecary_points = 50;
					break;
				case "newpsyk":
					obj_controller.psyker_points = 70;
					break;
				case "newtech":
					obj_controller.tech_points = 400;
					break;
				case "newchap":
					obj_controller.chaplain_points = 50;
					break;
				case "additem":
					if (input_string[3] != "1") {
						scr_add_item(input_string[1], string_digits(input_string[2]), string_lower(input_string[3]));
					} else {
						scr_add_item(input_string[1], string_digits(input_string[2]));
					}
					break;
				case "artifact":
					if (input_string[1] != "1") {
						scr_add_artifact(input_string[1], "", 6, obj_ini.ship[1], 501);
					} else {
						scr_add_artifact("random", "", 6, obj_ini.ship[1], 501);
					}
					break;
				case "sisterhospitaler":
					repeat(string_digits(input_string[1])){
						scr_add_man("Sister Hospitaler", 0, "", "", 0, true, "default");
					}
					break;
				case "sisterofbattle":
					repeat(string_digits(input_string[1])){
						scr_add_man("Sister of Battle", 0, "", "", 0, true, "default");
					}
					break;
				case "skitarii":
					repeat(string_digits(input_string[1])){
						scr_add_man("Skitarii", 0, "", "", 0, true, "default");
					}
					break;
				case "techpriest":
					repeat(string_digits(input_string[1])){
						scr_add_man("Techpriest", 0, "", "", 0, true, "default");
					}
					break;
				case "crusader":
					repeat(string_digits(input_string[1])){
						scr_add_man("Crusader", 0, "", "", 0, true, "default");
					}
					break;
				case "flashgit":
					repeat(string_digits(input_string[1])){
						scr_add_man("Flash Git", 0, "", "", 0, true, "default");
					}
					break;
				case "chaosfleetspawn":
					spawn_chaos_warlord();
					break;
				case "neworkfleet":
					var p_fleet = get_largest_player_fleet();
					with (instance_nearest(p_fleet.x, p_fleet.y, obj_star)) {
						new_ork_fleet(x, y);
					}
					break;
				case "inquisarti":
					scr_quest(0, "artifact_loan", 4, 10);
					var last_artifact = scr_add_artifact("good", "inquisition", 0, obj_ini.ship[1], 501);
					break;
				case "govmission":
					with (obj_star) {
						for (i = 1; i <= planets; i++) {
							var existing_problem = false; //has_any_problem_planet(i);
							if (!existing_problem) {
								if (p_owner[i] == eFACTION.Imperium) {
									show_debug_message("mission");
									scr_new_governor_mission(i);
								}
							}
						}
					}
					break;
				case "artifactpopulate":
					with (obj_star) {
						for (i = 1; i <= planets; i++) {
							array_push(p_feature[i], new new_planet_feature(P_features.Artifact));
						}
					}
					break;
				case "event":
					if (input_string[1] == "crusade") {
						show_debug_message("crusading");
						with (obj_controller) {
							launch_crusade();
						}
					} else if (input_string[1] == "tomb") {
						show_debug_message("necron_tomb_awaken");
						with (obj_controller) {
							awaken_tomb_event();
						}
					} else if (input_string[1] == "techuprising") {
						var pip = instance_create(0, 0, obj_popup);
						pip.title = "Technical Differences!";
						pip.text = "You Recive an Urgent Transmision A serious breakdown in culture has coccured causing believers in tech heresy to demand that they are given preseidence and assurance to continue their practises";
						pip.image = "tech_uprising";
					} else if (input_string[1] == "inspection") {
						new_inquisitor_inspection();
					} else if (input_string[1] == "slaughtersong") {
						create_starship_event();
					} else {
						with (obj_controller) {
							scr_random_event(false);
						}
					}
					break;
				case "infreq":
					if (global.cheat_req == 0) {
						global.cheat_req = 1;
						cheatyface = 1;
						obj_controller.tempRequisition = obj_controller.requisition;
						obj_controller.requisition = 51234;
					} else {
						global.cheat_req = 0;
						cheatyface = 1;
						obj_controller.requisition = obj_controller.tempRequisition;
					}
					break;
				case "infseed":
					if (global.cheat_gene == 0) {
						global.cheat_gene = 1;
						cheatyface = 1;
						obj_controller.tempGene_seed = obj_controller.gene_seed;
						obj_controller.gene_seed = 9999;
					} else {
						global.cheat_gene = 0;
						cheatyface = 1;
						obj_controller.gene_seed = obj_controller.tempGene_seed;
					}
					break;
				case "debug":
					if (global.cheat_debug == 0) {
						global.cheat_debug = 1;
						cheatyface = 1;
					} else {
						global.cheat_debug = 0;
						cheatyface = 1;
					}
					break;
				case "test":
					cheatyface = 1;
					diplomacy = 10.5;
					scr_dialogue("test");
					break;
				case "req": 
					if (global.cheat_req == 0) {
						cheatyface = 1;
						obj_controller.requisition = string_digits(input_string[1]);
					}
					break;
				case "seed":
					if (global.cheat_gene == 0) {
						cheatyface = 1;
						obj_controller.gene_seed = string_digits(input_string[1]);
					}
					break;
				case "depimp":
					obj_controller.disposition[2] = string_digits(input_string[1]);
					break;
				case "depmec":
					obj_controller.disposition[3] = string_digits(input_string[1]);
					break;
				case "depinq":
					obj_controller.disposition[4] = string_digits(input_string[1]);
					break;
				case "depecc":
					obj_controller.disposition[5] = string_digits(input_string[1]);
					break;
				case "depeld":
					obj_controller.disposition[6] = string_digits(input_string[1]);
					break;
				case "depork":
					obj_controller.disposition[7] = string_digits(input_string[1]);
					break;
				case "deptau":
					obj_controller.disposition[8] = string_digits(input_string[1]);
					break;
				case "deptyr":
					obj_controller.disposition[9] = string_digits(input_string[1]);
					break;
				case "depcha":
					obj_controller.disposition[10] = string_digits(input_string[1]);
					break;
				case "depall":
					global.cheat_disp = 1;
					cheatyface = 1;
					for (var i = 2; i <= 10; i++) {
						obj_controller.disposition[i] = string_digits(input_string[1]);
					}
					break;
				case "stc":
					repeat(cheat_name[1]){
						scr_add_stc_fragment();
					}
					break;
				case "recruit":
					var _start_pos = 0
					var length = (array_length(obj_controller.recruit_name) - 1)
					var i = 0;
					while (i < length) {
						if (obj_controller.recruit_name[i] == "") {
							_start_pos = i
							break
						} else {
							i++
							continue
						}
					}
					for (i = _start_pos; i < (string_digits(input_string[1]) + _start_pos); i++) {
						array_insert(obj_controller.recruit_corruption, i, 0);
						array_insert(obj_controller.recruit_distance, i, 0);
						array_insert(obj_controller.recruit_training, i, 1);
						array_insert(obj_controller.recruit_exp, i, 20);
						array_insert(obj_controller.recruit_data, i, {});
						array_insert(obj_controller.recruit_name, i, global.name_generator.generate_space_marine_name());
					}
					scr_alert("green", "recruitment", (string(input_string[1]) + "has started training."), 0, 0)
					break;
			}
		}
	} catch(_exception) {
		log_into_file(_exception.longMessage);
		log_into_file(_exception.script);
		log_into_file(_exception.stacktrace);
	}
}