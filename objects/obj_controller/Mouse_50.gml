// This script handles left click interactions throught the main menus of the game
var xx, yy;
xx=__view_get( e__VW.XView, 0 );
yy=__view_get( e__VW.YView, 0 );

if (trading>0) and (force_goodbye!=0) then trading=0;

// ** Reclusium Jail Marines**
if (menu==12) and (cooldown<=0) and (penitorium>0){
    var behav=0,r_eta=0,re=0;
    for(var qp=1; qp<=min(36,penitorium); qp++){
        if (qp<=penitorium) and (mouse_y>=yy+100+((qp-1)*20)) and (mouse_y<yy+100+(qp*20)){
            if (mouse_x>=xx+1433) and (mouse_x<xx+1497){
                cooldown=20;
                var c=penit_co[qp],e=penit_id[qp];

                if (obj_ini.role[c,e]="Chapter Master"){
                    tek="c";
                    alarm[7]=5;
                    global.defeat=3;
                }
                // TODO Needs to be based on role
                kill_and_recover(c,e);
                diplo_char=c;
                with(obj_ini){
                    scr_company_order(obj_controller.diplo_char);
                }
                re=1;
                diplo_char=0;
            }
            if (mouse_x>=xx+1508) and (mouse_x<xx+1567){
                cooldown=20;
                var c=penit_co[qp],e=penit_id[qp];
                obj_ini.god[c,e]-=10;
                re=1;
            }
        }
    }
    if (re==1){
        for(var g=1; g<=100; g++){
            penit_co[g]=0;
            penit_id[g]=0;
        }
        penitorium=0;
        var p=0;
        for(var c=0; c<11; c++){
            for(var e=1; e<=250; e++){
                if (obj_ini.god[c,e]>=10){
                    p+=1;
                    penit_co[p]=c;
                    penit_id[p]=e;
                    penitorium+=1;
                }
            }
        }
    }
}

// ** Recruitement **
else if (menu==15) and (cooldown<=0){
    if (mouse_x>=xx+748) and (mouse_x<xx+772){
        if (mouse_y>=yy+355) and (mouse_y<yy+373) and (recruiting<5) and (gene_seed>0) and (obj_ini.doomed==0) and (string_count("|",recruiting_worlds)>0) and (penitent==0){
            cooldown=8000;
            recruiting+=1;
            income_recruiting-=2*(string_count("|",recruiting_worlds));
            scr_income();
        }
        if (mouse_y>=yy+395) and (mouse_y<yy+413) and (training_apothecary<6){
            cooldown=8000;
            training_apothecary+=1;
            scr_income();
        }
        if (mouse_y>=yy+415) and (mouse_y<yy+433) and (training_chaplain<6) and (global.chapter_name!="Space Wolves") and (global.chapter_name!="Iron Hands"){
            cooldown=8000;
            training_chaplain+=1;
            scr_income();
        }
        if (mouse_y>=yy+435) and (mouse_y<yy+452) and (training_psyker<6) and (!scr_has_disadv("Psyker Intolerant")){
            cooldown=8000;
            training_psyker+=1;
            scr_income();
        }
        if (mouse_y>=yy+455) and (mouse_y<yy+473) and (training_techmarine<6){
            cooldown=8000;
            var pid=scr_role_count("Techmarine","");
            if (pid>=((disposition[3]/2)+5)) then training_techmarine=0;
            if (pid<((disposition[3]/2)+5)){
                training_techmarine+=1;
                scr_income();
            }
        }
    }
    if (mouse_x>=xx+726) and (mouse_x<xx+745){
        if (mouse_y>=yy+355) and (mouse_y<yy+373) and (recruiting>0){
            cooldown=8000;
            recruiting-=1;
            income_recruiting+=2*(string_count("|",obj_controller.recruiting_worlds));
            scr_income();
        }
        if (mouse_y>=yy+395) and (mouse_y<yy+413) and (training_apothecary>0){
            cooldown=8000;
            training_apothecary-=1;
            scr_income();
        }
        if (mouse_y>=yy+415) and (mouse_y<yy+433) and (training_chaplain>0){
            cooldown=8000;
            training_chaplain-=1;
            scr_income();
        }
        if (mouse_y>=yy+435) and (mouse_y<yy+452) and (training_psyker>0){
            cooldown=8000;
            training_psyker-=1;
            scr_income();
        }
        if (mouse_y>=yy+455) and (mouse_y<yy+473) and (training_techmarine>0){
            cooldown=8000;
            training_techmarine-=1;
            scr_income();
        }
    }
    // Change trial type

    if (mouse_y>=yy+518) and (mouse_y<=yy+542){
        var onceh=0;
        if (mouse_x>=xx+713) and (mouse_x<=xx+752){
            cooldown=8000;
            recruit_trial++;
            if (recruit_trial==eTrials.num) then recruit_trial=0;
        }
        if (mouse_x>=xx+492) and (mouse_x<=xx+528){
            cooldown=8000;
            recruit_trial--;
            if (recruit_trial<0) then recruit_trial=eTrials.num-1;
        }
    }
}
// ** Fleet count **
// Moved to scr_fleet_advisor();
/* if (menu==16) and (cooldown<=0){
    var i=ship_current;
    for(var j=0; j<34; j++){
        i+=1;
        if (obj_ini.ship[i]!="") and (mouse_x>=xx+953) and (mouse_x>=yy+84+(i*20)) and (mouse_x<xx+969) and (mouse_y<yy+100+(i*20)){
            temp[40]=obj_ini.ship[i];
            with(obj_p_fleet){
                for(var k=1; k<=40; k++){
                    if (capital[k]==obj_controller.temp[40]) then instance_create(x,y,obj_temp7);
                    if (frigate[k]==obj_controller.temp[40]) then instance_create(x,y,obj_temp7);
                    if (escort[k]==obj_controller.temp[40]) then instance_create(x,y,obj_temp7);
                }
            }
            if (instance_exists(obj_temp7)){
                x=obj_temp7.x;
                y=obj_temp7.y;
                cooldown=8000;
                menu=0;
                with(obj_fleet_show){instance_destroy();}
                instance_create(obj_temp7.x,obj_temp7.y,obj_fleet_show);
                with(obj_temp7){instance_destroy();}
            }
        }
    }
} */


