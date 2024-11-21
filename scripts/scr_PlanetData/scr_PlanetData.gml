// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function PlanetData(planet, system) constructor{
	self.planet = planet;
	self.system = system;
	player_disposition = system.dispo[planet];
	planet_type = system.p_type[planet];
    operatives = system.p_operatives[planet];
    features =system.p_feature[planet];
    current_owner = system.p_owner[planet];
    origional_owner = system.p_first[planet];
    population = system.p_population[planet];
    max_population = system.p_max_population[planet];
    large_population = system.p_large[planet];
    secondary_population = system.p_pop[planet];
    guardsmen = system.p_guardsmen[planet];
    pdf = system.p_pdf[planet];
    fortification_level  = system.p_fortified[planet];
    star_station = system.p_station[planet];

    static name = function(){
    	var _name="";
    	with (system){
    		_name =  planet_numeral_name(planet);
    	}
    	return _name;
    }

    // Whether or not player forces are on the planet
    player_forces = system.p_player[planet];
    defence_lasers = system.p_lasers[planet];
    defence_silos = system.p_silo[planet];
    ground_defences = system.p_defenses[planet];
    upgrades = system.p_upgrades[planet];
    // v how much of a problem they are from 1-5
    planet_forces = [
    	0,
    	player_forces,
    	guardsmen,
    	0,
    	system.p_sisters[planet],
    	system.p_eldar[planet],
    	system.p_orks[planet],
    	system.p_tau[planet],
    	system.p_tyranids[planet],
    	system.p_chaos[planet]+ system.p_demons[planet],
    	system.p_traitors[planet],
    	0,
    	system.p_necrons[planet]
    ]
    static xenos_and_heretics = function(){
    	var xh_force = 0;
    	for (var i=5;i<array_length(planet_forces); i++){
    		xh_force += planet_forces[i];
    	} 
    	return xh_force;
    }
    deamons = system.p_demons[planet];
    chaos_forces = system.p_chaos[planet];

    requests_help = system.p_halp[planet];

    // current planet heresy
    corruption = system.p_heresy[planet];

    is_heretic = system.p_hurssy[planet];

    heretic_timer = system.p_hurssy_time[planet];

    secret_corruption = system.p_heresy_secret[planet];

    population_influences = system.p_influence[planet];

    raided_this_turn = system.p_raided[planet];
    // 
    governor = system.p_governor[planet];

    problems = system.p_problem[planet];
    problem_data = system.p_problem_other_data[planet];
    problem_timers = system.p_timer[planet];

    static marine_training = planet_training_sequence;

    static has_feature = function(feature){
    	return planet_feature_bool(features, feature);
    }

    static get_features = function(request_feature){
    	var _array_positions = search_planet_features(features,request_feature);
    	var _select_features = [];
  		for (var i=0;i<array_length(_array_positions);i++){
  			array_push(_select_features, features[_array_positions[i]]);
  		}
  		return _select_features;
    }
    static planet_training = function(local_screening_points){
    	var _training_happend = false;
	    if (has_feature(P_features.Recruiting_World)){
	        if (obj_controller.gene_seed == 0) and (obj_controller.recruiting > 0) {
	        	if (turn_end){
	                obj_controller.recruiting = 0;
	                obj_controller.income_recruiting = 0;
	                scr_alert("red", "recruiting", "The Chapter has run out of gene-seed!", 0, 0);
	        	}
	        }else if (obj_controller.recruiting > 0){
	        	if (local_screening_points>0){
	        		if (turn_end){
	           			marine_training(local_screening_points);
	           		}
	           		_training_happend = true;
	        	} else {
	        		scr_alert("red", "recruiting", $"Recruitment on {name()} halted due to insufficient apothecary rescources", 0, 0);
	        	}
	        }
		}
		return _training_happend;   	
    }

    static recover_starship = function(techs){
    	try {
			var engineer_count=array_length(techs);
			if (has_feature(P_features.Starship) && engineer_count>0 && turn_end){
				//TODO allow total tech point usage here
		        var _starship = get_features(,P_features.Starship)[0];

		        var _engineer_score_start = _starship.engineer_score;
		    	if (_starship.engineer_score<2000){
		        	for (var v=0;v<engineer_count;v++){
		        		_starship.engineer_score += (techs[v].technology/2);
		        	}
		        	scr_alert("green","owner",$"Ancient ship repairs {min((_starship.engineer_score/2000)*100, 100)}% complete",x,y);
		    	}

		        var _maxr=0,_requisition_spend=0,_target_spend=10000;

		        _maxr=floor(obj_controller.requisition/50);
		        _requisition_spend=min(_maxr*50,array_length(techs)*50,_target_spend-_starship.funds_spent);
		        obj_controller.requisition-=_requisition_spend;
		        _starship.funds_spent+=_requisition_spend;
		    
		        if (_requisition_spend>0 && _starship.funds_spent<_target_spend){
		            scr_alert("green","owner",$"{_requisition_spend} Requision spent on Ancient Ship repairs in materials and outfitting (outfitting {(_starship.funds_spent/_target_spend)*100}%)",x,y);
		        }
		        if (_starship.funds_spent>=_target_spend && _starship.engineer_score>=2000){// u2=tar;
		        	//TODO refactor into general new ship logic
		            delete_features(cur_system.p_feature[p],P_features.Starship);
		        
		            var locy=$"{name} {scr_roman_numerals()[p-1]}";
		        
		            var flit=instance_create(cur_system.x,cur_system.y,obj_p_fleet);
		      
		        	var _slaughter = new_player_ship("Gloriana", name, "Slaughtersong");
		            flit.capital[1]=obj_ini.ship[_slaughter];
		            flit.capital_number=1;
		            flit.capital_num[1]=_slaughter;
		            flit.capital_uid[1]=obj_ini.ship_uid[_slaughter];
		            flit.oribiting = cur_system.id;
		        
		            scr_popup($"Ancient Ship Restored",$"The ancient ship within the ruins of {locy} has been fully repaired.  It is determined to be a Slaughtersong vessel and is bristling with golden age weaponry and armour.  Your {string(obj_ini.role[100][16])}s are excited; the Slaughtersong is ready for it's maiden voyage, at your command.","","");                
		        }
		    }    	
	    }catch (_exception){
			handle_exception(_exception);
		}
	} 

}