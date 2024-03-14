
var xx,yy,x2,y2;
var romanNumerals=scr_roman_numerals();
xx=__view_get( e__VW.XView, 0 )+0;
yy=__view_get( e__VW.YView, 0 )+0;

x2=962;y2=107;

draw_set_font(fnt_40k_14);
draw_set_color(c_gray);
draw_set_halign(fa_left);


var te="";
// TODO refactor target_comp and how companies are counted in general
if (shop=="vehicles"){
    if (target_comp<=10) then te=romanNumerals[target_comp-1];
    if (mouse_x>=xx+1262) and (mouse_y>=yy+78) and (mouse_x<=xx+1417) and (mouse_y<yy+103) then draw_set_alpha(0.8);
    draw_text(xx+1310,yy+82,string_hash_to_newline("Target: "+string(te)+" Company"));
}

draw_set_alpha(1);
draw_set_font(fnt_40k_14);
draw_set_color(0);
var shop_area="";
if(tab_buttons.equipment.draw(xx+960,yy+64, "Equipment")){
    shop_area="equipment";
}
if (tab_buttons.armour.draw(xx+1075,yy+64, "Armour")){
    shop_area="equipment2";
}
if (tab_buttons.vehicles.draw(xx+1190,yy+64, "Vehicles")){
    shop_area="vehicles";
}
if (obj_controller.in_forge){
    if (tab_buttons.ships.draw(xx+1460,yy+64, "Manufactoring")){
        shop_area="production";
    }
}else{
    if (tab_buttons.ships.draw(xx+1460,yy+64, "Ships")){
        shop_area="warships";
    }
}
draw_set_halign(fa_left);
draw_text(xx+962,yy+109,string_hash_to_newline("Name"));
draw_text(xx+962.5,yy+109.5,string_hash_to_newline("Name"));
if (shop!="production"){
    draw_text(xx+1280,yy+109,string_hash_to_newline("Stocked"));
    draw_text(xx+1280.5,yy+109.5,string_hash_to_newline("Stocked"));
    if (shop="equipment" or shop="equipment2"){
    draw_text(xx+1280+10+string_width("Stocked"),yy+109.5,string_hash_to_newline("MC"));
    draw_text(xx+1280+10.5+string_width("Stocked"),yy+109.5,string_hash_to_newline("MC"));
    }
}
draw_text(xx+1430.5,yy+109.5,string_hash_to_newline("Cost"));
draw_set_color(c_gray);


if (shop="warships"){
    if (construction_started>0){
        var apa=construction_started/30;draw_set_alpha(apa);
        draw_set_color(c_yellow);
        draw_set_halign(fa_center);
        draw_text_transformed(__view_get( e__VW.XView, 0 )+420,yy+370,string_hash_to_newline("CONSTRUCTION STARTED!#ETA: "+string(eta)+" months"),1.5,1.5,0);
        draw_set_halign(fa_left);
        draw_set_color(38144);
        draw_set_alpha(1);
    }
}

for(var i=1; i<=39; i++){
    y2+=20;
    if (item[i]!=""){
        if (!obj_controller.in_forge && nobuy[i]=0) ||  (obj_controller.in_forge && forge_cost[i]>0){
            draw_set_color(c_gray);
            if (hover=i) then draw_set_color(c_white);
            if (shop!="production"){
                if (!keyboard_check(vk_shift)) or (shop="warships") then draw_text(xx+x2+x_mod[i],yy+y2,string_hash_to_newline(item[i]));// Name
                if (keyboard_check(vk_shift)) and (shop!="warships") then draw_text(xx+x2+x_mod[i],yy+y2,string_hash_to_newline(string(item[i])+" x5"));// Name
            } else {
                draw_text(xx+x2+x_mod[i],yy+y2,string_hash_to_newline(item[i][1]));// Name
            }
            if (item_stocked[i]=0) and ((mc_stocked[i]=0) or (shop!="equipment")) then draw_set_alpha(0.5);
            if (mc_stocked[i]=0) and (shop!="production") then draw_text(xx+1300,yy+y2,string_hash_to_newline(item_stocked[i]));// Stocked
            if (mc_stocked[i]>0) then draw_text(xx+1300,yy+y2,string_hash_to_newline(string(item_stocked[i])+"   mc: "+string(mc_stocked[i])));
            draw_set_alpha(1);

            if (obj_controller.in_forge){
                draw_sprite_ext(
                            spr_forge_points_icon,0, 
                            xx+1430,
                            yy+y2+3, 
                            0.3, 
                            0.3, 
                            0,
                            c_white,
                            1); 
            } else{
                draw_sprite_ext(spr_requisition,0,xx+1430,yy+y2+6,1,1,0,c_white,1);
            }            
			draw_set_color(16291875)
            if (obj_controller.in_forge){
				draw_set_color(#af5a00)
			}

            var cost = obj_controller.in_forge ? forge_cost[i] : item_cost[i]
             if (!obj_controller.in_forge){
                if (!keyboard_check(vk_shift)) and (obj_controller.requisition<item_cost[i]) then draw_set_color(255);
                if (keyboard_check(vk_shift)) and (obj_controller.requisition<(item_cost[i]*5)) then draw_set_color(255);
            }
            if (shop!="production"){
                if (keyboard_check(vk_shift)) then cost*=5;
            }

            draw_text(xx+1447,yy+y2,cost);// Requisition
            if (!obj_controller.in_forge ){
                if (obj_controller.requisition< cost) then draw_set_alpha(0.25);
            }

            draw_sprite(spr_build_tiny2,0,xx+1530,yy+y2+2);

            draw_set_alpha(1);
           if (obj_controller.in_forge){
            if (point_in_rectangle(mouse_x, mouse_y, xx+1520, yy+y2+2, xx+1580, yy+y2+18)&& mouse_check_button_pressed(mb_left) ){
                if (array_length(obj_controller.forge_queue)<20){
                    var new_queue_item = {
                        name:item[i],
                        count:1,
                        forge_points:forge_cost[i],
                        ordered:obj_controller.turn,
                    }
                    if (shop!="production"){
                        if (keyboard_check(vk_shift)){
                            new_queue_item.count = 5;
                            new_queue_item.forge_points = 5 * forge_cost[i];
                        }
                    }
                    array_push(obj_controller.forge_queue, new_queue_item);
                }               
            }
           }
        }
        if (!obj_controller.in_forge && nobuy[i]=1) ||  (obj_controller.in_forge && forge_cost[i]=0){
            draw_set_alpha(1);
            draw_set_color(881503);
            draw_text(xx+x2+x_mod[i],yy+y2,string_hash_to_newline(item[i]));// Name
            if (item_stocked[i]=0) then draw_set_alpha(0.5);
            draw_text(xx+1300,yy+y2,string_hash_to_newline(item_stocked[i]));// Stocked
            draw_set_alpha(1);
        }
    }
}

if (tooltip_show!=0){
    tooltip_draw(tooltip, 400)
}

if (shop_area!=""){
    obj_controller.cooldown=8000;
    shop=shop_area
    instance_create(50,50,obj_shop);
}
