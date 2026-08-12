function MissionHelper() constructor{

}


function PlanetProblem(name, timer, data star, planet){
	timer = timer;
	p_id = name;
	data = data;
	star = star;
	planet = planet;

	static __init(){
		switch(p_id){
			case "necron":
		        new_star_event_marker("green");
		        mission_is_go = true;
		}
	}

	__init();
}