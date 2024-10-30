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

function savechapter(){
	//saves a player made chapter into an ini file for use later
	chaptersave  = "chaptersave#1.ini"
	if(file_exists(chaptersave)){
	file_delete(chaptersave);
	}
    ini_open(chaptersave);

    // Global variables
	ini_write_string("Save","chapter_id",chapter)
    ini_write_string("Save","chapter_name",chapter);
	ini_write_real("Save","icon#",icon);
    ini_write_string("Save","icon_name",icon_name);
    ini_write_real("Save","strength",strength);
    ini_write_real("Save","purity",purity);
    ini_write_real("Save","stability",stability);
	ini_write_real("Save","cooperation",cooperation);
	ini_write_real("Save","founding",founding);
	
	ini_write_real("Save","fleet_type",fleet_type);
	ini_write_string("Save","homeworld",homeworld);
	ini_write_string("Save","homeworld_name",homeworld_name);
	ini_write_string("Save","recruiting",recruiting);
	ini_write_string("Save","recruiting_name",recruiting_name);
	ini_write_real("Save","home_worldexists",homeworld_exists);
	ini_write_real("Save","recruiting_exists",recruiting_exists);
	ini_write_real("Save","home_world_rule",homeworld_rule);
	ini_write_string("Save","aspirant_trial",aspirant_trial);
	
	ini_write_string("Controller","main_color",col[main_color]);
    ini_write_string("Controller","secondary_color",col[secondary_color]);
    ini_write_string("Controller","main_trim",col[main_trim]);
    ini_write_string("Controller","left_pauldron",col[left_pauldron]);
    ini_write_string("Controller","right_pauldron",col[right_pauldron])
    ini_write_string("Controller","lens_color",col[lens_color]);
    ini_write_string("Controller","weapon_color",col[weapon_color]);
    ini_write_real("Controller","col_special",col_special);
    ini_write_real("Controller","trimmed",trim);
	ini_write_real("Controller","equal_specialists",equal_specialists)
	



	ini_write_real("Creation","preomnor",preomnor);
    ini_write_real("Creation","voice",voice);
    ini_write_real("Creation","doomed",doomed);
    ini_write_real("Creation","lyman",lyman);
    ini_write_real("Creation","omophagea",omophagea);
    ini_write_real("Creation","ossmodula",ossmodula);
    ini_write_real("Creation","membrane",membrane);
    ini_write_real("Creation","zygote",zygote);
    ini_write_real("Creation","betchers",betchers);
    ini_write_real("Creation","catalepsean",catalepsean);
    ini_write_real("Creation","secretions",secretions);
    ini_write_real("Creation","occulobe",occulobe);
    ini_write_real("Creation","mucranoid",mucranoid)
	ini_write_string("Creation","battle_cry",battle_cry);
	
	ini_write_string("Creation","recruiter_name",recruiter);
	ini_write_string("Creation","mutation",mutations);
	ini_write_string("Creation","mutations_selected",mutations_selected);
    ini_write_real("Creation","successors",successors);
    ini_write_real("Creation","progenitor_disposition",disposition[1]);
    ini_write_real("Creation","imperium_disposition",disposition[2]);
    ini_write_real("Creation","admech_disposition",disposition[3]);
	ini_write_real("Creation","astartes_disposition",disposition[6]);
	ini_write_real("Creation","inquisition_disposition",disposition[4]);
	ini_write_real("Creation","ecclesiarchy_disposition",disposition[5]);
	ini_write_real("Creation","reserved_disposition",disposition[7]);
	
	
	
    ini_write_string("Creation","chief_name",clibrarian);
    ini_write_string("Creation","high_name",hchaplain);
    ini_write_string("Creation","high2_name",hapothecary);
    ini_write_string("Creation","forgey_name",fmaster);
    ini_write_string("Creation","lord_name",admiral);
	ini_write_string("Creation","master_name",chapter_master_name);
	ini_write_real("Creation","chapter_master_melee",chapter_master_melee);
	ini_write_string("Creation","master_ranged",chapter_master_ranged);
	ini_write_string("Creation","master_specialty",chapter_master_specialty);
	ini_encode_and_json("Creation","complex_livery", complex_livery_data);

	for(var i =1;i<=8;i++){
		ini_write_string("Creation",$"adv21{i}",adv[i])
		ini_write_string("Creation",$"dis21{i}",dis[i])
	}
	
	for(var i=0;i<=22;i++){
	    ini_write_string("Save",$"role_21{i}",role[100][i]);
		ini_write_string("Save",$"wep1_21{i}",wep1[100][i]);
		ini_write_string("Save",$"wep2_21{i}",wep2[100][i])
		ini_write_string("Save",$"armour_21{i}",armour[100][i]);
		ini_write_string("Save",$"gear_21{i}",gear[100][i]);
		ini_write_string("Save",$"mobi_21{i}",mobi[100][i]);
	}
	
	
		

		
		
	load_to_ships=[2,0,0];
	founding21 = founding;
	chapter21=chapter;
	all_chapters[CHAPTERS.CUSTOM_1].name = chapter21; 					

	icon21=icon;
	icon_name21=icon_name;
	fleet_type21=fleet_type;
	strength21=strength;
	purity21=purity;
	stability21=stability;
	cooperation21=cooperation;
	homeworld21=homeworld;
	homeworld_name21=homeworld;
	recruiting_world21=recruiting;
	recruiting_name21=recruiting_name;
	homeworld_exists21=homeworld_exists;
	recruiting_exists21=recruiting_exists;
	homeworld_rule21=homeworld_rule;
	aspirant_trial21=aspirant_trial;

	    // Pauldron2: Left, Pauldron: Right
		 color_to_main21=col[main_color];
	    
	    
	    
	    
	    

	   
		 color_to_secondary21=    col[secondary_color]
		 color_to_trim21=col[main_trim];
	     color_to_pauldron21=col[right_pauldron];
		 color_to_pauldron2_21=col[left_pauldron];
		 color_to_lens21=col[lens_color];
	     color_to_weapon21=col[weapon_color];
		 col_special21=col_special;
		 trim21=trim;
	     hapothecary21=hapothecary;
	     hchaplain21=hchaplain;
	     clibrarian21=clibrarian;
	     fmaster21=fmaster;
	     admiral21=admiral;
		recruiter21=recruiter;
	     battle_cry_21=battle_cry;
		 //monastery_name21=monastery_name;
		 //master_name21=master_name;
	     equal_specialists21=equal_specialists

     
    // load_to_ships=0;

     successors21=successors;
     mutations21=mutations;
	 mutations_selected21=mutations_selected;
     preomnor21=preomnor;
	 voice21=voice;
	 doomed21=doomed;
	 lyman21=lyman;
	 omophagea21=omophagea;
	 ossmodula21=ossmodula;
	 membrane21=membrane;
     zygote21=zygote;
	 betchers21=betchers;
	 catalepsean21=catalepsean;
	 secretions21=secretions;
	 occulobe21=occulobe;
	 mucranoid21=mucranoid;
     disposition21[1]=disposition[1];// Prog
     disposition21[2]=disposition[2];
	 disposition21[3]=disposition[3];
	 disposition21[4]=disposition[4];
	 disposition21[5]=disposition[5];
     disposition21[6]=disposition[6];// Astartes
     disposition21[7]=disposition[7];// Reserved
     chapter_master_name21=chapter_master_name;
	 chapter_master_melee21=chapter_master_melee;
     chapter_master_ranged21=chapter_master_ranged;
	 chapter_master_specialty21= chapter_master_specialty;

	 for(var i = 1; i <= 8; i++){
		adv21[i] = adv[i];
		dis21[i] = dis[i];
	 }

  for (var i=0;i<=22;i++){
    role_21[i]=role[100][i];
	wep1_21[i]=wep1[100][i]
	wep2_21[i]=wep2[100][i]
	armour_21[i]=armour[100][i]
	gear_21[i]=gear[100][i]
	mobi_21[i]=mobi[100][i]
}

ini_close(); 
		 

}