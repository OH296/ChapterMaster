// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information


enum eFACTION {
	Player = 1,
	Imperium,
	Mechanicus,
	Inquisition,
	Ecclesiarchy,
	Eldar,
	Ork,
	Tau,
	Tyranids,
	Chaos,
	Heretics,
    Genestealer,
	Necrons = 13
}


function set_up_dispositions(){
	faction = ["", "Player","Imperium","Mechanicus","Inquisition","Ecclesiarchy","Eldar","Ork","Tau","Tyranids","Chaos","Heretics","","Necrons"];
	disposition = array_create(14, 0);
	imperial_factions = [
	    eFACTION.Imperium,
	    eFACTION.Mechanicus,
	    eFACTION.Inquisition,
	    eFACTION.Ecclesiarchy,
	]


	// ** Initial disposition for Imperial factions **
	if (instance_exists(obj_ini)){
	    disposition[2]=obj_ini.imperium_disposition;
	    disposition[3]=obj_ini.mechanicus_disposition;
	    disposition[4]=obj_ini.inquisition_disposition;
	    disposition[5]=obj_ini.ecclesiarchy_disposition;
	}
	// ** Initial disposition for non Imperials **
	disposition[6]=-10;
	disposition[7]=-40;
	disposition[8]=0;
	disposition[9] = irandom_range(40,100) = 1;// use this to countdown genestealer cults, create one at the end
	disposition[10]=-70;
	disposition[10]=-70;
	faction[12]="";
	disposition[12]=0;
	disposition[13]=-20;
	// ** Max disposition for imperials **
	// ** Max disposition for non imperials **	
	disposition_max = array_create(14, 0);
	disposition_max[2]=40;
	disposition_max[3]=40;
	disposition_max[4]=40;
	disposition_max[5]=40;
	if (instance_exists(obj_ini)){
	    disposition_max[2]=min(40+obj_ini.imperium_disposition,100);

	    disposition_max[3]=min(40+obj_ini.mechanicus_disposition,100);

	    disposition_max[4]=min(40+obj_ini.inquisition_disposition,100);

	    disposition_max[5]=min(40+obj_ini.ecclesiarchy_disposition,100);
	    if (!global.load) and (scr_has_disadv("Tolerant")){
	        obj_controller.disposition[6]+=5;
	        obj_controller.disposition[7]+=5;
	        obj_controller.disposition[8]+=10;
	    }		    

	}
    // Tolerant trait	
	faction_favour = array_create(14, 0);
}

function alter_disposition(faction_id, change, return_string=false){
	with (obj_controller){
		var _start = disposition[faction_id];
		disposition[faction_id]  = min(disposition_max[faction_id], disposition[faction]+=change);
		//returns change
		var _change = disposition[faction] - _start;;
		if (return_string){
			return "{faction[faction_id]} {_change?"+":""}{_change}";
		} else {
			return _change;
		}
	}
}

function alter_multi_disposition(disposition_array, return_string){
	if (return_string){
		var _dis_string  = "";
		for (var i=0;i<array_length(disposition_array)i++){
			var _data  =  disposition_array[i];
			_dis_string += " "+alter_disposition(_data[0], _data[1], true);
		}
		return _dis_string;
	} else {
		for (var i=0;i<array_length(disposition_array)i++){		
			var _data  =  disposition_array[i];
			alter_disposition(_data[0], _data[1]);
		}
	}
}





