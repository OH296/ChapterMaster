#macro unit_type_unknown "unknown"
#macro unit_type_astartes "astartes"
#macro unit_type_terminator "terminator"
#macro unit_type_dreadnought "dreadnought"
#macro unit_type_land_raider "land_raider"
#macro unit_type_rhino "rhino"
#macro unit_type_predator "predator"
#macro unit_type_land_speeder "land_speeder"
#macro unit_type_whirlwind "whirlwind"

function scr_weapons_equip() {

	// gets the weapons for the particular slot


	var equipment_slot = 0;
	var equipment_tab = 0;
	var unit_type = "";
	var unit_is_vehicle = false;
	var standard_equip = false;
	var creation_equip = false;
	var mass_equip = false;
	var equip_data;
	var valid = -1;

	var i = -1;
	repeat(50) {
		i += 1;
		item_name[i] = "";
	}

	// This is for equipping the selected marines on the company view
	if (instance_exists(obj_controller)) and(instance_exists(obj_popup)) and(!instance_exists(obj_mass_equip)) {
		standard_equip = true;
		equipment_slot = target_comp;
		equipment_tab = tab;
		unit_type = obj_popup.unit_type;
		unit_is_vehicle = obj_popup.unit_is_vehicle;
	}
	// This is for equipping roles on the creation screen
	if (instance_exists(obj_creation)) {
		creation_equip = true;
		equipment_slot = target_gear;
		equipment_tab = tab;
		unit_type = obj_creation_popup.type - 100;
		if (unit_type >= 50) {
			return;
		} else if (unit_type == 4) {
			unit_type = unit_type_terminator;
		} else if (unit_type == 6) {
			unit_type = unit_type_dreadnought;
		} else {
			unit_type = unit_type_astartes;
		}
	}
	// This is for equipping roles on the chapter management screen
	if (instance_exists(obj_mass_equip)) {
		// equipment_slot=tab;equipment_tab=1;
		mass_equip = true;
		equipment_tab = tab;
		equipment_slot = tab;
		unit_type = obj_mass_equip.role;
		if (unit_type >= 50) {
			return;
		} else if (unit_type == 4) {
			unit_type = unit_type_terminator;
		} else if (unit_type == 6) {
			unit_type = unit_type_dreadnought;
		} else {
			unit_type = unit_type_astartes;
		}
	}

	// if ((unit_type<50) and (unit_type!=6) and (unit_type!=4)) then unit_type=1
	// unit_type=1 for normal marine gear
	// unit_type=4 for terminators
	// unit_type=6 for dread
	// unit_type=50 for Land Raider
	// unit_type=51 for Rhino
	// unit_type=52 for Predator
	// unit_type=53 for Land Speeder
	// unit_type=54 for Whirlwind

	if (equipment_slot<3) and (unit_type==unit_type_astartes){
		if(equipment_tab=1){
			if (standard_equip){ // Infantry Ranged
				item_name[1]="(None)";
				item_name[2]="(any)";
				valid=3;
				for (i=0;i<array_length(obj_ini.equipment);i++){
					if (obj_popup.master_crafted==1){
						if (!array_contains(obj_ini.equipment_quality[i],"master_crafted")){
							continue;
						}
					}				
					equip_data = gear_weapon_data("weapon", obj_ini.equipment[i]);
					if (is_struct(equip_data) && obj_ini.equipment_number[i]>0){
						if (equip_data.range>1.1 && !equip_data.has_tag("vehicle")){
							item_name[valid]=equip_data.name;
							valid++;
						}
					}
				}
			} else {
				item_name = [
					"",
					"(None)",
					"Bolt Pistol",
					"Bolter",
					"Stalker Pattern Bolter",
					"Storm Bolter",
					"Heavy Bolter",
					"Combiflamer",
					"Flamer",
					"Heavy Flamer",
					"Lascannon",
					"Lascutter",
					"Infernus Pistol",
					"Meltagun",
					"Multi-Melta",
					"Plasma Pistol",
					"Plasma Gun",
					"Plasma Cannon",
					"Missile Launcher",
					"Autocannon",
					"Sniper Rifle",
					"Webber"
				];
			}
		}else if (equipment_tab=2){
			if (standard_equip){
				item_name[1]="(None)";
				item_name[2]="(any)";
				valid=3;				
				for (i=0;i<array_length(obj_ini.equipment);i++){
					if (obj_popup.master_crafted==1){
						if (!array_contains(obj_ini.equipment_quality[i],"master_crafted")){
							continue;
						}
					}				
					equip_data = gear_weapon_data("weapon", obj_ini.equipment[i]);
					if (is_struct(equip_data) && obj_ini.equipment_number[i]>0){
						if (equip_data.range<=1.1  && !equip_data.has_tag("vehicle")){
							item_name[valid]=equip_data.name;
							valid++;
						}
					}
				}
			} else {
				item_name = [
					"",
					"Combat Knife",
					"Chainsword",
					"Chainaxe",
					"Eviscerator",
					"Power Sword",
					"Power Axe",
					"Power Spear",
					"Power Mace",
					"Power Fist",
					"Boltstorm Gauntlet",
					"Lightning Claw",
					"Force Staff",
					"Thunder Hammer",
					"Heavy Thunder Hammer",
					"Boarding Shield",
					"Storm Shield"
				];
			}
		}
	}

	if (equipment_slot<3) and (unit_type==unit_type_terminator){
		if(equipment_tab=1){
			if (standard_equip){ // Infantry Ranged
				item_name[1]="(None)";
				item_name[2]="(any)";
				valid=3;
				for (i=0;i<array_length(obj_ini.equipment);i++){
					if (obj_popup.master_crafted==1){
						if (!array_contains(obj_ini.equipment_quality[i],"master_crafted")){
							continue;
						}
					}				
					equip_data = gear_weapon_data("weapon", obj_ini.equipment[i]);
					if (is_struct(equip_data) && obj_ini.equipment_number[i]>0){
						if (equip_data.range>1.1 && equip_data.has_unit(unit_type_terminator)){
							item_name[valid]=equip_data.name;
							valid++;
						}
					}
				}
			} else {
				item_name = [
					"",
					"(None)",
					"Storm Bolter",
					"Combiflamer",
					"Heavy Flamer",
					"Multi-Melta",
					"Plasma Cannon",
					"Assault Cannon"
				];
			}
		}else if (equipment_tab=2){
			if (standard_equip){
				item_name[1]="(None)";
				item_name[2]="(any)";
				valid=3;				
				for (i=0;i<array_length(obj_ini.equipment);i++){
					if (obj_popup.master_crafted==1){
						if (!array_contains(obj_ini.equipment_quality[i],"master_crafted")){
							continue;
						}
					}				
					equip_data = gear_weapon_data("weapon", obj_ini.equipment[i]);
					if (is_struct(equip_data) && obj_ini.equipment_number[i]>0){
						if (equip_data.range<=1.1 && equip_data.has_unit(unit_type_terminator)){
							item_name[valid]=equip_data.name;
							valid++;
						}
					}
				}
			} else {
				item_name = [
					"",
					"Chainaxe",
					"Power Sword",
					"Power Axe",
					"Power Mace",
					"Power Fist",
					"Boltstorm Gauntlet",
					"Chainfist",
					"Lightning Claw",
					"Force Staff",
					"Thunder Hammer",
					"Heavy Thunder Hammer",
					"Boarding Shield",
					"Storm Shield"
				];
			}
		}
	}

	if (equipment_slot<3) and (equipment_tab=1) and (unit_type == unit_type_dreadnought){
		var i=0; // Dreadnought Ranged
			item_name[1]="(None)";
			item_name[2]="(any)";
			valid=3;
			if (standard_equip){
				for (i=0;i<array_length(obj_ini.equipment);i++){
					if (obj_popup.master_crafted==1){
						if (!array_contains(obj_ini.equipment_quality[i],"master_crafted")){
							continue;
						}
					}
					equip_data = gear_weapon_data("weapon", obj_ini.equipment[i]);
					if (is_struct(equip_data) && obj_ini.equipment_number[i]>0){
						if (equip_data.range>1.1 && equip_data.has_unit(unit_type_dreadnought)){
							item_name[valid]=equip_data.name;
							valid++;
						}
					}
				}
			} else {
				item_name = [
					"",
					"Multi-Melta",
					"Twin Linked Heavy Flamer Sponsons",
					"Plasma Cannon",
					"Assault Cannon",
					"Autocannon",
					"Missile Launcher",
					"Twin Linked Lascannon",
					"Twin Linked Assault Cannon Mount",
					"Twin Linked Heavy Bolter",
					"Heavy Conversion Beam Projector"
				];
			}
	}

	if (equipment_slot<3) and (equipment_tab=2) and (unit_type == unit_type_dreadnought){
		var i=0; // Dreadnought Melee
		if (standard_equip){
			item_name[1]="(None)";
			item_name[2]="(any)";
			valid=3;		
			for (i=0;i<array_length(obj_ini.equipment);i++){
				if (obj_popup.master_crafted==1){
					if (!array_contains(obj_ini.equipment_quality[i],"master_crafted")){
						continue;
					}
				}				
				equip_data = gear_weapon_data("weapon", obj_ini.equipment[i]);
				if (is_struct(equip_data) && obj_ini.equipment_number[i]>0){
					if (equip_data.range<=1.1 && equip_data.has_unit(unit_type_dreadnought)){
						item_name[valid]=equip_data.name;
						valid++;
					}
				}
			}
		} else {
			i+=1;
			item_name[i]="Close Combat Weapon";
			i+=1;
			item_name[i]="Dreadnought Power Claw";
			i+=1;
			item_name[i]="Dreadnought Lightning Claw";
		}
	}

	if (equipment_slot=3) and (unit_type == unit_type_astartes){ // unit_type == unit_type_astartes for normal infantry gear
	    var i=0;

	    if (!instance_exists(obj_creation)) and (!instance_exists(obj_mass_equip)){
			item_name[1]="(None)";
			item_name[2]="(any)";
			valid=3;		
			for (i=0;i<array_length(obj_ini.equipment);i++){
				equip_data = gear_weapon_data("armour", obj_ini.equipment[i]);
				if (is_struct(equip_data) && obj_ini.equipment_number[i]>0 && equip_data.has_unit(unit_type)){
					item_name[valid]=equip_data.name;
					valid++;
				}
			}
	    }else if (instance_exists(obj_creation)) or (instance_exists(obj_mass_equip)){
	    	var i=0
	        var bub=0;
	        if (instance_exists(obj_creation)){if (type=112) then bub=1;}
	        if (instance_exists(obj_mass_equip)){if (obj_controller.settings=12) then bub=1;}
	        i+=1;item_name[i]="(None)";
	        i+=1;item_name[i]="Scout Armour";
	        // i+=1;item_name[i]="Power Armour";
	        i+=1;item_name[i]="MK3 Iron Armour";
	        i+=1;item_name[i]="MK4 Maximus";
	        i+=1;item_name[i]="MK5 Heresy";
	        i+=1;item_name[i]="MK6 Corvus";
	        i+=1;item_name[i]="MK7 Aquila";
	        i+=1;item_name[i]="MK8 Errant";
	        i+=1;item_name[i]="Artificer Armour";
	        i+=1;item_name[i]="Terminator Armour";
	        i+=1;item_name[i]="Tartaros";
	    }

	    else i+=1;

	    // var bad;bad=0;if (instance_exists(obj_creation_popup)){if ((obj_creation_popup.type-100)!=6) then bad=1;}
	    // if (bad=0){item_name[i]="Dreadnought";}
	}

	if (equipment_slot=3) and (unit_type == unit_type_terminator){ // unit_type == unit_type_astartes for normal infantry gear
	    var i=0;

	    if (!instance_exists(obj_creation)) and (!instance_exists(obj_mass_equip)){
			item_name[1]="(None)";
			item_name[2]="(any)";
			valid=3;		
			for (i=0;i<array_length(obj_ini.equipment);i++){
				equip_data = gear_weapon_data("armour", obj_ini.equipment[i]);
				if (is_struct(equip_data) && obj_ini.equipment_number[i]>0 && equip_data.has_unit(unit_type)){
					item_name[valid]=equip_data.name;
					valid++;
				}
			}
	    }else if (instance_exists(obj_creation)) or (instance_exists(obj_mass_equip)){
	    	var i=0
	        var bub=0;
	        if (instance_exists(obj_creation)){if (type=112) then bub=1;}
	        if (instance_exists(obj_mass_equip)){if (obj_controller.settings=12) then bub=1;}
	        i+=1;item_name[i]="(None)";
	        i+=1;item_name[i]="Terminator Armour";
	        i+=1;item_name[i]="Tartaros";
	    }

	    else i+=1;

	    // var bad;bad=0;if (instance_exists(obj_creation_popup)){if ((obj_creation_popup.type-100)!=6) then bad=1;}
	    // if (bad=0){item_name[i]="Dreadnought";}
	}

	if (equipment_slot=4) and (unit_type == unit_type_astartes || unit_type == unit_type_terminator){ // unit_type == unit_type_astartes for normal infantry gear
		if (!instance_exists(obj_creation)) and (!instance_exists(obj_mass_equip)){
			item_name[1]="(None)";
			valid=2;		
			for (i=0;i<array_length(obj_ini.equipment);i++){
				equip_data=gear_weapon_data("gear", obj_ini.equipment[i]);
				if (is_struct(equip_data) && obj_ini.equipment_number[i]>0 && equip_data.has_unit(unit_type)){
					item_name[valid]=equip_data.name;
					valid++;
				}
			}
		} else {
		    var i=0;
		    i+=1;item_name[i]="(None)";
		    // i+=1;item_name[i]="Bionics";
			i+=1;item_name[i]="Combat Shield";
		    i+=1;item_name[i]="Iron Halo";
		    i+=1;item_name[i]="Narthecium";
		    i+=1;item_name[i]="Psychic Hood";
		    i+=1;item_name[i]="Rosarius";

		}	
	}
	if (equipment_slot=5) and (unit_type == unit_type_astartes){ // unit_type == unit_type_astartes for normal infantry gear
		if (!instance_exists(obj_creation)) and (!instance_exists(obj_mass_equip)){		
			item_name[1]="(None)";
			valid=2;		
			for (i=0;i<array_length(obj_ini.equipment);i++){
				equip_data=gear_weapon_data("mobility", obj_ini.equipment[i]);
				if (is_struct(equip_data) && obj_ini.equipment_number[i]>0  && equip_data.has_unit(unit_type)){
					item_name[valid]=equip_data.name;
					valid++;
				}
			}
		} else {
	    var i;i=0;
		    i+=1;item_name[i]="(None)";
		    i+=1;item_name[i]="Bike";
		    i+=1;item_name[i]="Jump Pack";	
			i+=1;item_name[i]="Servo-arm";	
			i+=1;item_name[i]="Servo-harness";
	    }	
	}
	if (equipment_slot=5) and (unit_type == unit_type_terminator){ // unit_type == unit_type_astartes for normal infantry gear
		if (!instance_exists(obj_creation)) and (!instance_exists(obj_mass_equip)){		
			item_name[1]="(None)";
			valid=2;		
			for (i=0;i<array_length(obj_ini.equipment);i++){
				equip_data = gear_weapon_data("mobilitiy", obj_ini.equipment[i]);
				if (is_struct(equip_data) && obj_ini.equipment_number[i]>0 && equip_data.has_unit(unit_type)){
					item_name[valid]=equip_data.name;
					valid++;
				}
			}
		} else {
	    var i;i=0;
		    i+=1;item_name[i]="(None)";
			i+=1;item_name[i]="Servo-arm";	
			i+=1;item_name[i]="Servo-harness";
	    }	
	}


	
		if (equipment_slot=1) and (equipment_tab=1) and (unit_type == unit_type_land_raider){var i;i=0; // Land Raider Regular Front Weapon
		i+=1;item_name[i]="(None)";
			i+=1;item_name[i]="Twin Linked Heavy Bolter Mount";
			i+=1;item_name[i]="Twin Linked Lascannon Mount";
			i+=1;item_name[i]="Twin Linked Assault Cannon Mount";
			i+=1;item_name[i]="Whirlwind Missiles";
	}

	if (equipment_slot=1) and (equipment_tab=2) and (unit_type == unit_type_land_raider){
			i=0; // Land Raider Relic Front Weapon
			i+=1;item_name[i]="(None)";
			//i+=1;item_name[i]="Thunderfire Cannon Mount";
			i+=1;item_name[i]="Neutron Blaster Turret";
			i+=1;item_name[i]="Reaper Autocannon Mount";
			//i+=1;item_name[i]="Twin Linked Helfrost Cannon Mount";
			//i+=1;item_name[i]="Graviton Cannon Mount";
	}

	if (equipment_slot=2) and (equipment_tab=1) and (unit_type == unit_type_land_raider){var i;i=0; // Land Raider Regular Sponsons
			i+=1;item_name[i]="(None)";
			i+=1;item_name[i]="Twin Linked Lascannon Sponsons";
			i+=1;item_name[i]="Hurricane Bolter Sponsons";
			i+=1;item_name[i]="Flamestorm Cannon Sponsons";
	}

	if (equipment_slot=2) and (equipment_tab=2) and (unit_type == unit_type_land_raider){var i;i=0; // Land Raider Relic Sponsons
			i+=1;item_name[i]="(None)";
			i+=1;item_name[i]="Quad Linked Heavy Bolter Sponsons";
			i+=1;item_name[i]="Twin Linked Heavy Flamer Sponsons";
			i+=1;item_name[i]="Twin Linked Multi-Melta Sponsons";
			i+=1;item_name[i]="Twin Linked Volkite Culverin Sponsons";
	}

	if (equipment_slot=3) and (equipment_tab=1) and (unit_type == unit_type_land_raider){var i;i=0; // Land Raider Pintle
			i+=1;item_name[i]="(None)";
			i+=1;item_name[i]="Bolter";
			i+=1;item_name[i]="Combiflamer";
			i+=1;item_name[i]="Twin Linked Bolters";
			i+=1;item_name[i]="Storm Bolter";
			i+=1;item_name[i]="HK Missile";
	}

	if (equipment_slot<3) and (equipment_tab=1) and (unit_type == unit_type_rhino){var i;i=0; // Rhino Weapons
		i+=1;item_name[i]="(None)";
		i+=1;item_name[i]="Bolter";
			i+=1;item_name[i]="Combiflamer";
			i+=1;item_name[i]="Twin Linked Bolters";
			i+=1;item_name[i]="Storm Bolter";
			i+=1;item_name[i]="HK Missile";
	}

	if (equipment_slot=1) and (equipment_tab=1) and (unit_type == unit_type_predator){var i;i=0; // Predator Turret
			i+=1;item_name[i]="(None)";
			i+=1;item_name[i]="Autocannon Turret";
			i+=1;item_name[i]="Twin Linked Lascannon Turret";
			i+=1;item_name[i]="Flamestorm Cannon Turret";
			i+=1;item_name[i]="Twin Linked Assault Cannon Turret";
			i+=1;item_name[i]="Magna-Melta Turret";
			i+=1;item_name[i]="Plasma Destroyer Turret";
			i+=1;item_name[i]="Heavy Conversion Beam Projector";
			i+=1;item_name[i]="Neutron Blaster Turret";
			i+=1;item_name[i]="Volkite Saker Turret";
			//i+=1;item_name[i]="Graviton Cannon Turret";
	}
	if (equipment_slot=2) and (equipment_tab=1) and (unit_type == unit_type_predator){var i;i=0; // Predator Sponsons
			i+=1;item_name[i]="(None)";
			i+=1;item_name[i]="Heavy Bolter Sponsons";
			i+=1;item_name[i]="Lascannon Sponsons";
			i+=1;item_name[i]="Heavy Flamer Sponsons";
			i+=1;item_name[i]="Volkite Culverin Sponsons";
	}
	if (equipment_slot=3) and (equipment_tab=1) and (unit_type == unit_type_predator){var i;i=0; // Predator Pintle
			i+=1;item_name[i]="(None)";
			i+=1;item_name[i]="Bolter";
			i+=1;item_name[i]="Combiflamer";
			i+=1;item_name[i]="Twin Linked Bolters";
			i+=1;item_name[i]="Storm Bolter";
			i+=1;item_name[i]="HK Missile";
	}
	if (equipment_slot=1) and (equipment_tab=1) and (unit_type == unit_type_land_speeder){var i;i=0; // Land Speeder Primary
			i+=1;item_name[i]="(None)";
		i+=1;item_name[i]="Multi-Melta";
			i+=1;item_name[i]="Heavy Bolter";
	}

	if (equipment_slot=2) and (equipment_tab=1) and (unit_type == unit_type_land_speeder){var i;i=0; // Land Speeder Secondary
			i+=1;item_name[i]="(None)";
		i+=1;item_name[i]="Assault Cannon";
			i+=1;item_name[i]="Heavy Flamer";
	}

	if (equipment_slot=1) and (equipment_tab=1) and (unit_type == unit_type_whirlwind){var i;i=0; // Whirlwind Missiles
			i+=1;item_name[i]="(None)";
		i+=1;item_name[i]="Whirlwind Missiles";
	}

	if (equipment_slot=2) and (equipment_tab=1) and (unit_type == unit_type_whirlwind){var i;i=0; // Whirlwind Pintle
		i+=1;item_name[i]="(None)";
		i+=1;item_name[i]="Bolter";
		i+=1;item_name[i]="Combiflamer";
		i+=1;item_name[i]="Twin Linked Bolters";
		i+=1;item_name[i]="Storm Bolter";
		i+=1;item_name[i]="HK Missile";
	}

	if (equipment_slot=4) and (equipment_tab=1) and ((unit_type == unit_type_land_raider) or (unit_type == unit_type_rhino) or (unit_type == unit_type_predator) or (unit_type == unit_type_whirlwind)){var i=0; // Tank Upgrade
			i+=1;item_name[i]="(None)";
		i+=1;item_name[i]="Armoured Ceramite";
		i+=1;item_name[i]="Artificer Hull";
		i+=1;item_name[i]="Heavy Armour";
			if unit_type == unit_type_land_raider{i+=1;item_name[i]="Void Shield";} //only for Land Raiders
	}
	if (equipment_slot=5) and (equipment_tab=1) and ((unit_type == unit_type_land_raider) or (unit_type == unit_type_rhino) or (unit_type == unit_type_predator) or (unit_type == unit_type_whirlwind) or (unit_type == unit_type_dreadnought)){var i;i=0; // Tank Accessory
			i+=1;item_name[i]="(None)";
		if unit_type!=unit_type_dreadnought {i+=1;item_name[i]="Dozer Blades"};
		i+=1;item_name[i]="Searchlight";
		i+=1;item_name[i]="Smoke Launchers";
		i+=1;item_name[i]="Frag Assault Launchers";
		if !unit_is_vehicle and unit_type!=unit_type_dreadnought{i+=1;item_name[i]="Lucifer Pattern Engine"}; //not available for Land Raiders
	}
}