
// show_message("Post-combat cleanup at obj_p_fleet.alarm[1]");


/*with(obj_ini){
    scr_dead_marines(2);
}

with(obj_ini){scr_ini_ship_cleanup();}*/



with(obj_ini){
    scr_ini_ship_cleanup();
}

if (player_fleet_ship_count() == 0) then instance_destroy();
// if ((capital_number+frigate_number+escort_number)<=0) then instance_destroy();


/* */
/*  */
