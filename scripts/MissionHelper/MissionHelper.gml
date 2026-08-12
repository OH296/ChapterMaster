function MissionHelper() constructor{

}

function SystemProblem(name, timer, data)

function PlanetProblem(name, timer, data, planet){
	timer = timer;
	p_id = name;
	data = data;
	p_data = planet;

	static mark = fuction(colour){
		with (p_data.system){
			new_star_event_marker(colour)
		}
	}

	static __init(){
		switch(p_id){
			case "necron":
		        mark("green");
		        break;
		    case "meeting":
	            var rando = choose(1, 2);
	            i]f (rando == 1) {
	                obj_controller.diplo_text += $"A proposal that needs further consideration and some negotiation.  Meet me at {p_data.name()} and we shall resolve this.";
	            }
	            if (rando == 2) {
	                obj_controller.diplo_text += $"Interesting. I shall be at {p_data.name()} and, if you are sincere, you will come to me and we can take this proposal to its logical conclusion.";
	            }
	            scr_event_log("", $"Chaos Lord {obj_controller.faction_leader[eFACTION.CHAOS]} agrees to meet with you on {p_data.name()} to discuss an alliance.");
	            mark("purple");
		}
	}

	__init();
}