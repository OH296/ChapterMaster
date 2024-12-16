
function scr_kill_ship(index){
	with(obj_ini){
		var _units_on_ship = [];
		var _unit;
		for (var co=0;co<=companies;co++){
			for (var i=0;i<array_length(obj_ini.name[co]);i++){
				_unit = fetch_unit([co,i]);
				if (_unit.ship_location == index){
					if (!irandom(luck)-3){
						scr_kill_unit(unit.company, unit.marine_number);
					} else {
						array_push(_units_on_ship, _unit);
					}
				}
			}
			for (var i=0;i<array_length(obj_ini.veh_role);i++){
				if (obj_ini.veh_lid[co][i]==index){
	                obj_ini.veh_race[company,i]=0;
	                obj_ini.veh_loc[company,i]="";
	                obj_ini.veh_name[company,i]="";
	                obj_ini.veh_role[company,i]="";
	                obj_ini.veh_wep1[company,i]="";
	                obj_ini.veh_wep2[company,i]="";
	                obj_ini.veh_wep3[company,i]="";
	                obj_ini.veh_upgrade[company,i]="";
	                obj_ini.veh_acc[company,i]="";
	                obj_ini.veh_hp[company,i]=100;
	                obj_ini.veh_chaos[company,i]=0;
	                obj_ini.veh_pilots[company,i]=0;
	                obj_ini.veh_lid[company,i]=-1;
				}
			}
		}
		var in_warp = obj_ini.ship_location[index] == "Warp";
		var _available_ships = [];
		var _ship_fleet = find_ships_fleet(index);
		if (!in_warp){
			var _nearest_star = star_by_name(obj_ini.ship_location[index]);
		}
		if (_ship_fleet!="none"){
			delete_ship_from_fleet(index,_ship_fleet);
			_available_ships = fleet_full_ship_array(_ship_fleet);
		}		
		array_delete(ship,index,1);
		array_delete(ship_uid,index,1);
		array_delete(ship_owner,index,1);
		array_delete(ship_class,index,1);
		array_delete(ship_size,index,1);
		array_delete(ship_leadership,index,1);
		array_delete(ship_hp,index,1);
		array_delete(ship_maxhp,index,1);

		array_delete(ship_location,index,1);
		array_delete(ship_shields,index,1);
		array_delete(ship_conditions,index,1);
		array_delete(ship_speed,index,1);
		array_delete(ship_turning,index,1);

		array_delete(ship_front_armour,index,1);
		array_delete(ship_other_armour,index,1);
		array_delete(ship_weapons,index,1);

		array_delete(ship_wep ,index,1);
		array_delete(ship_wep_condition,index,1);
		array_delete(ship_wep_facing,index,1);

		array_delete(ship_capacity,index,1);
		array_delete(ship_carrying,index,1);
		array_delete(ship_contents,index,1);
		array_delete(ship_turrets,index,1);

		_units_on_ship = array_shuffle(_units_on_ship);
		for (var i=0;i<array_length(_available_ships);i++){
			var _cur_ship = _available_ships[i];
			var f=0;
			var _total_units = array_length(_units_on_ship);
			while (ship_carrying[_cur_ship]<ship_capacity[_cur_ship] && f<_total_units && array_length(_units_on_ship)>0){
				f++;
				if (_units_on_ship[0].get_unit_size()+ship_carrying[_cur_ship]<=ship_capacity[_cur_ship]){
					_units_on_ship[0].load_marine(_cur_ship);
					array_delete(_units_on_ship, 0, 1);
				}
			}
		}
		if (!in_warp){
			if (_nearest_star!="none"){
				while(array_length(_units_on_ship)>0){
					_unit = array_pop(_units_on_ship);
					if (irandom(100)>100-luck){
						_unit.unload(irandom_range(1, _nearest_star.planets), _nearest_star);
					}
				}
			}
		}
		for (var i=0;i<array_length(_units_on_ship);i++){
			scr_kill_unit(_units_on_ship[i].company, _units_on_ship[i].marine_number)
		}
	}
}

function scr_ini_ship_cleanup() {
	// If the ship is dead then make it fucking dead man
	if (array_length(ship)){
		for (var i=array_length(ship)-1;i>=0;i--){
		    if (ship[i]!="") and (ship_hp[i]<=0){
		        scr_kill_ship(i);
		    }
		}
	}

}