// ** Diplomacy **
if (menu==20) and (diplomacy>0) or ((diplomacy<-5) and (diplomacy>-6)) and (cooldown<=0) and (diplomacy<10){
    if (trading==0) and (diplo_option[1]=="") and (diplo_option[2]=="") and (diplo_option[3]=="") and (diplo_option[4]==""){
        if (force_goodbye<=0){
            if (audience==0){
                // Trade
                if (mouse_x>=xx+442) and (mouse_y>=yy+718) and (mouse_x<xx+547) and (mouse_y<yy+737) and (audience==0) and (force_goodbye==0){
                    trading=1;
                    scr_dialogue("open_trade");
                    cooldown=8;
                    click2=1;
                    trade_likely="";
                }
                // Demand
                if (mouse_x>=xx+561) and (mouse_y>=yy+718) and (mouse_x<xx+667) and (mouse_y<yy+737) and (force_goodbye==0){
                    cooldown=8;
                    click2=1;
                    trading_demand=diplomacy;
                    scr_dialogue("trading_demand");
                }
                // Discuss
                if (mouse_x>=xx+682) and (mouse_y>=yy+718) and (mouse_x<xx+787) and (mouse_y<yy+737) and (force_goodbye==0){
                    // TODO
                }
            }
            // Denounce
            if (mouse_x>=xx+442) and (mouse_y>=yy+752) and (mouse_x<xx+547) and (mouse_y<yy+771) and (force_goodbye==0){
                if (diplo_last!="denounced"){
                    scr_dialogue("denounced");
                    cooldown=8;
                    click2=1;
                }
            }
            // Praise
            if (mouse_x>=xx+561) and (mouse_y>=yy+752) and (mouse_x<xx+667) and (mouse_y<yy+771) and (force_goodbye==0){
                if (diplo_last!="praised"){
                    scr_dialogue("praised");
                    cooldown=8;
                    click2=1;
                }
            }
            if (audience==0){
                // Propose Alliance
                if (mouse_x>=xx+682) and (mouse_y>=yy+752) and (mouse_x<xx+787) and (mouse_y<yy+771) and (force_goodbye==0){
                    if (diplo_last!="propose_alliance"){
                        cooldown=8;
                        click2=1;
                        scr_dialogue("propose_alliance");
                    }
                }
                // TODO Declare war here
            }
        }

        /*
        Propose Alliance    same as Discuss but 752-771
        Declare War         551,784,677,803
        */

        // Exit
        if (mouse_x>=xx+818) and (mouse_y>=yy+795) and (mouse_x<xx+897) and (mouse_y<yy+814){
            click=1;
            if (audio_is_playing(snd_blood)==true) then scr_music("royal",2000);

            if (complex_event==true) and (instance_exists(obj_temp_meeting)){
                complex_event=false;
                diplomacy=0;
                menu=0;
                force_goodbye=0;
                cooldown=80;
                with(obj_temp_meeting){instance_destroy();}
                if (instance_exists(obj_turn_end)){
                    obj_turn_end.alarm[1]=1;
                    exit;
                }
                exit;
            }
            if (trading_artifact!=0){
                for(var h=1; h<=4; h++){
                    diplo_option[h]="";
                    diplo_goto[h]="";
                }
                diplomacy=0;
                menu=0;
                force_goodbye=0;
                cooldown=8;
                if (trading_artifact==2) and (instance_exists(obj_ground_mission)){
                    obj_ground_mission.alarm[2]=1;
                }// 135 this might not be needed
                trading_artifact=0;
                with(obj_popup){
                    obj_ground_mission.alarm[1]=1;
                    instance_destroy();
                }
                exit;
            }
            if (force_goodbye==5){
                for(var h=1; h<=4; h++){
                    diplo_option[h]="";
                    diplo_goto[h]="";
                }
                diplomacy=0;
                menu=0;
                force_goodbye=0;
                cooldown=8;
                exit;
            }
            if (liscensing==2) and (repair_ships==0){
                cooldown=8;
                var cru=instance_create(mouse_x,mouse_y,obj_crusade);
                cru.owner=diplomacy;
                cru.placing=true;
                diplomacy=0;
                force_goodbye=0;
                menu=0;
                exit_all=0;
                liscensing=0;
                if (zoomed==0) then scr_zoom();
                exit;
            }
            if (exit_all!=0){
                cooldown=8;
                diplomacy=0;
                force_goodbye=0;
                menu=0;
                exit_all=0;
            }
            if (diplo_last=="artifact_thanks") and (force_goodbye!=0){
                diplomacy=0;
                menu=13;
                force_goodbye=0;
                cooldown=8;
                exit;
            }
            // Exits back to diplomacy thing
            if (audience==0){
                cooldown=8;
                diplomacy=0;
                force_goodbye=0;
            }
            // No need to check for next audience
            if (audience>0) and (!instance_exists(obj_turn_end)){
                cooldown=8;
                diplomacy=0;
                menu=0;
                audience=0;
                force_goodbye=0;
                exit;
            }
            if (audience>0) and (instance_exists(obj_turn_end)){
                if (complex_event==false){
                    cooldown=8;
                    diplomacy=0;
                    menu=0;
                    obj_turn_end.alarm[1]=1;
                    audience=0;
                    force_goodbye=0;
                    exit;
                }
                if (complex_event=true){
                    // TODO
                }
            }// Have this check for the next audience, if any
        }
        // Trade goods go here
        if (trading==1) or (trading==2){
            for(var i=0;i<7;i++){
                trade_theirs[i]="";
                trade_disp[i]=-100;
            }

            trade_req=requisition;
            trade_gene=gene_seed;
            trade_chip=stc_wargear_un+stc_vehicles_un+stc_ships_un;
            trade_info=info_chips;
            // Imperium trade goods
            cooldown=8;
            
        }
    }
    if (trading==0) and ((diplo_option[1]!="") or (diplo_option[2]!="") or (diplo_option[3]!="") or (diplo_option[4]!="")){
        if (force_goodbye==0) and (cooldown<=0){

            var diplo_pressed=0;
            yy=__view_get( e__VW.YView, 0 )+0;

            var opts=0;
            for(var dp=1; dp<=4; dp++){if (diplo_option[dp]!="") then opts+=1;}
            if (opts==4) then yy-=30;
            if (opts==2) then yy+=30;
            if (opts==1) then yy+=60;
            for(var slot=1; slot<=4; slot++){
                if (diplo_option[slot]!=""){
                    if (mouse_x>=xx+354) and (mouse_y>=yy+694) and (mouse_x<xx+887) and (mouse_y<yy+717) and (cooldown<=0){
                        diplo_pressed=slot;
                    }
                }
                yy+=30;
            }
            yy=__view_get( e__VW.YView, 0 );

            if (diplo_pressed>0) and (diplo_goto[diplo_pressed]!="") and (cooldown<=0){
                click2=1;
                scr_dialogue(diplo_goto[diplo_pressed]);
                cooldown=4000;
                exit;
            }
            if (diplo_pressed==1){
                click2=1;
                if (questing==0) and (trading_artifact==0) and (trading_demand==0){
                    if (diplomacy==4) and (diplo_option[1]=="It will not happen again"){// It will not happen again mang
                        scr_dialogue("you_better");
                        diplo_option[1]="";
                        diplo_option[2]="";
                        diplo_option[3]="";
                        force_goodbye=1;

                        var tb,tc;
                        explode_script(obj_controller.temp[1008],"|");
                        tb=string(explode[0]);
                        tc=real(explode[1]);
                        var ev=0;
                        for(var v=1; v<=99; v++){if (ev==0) and (event[v]=="") then ev=v;}
                        event[ev]="remove_serf|"+string(tb)+"|"+string(tc)+"|";
                        event_duration[ev]=choose(1,2);
                        exit;
                    }
                }
                if (questing!=0){
                    cooldown=8;
                    if (questing==1) and (diplomacy==6){
                        if (requisition>=500){
                            scr_loyalty("Xeno Trade","+");
                            scr_dialogue("mission1_thanks");
                            scr_quest(2,"fund_elder",6,0);
                            requisition-=500;questing=0;
                            diplo_option[1]="";
                            diplo_option[2]="";
                            diplo_option[3]="";
                            exit;
                        }
                    }
                }
                if ((diplomacy==3) or (diplomacy==5)) and (trading_artifact!=0){
                    trading=1;
                    scr_dialogue("open_trade");
                    trade_take[1]="Artifact";
                    trade_tnum[1]=1;
                    trade_req=requisition;
                    trade_gene=gene_seed;
                    trade_chip=info_chips;
                    trade_info=stc_wargear_un+stc_vehicles_un+stc_ships_un;
                }
                if (trading_demand>0) and (diplo_option[1]!="Cancel") and (diplo_option[1]!="") then scr_demand(1);
            }
            if (diplo_pressed==2){
                click2=1;

                if (questing==0) and (trading_artifact==0) and (trading_demand==0){// Don't want no trabble
                    if (diplomacy==4) and (diplo_option[2]=="Very well"){
                        diplo_option[1]="";
                        diplo_option[2]="";
                        diplo_option[3]="";
                        force_goodbye=1;

                        var tb,tc;
                        explode_script(obj_controller.temp[1008],"|");
                        tb=string(explode[0]);
                        tc=real(explode[1]);
                        var ev=0;
                        for(var v=1; v<=99; v++){if (ev==0) and (event[v]=="") then ev=v;}
                        event[ev]="remove_serf|"+string(tb)+"|"+string(tc)+"|";
                        event_duration[ev]=choose(1,2);
                        cooldown=8;
                        diplomacy=0;
                        menu=0;
                        obj_turn_end.alarm[1]=1;
                        audience=0;
                        force_goodbye=0;
                        exit;
                    }
                }
                if (questing!=0){
                    cooldown=8;
                    if (questing==1) and (diplomacy==6){
                        scr_dialogue("quest_maybe");
                        questing=0;
                        diplo_option[1]="";
                        diplo_option[2]="";
                        diplo_option[3]="";
                        exit;
                    }
                }
                if (trading_demand>0) and (diplo_option[2]!="Cancel") and (diplo_option[2]!="") then scr_demand(2);
                if (trading_demand>0) and (diplo_option[2]=="Cancel"){
                    cooldown=8000;
                    trading_demand=0;
                    diplo_option[1]="";
                    diplo_option[2]="";
                    diplo_option[3]="";
                    diplo_text="...";
                    diplo_txt="...";
                }
                if (diplomacy>0) and (trading_artifact>0) and (menu==20){
                    cooldown=8;
                    obj_ground_mission.alarm[1]=2;
                    trading_artifact=0;
                    menu=0;
                    diplomacy=0;
                    diplo_option[1]="";
                    diplo_option[2]="";
                    diplo_option[3]="";
                }
            }
            if (diplo_pressed==3){
                click2=1;
                if (questing==0) and (trading_artifact==0) and (trading_demand==0){
                    if (diplomacy==4) and (string_count("You will not",diplo_option[3])>0){// MIIIIINE!!!1
                        scr_dialogue("die_heretic");
                        diplo_option[1]="";
                        diplo_option[2]="";
                        diplo_option[3]="";
                        force_goodbye=1;
                        exit;
                    }
                }
                if (questing!=0){
                    cooldown=8;
                    if (questing==1) and (diplomacy==6){// That +2 counteracts the WAITED TOO LONG penalty
                        scr_dialogue("mission1_refused");
                        scr_quest(3,"fund_elder",6,0);
                        questing=0;
                        diplo_option[1]="";
                        diplo_option[2]="";
                        diplo_option[3]="";
                        exit;
                    }
                }
                if (trading_demand>0) and (diplo_option[3]!="Cancel") and (diplo_option[3]!="") then scr_demand(3);
                if (trading_demand>0) and (diplo_option[3]=="Cancel"){
                    cooldown=8;
                    trading_demand=0;
                    diplo_option[1]="";
                    diplo_option[2]="";
                    diplo_option[3]="";
                    diplo_text="...";
                    diplo_txt="...";
                }
            }
        }
        if (force_goodbye!=0) and (cooldown<=0){// Want to check to see if the deal went fine here
            if (trading_artifact!=0){
                click2=1;
                obj_controller.diplo_option[1]="";
                obj_controller.diplo_option[2]="";
                diplo_option[3]="";
                diplomacy=0;
                menu=0;
                force_goodbye=0;
                with(obj_popup){instance_destroy();}
                if (trading_artifact!=2) then obj_ground_mission.alarm[1]=1;
                if (trading_artifact==2) then obj_ground_mission.alarm[2]=1;
                exit;
            }
        }
    }
    //
    if (trading==1) or (trading==2){

        // Remove items buttons
        if (trading_artifact==0){
            if (scr_hit(xx+507,yy+399,xx+527,yy+418)==true) and (trade_tnum[2]==0) and (trade_tnum[1]!=0) and (cooldown<=0){
                trade_tnum[1]=0;
                trade_take[1]="";
                cooldown=8000;
                click2=1;
                scr_trade(false);
            }
            if (scr_hit(xx+507,yy+419,xx+527,yy+438)==true) and (trade_tnum[3]==0) and (trade_tnum[2]!=0) and (cooldown<=0){
                trade_tnum[2]=0;
                trade_take[2]="";
                cooldown=8000;
                click2=1;
                scr_trade(false);
            }
            if (scr_hit(xx+507,yy+439,xx+527,yy+458)==true) and (trade_tnum[4]==0) and (trade_tnum[3]!=0) and (cooldown<=0){
                trade_tnum[3]=0;
                trade_take[3]="";
                cooldown=8000;
                click2=1;
                scr_trade(false);
            }
            if (scr_hit(xx+507,yy+459,xx+527,yy+478)==true) and (trade_tnum[4]!=0) and (cooldown<=0){
                trade_tnum[4]=0;
                trade_take[4]="";
                cooldown=8000;
                click2=1;
                scr_trade(false);
            }
        }
        if (scr_hit(xx+507,yy+547,xx+527,yy+566)==true) and (trade_mnum[2]==0) and (trade_mnum[1]!=0) and (cooldown<=0){
            if (trade_give[1]=="Requisition") then trade_req+=trade_mnum[1];
            if (trade_give[1]=="Gene-Seed") then trade_gene+=trade_mnum[1];
            if (trade_give[1]=="STC Fragment") then trade_chip+=trade_mnum[1];
            if (trade_give[1]=="Info Chip") then trade_info+=trade_mnum[1];
            trade_mnum[1]=0;
            trade_give[1]="";
            cooldown=8000;
            click2=1;
            scr_trade(false);
        }
        if (scr_hit(xx+507,yy+567,xx+527,yy+586)==true) and (trade_mnum[3]==0) and (trade_mnum[2]!=0) and (cooldown<=0){
            if (trade_give[2]=="Requisition") then trade_req+=trade_mnum[2];
            if (trade_give[2]=="Gene-Seed") then trade_gene+=trade_mnum[2];
            if (trade_give[2]=="STC Fragment") then trade_chip+=trade_mnum[2];
            if (trade_give[2]=="Info Chip") then trade_info+=trade_mnum[2];
            trade_mnum[2]=0;
            trade_give[2]="";
            cooldown=8000;
            click2=1;
            scr_trade(false);
        }
        if (scr_hit(xx+507,yy+587,xx+527,yy+606)==true) and (trade_mnum[4]==0) and (trade_mnum[3]!=0) and (cooldown<=0){
            if (trade_give[3]=="Requisition") then trade_req+=trade_mnum[3];
            if (trade_give[3]=="Gene-Seed") then trade_gene+=trade_mnum[3];
            if (trade_give[3]=="STC Fragment") then trade_chip+=trade_mnum[3];
            if (trade_give[3]=="Info Chip") then trade_info+=trade_mnum[3];
            trade_mnum[3]=0;
            trade_give[3]="";
            cooldown=8000;
            click2=1;
            scr_trade(false);
        }
        if (scr_hit(xx+507,yy+607,xx+527,yy+626)==true) and (trade_mnum[4]!=0) and (cooldown<=0){
            if (trade_give[4]=="Requisition") then trade_req+=trade_mnum[4];
            if (trade_give[4]=="Gene-Seed") then trade_gene+=trade_mnum[4];
            if (trade_give[4]=="STC Fragment") then trade_chip+=trade_mnum[4];
            if (trade_give[4]=="Info Chip") then trade_info+=trade_mnum[4];
            trade_mnum[4]=0;
            trade_give[4]="";
            cooldown=8000;
            click2=1;
            scr_trade(false);
        }
    }
}
// Diplomacy
if (zoomed==0) and (cooldown<=0) and (menu==20) and (diplomacy==0){
    xx+=55;
    yy-=20;
	var onceh=0
	// Daemon emmissary
	    if (point_in_rectangle(mouse_x, mouse_y, xx+688,yy+181,xx+1028,yy+281)){
			diplomacy=10.1;
            diplomacy_pathway="intro";
            scr_dialogue(diplomacy_pathway);
            onceh=1;
            cooldown = 1;
		}
    var faction_interact_coords=[
        [
            [xx+194,yy+355,xx+288,yy+369],//imperium
            [xx+292,yy+355,xx+350,yy+369],
            2
        ],
        [
            [xx+194,yy+491,xx+288,yy+503],//mechanicus
            [xx+292,yy+491,xx+350,yy+503],
            3
        ],
        [
            [xx+194,yy+630,xx+288,yy+644],//Inquisition
            [xx+292,yy+630,xx+350,yy+644],
            4
        ],
        [
            [xx+194,yy+760,xx+288,yy+774],//sisters
            [xx+292,yy+760,xx+350,yy+774],
            5
        ], 
        [
            [xx+1203,yy+355,xx+1300,yy+369],//eldar
            [xx+1303,yy+355,xx+1350,yy+369],
            6
        ],
        [
            [xx+1203,yy+491,xx+1300,yy+503],//orks
            [xx+1303,yy+491,xx+1350,yy+503],
            7
        ],
        [
            [xx+1203,yy+630,xx+1300,yy+644],//Tau
            [xx+1303,yy+630,xx+1350,yy+644],
            8
        ],
        [
            [xx+1203,yy+760,xx+1300,yy+774],//heretic
            [xx+1303,yy+760,xx+1350,yy+774],
            10
        ],                                           
    ]
    for (var i=0;i<array_length(faction_interact_coords);i++){
        var fac_data = faction_interact_coords[i];
        if (point_in_rectangle(mouse_x, mouse_y, fac_data[0][0], fac_data[0][1], fac_data[0][2], fac_data[0][3])){
            if (known[fac_data[2]]!=0) and (turns_ignored[fac_data[2]]==0){
                diplomacy=fac_data[2];
                cooldown=8000;
            }
        } else if (point_in_rectangle(mouse_x, mouse_y, fac_data[1][0], fac_data[1][1], fac_data[1][2], fac_data[1][3])){
            cooldown=8000;
            click2=1;
            if (ignore[fac_data[2]]==0){
                ignore[fac_data[2]]=1;
            }else if (ignore[fac_data[2]]==1){
                ignore[fac_data[2]]=0;
            }            
        }
    }
    if (diplomacy>0) and (cooldown==8000){
        onceh=0;
        if (known[diplomacy]==1) and (diplomacy!=4) and (onceh==0){
            scr_dialogue("intro");
            onceh=1;
            known[diplomacy]=2;
            faction_justmet=1;
        }
        if (known[diplomacy]>=2) and (diplomacy!=4) and (onceh==0){
            scr_dialogue("hello");
            onceh=1;
        }
        if (known[eFACTION.Inquisition]==1) and (diplomacy==4) and (onceh==0){
            scr_dialogue("intro");
            onceh=1;
            known[diplomacy]=2;
            faction_justmet=1;
            obj_controller.last_mission=turn+1;
        }
        if (known[eFACTION.Inquisition]==3) and (diplomacy==4) and (onceh==0){
            scr_dialogue("intro");
            onceh=1;
            known[diplomacy]=4;
            faction_justmet=1;
            obj_controller.last_mission=turn+1;
        }
        if (known[diplomacy]>=4) and (diplomacy==4) and (onceh==0){
            scr_dialogue("hello");
            onceh=1;
        }
    }
}


        // End Turn
