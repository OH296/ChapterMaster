// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

function trade_tiers(faction){
	var _trade_data = [
		{},
		{},
		//start imperium
		{
			"Requisition":{
				min_disp : 0,
				require_input : true,
				max_size : 100000,
			},
			"Recruiting Planet":{
				min_disp : 0,
			},
			"License: Repair":{
				min_disp : 0,
			},
			"License: Crusade":{
				min_disp : 0,
			},
		},
		//start mechanicus
		{
			"Terminator Armour":{
				min_disp : 30,
				require_input : true,
				max_size : 5,				
			},
			"Land Raider":{
				min_disp : 20,
			},
			"Minor Artifact":{
				min_disp : 40,
			},
			"Skitarii":{
				min_disp : 25,
				require_input : true,
				max_size : 1000,				
			},
			"Techpriest":{
				min_disp : 55,
			},
		},
		{
			"Condemnor Boltgun":{
				min_disp : 20,
				require_input : true,
				max_size : 50,				
			},
			"Land Hellrifle":{
				min_disp : 30,
				require_input : true,
				max_size : 30,				
			},
			"Incinerator":{
				min_disp : 20,
				require_input : true,
				max_size : 30,				
			},
			"Crusader":{
				min_disp : 25,
				require_input : true,
				max_size : 30,				
			},
			"Exterminatus":{
				min_disp : 40,
			},
			"Cyclonic Torpedo":{
				min_disp : 60,
			},			
		},
		{
			"Eviscerator":{
				min_disp : 20,
				require_input : true,
				max_size : 30,				
			},
			"Heavy Flamer":{
				min_disp : 30,
				require_input : true,
				max_size : 30,				
			},
			"Inferno Bolts":{
				min_disp : 30,
				require_input : true,
				max_size : 200,				
			},
			"Sister of Battle":{
				min_disp : 40,
				require_input : true,
				max_size : 60,					
			},
			"Sister Hospitaler":{
				min_disp : 45,
			},			
		},
		{
			"Eldar Power Sword":{
				min_disp : -10,
				max_size : 30,
				require_input : true,				
			},
			"Archeotech Laspistol":{
				min_disp : -10,
				max_size : 5,
				require_input : true,				
			},
			"Ranger":{
				min_disp : 10,
				max_size : 5,
				require_input : true,				
			},
			"Useful Information":{
				min_disp : -15,
			},		
		},
		{
			"Power Klaw":{
				min_disp : -100,
				max_size : 30,
				require_input : true,				
			},
			"Ork Sniper":{
				min_disp : -100,
				max_size : 200,
				require_input : true,				
			},
			"Flash Git":{
				min_disp : -100,
				max_size : 200,
				require_input : true,				
			},		
		},{},{},{},{},{},{},{},{},{}																		
	]
	var _data = _trade_data[faction];
	return _data;
}
function TradeHandler(faction){
	left_panel = new DataSlate();
	center_panel = new DataSlate();
	right_panel = new DataSlate();

	trade_options = trade_tiers(faction);
	trade_viables = [];
	player_disp = disposition[faction];
	player_items = {
			"Requisition":{
				min_disp : -100,
				t_num : 0
			},
			"Gene-Seed":{
				min_disp : -100,
				t_num : 0
			},
			"STC Fragment":{
				min_disp : -100,
				t_num : 0
			},
			"Info Chip":{
				min_disp : -100,
				t_num : 0
			},						
		}
	var _trade_items = struct_get_names(trade_options);
	for (var i=0;i<array_length(_trade_items)i++){
		var _opt = trade_options[$_trade_items[i]];
		if (player_disp>=opt.min_disp){
			_opt.t_num = 0;
			array_push(trade_viables,_trade_items[i]);
		}
	}
	
	self.faction = faction;

	offer_button = new InteractiveButton({
		x1:682,
		y1:649,
		str1:"Offer",
	});
	clear_button = new InteractiveButton({
		x1:562,
		y1:649,
		str1:"Offer",
	});
	offer_button = new InteractiveButton({
		x1:857,
		y1:797,
		str1:"Exit",
	});	
	trade_target = 0;
	trade_theirs = array_create(10,"");
	trade_likely = "";
	draw = function(){
		left_panel.draw(342, )
        draw_set_color(38144);
        draw_rectangle(342,326,486,673,1);
        draw_rectangle(343,327,485,672,1);// Left Main Panel
        draw_rectangle(504,371,741,641,1);
        draw_rectangle(505,372,740,640,1);// Center panel
        draw_rectangle(759,326,903,673,1);
        draw_rectangle(760,327,902,672,1);// Right Main Panel
    
        draw_rectangle(342,326,486,371,1);// Left Title Panel
        draw_rectangle(759,326,903,371,1);// Right Title Panel
    
        draw_set_font(fnt_40k_14b);draw_set_halign(fa_center);
        draw_text(411,330,string_hash_to_newline(string(obj_controller.faction[diplomacy])+"#Items"));
        draw_text(829,330,string_hash_to_newline(string(global.chapter_name)+"#Items"));

        draw_set_halign(fa_left);draw_set_font(fnt_40k_14);
        draw_set_color(38144);		
		if (trade_likely!="") then draw_text(623,348,string_hash_to_newline("["+string(trade_likely)+"]"));
		var _trade_option_draw = [347,382];
		for (var i=0;i<array_length(trade_viables);i++){
			var _trade_name = trade_viables[i]
			var _data = trade_options[$_trade_name];
			var _button_coords = draw_unit_buttons(_trade_option_draw,_trade_name);
			_trade_option_draw = [347, _button_coords[3]];
			if (point_and_click(_button_coords)){
				if (struct_exists(_data, "require_input")){
					if (_data.require_input){
						get_diag_integer($"{_trade_name}s Wanted?"_data.max_size, $"t{_trade_name}")
					}
				}
			}	
		}
		var _trade_option_draw = [347+419,382];
		var player_item_names =struct_get_names(player_items);
		for (var i=0;i<array_length(player_item_names);i++){
			var _data = player_items[$player_item_names[i]];
			var _button_coords = draw_unit_buttons(_trade_option_draw,player_item_names[i]);
			_trade_option_draw = [_trade_option_draw[0], _button_coords[3]];
			if (point_and_click(_button_coords)){
				if (struct_exists(_data, "require_input")){
					if (_data.require_input){
						get_diag_integer($"{_trade_name}s Wanted?"_data.max_size, $"m{_trade_name}")
					}
				}
			}					
		}
		exit_button.draw();
		exit_button.update();
		if (exit_button.clicked()){
			with (obj_controller){
	            cooldown=8;
	            trading=0;
	            scr_dialogue("trade_close");
	            click2=1;
	            if (trading_artifact!=0){
	                diplomacy=0;
	                menu=0;
	                force_goodbye=0;
	                with(obj_popup){instance_destroy();}
	                obj_ground_mission.alarm[1]=1;
	                exit;
	            }
	        }			
		}
		clear_button.draw();
		clear_button.update();
		if (clear_button.clicked()){
            cooldown=8;
            click2=1;
            trade_likely="";
            trade_req=requisition;
            trade_gene=gene_seed;
            trade_chip=stc_wargear_un+stc_vehicles_un+stc_ships_un;
            trade_info=info_chips;

            for(var i=0;i<6;i++){
                if (trading_artifact==0){
                    trade_take[i]="";
                    trade_tnum[i]=0;
                }
                trade_give[i]="";
                trade_mnum[i]=0;
            }			
		}
		offer_button.draw();
		offer_button.update();
		if (offer_button.clicked()){
            cooldown=8;
            click2=1;
            if (diplo_last!="offer") then scr_trade(true);			
		}			
	}
}
obj_controller.trade_handler = new TradeHandler();
function scr_trade_window(){

}