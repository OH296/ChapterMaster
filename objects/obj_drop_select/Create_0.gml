
mouse_left=1;
attack=0;
once_only=0;

raid_tact=1;
raid_vet=1;
raid_assa=1;
raid_deva=1;
raid_scou=1;
raid_term=1;
raid_spec=1;
raid_wounded=obj_controller.select_wounded;
refresh_raid=0;
remove_local=1;

// 

main_slate = new DataSlate();
draw = drop_select_draw;
main_slate.inside_method = draw;
roster_slate = new DataSlate();
local_content_slate = new DataSlate();
var i=-1;
formation_current=0;
via =  array_create(100, 0);
formation_possible = array_create(13, 0);
force_present = array_create(51, 0);

r_master=0;
r_honor=0;
r_capts=0;
r_mahreens=0;
r_veterans=0;
r_terminators=0;
r_dreads=0;
r_chaplains=0;
r_champions=0;
r_psykers=0;
r_apothecaries=0;
r_techmarines=0;
// Attack
r_bikes=0;


if (action_if_number(obj_saveload, 0, 0)){

    ship_names="";
    sh_target=0;
    max_ships=0;
    ships_selected=0;

    purge=0;
    purge_method=0;
    purge_score=0;
    purge_a=0;
    purge_b=0;
    purge_c=0;
    purge_d=0;
    tooltip="";
    tooltip2="";
    all_sel=0;


    var i=-1;
    var _ship_index = array_length(obj_ini.ship);
    ship=array_create(_ship_index, "");
    ship_size=array_create(_ship_index, 0);
    ship_all=array_create(_ship_index, 0);
    ship_use=array_create(_ship_index, 0);
    ship_max=array_create(_ship_index, 0);
    ship_ide=array_create(_ship_index, -1);

    i=500;
    ship[i]="Local";
    ship_size[i]=0;
    ship_all[i]=0;
    ship_use[i]=0;
    ship_max[i]=0;
    ship_ide[i]=-42;


    menu=0;



    roster = new Roster();
    if (instance_exists(p_target)){
        roster.roster_location = p_target.name;
    }

    roster.roster_planet = planet_number;
    roster.determine_full_roster();

    local_forces = new Roster();

    // These should be set to a negative value; that is, effectively, how much when it is selected (i.e. *-1)

    attacking=0;
    sisters=0;
    eldar=0;
    ork=0;
    tau=0;
    traitors=0;
    tyranids=0;
    csm=0;
    necrons=0;
    demons=0;

    fighting = array_create(11, array_create(501));
    veh_fighting = array_create(11, array_create(501));
}
camera_width = camera_get_view_width(view_camera[0]);
camera_height = camera_get_view_height(view_camera[0]);

w = 0;
h = 0;
x1 = 0;
y1 = 0;
x2 = 0;
y2 = 0;

formation = new InteractiveButton();
target = new InteractiveButton();

btn_attack = new InteractiveButton();
btn_attack.text_color = CM_GREEN_COLOR;
btn_attack.button_color = CM_GREEN_COLOR;
btn_attack.width = 90;
btn_back = new InteractiveButton();
btn_back.str1 = "BACK";
btn_back.text_color = CM_GREEN_COLOR;
btn_back.button_color = CM_GREEN_COLOR;
btn_back.width = 90;

