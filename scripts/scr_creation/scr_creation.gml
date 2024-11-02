/// @mixin obj_creation
function scr_creation(slide_num) {

	// 1 = chapter select
	// 2 = Chapter Naming, Points assignment, advantages/disadvantages
	// 3 = Homeworld, Flagship, Psychic discipline, Aspirant Trial
	// 4 = Livery, Roles
	// 5 = Gene Seed Mutations, Disposition
	// 6 = Chapter Master
	
	show_debug_message($"calling scr_creation with input {slide_num}");
	if (slide_num=2) and (custom>0){
	    if (name_bad=1){cooldown=8000;/*(sound_play(bad);*/}
	    if (name_bad=0){
	        change_slide=1;goto_slide=3;cooldown=8000;race[100,17]=1;
	        if (scr_has_disadv("Psyker Intolerant")) then race[100,17]=0;
	    }
	}

	if (slide_num=2) and (custom=0){
	    change_slide=1;
	    goto_slide=3;
	    cooldown=8000;
	    race[100,Role.CHAPLAIN]=1;
		race[100,Role.LIBRARIAN]=1;
	    if(scr_has_disadv("Psyker Intolerant")){
			race[100,Role.LIBRARIAN]=0;
		}
	    if (chapter_name="Iron Hands" || chapter_name="Space Wolves"){
			race[100,Role.CHAPLAIN]=0;	
		} 
	}


	if (floor(slide_num)==3) and (recruiting_name!=homeworld_name){
	    change_slide=1;goto_slide=4;cooldown=8000;alarm[0]=1;
    
	    if (slide_num=3.5){

			if (array_length(col)>0){
			    if (color_to_main!=""){
			        main_color = max(array_find_value(col,color_to_main),0);
			        color_to_main = "";
			        full_liveries = "none";
			    }
			    if (color_to_secondary!=""){
			        secondary_color = max(array_find_value(col,color_to_secondary),0);
			        color_to_secondary = "";
			        full_liveries = "none";
			    }
			    if (color_to_trim!=""){
			        main_trim = max(array_find_value(col,color_to_trim),0);
			        color_to_trim = "";
			        full_liveries = "none";
			    }
			    if (color_to_pauldron!=""){
			        right_pauldron = max(array_find_value(col,color_to_pauldron),0);
			        color_to_pauldron = "";  
			        full_liveries = "none";   
			    }
			    if (color_to_pauldron2!=""){
			        left_pauldron = max(array_find_value(col,color_to_pauldron2),0);
			        color_to_pauldron2 = "";
			        full_liveries = "none";
			    }
			    if (color_to_lens!=""){
			        lens_color = max(array_find_value(col,color_to_lens),0);
			        color_to_lens = ""; 
			        full_liveries = "none"; 
			    }
			    if (color_to_weapon!=""){
			        weapon_color = max(array_find_value(col,color_to_weapon),0);
			        color_to_weapon = "";
			        full_liveries = "none";
			    }
			}
			if (full_liveries == "none"){
			    var struct_cols = {
			        main_color :main_color,
			        secondary_color:secondary_color,
			        main_trim:main_trim,
			        right_pauldron:right_pauldron,
			        left_pauldron:left_pauldron,
			        lens_color:lens_color,
			        weapon_color:weapon_color
			    }
			    livery_picker.scr_unit_draw_data();
			    livery_picker.set_defualt_armour(struct_cols,col_special);
			    full_liveries = array_create(21,DeepCloneStruct(livery_picker.map_colour));
			    full_liveries[Role.LIBRARIAN] = livery_picker.set_defualt_librarian(struct_cols);

			    full_liveries[Role.CHAPLAIN] = livery_picker.set_defualt_chaplain(struct_cols);

			    full_liveries[Role.APOTHECARY] = livery_picker.set_defualt_apothecary(struct_cols);

			    full_liveries[Role.TECHMARINE] = livery_picker.set_defualt_techmarines(struct_cols);
			    livery_picker.scr_unit_draw_data();
			    livery_picker.set_defualt_armour(struct_cols,col_special);  
			}
	    }
	}
     
	if (slide_num=4){
	    if (hapothecary!="") and (hchaplain!="") and (clibrarian!="") and (fmaster!="") and (recruiter!="") and (admiral!="") and (battle_cry!=""){
	        change_slide=1;
	        goto_slide=5;
	        cooldown=8000;
        
	        if (custom=2){
	            mutations_selected=0;
	            preomnor=0;
	            voice=0;
	            doomed=0;
	            lyman=0;
	            omophagea=0;
	            ossmodula=0;
	            membrane=0;
	            zygote=0;
	            betchers=0;
	            catalepsean=0;
	            secretions=0;
	            occulobe=0;
	            mucranoid=0;
	            if (purity>=1) then mutations=4;
	            if (purity>=2) then mutations=3;
	            if (purity>=4) then mutations=2;
	            if (purity>=7) then mutations=1;
	            if (purity=10) then mutations=0;
	        }
        
	        if (custom>0){
	            disposition[0]=0;
	            disposition[1]=0;// Prog
	            disposition[2]=0;// Imp
	            disposition[3]=0;// Mech
	            disposition[4]=0;// Inq
	            disposition[5]=0;// Ecclesiarchy
	            disposition[6]=0;// Astartes
	            disposition[7]=0;// Reserved
            
	            disposition[1]=60;disposition[6]=50;
	            if (founding=3) then disposition[1]=70;
	            if (founding=4) then disposition[1]=50;
	            if (founding=8) then disposition[1]=70;
            
	            disposition[2]=50;
	            disposition[3]=40;
	            disposition[4]=30;
	            disposition[5]=40;
            
	            if (strength>5) then disposition[4]-=(strength-5)*2;
	            if (purity<6) then disposition[4]-=5;
	            if (founding=10) then disposition[4]-=5;
            
	            if (cooperation<5){
	                disposition[6]-=(6-cooperation)*2;
	                disposition[5]-=(6-cooperation)*2;
	                disposition[4]-=(6-cooperation);
	                disposition[3]-=(6-cooperation);
	                disposition[2]-=(6-cooperation)*2;
	            }
            
	            var ahuh,k;ahuh=0;k=0;
	            repeat(4){k+=1;if (adv[k]="Crafters") then ahuh=1;}
	            if (ahuh=1) then disposition[3]+=2;ahuh=0;k=0;
            
	            repeat(4){k+=1;if (adv[k]="Tech-Brothers") then ahuh=1;}
	            if (ahuh=1) then disposition[3]+=10;ahuh=0;k=0;
            
	            repeat(4){k+=1;if (adv[k]="Psyker Intolerant") then ahuh=1;}
	            if (ahuh=1) then disposition[4]+=5;ahuh=0;k=0;
            
	            repeat(4){k+=1;if (adv[k]="Daemon Binders") then ahuh=1;}
	            if (ahuh=1) then disposition[3]-=8;ahuh=0;k=0;
            
	            repeat(4){k+=1;if (adv[k]="Sieged") then ahuh=1;}
	            if (ahuh=1) then disposition[6]+=5;ahuh=0;k=0;
            
	            repeat(4){k+=1;if (adv[k]="Suspicious") then ahuh=1;}
	            if (ahuh=1) then disposition[4]-=15;ahuh=0;k=0;
            
	            repeat(4){k+=1;if (adv[k]="Tech-Heresy") then ahuh=1;}
	            if (ahuh=1) then disposition[3]-=8;ahuh=0;k=0;
            
	            repeat(4){k+=1;if (adv[k]="Psyker Abundance") then ahuh=1;}
	            if (ahuh=1) then disposition[4]-=4;ahuh=0;k=0;
            
	            repeat(4){k+=1;if (dis[k]="Tolerant") then ahuh=1;}
	            if (ahuh=1){
	                disposition[1]-=5;disposition[2]-=5;disposition[4]-=5;
	                disposition[3]-=5;disposition[5]-=5;disposition[6]-=5;
	            }ahuh=0;k=0;
	        }
	    }
	}

	// 5 to 6
	if (slide_num=5){
	    if (custom=0) or (mutations<=mutations_selected){change_slide=1;goto_slide=6;cooldown=8000;}
	}

	// 6 to finish
	if (slide_num=6){
	    if (chapter_master_name!="") and (chapter_master_melee!=0) and (chapter_master_ranged!=0) and (chapter_master_specialty!=0){
	        global.icon_name=obj_creation.icon_name;
	        cooldown=9999;instance_create(0,0,obj_ini);audio_stop_all();
	        audio_play_sound(snd_royal,0,true);
	        audio_sound_gain(snd_royal,0,0);
	        var nope;nope=0;if (master_volume=0) or (music_volume=0) then nope=1;
	        if (nope!=1){audio_sound_gain(snd_royal,0.25*master_volume*music_volume,2000);}
        
	        if (founding=8) or (chapter_name="Salamanders") then obj_ini.skin_color=1;
	        if (chapter_name!="Salamanders") and (founding!=8) and (secretions=1){
	            obj_ini.skin_color=choose(2,3,4);
	        }
        
	        room_goto(Game);
	    }
	}


}
