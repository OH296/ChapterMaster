/// @mixin obj_creation
function scr_save_chapter(chapter_id){
	//saves a player made chapter into json file in AppData for use later
	var chaptersave  = $"chaptersave#{chapter_id}.json";
	var custom_splash = 97;
	var chap = new ChapterData();
	chap.id = chapter_id;
	chap.splash = custom_splash;
	chap.name = chapter_name;
	chap.flavor = "Your Chapter";
	chap.founding = founding;
	chap.origin = CHAPTER_ORIGIN.CUSTOM;
	chap.icon = icon;
	chap.icon_name = obj_creation.icon_name || "da";
	chap.aspirant_trial = aspirant_trial;
	chap.fleet_type = fleet_type;
	chap.strength = strength;
	chap.purity = purity;
	chap.stability = stability;
	chap.cooperation = cooperation;
	chap.homeword = homeworld;
	chap.homeworld_exists = homeworld_exists;
	chap.homeworld_name = homeworld_name;
	chap.homeworld_rule = homeworld_rule;
	chap.recruiting = recruiting;
	chap.recruiting_exists = recruiting_exists;
	chap.advantages = adv;
	chap.disadvantages = dis;
	chap.colors = {
		main: color_to_main,
		secondary: color_to_secondary,
		pauldron_l: color_to_pauldron,
		pauldron_r: color_to_pauldron2,
		trim: color_to_trim,
		trim_on: trim,
		lens: color_to_lens,
		weapon: color_to_weapon,
		special: col_special
	};
	chap.names = {
		hapothecary: hapothecary,
		hchaplain: hchaplain,
		admiral: admiral,
		clibrarian: clibrarian,
		recruiter: recruiter,
		fmaster: fmaster,
		honorcapt: global.name_generator.generate_imperial_name(),
		watchmaster: global.name_generator.generate_imperial_name(),
		arsenalmaster: global.name_generator.generate_imperial_name(),
		marchmaster: global.name_generator.generate_imperial_name(),
		ritesmaster: global.name_generator.generate_imperial_name(),
		victualler: global.name_generator.generate_imperial_name(),
		lordexec: global.name_generator.generate_imperial_name(),
		relmaster: global.name_generator.generate_imperial_name(),
	}
	chap.mutations = {
		preomnor: preomnor,
		voice: voice,
		doomed: doomed,
		lyman: lyman,
		omophagea: omophagea,
		ossmodula: ossmodula,
		membrane: membrane,
		zygote: zygote,
		betchers: betchers,
		catalepsean: catalepsean,
		secretions: secretions,
		occulobe: occulobe,
		mucranoid: mucranoid,
	}
	chap.battle_cry = battle_cry;
	chap.equal_specialists = equal_specialists;
	chap.load_to_ships = {
		escort_load: load_to_ships[0],
		split_scouts: load_to_ships[1],
		split_vets: load_to_ships[2],
	};
	chap.disposition = disposition;
	if(variable_instance_exists(self.id, "monastery_name")){
		chap.monastary_name = monastery_name;
	}
	chap.chapter_master = {
		name: chapter_master_name,
		melee: chapter_master_melee,
		ranged: chapter_master_ranged,
		specialty: chapter_master_specialty,
		traits: [],
	}

	global.chapter_creation_object = chap;

	var data_json = json_stringify({chapter: global.chapter_creation_object}, true);
	if(file_exists(chaptersave)){
		file_delete(chaptersave);
	}
	var fileid = file_text_open_write(chaptersave);
	file_text_write_string(fileid, data_json);
	file_text_close(fileid)
	

}