scr_menu_clear_up(function(){  
    if (zoomed==0) and (menu==40) and (cooldown<=0){
        xx=xx+0;
        yy=yy+0;

        if (mouse_x>=xx+73) and (mouse_y>=yy+69) and (mouse_x<xx+305) and (mouse_y<yy+415){
            menu=41;
            cooldown=8000;
        }
        if (mouse_x>=xx+336) and (mouse_y>=yy+69) and (mouse_x<xx+568) and (mouse_y<yy+415){
            menu=42;
            cooldown=8000;
        }
    }

    // This is the back button at LOADING TO SHIPS
    if (zoomed==0) and (menu==30) and (managing>0||managing==-1) and (cooldown<=0){
        xx=xx+0;
        yy=yy+0;

        if (mouse_x>=xx+22) and (mouse_y>=yy+84) and (mouse_x<xx+98) and (mouse_y<yy+126){
            menu=1;
            cooldown=8000;
        }
    }
    // Selecting individual marines
    if (menu=1) and (managing>0) || (managing<0) and (!view_squad || !company_report){
        var unit;                 
        var eventing=false, bb="";
        xx=__view_get( e__VW.XView, 0 )+0;
        yy=__view_get( e__VW.YView, 0 )+0;
        var top=man_current,sel,temp1="",temp2="",temp3="",temp4="",temp5="", squad_sel=0;
        var stop=0;

        if (man_size==0) then alll=0;

        if (cooldown<=0){
            // selecting all
            if (point_in_rectangle(mouse_x,mouse_y,xx+1281,yy+607,xx+1409,yy+636)){
                cooldown=8;
                if (alll==0){
                    scr_load_all(true);
                    selecting_types="%!@";
                } else if (alll==1){
                    scr_load_all(false);
                    selecting_types="";
                }
            } 

        }

    }
    if (menu==50) and (managing>0) and (cooldown<=0){
        if (mouse_x>=xx+217) and (mouse_y>=yy+28) and (mouse_x<xx+250) and (mouse_y<yy+59){
            cooldown=8;
            menu=1;
            click=1;
        }
    }
});
