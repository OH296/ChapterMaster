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

    static has_feature(feature){
    	return planet_feature_bool(features, feature);
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
	           			_planet_data.marine_training(local_screening_points);
	           		}
	           		_training_happend = true;
	        	} else {
	        		scr_alert("red", "recruiting", $"Recruitment on {_planet_data.name()} halted due to insufficient apothecary rescources", 0, 0);
	        	}
	        }
		}
		return _training_happend;   	
    }

}