enum ShaderType {
    Body,
    Helmet,
    LeftPauldron,
    Lens,
    Trim,
    RightPauldron,
    Weapon
}

enum UnitSpecialization {
    None,
    Chaplain,
    Apothecary,
    Techmarine,
    Librarian,
    DeathCompany,
    IronFather,
    WolfPriest,
}

enum UnitSpecialColours {
    None,
    Deathwing,
    Ravenwing,
    Gold,
}

enum eARMOUR_SET {
    None,
    MK3,
    MK4,
    MK5,
    MK6,
    MK7,
    MK8,
    Indomitus,
    Tartaros,
}

function UnitImage(unit_surface) constructor{
    u_surface = unit_surface;
    static draw = function (xx, yy, _background=false){
        if (_background){
            draw_rectangle_color_simple(xx-1,yy-1,xx+1+166,yy+271+1,0,c_black);
            draw_rectangle_color_simple(xx-1,yy-1,xx+166+1,yy+271+1,1,c_gray);
            draw_rectangle_color_simple(xx-2,yy-2,xx+166+2,yy+2+271,1,c_black);
            draw_rectangle_color_simple(xx-3,yy-3,xx+166+3,yy+3+271,1,c_gray);
        }      
        if (surface_exists(u_surface)){
            draw_surface(u_surface, xx-200,yy-90);
        }
    }

    static draw_part = function (xx, yy,left,top,width,height, _background=false){
        if (_background){
            draw_rectangle_color_simple(xx-1+left,yy-1+top,xx+1+width,yy+height+1,0,c_black);
            draw_rectangle_color_simple(xx-1+left,yy-1+top,xx+width+1,yy+height+1,1,c_gray);
            draw_rectangle_color_simple(xx-2+left,yy-2+top,xx+width+2,yy+2+height,1,c_black);
            draw_rectangle_color_simple(xx-3+left,yy-3+top,xx+width+3,yy+3+height,1,c_gray);
        }     
        if (surface_exists(u_surface)){
            draw_surface_part(u_surface, left+200, top+90, width,height, xx,yy);
        }       
    }

    static destroy_image = function(){
        if (surface_exists(u_surface)){
            surface_free(u_surface);
        }
    }
}

function BaseColor(R,G,B) constructor{
    r=R;
    g=G;
    b=B;
}

//TODO this is a laxy fix and can be written better
function set_shader_color(shaderType, colorIndex) {
    var findShader, setShader;
    if (instance_exists(obj_controller)){
        with (obj_controller){
            switch (shaderType) {
                case ShaderType.Body:
                    setShader = colour_to_set1;
                    break;
                case ShaderType.Helmet:
                    setShader = colour_to_set2;
                    break;
                case ShaderType.LeftPauldron:
                    setShader = colour_to_set3;
                    break;
                case ShaderType.Lens:
                    setShader = colour_to_set4;
                    break;
                case ShaderType.Trim:
                    setShader = colour_to_set5;
                    break;
                case ShaderType.RightPauldron:
                    setShader = colour_to_set6;
                    break;
                case ShaderType.Weapon:
                    setShader = colour_to_set7;
                    break;
            }
            shader_set_uniform_f(setShader, col_r[colorIndex]/255, col_g[colorIndex]/255, col_b[colorIndex]/255);
        }
    } else if (instance_exists(obj_creation)){
        with (obj_controller){
            switch (shaderType) {
                case ShaderType.Body:
                    setShader = colour_to_set1;
                    break;
                case ShaderType.Helmet:
                    setShader = colour_to_set2;
                    break;
                case ShaderType.LeftPauldron:
                    setShader = colour_to_set3;
                    break;
                case ShaderType.Lens:
                    setShader = colour_to_set4;
                    break;
                case ShaderType.Trim:
                    setShader = colour_to_set5;
                    break;
                case ShaderType.RightPauldron:
                    setShader = colour_to_set6;
                    break;
                case ShaderType.Weapon:
                    setShader = colour_to_set7;
                    break;
            }
            shader_set_uniform_f(setShader, col_r[colorIndex]/255, col_g[colorIndex]/255, col_b[colorIndex]/255);
        }        
    }
}

// Define armour types
enum ArmourType {
    Normal,
    Scout,
    Terminator,
    Dreadnought,
    None
}

// Define backpack types
enum BackType {
    None,
    Dev,
    Jump,
}

function make_colour_from_array(col_array){
    return make_color_rgb(col_array[0] *255, col_array[1] * 255, col_array[2] * 255);
}

function set_shader_to_base_values(){
    with (obj_controller){
            shader_set_uniform_f_array(colour_to_find1, body_colour_find );
            shader_set_uniform_f_array(colour_to_set1, body_colour_replace );
            shader_set_uniform_f_array(colour_to_find2, secondary_colour_find );       
            shader_set_uniform_f_array(colour_to_set2, secondary_colour_replace );
            shader_set_uniform_f_array(colour_to_find3, pauldron_colour_find );       
            shader_set_uniform_f_array(colour_to_set3, pauldron_colour_replace );
            shader_set_uniform_f_array(colour_to_find4, lens_colour_find );       
            shader_set_uniform_f_array(colour_to_set4, lens_colour_replace );
            shader_set_uniform_f_array(colour_to_find5, trim_colour_find );
            shader_set_uniform_f_array(colour_to_set5, trim_colour_replace );
            shader_set_uniform_f_array(colour_to_find6, pauldron2_colour_find );
            shader_set_uniform_f_array(colour_to_set6, pauldron2_colour_replace );
            shader_set_uniform_f_array(colour_to_find7, weapon_colour_find );
            shader_set_uniform_f_array(colour_to_set7, weapon_colour_replace );
        }
        shader_set_uniform_i(shader_get_uniform(sReplaceColor, "u_blend_modes"), 0);   
}

function set_shader_array(shader_array){
    for (var i=0;i<array_length(shader_array);i++){
        if (shader_array[i]>-1){
            set_shader_color(i, shader_array[i]);
        }
    }
}

/// @mixin
function scr_draw_unit_image(_background=false){
    static draw_unit_hands = function(x_surface_offset, y_surface_offset, armour_type, specialist_colours, hide_bionics, right_left){
        shader_set(sReplaceColor);
        if (arm_variant[right_left] == 1) {
            return;
        }

        if (armour_type != ArmourType.None){
            var offset_x = x_surface_offset;
            var offset_y = y_surface_offset;
            switch(armour_type){
                case ArmourType.Terminator:
                    var _hand_spr = spr_terminator_hands;
                    break;
                case ArmourType.Scout:
                    var _hand_spr = spr_pa_hands;
                    offset_y += 11;
                    offset_x += ui_xmod[right_left];
                default:
                case ArmourType.Normal:
                    var _hand_spr = spr_pa_hands;
                    break;
            }
            if (hand_variant[right_left] > 0){
                var _spr_index = (hand_variant[right_left] - 1) * 2;
                if (right_left == 2) {
                    _spr_index += (specialist_colours >= 2) ? 1 : 0;
                    draw_sprite_flipped(_hand_spr, _spr_index, offset_x, offset_y);
                } else {
                    draw_sprite(_hand_spr, _spr_index, offset_x, offset_y);
                }
            }
            // Draw bionic hands
            if (hand_variant[right_left] == 1){
                if (armour_type == ArmourType.Normal && !hide_bionics && struct_exists(body[$ (right_left == 1 ? "right_arm" : "left_arm")], "bionic")) {
                    var bionic_hand = body[$ (right_left == 1 ? "right_arm" : "left_arm")][$ "bionic"];
                    var bionic_spr_index = bionic_hand.variant * 2;
                    if (right_left == 2) {
                        bionic_spr_index += (specialist_colours >= 2) ? 1 : 0;
                        draw_sprite_flipped(spr_bionics_hand, bionic_spr_index, offset_x, offset_y);
                    } else {
                        draw_sprite(spr_bionics_hand, bionic_spr_index, offset_x, offset_y);
                    }
                }
            }
        }
        shader_set(full_livery_shader);
    };

    static draw_unit_arms = function(_x_surface_offset, _y_surface_offset, _armour_type, _specialist_colours, _hide_bionics, _complex_set) {
        shader_set(sReplaceColor);
        if (array_contains([ArmourType.Normal, ArmourType.Terminator, ArmourType.Scout], _armour_type)) {
            var _bionic_options = [];
            var _arm_spr;
            switch (_armour_type) {
                case ArmourType.Terminator:
                    _arm_spr = spr_terminator_arms;
                    _bionic_options = [spr_indomitus_right_arm_bionic];
                    break;
                case ArmourType.Scout:
                    _arm_spr = spr_scout_arms;
                    break;
                case ArmourType.Normal:
                default:
                    _bionic_options = [spr_bionics_arm, spr_bionics_arm_2];
                    if (armour() == "Artificer Armour") {
                        //todo: refactor this
                        _arm_spr = spr_pa_arms_ornate;
                    } else {
                        _arm_spr = spr_pa_arms;
                    }
                    break;
            }
            for (var _right_left = 1; _right_left <= 2; _right_left++) {
                // Draw bionic arms
                var _bionic_arm = get_body_data("bionic", _right_left == 1 ? "right_arm" : "left_arm");
                if (arm_variant[_right_left] == 1 && array_length(_bionic_options) && !_hide_bionics && _bionic_arm) {
                    var _bionic_variant = _bionic_arm.variant % array_length(_bionic_options);
                    var _bionic_spr_index = 0;
                    var _bionic_spr = _bionic_options[_bionic_variant];
                    if (_right_left == 2) {
                        if (_specialist_colours >= 2) {
                            _bionic_spr_index = sprite_get_number(_bionic_spr) - 1;
                        }
                        draw_sprite_flipped(_bionic_spr, _bionic_spr_index, _x_surface_offset, _y_surface_offset);
                    } else {
                        draw_sprite(_bionic_spr, _bionic_spr_index, _x_surface_offset, _y_surface_offset);
                    }
                } else if (arm_variant[_right_left] > 0) {
                    shader_set(full_livery_shader);
                    if ((_right_left == 1) && struct_exists(_complex_set, "right_arm") && (arm_variant[_right_left] == 1)) {
                        draw_sprite(_complex_set.right_arm, 0, _x_surface_offset, _y_surface_offset);
                        shader_set(sReplaceColor);
                    } else if ((_right_left == 2) && struct_exists(_complex_set, "left_arm") && (arm_variant[_right_left] == 1)) {
                        shader_set(full_livery_shader);
                        draw_sprite(_complex_set.left_arm, 0, _x_surface_offset, _y_surface_offset);
                        shader_set(sReplaceColor);
                    } else {
                        shader_set(sReplaceColor);
                        var _spr_index = (arm_variant[_right_left] - 1) * 2;
                        if (_right_left == 2) {
                            _spr_index += (_specialist_colours >= 2) ? 1 : 0;
                            draw_sprite_flipped(_arm_spr, _spr_index, _x_surface_offset, _y_surface_offset);
                        } else {
                            draw_sprite(_arm_spr, _spr_index, _x_surface_offset, _y_surface_offset);
                        }
                    }
                }
            }
        }
        shader_set(full_livery_shader);
    };

    var _role = obj_ini.role[100];
    var complex_set={};    
    var x_surface_offset = 200;
    var y_surface_offset = 110;
    var unit_surface = surface_create(600, 600);
    surface_set_target(unit_surface);
    draw_clear_alpha(c_black, 0);//RESET surface
    draw_set_font(fnt_40k_14b);
    draw_set_color(c_gray);
	var xx=__view_get( e__VW.XView, 0 )+0, yy=__view_get( e__VW.YView, 0 )+0, bb="", img=0;
    var modest_livery = obj_controller.modest_livery;
    var progenitor_visuals = obj_controller.progenitor_visuals;
    var draw_sequence = [];
    try {
    if (name_role()!="") and (base_group=="astartes"){
        for (var i = 1; i <= 2; i++) {
            ui_weapon[i]=spr_weapon_blank;
            arm_variant[i]=1;
            hand_variant[i]=1;
            hand_on_top[i]=false;
            ui_spec[i]=false;
            ui_twoh[i]=false;
            ui_xmod[i]=0;
            ui_ymod[i]=0;
            new_weapon_draw[i]=false;
        }
        var draw_backpack = true;
        var ui_force_both=false;
        var pauldron_trim=false;
        var armour_bypass = false;
        var hide_bionics = false;
        var robes_bypass = false;
        var robes_hood_bypass = false;
        var halo_bypass = false;
        var arm_bypass = false;
        var armour_draw = [];
		var specialist_colours=obj_ini.col_special; 
        var specific_armour_sprite = "none";
        var unit_chapter = global.chapter_name;
        var unit_progenitor = progenitor_visuals ? progenitor_map() : 0;
        var unit_is_sniper = false;
        var unit_role = role();
        var unit_wep1=weapon_one();
        var unit_wep2=weapon_two();
        var unit_armour=armour();
        var unit_gear=gear();
        var unit_back=mobility_item()
        var unit_specialization=UnitSpecialization.None;
        var unit_special_colours=0;
        var skin_color=obj_ini.skin_color;
        var armour_type = ArmourType.Normal;
        var armour_sprite = spr_weapon_blank;
        var complex_livery = false;
        var back_equipment = BackType.None;
        var psy_hood = false;
        var skull_mask = false;
        var servo_arm = 0;
        var servo_harness = 0;
        var halo = 0;
        var reverent_guardians = false;
        var tech_brothers_trait = -5;
        var body_part;
        var dev_trait = 0;

        // if (unit_role=="Chapter Master"){unit_specialization=111;}
        // // Honour Guard
        // else if (unit_role==obj_ini.role[100,2]){unit_specialization=14;}
        // Chaplain
        if (is_specialist(unit_role,"chap",true)){
            if (unit_chapter== "Iron Hands"){
                unit_specialization=UnitSpecialization.IronFather;
            } else if (unit_chapter == "Space Wolves") {
                unit_specialization=UnitSpecialization.WolfPriest;
            } else {
                unit_specialization=UnitSpecialization.Chaplain;
            }
        }
        // Techmarine
        else if (is_specialist(unit_role,"forge",true)){
            if (unit_chapter== "Iron Hands"){
                unit_specialization=UnitSpecialization.IronFather;
            } else {
                unit_specialization=UnitSpecialization.Techmarine;
            }
        }
        // Apothecary
        else if (is_specialist(unit_role,"apoth",true)){
            if (unit_chapter == "Space Wolves") {
                unit_specialization=UnitSpecialization.WolfPriest;
            } else {
                unit_specialization=UnitSpecialization.Apothecary;
            }
        }
        // Librarian
        else if (is_specialist(unit_role,"libs",true)){unit_specialization=UnitSpecialization.Librarian;}
        // Death Company
        else if (unit_role=="Death Company"){unit_specialization=UnitSpecialization.DeathCompany;}
        // Dark Angels
        if (unit_chapter=="Dark Angels"){
            // Deathwing
            if (company == 1) {
                unit_special_colours=UnitSpecialColours.Deathwing;
            }
            // Ravenwing
            else if (company == 2) {
                unit_special_colours=UnitSpecialColours.Ravenwing;
            }
        }
        // Blood Angels gold
        if ((unit_role==_role[eROLE.HonourGuard] || unit_role=="Chapter Master")) and (unit_chapter=="Blood Angels"){
            unit_special_colours=UnitSpecialColours.Gold;
        }
        // Sets up the description for the equipement of current marine            

        if (scr_has_adv("Reverent Guardians")){
            if (array_contains([UnitSpecialization.Chaplain, UnitSpecialization.WolfPriest, UnitSpecialization.Librarian], unit_specialization) || unit_role=="Chapter Master"){
                    reverent_guardians = true;
            }
        }

        if (unit_gear == "Psychic Hood"){
            psy_hood = true;
        }

        if (array_contains([UnitSpecialization.Chaplain, UnitSpecialization.WolfPriest], unit_specialization)) then skull_mask = true;
    
        // if (_armour_type!=ArType.Norm) then draw_backpack=false;

        if (unit_back=="Jump Pack"){
			draw_backpack=false;
			back_equipment=BackType.Jump;
		}else if (unit_back=="Heavy Weapons Pack"){
            draw_backpack=false;
			back_equipment=BackType.Dev;
        } else if (unit_back="Servo-arm"){
            servo_arm=1;
        } else if (unit_back="Servo-harness"){
            servo_harness=1;
        }

        if (unit_gear == "Iron Halo"){
            halo = 1;
        }

        switch(unit_armour){
            case "Scout Armour":
                armour_type = ArmourType.Scout;
                break;
            case "Terminator Armour":
            case "Tartaros":
                armour_type = ArmourType.Terminator;
                break;
            case "Dreadnought":
                armour_type = ArmourType.Dreadnought;
                break;
            case ITEM_NAME_NONE:
            case "":
            case "None":
                armour_type = ArmourType.None;
                break;
            }
		
        if (armour_type!=ArmourType.Normal) then draw_backpack=false;
        
        if (armour_type!=ArmourType.Dreadnought && armour_type!=ArmourType.None){
            if (weapon_one()!=""){
                scr_ui_display_weapons(1,unit_armour,weapon_one(), armour_type);
            }
            
            if (weapon_two()!="") and (ui_twoh[1]==false){
                scr_ui_display_weapons(2,unit_armour,weapon_two(), armour_type);
            }
        }

        if(shader_is_compiled(sReplaceColor)){
            shader_set(sReplaceColor);

            set_shader_to_base_values();

            //TODO make some sort of reusable structure to handle this sort of colour logic
            // also not ideal way of creating colour variation but it's a first pass
            var shader_array_set = array_create(8, -1);
        
            pauldron_trim=obj_controller.trim;
			specialist_colours=obj_ini.col_special;
			
			// Chaplain
            if (array_contains([UnitSpecialization.Chaplain, UnitSpecialization.WolfPriest], unit_specialization)){
                shader_array_set[ShaderType.Body] = Colors.Black;
                shader_array_set[ShaderType.Helmet] = Colors.Black;
                shader_array_set[ShaderType.Lens] = Colors.Red;
                shader_array_set[ShaderType.Trim] = Colors.Dark_Gold;
                shader_array_set[ShaderType.RightPauldron] = Colors.Black;
                pauldron_trim=1;
                specialist_colours=0;
                if (unit_chapter == "Dark Angels") {
                    shader_array_set[ShaderType.Trim] = Colors.Copper;
                    if (unit_role == "Master of Sanctity") {
                        shader_array_set[ShaderType.Helmet] = Colors.Caliban_Green;
                        pauldron_trim=0;
                    }
                }
            }
			//TODO complex shader means no need for all this edge case stuff
			
			// Honour Guard
            else if (unit_role==_role[eROLE.HonourGuard]){
                pauldron_trim=0;
                specialist_colours=0;
                // Blood Angels
                if (unit_special_colours==UnitSpecialColours.Gold){
                    shader_array_set[ShaderType.Body] = Colors.Gold;
                    shader_array_set[ShaderType.Helmet] = Colors.Gold;
                    shader_array_set[ShaderType.LeftPauldron] = Colors.Gold;
                    shader_array_set[ShaderType.Trim] = Colors.Gold;
                // Ultramarines
                } else if (unit_chapter == "Ultramarines"){
                    shader_array_set[ShaderType.Helmet] = Colors.Sanguine_Red;
                }
            }

			// Blood Angels Death Company Marines
            else if (unit_specialization==UnitSpecialization.DeathCompany){
                shader_array_set[ShaderType.Body] = Colors.Black;
                shader_array_set[ShaderType.Helmet] = Colors.Black;
                shader_array_set[ShaderType.LeftPauldron] = Colors.Black;
                shader_array_set[ShaderType.Lens] = Colors.Red;
                shader_array_set[ShaderType.Trim] = Colors.Black;
                shader_array_set[ShaderType.RightPauldron] = Colors.Black;
                shader_array_set[ShaderType.Weapon] = Colors.Dark_Red;
                pauldron_trim=0;
                specialist_colours=0;
            }
			
			// Dark Angels Deathwing
            if (unit_special_colours == UnitSpecialColours.Deathwing){
                if !array_contains([_role[eROLE.Chaplain],_role[eROLE.Librarian], _role[eROLE.Techmarine]], unit_role){
                    shader_array_set[ShaderType.Body] = Colors.Deathwing;
                    shader_array_set[ShaderType.Trim] = Colors.Light_Caliban_Green;
                    if (unit_role != _role[eROLE.Apothecary]){
                        shader_array_set[ShaderType.Helmet] = Colors.Deathwing;
                    }
                }
                if !array_contains([_role[eROLE.Chaplain],_role[eROLE.Techmarine]], unit_role){
                    shader_array_set[ShaderType.RightPauldron] = Colors.Deathwing;
                }
                shader_array_set[ShaderType.LeftPauldron] = Colors.Deathwing;
                pauldron_trim=0;
                specialist_colours=0;
            }
            
			// Dark Angels Ravenwing
            if (unit_special_colours == UnitSpecialColours.Ravenwing){
                if !array_contains([_role[eROLE.Chaplain],_role[eROLE.Librarian], _role[eROLE.Techmarine],_role[eROLE.Apothecary]], unit_role){
                    shader_array_set[ShaderType.Body] = Colors.Black;
                    shader_array_set[ShaderType.Helmet] = Colors.Black;
                }
                if !array_contains([_role[eROLE.Chaplain],_role[eROLE.Techmarine]], unit_role){
                    shader_array_set[ShaderType.RightPauldron] = Colors.Black;
                }
                shader_array_set[ShaderType.LeftPauldron] = Colors.Black;
                pauldron_trim=0;
                specialist_colours=0;
            }

			// Dark Angels Captains
            if (unit_chapter == "Dark Angels" && unit_role == _role[eROLE.Captain] && company != 1){
                shader_array_set[ShaderType.RightPauldron] = Colors.Dark_Red;
                shader_array_set[ShaderType.Helmet] = Colors.Deathwing;
                pauldron_trim=0;
                specialist_colours=0;
            }

            // Dark Angels Honour Guard
            if (unit_chapter == "Dark Angels" && unit_role == _role[eROLE.HonourGuard]){
                shader_array_set[ShaderType.Body] = Colors.Deathwing;
                shader_array_set[ShaderType.RightPauldron] = Colors.Deathwing;
                shader_array_set[ShaderType.LeftPauldron] = Colors.Deathwing;
                shader_array_set[ShaderType.Trim] = Colors.Copper;
                pauldron_trim=0;
                specialist_colours=0;
            }

			// Blood Angels Sergeants
            if (unit_chapter == "Blood Angels" && unit_role == _role[eROLE.Sergeant]){
                shader_array_set[ShaderType.LeftPauldron] = Colors.Black;
                shader_array_set[ShaderType.RightPauldron] = Colors.Black;
                pauldron_trim=0;
                specialist_colours=0;
            }

            //We can return to the custom shader values at any time during draw doing this 
            set_shader_array(shader_array_set);
			// Marine draw sequence
            /*
            main
            secondary
            pauldron
            lens
            trim
            pauldron2
            weapon
            */
        
            //Rejoice!
            // draw_sprite(spr_marine_base,img,x_surface_offset,y_surface_offset);
        
            if (unit_armour!=""){
                var yep=0;
                if scr_has_adv("Devastator Doctrine"){
                    dev_trait=1
                }
                if (unit_specialization == UnitSpecialization.Techmarine){
                    if (scr_has_adv("Tech-Brothers")){
                        tech_brothers_trait=0
                    }
				}
            }else{armour_sprite=spr_weapon_blank;}// Define armour
        
			
			
            if (armour_type == ArmourType.Scout){
				if (dev_trait>0) then dev_trait=10;
				armour_sprite=spr_scout_colors2;
                if (squad!="none"){
                    if (obj_ini.squads[squad].type=="scout_sniper_squad" || weapon_one()=="Sniper Rifle" || weapon_two()=="Sniper Rifle"){
                        unit_is_sniper = true;
                    }
                }
			}
                
            // Draw the lights
            if (unit_specialization == UnitSpecialization.Apothecary) and (unit_armour!="") and (back_equipment == BackType.None){
                if (unit_armour=="Terminator Armour") then draw_sprite(spr_gear_apoth,0,x_surface_offset,y_surface_offset-22); // for terminators
                else draw_sprite(spr_gear_apoth,0,x_surface_offset,y_surface_offset-6); // for normal power armour
            }
        
            // Draw Techmarine gear
            if (servo_arm > 0 || servo_harness > 0) && (!arm_bypass) {
                var arm_offset_y = 0;
                if (unit_armour == "Terminator Armour" || unit_armour == "Tartaros") {
                    arm_offset_y -= 18;
                }
            
                draw_sprite(servo_arm > 0? spr_servo_arm : spr_servo_harness, 0, x_surface_offset, y_surface_offset + arm_offset_y);
            }

            if (armour_type==ArmourType.None){            
                if (unit_role=="Chapter Master" && unit_chapter=="Doom Benefactors") then skin_color=6;
            
                draw_sprite(spr_marine_base,skin_color,x_surface_offset,y_surface_offset);
            
               // if (skin_color!=6) then draw_sprite(spr_clothing_colors,clothing_style,x_surface_offset,y_surface_offset);
            } else { 
                if (armour_type == ArmourType.Scout){
                    if (unit_is_sniper = true){
                        draw_sprite(spr_marine_head,skin_color,x_surface_offset,y_surface_offset);
                        draw_sprite(spr_scout_colors,11,x_surface_offset,y_surface_offset);// Scout Sniper Cloak
                    }
                    draw_sprite(armour_sprite,specialist_colours,x_surface_offset,y_surface_offset);
                    //draw_sprite(spr_facial_colors,clothing_style,x_surface_offset,y_surface_offset);
                    specific_armour_sprite=armour_sprite;
                    armour_bypass=true;
                }else if (unit_armour=="MK3 Iron Armour"){
                    specific_armour_sprite = spr_mk3_complex;
                    complex_set = get_complex_set(eARMOUR_SET.MK3);
                    complex_livery = true;
                    if (scr_has_style("Knightly")){
                        complex_set.add_relative_to_status("crest", spr_da_mk5_helm_crests, 2, get_body_data("crest_variation","head"), self);
                    }                      
                    if (unit_progenitor == ePROGENITOR.DARK_ANGELS){
                        complex_livery = false;
                        if (unit_role==_role[eROLE.Captain]){
                            // specific_armour_sprite = spr_da_mk3;
                            armour_draw=[spr_da_mk3,0];
                            robes_bypass = true;
                            robes_hood_bypass = true;
                            armour_bypass=true;
                        }
                    }
                } else if (unit_armour=="MK4 Maximus"){
                    specific_armour_sprite = spr_mk4_complex;
                    complex_set = get_complex_set(eARMOUR_SET.MK4);
                    complex_livery = true;
                    if (scr_has_style("Knightly")){
                        complex_set.add_relative_to_status("crest", spr_da_mk5_helm_crests, 2, get_body_data("crest_variation","head"), self);
                    }                      
                    if (array_contains(["Champion",_role[2],_role[5]], unit_role)){
                        /*if (unit_chapter=="Ultramarines"){
                            armour_draw=[spr_ultra_honor_guard,body.torso.armour_choice];
                            armour_bypass=true;
                            draw_sprite(spr_ultra_honor_guard,2,x_surface_offset,y_surface_offset);
                        } else {
                            armour_draw=[spr_generic_honor_guard,body.torso.armour_choice];
                            armour_bypass=true;
                        }*/                      
                    }
                    if (unit_progenitor == ePROGENITOR.DARK_ANGELS){
                        if (unit_role==_role[eROLE.Captain]){
                            // specific_armour_sprite = spr_da_mk4;
                            complex_livery = false;
                            armour_draw=[spr_da_mk4,0];
                            robes_bypass = true;
                            robes_hood_bypass = true;
                            armour_bypass=true;
                        }
                    }
                } else if (unit_armour=="MK5 Heresy"){
                    specific_armour_sprite = spr_mk5_complex;
                    complex_set = get_complex_set(eARMOUR_SET.MK5);
                    complex_livery = true;
                    //TODO sort this mess out streamline system somehow
                    if (scr_has_style("Mongol")){
                        complex_set.add_to_area("mouth_variants", spr_mk5_samuri_faceplate);
                    }
                    if (scr_has_style("Knightly")){
                        complex_set.add_relative_to_status("crest", spr_da_mk5_helm_crests, 2, get_body_data("crest_variation","head"), self);
                    }                      
                    if (unit_progenitor == ePROGENITOR.DARK_ANGELS){
                        if (unit_role==_role[eROLE.Captain]){
                            // specific_armour_sprite = spr_da_mk5;
                            armour_draw=[spr_da_mk5,0];
                            robes_bypass = true;
                            robes_hood_bypass = true;
                            armour_bypass=true;
                            complex_livery = false;
                        }                        
                    }                   
                } else if (unit_armour=="MK6 Corvus"){
                    specific_armour_sprite = spr_mk6_complex;
                    complex_set = get_complex_set(eARMOUR_SET.MK6);
                    complex_livery = true;
                    specific_armour_sprite = spr_beakie_colors;
                    if (scr_has_style("Knightly")){
                        complex_set.add_relative_to_status("crest", spr_da_mk6_helm_crests, 2, get_body_data("crest_variation","head"), self);
                    }
                    if (obj_ini.progenitor == ePROGENITOR.DARK_ANGELS){
                        complex_set.add_relative_to_status("crest", spr_da_mk6_helm_crests, 2, get_body_data("crest_variation","head"), self);
                        if (unit_role==_role[eROLE.Captain]){
                            complex_livery = false;
                            // specific_armour_sprite = spr_da_mk6;
                            armour_draw=[spr_da_mk6,0];
                            robes_bypass = true;
                            robes_hood_bypass = true;
                            armour_bypass=true;
                        }                      
                    }

                } else if (unit_armour=="MK7 Aquila" || unit_armour="Power Armour"){
                    specific_armour_sprite = spr_mk7_complex;
                    complex_set = get_complex_set(eARMOUR_SET.MK7);
                    complex_livery = true;
                    if (scr_has_style("Knightly")){
                        complex_set.add_relative_to_status("crest", spr_da_mk7_helm_crests, 2, get_body_data("crest_variation","head"), self);
                    }
                    if (obj_ini.progenitor == ePROGENITOR.DARK_ANGELS){
                        if (unit_role==_role[eROLE.Captain]){
                            // specific_armour_sprite = spr_da_mk7;
                            armour_draw = [spr_da_mk7,0];
                            robes_bypass = true;
                            robes_hood_bypass = true;
                            armour_bypass = true;
                            complex_livery = false;
                        }                          
                    }
                } else if (unit_armour=="MK8 Errant"){
                    specific_armour_sprite = spr_mk8_colors;
                    complex_set = get_complex_set(eARMOUR_SET.MK8);
                    complex_livery = true;
                    if (scr_has_style("Knightly")){
                        complex_set.add_relative_to_status("crest", spr_da_mk7_helm_crests, 2, get_body_data("crest_variation","head"), self);
                    }
                    if (unit_progenitor == ePROGENITOR.DARK_ANGELS) {
                        if (unit_role==_role[eROLE.Captain]){
                            // specific_armour_sprite = spr_da_mk8;
                            armour_draw=[spr_da_mk8,0];
                            robes_bypass = true;
                            robes_hood_bypass = true;
                            armour_bypass=true;
                        }                          
                    }                    
                } else if (unit_armour=="Artificer Armour"){
                    complex_set = get_complex_set(eARMOUR_SET.MK7);
                    complex_set.add_group({
                        right_leg : spr_artificer_right_leg,
                        left_leg : spr_artificer_left_leg,
                        chest_variants : spr_artificer_chest,
                        thorax_variants : spr_artificer_thorax,
                        mouth_variants : spr_artificer_mouth,
                        left_trim : spr_artificer_left_trim,
                        left_pauldron : spr_artificer_left_pad,
                    });
                    if (scr_has_style("Knightly")){
                        complex_set.add_relative_to_status("crest", spr_da_mk7_helm_crests, 2, get_body_data("crest_variation","head"), self);
                    }                    
                    complex_livery = true;
                    if (array_contains(["Champion",_role[2],_role[5]], unit_role)){
                        if (unit_chapter=="Ultramarines"){
                            armour_draw=[spr_ultra_honor_guard2, body.torso.armour_choice];
                            armour_bypass=true;
                            // Draw cape;
                            draw_sprite(spr_ultra_honor_guard2,2,x_surface_offset,y_surface_offset);
                        }
                    } 
                    if (unit_chapter=="Blood Angels" || unit_progenitor == eCHAPTERS.BLOOD_ANGELS){
                        if (unit_role=="Chapter Master"){

                            armour_bypass=true;
                            hide_bionics = true;
                            robes_bypass = true;
                            robes_hood_bypass = true;
                            armour_draw=[spr_dante,0];
                            // Draw wings;
                            draw_sprite(spr_dante,1,x_surface_offset,y_surface_offset);
                        } else if (unit_role==_role[2]){
                            
                            armour_bypass=true;
                            hide_bionics = true;
                            robes_bypass = true;
                            robes_hood_bypass = true;
                            armour_draw=[spr_sanguin_guard,0];
                            draw_sprite(spr_sanguin_guard,1,x_surface_offset,y_surface_offset);
                        }
                    } else if(unit_chapter=="Dark Angels"){
                        if (unit_role=="Chapter Master"){
                            armour_bypass=true;
                            hide_bionics = true;
                            robes_bypass = true;
                            robes_hood_bypass = true;
                            armour_draw=[spr_azreal,0];
                        }
                        if (unit_role=="Master of Sanctity"){
                            armour_bypass=true;
                            hide_bionics = true;
                            robes_bypass = true;
                            robes_hood_bypass = true;
                            skull_mask = false;
                            armour_draw=[spr_da_chaplain,0];
                        }
                    }
                } else if (unit_armour=="Tartaros"){
                    specific_armour_sprite = spr_tartaros_complex;
                    complex_set = get_complex_set(eARMOUR_SET.Tartaros);
                    complex_livery = true;
                } else if (unit_armour=="Terminator Armour"){
                    specific_armour_sprite = spr_indomitus_complex;
                    complex_set = get_complex_set(eARMOUR_SET.Indomitus);
                    complex_livery = true;
                    if(unit_chapter == "Dark Angels"){
                        if (unit_role == _role[eROLE.HonourGuard]){
                            armour_bypass=true;
                            armour_draw=[spr_da_term_honor,0];
                            hide_bionics = true;
                        }
                    }
                }
                if (unit_role == _role[eROLE.Champion] || unit_role == _role[eROLE.Captain]){
                    if (unit_armour=="Terminator Armour" || unit_armour="Tartaros"){
                        complex_set.add_to_area("crown", spr_terminator_laurel);
                    } else if (armour_type == ArmourType.Normal){
                        complex_set.add_to_area("crown", spr_laurel);
                        if (unit_role == _role[eROLE.Champion]) {
                            if (unit_armour!="MK3 Iron Armour"){
                                complex_set.add_to_area("mouth_variants", spr_special_helm);
                            }
                        }   
                    }
                }
                if (armour_type == ArmourType.Normal){
                    if (progenitor_map() == 2){
                        complex_set.add_to_area("crest", spr_mongol_topknots);
                        complex_set.add_to_area("forehead", spr_mongol_hat);
                    }
                    if (scr_has_style("Mechanical Cult")){
                        complex_set.add_relative_to_status("tabbard", spr_metal_tabbard, 2, get_body_data("tabbard_variation","torso"), self);
                    }                    
                }
                if (unit_specialization == UnitSpecialization.Techmarine){
                    if array_contains(["MK5 Heresy", "MK6 Corvus","MK7 Aquila", "MK8 Errant", "Artificer Armour"], unit_armour){
                        if (has_trait("tinkerer") && complex_livery){
                            complex_set.add_group({
                                "armour":spr_techmarine_complex,
                                "right_trim":spr_techmarine_right_trim,
                                "left_trim":spr_techmarine_left_trim,
                                "leg_variants":spr_techmarine_left_leg,
                                "leg_variants":spr_techmarine_right_leg,
                                "head":spr_techmarine_head,
                                "chest_variants":spr_techmarine_chest,                               
                            })
                        }
                    }

                }
                if (armour_type==ArmourType.Normal && complex_livery && unit_role==_role[2]){
                    complex_set.add_group({
                        right_leg : spr_artificer_right_leg,
                        left_leg : spr_artificer_left_leg,
                        chest_variants : spr_artificer_chest,
                        thorax_variants : spr_artificer_thorax,
                        mouth_variants : spr_artificer_mouth
                    });
                }

                // Chaplain helmet
                if (skull_mask) {
                    complex_set.remove_area("mouth_variants");
                    if (armour_type == ArmourType.Terminator) {
                        if (unit_specialization == UnitSpecialization.WolfPriest) {
                            complex_set.replace_area("head",spr_chaplain_wolfterm_helm);
                        } else {
                            complex_set.replace_area("head",spr_chaplain_term_helm);
                        }
                    } else {
                        if (unit_specialization == UnitSpecialization.WolfPriest) {
                            complex_set.replace_area("head",spr_chaplain_wolf_helm);
                        } else {
                            complex_set.replace_area("head",spr_chaplain_helm); 
                        }
                    }
                }

                // Draw the Iron Halo
                if (halo==1 && !halo_bypass){
                    var halo_offset_y = 0;
                    var halo_color=0;
                    var halo_type = 2;
                    if (array_contains(["Raven Guard", "Dark Angels"], unit_chapter)) {
                        halo_color = 1;
                    }
                    if (unit_armour=="Terminator Armour"){
                        halo_type = 2;
                        halo_offset_y -= 20;
                    } else if (unit_armour=="Tartaros"){
                        halo_type = 2;
                        halo_offset_y -= 20;
                    }
                    draw_sprite(spr_gear_halo,halo_type+halo_color,x_surface_offset,y_surface_offset+halo_offset_y);
                }

                 // Draw the backpack
                if (draw_backpack){
                    var _backpack_sprite = "";
                    var _backpack_index = 0;

                    if (specialist_colours==0) {
                        _backpack_sprite = armour_sprite;
                        _backpack_index = 10;
                    } else if (specialist_colours==1) {
                        _backpack_sprite = armour_sprite;
                        _backpack_index = 11;
                    } else if (specialist_colours>=2) {
                        _backpack_sprite = armour_sprite;
                        _backpack_index = 12;
                    }

                    if (body.torso.backpack_variation % 3 == 0) {
                        if (unit_progenitor == ePROGENITOR.DARK_ANGELS){
                            if array_contains(["MK5 Heresy", "MK6 Corvus","MK7 Aquila", "MK8 Errant", "Artificer Armour"], unit_armour){
                                _backpack_sprite = spr_da_backpack;
                                complex_set.add_to_area("backpack",spr_da_backpack);                                                        
                            }
                        }
                        if (reverent_guardians) and (!modest_livery){
                            complex_set.add_to_area("backpack",spr_pack_brazier3);                         
                        }
                    }

                    /*if (unit_progenitor == "Dark Angels") {
                        if (unit_role == "Chapter Master") {
                            _backpack_sprite = spr_da_backpack;
                            _backpack_index = 1;
                        } else if (unit_role == "Master of Sanctity") {
                            _backpack_sprite = spr_da_chaplain;
                            _backpack_index = 1;
                        }
                    }*/
                    if (complex_livery) && (struct_exists(complex_set, "backpack")){
                        var choice = get_body_data("backpack_variation","torso")%sprite_get_number(complex_set.backpack);
                        setup_complex_livery_shader(role(),self);
                        draw_sprite(complex_set.backpack,choice,x_surface_offset,y_surface_offset);
                        shader_set(sReplaceColor);
                    } else {
                        draw_sprite(_backpack_sprite, _backpack_index, x_surface_offset, y_surface_offset);
                    }
                }else{
                    if (back_equipment==BackType.Jump){
                        var color_variant = min(specialist_colours, 2);
                        draw_sprite(spr_pack_jump,color_variant,x_surface_offset,y_surface_offset);
                    } else if (back_equipment==BackType.Dev){
                        var color_variant = min(specialist_colours, 2);
                        draw_sprite(spr_pack_devastator,color_variant,x_surface_offset,y_surface_offset);
                    }
                }

                if (armour_type == ArmourType.Terminator && complex_livery){
                    var _body_parts = ARR_body_parts;
                    for (var part = 0; part < array_length(_body_parts); part++) {
                        if (struct_exists(body[$ _body_parts[part]], "bionic")) {

                            var body_part = _body_parts[part];
                            var bionic = body[$ body_part][$ "bionic"];
                            switch (body_part) {
                                case "left_eye":
                                    complex_set.add_to_area("left_eye", spr_indomitus_left_eye_bionic);
                                    break;

                                case "right_eye":
                                    complex_set.add_to_area("right_eye", spr_indomitus_right_eye_bionic);
                                    break;

                                case "left_leg":
                                    complex_set.add_to_area("left_leg", spr_indomitus_left_leg_bionic);
                                    break;

                                case "right_leg":
                                    complex_set.add_to_area("right_leg", spr_indomitus_right_leg_bionic);
                                    break;
                            }

                        } 
                    }                   
                }
                if(!complex_livery){
                    draw_unit_arms(x_surface_offset, y_surface_offset, armour_type, specialist_colours, hide_bionics, complex_set);
                }
                if (armour_type == ArmourType.Normal && (!robes_bypass || !robes_hood_bypass)) {
                    var robe_offset_x = 0;
                    var robe_offset_y = 0;
                    var hood_offset_x = 0;
                    var hood_offset_y = 0;
                    if (armour_type == ArmourType.Scout) {
                        robe_offset_x = 1;
                        robe_offset_y = 10;
                        hood_offset_x = 1;
                        hood_offset_y = 10;
                    }
                    if (struct_exists(body[$ "head"],"hood") && !robes_hood_bypass) {
                        draw_sprite(spr_marine_cloth_hood,0,x_surface_offset+hood_offset_x,y_surface_offset+hood_offset_y);     
                    }
                    if (struct_exists(body[$ "torso"],"robes") && !robes_bypass) {
                        if (body.torso.robes == 0){
                            complex_set.add_to_area("robe",spr_marine_robes);      
                        } else if (body.torso.robes == 1) {
                            if (scr_has_adv("Daemon Binders") && !modest_livery){
                                var _index = pauldron_trim == 1 ? 0 : 1;
                                draw_sprite(spr_binders_robes,_index,x_surface_offset+robe_offset_x,y_surface_offset+robe_offset_y);
                            } else {
                                draw_sprite(spr_marine_robes,1,x_surface_offset+robe_offset_x,y_surface_offset+robe_offset_y);       
                            }
                        } else {
                            complex_set.add_to_area("tabbard",spr_cloth_tabbard);   
                        }
                    }              
                }              
                
                if (armour_type==ArmourType.Normal && complex_livery){
                    if (struct_exists(body[$ "right_leg"], "bionic")) {
                        complex_set.replace_area("right_leg",spr_bionic_leg_right);
                    }
                }
                if (armour_type==ArmourType.Normal && complex_livery){
                    if (struct_exists(body[$ "left_leg"], "bionic")) {
                        complex_set.replace_area("left_leg",spr_bionic_leg_left);
                    }
                } 
                if (complex_livery){
                    setup_complex_livery_shader(role(),self);
                    var _complex_helm = false;
                    if (unit_role ==_role[eROLE.Sergeant]){
                        _complex_helm = obj_ini.complex_livery_data.sgt;
                    }else if(unit_role==_role[eROLE.VeteranSergeant]){
                        _complex_helm = obj_ini.complex_livery_data.vet_sgt;
                    }else if(unit_role==_role[eROLE.Captain]){
                        _complex_helm = obj_ini.complex_livery_data.captain;
                    }else if(unit_role==_role[eROLE.Veteran] || (unit_role==_role[eROLE.Terminator] && company == 1)){
                        _complex_helm = obj_ini.complex_livery_data.veteran;
                    }
                    if (is_struct(_complex_helm) && struct_exists(complex_set, "head")){
                        surface_reset_target();
                        complex_set.complex_helms(_complex_helm, self);
                        surface_set_target(unit_surface);
                    }
                    if (psy_hood){
                        complex_set.replace_area("crown", spr_psy_hood_complex);
                    }
                }

                // Draw torso
                if (!armour_bypass){
                    if (complex_livery){
                        if (struct_exists(complex_set, "armour")){
                            complex_set.draw_cloaks(self,x_surface_offset,y_surface_offset );
                             draw_unit_arms(x_surface_offset, y_surface_offset, armour_type, specialist_colours, hide_bionics, complex_set);
                             shader_set(full_livery_shader);
                            if (struct_exists(complex_set, "armour")){
                                var choice = get_body_data("armour_choice","torso")%sprite_get_number(complex_set.armour);
                                draw_sprite(complex_set.armour,choice,x_surface_offset,y_surface_offset);
                            }
                            if (struct_exists(complex_set, "chest_variants")){
                                var choice = get_body_data("chest_variation","torso")%sprite_get_number(complex_set.chest_variants);
                                draw_sprite(complex_set.chest_variants,choice,x_surface_offset,y_surface_offset);
                            }
                            if (struct_exists(complex_set, "thorax_variants")){
                                var choice = get_body_data("thorax_variation","torso")%sprite_get_number(complex_set.thorax_variants);
                                draw_sprite(complex_set.thorax_variants,choice,x_surface_offset,y_surface_offset);
                            }
                            if (struct_exists(complex_set, "leg_variants")){
                                var choice = get_body_data("leg_variants","left_leg")%sprite_get_number(complex_set.leg_variants);
                                draw_sprite(complex_set.leg_variants,choice,x_surface_offset,y_surface_offset);
                            }
                            if (struct_exists(complex_set, "left_leg")){
                                var choice = get_body_data("leg_variants","left_leg")%sprite_get_number(complex_set.left_leg);
                                draw_sprite(complex_set.left_leg,choice,x_surface_offset,y_surface_offset);
                            }
                            if (struct_exists(complex_set, "right_leg")){
                                var choice = get_body_data("leg_variants","right_leg")%sprite_get_number(complex_set.right_leg);
                                draw_sprite(complex_set.right_leg,choice,x_surface_offset,y_surface_offset);
                            }                                                        
                            if (struct_exists(complex_set, "left_trim")){
                                var choice = get_body_data("trim_variation","left_arm")%sprite_get_number(complex_set.left_trim);
                                draw_sprite(complex_set.left_trim,choice,x_surface_offset,y_surface_offset);
                            } 
                            if (struct_exists(complex_set, "right_trim")){
                                var choice = get_body_data("trim_variation","right_arm")%sprite_get_number(complex_set.right_trim);
                                draw_sprite(complex_set.right_trim,choice,x_surface_offset,y_surface_offset);
                            }
                            complex_set.draw_head(self, x_surface_offset,y_surface_offset);
                            if (struct_exists(complex_set, "gorget")){
                                var choice = get_body_data("variant","throat")%sprite_get_number(complex_set.gorget);
                                draw_sprite(complex_set.gorget,choice,x_surface_offset,y_surface_offset);
                            }                                                                                                                     
                            if (struct_exists(complex_set, "right_pauldron")){
                                draw_sprite(complex_set.right_pauldron,company,x_surface_offset,y_surface_offset);
                            }
                            if (struct_exists(complex_set, "left_pauldron")){
                                draw_sprite(complex_set.left_pauldron,company,x_surface_offset,y_surface_offset);
                            }                            
                            if (struct_exists(complex_set, "left_knee")){
                                draw_sprite(complex_set.left_knee,company,x_surface_offset,y_surface_offset);
                            }
                            if (struct_exists(complex_set, "tabbard")){
                                var choice = get_body_data("tabbard_variation","torso")%sprite_get_number(complex_set.tabbard);
                                draw_sprite(complex_set.tabbard,company,x_surface_offset,y_surface_offset);
                            }
                            if (struct_exists(complex_set, "robe")){
                                var choice = get_body_data("tabbard_variation","torso")%sprite_get_number(complex_set.robe);
                                draw_sprite(complex_set.robe,company,x_surface_offset,y_surface_offset);
                            }                                                                                            
                                                                                                                                
                        } else {
                            draw_sprite(specific_armour_sprite,0,x_surface_offset,y_surface_offset);
                        }                       
                        shader_set(sReplaceColor);
                    } else{                   
                        draw_sprite(armour_sprite,specialist_colours,x_surface_offset,y_surface_offset);
                    }
                    // Draw additional torso decals

                    if (array_contains(["MK3 Iron Armour", "MK6 Corvus", "MK7 Aquila", "MK8 Errant"], unit_armour)){
                        if (back_equipment == BackType.Jump || back_equipment == BackType.Dev){
                            draw_sprite(mk7_chest_variants,1,x_surface_offset,y_surface_offset);
                        }
                    }
                    // Draw pauldron trim
                    if (!complex_livery){
                         if (specific_armour_sprite != "none"){
                            if (pauldron_trim==0 && specialist_colours<=1) then draw_sprite(specific_armour_sprite,4,x_surface_offset,y_surface_offset);
                            if (pauldron_trim==0 && specialist_colours>=2) then draw_sprite(specific_armour_sprite,5,x_surface_offset,y_surface_offset);
                        }
                    }
                } else if (array_length(armour_draw)){
                    draw_sprite(armour_draw[0], armour_draw[1],x_surface_offset,y_surface_offset);
                }

                // Draw decals, features and other stuff
                if (dev_trait>=10) and (!modest_livery) then draw_sprite(armour_sprite,dev_trait,x_surface_offset,y_surface_offset);// Devastator Doctrine battle damage
                // if (tech_brothers_trait>=0) and (modest_livery=0) then draw_sprite(spr_gear_techb,tech_brothers_trait,x_surface_offset,y_surface_offset);// Tech-Brothers bling
                //sgt helms
                           
                // Apothecary Details
                shader_set(sReplaceColor);
                if (unit_specialization == UnitSpecialization.Apothecary){
                    if (unit_armour=="Tartaros"){
                        draw_sprite(spr_gear_apoth,1, x_surface_offset,y_surface_offset-6);// was y_draw-4 with old tartar
                    }else if (unit_armour=="Terminator Armour"){
                        draw_sprite(spr_gear_apoth,1,x_surface_offset,y_surface_offset-6);
                    }else{
                        draw_sprite(spr_gear_apoth,1,x_surface_offset,y_surface_offset);
                    }
                    if (gear() == "Narthecium"){
                        if (armour_type==ArmourType.Normal) {
                            draw_sprite(spr_narthecium_2,0,x_surface_offset+66,y_surface_offset+5);
                        } else if (armour_type!=ArmourType.Normal && armour_type!=ArmourType.Dreadnought){
                            draw_sprite(spr_narthecium_2,0,x_surface_offset+92,y_surface_offset+5);
                        }
                    }
                }

                // Techmarine Details
                if (array_contains([UnitSpecialization.Techmarine, UnitSpecialization.IronFather], unit_specialization)){
                    var lens_offset = 0;
                    if (unit_armour == "Terminator Armour" || unit_armour == "Tartaros"){
                        lens_offset = -6;
                    }
                    if (body.head.variation > 5) {
                        draw_sprite_flipped(spr_gear_techa, 0, x_surface_offset, y_surface_offset + lens_offset);
                    } else {
                        draw_sprite(spr_gear_techa,0,x_surface_offset,y_surface_offset + lens_offset);
                    }
                    if (body.torso.variation > 5) {
                        if (unit_armour == "Terminator Armour"){
                            draw_sprite(spr_metal_tabbard,1,x_surface_offset,y_surface_offset);
                        } else {
                            draw_sprite(spr_metal_tabbard,0,x_surface_offset,y_surface_offset);
                        }
                    }
                }
				
				// Librarian Details
                if (unit_specialization == UnitSpecialization.Librarian) {
                    if (armour_type == ArmourType.Normal) {
                        draw_sprite(spr_gear_librarian, 0, x_surface_offset, y_surface_offset);
                    } else if (armour_type == ArmourType.Terminator) {
						draw_sprite(spr_gear_librarian, 0, x_surface_offset-14, y_surface_offset-14);
					}
                }
            
                // Hood
                if (!complex_livery){
                    if (psy_hood && armour_type != ArmourType.Terminator && !armour_bypass){
                        var psy_hood_offset_x = 0;
                        var psy_hood_offset_y = 0;
                        robes_hood_bypass = true;
                        if (scr_has_adv("Daemon Binders") && !modest_livery){
                            var _index = pauldron_trim == 1 ? 0 : 1;
    						draw_sprite(spr_gear_hood2,_index,x_surface_offset+psy_hood_offset_x,y_surface_offset+psy_hood_offset_y);
                        } else {
                            // if (unit_armour=="Terminator Armour") {
                            //     psy_hood_offset_y = -8;
                            // }
                            //if (obj_ini.main_color=obj_ini.secondary_color) then draw_sprite(spr_gear_hood1,hood,0,y_surface_offset);
                            //if (obj_ini.main_color!=obj_ini.secondary_color) then draw_sprite(spr_gear_hood3,hood,0,y_surface_offset);
                            draw_sprite(spr_psy_hood,2, x_surface_offset+psy_hood_offset_x, y_surface_offset+psy_hood_offset_y);
                        }
                    }
                }
            }
            //purity seals/decorations
            //TODO imprvoe this logic to be more extendable

            if (armour_type==ArmourType.Normal){
                var _torso_data = body[$ "torso"];
                if (struct_exists(_torso_data,"purity_seal")){
                    var _torso_purity_seals = _torso_data[$"purity_seal"];
                    if (_torso_purity_seals[2]==1){
                        draw_sprite(spr_purity_seal,2,x_surface_offset-24,y_surface_offset+14);
                    }
                    if (_torso_purity_seals[0]==1){
                        draw_sprite(spr_purity_seal,0,x_surface_offset-44,y_surface_offset+18);
                    }
                    if (_torso_purity_seals[1]==1){
                        draw_sprite(spr_purity_seal,0,x_surface_offset-6,y_surface_offset+16);
                    }                                       
                }
                if (struct_exists(body[$ "left_arm"],"purity_seal")){
                    var _arm_seals = body[$ "left_arm"][$"purity_seal"];
                    if (_arm_seals[0]==1){
                        draw_sprite(spr_purity_seal,1,x_surface_offset+70,y_surface_offset);
                    }
                    if (_arm_seals[1]==1){
                        draw_sprite(spr_purity_seal,0,x_surface_offset+26,y_surface_offset+7);
                    }
                    if (_arm_seals[2]==1){
                        draw_sprite(spr_purity_seal,0,x_surface_offset+15,y_surface_offset+10);
                    }                                       
                }
                if (struct_exists(body[$ "right_arm"],"purity_seal")){
                    var _arm_seals = body[$ "right_arm"][$"purity_seal"];
                    if (_arm_seals[0]==1){
                        draw_sprite(spr_purity_seal,2,x_surface_offset-54,y_surface_offset-3);
                    }
                    if (_arm_seals[0]==1){
                        draw_sprite(spr_purity_seal,0,x_surface_offset-72,y_surface_offset+8);
                    }
                    if (_arm_seals[0]==1){
                        draw_sprite(spr_purity_seal,0,x_surface_offset-57,y_surface_offset+12);
                    }                    
                }            
            }		

			// Bionics
            if (!hide_bionics || armour_type != ArmourType.Terminator) {
                var eye_move_x = 0;
                var eye_move_y = 0;
                var eye_spacer = 0;
                if (unit_armour=="Terminator Armour") {
                    // Adjust eye bionics on chaplain terminator armour
                    if (skull_mask) {
                        eye_move_y = 2;
                        eye_spacer = -2;
                    // Adjust eye bionics on terminator armour
                    } else {
                        eye_move_y = -7;
                    }
                }
                // Draw bionics
                surface_reset_target();
                var bionic_surface = surface_create(512,512);             
                surface_set_target(bionic_surface);
                var _body_parts = ARR_body_parts;

                for (var part = 0; part < array_length(_body_parts); part++) {
                    if (struct_exists(body[$ _body_parts[part]], "bionic")) {
                        if (armour_type == ArmourType.Normal || unit_armour=="Terminator Armour") {
                            var body_part = _body_parts[part];
                            var bionic = body[$ body_part][$ "bionic"];
                            switch (body_part) {
                                case "left_eye":
                                    if (bionic.variant == 0) {
                                        draw_sprite(spr_bionics_eye, 1,x_surface_offset+ eye_move_x + eye_spacer, y_surface_offset + eye_move_y);
                                    } else if (bionic.variant == 1) {
                                        draw_sprite(spr_bionic_eye_2, 1,x_surface_offset+eye_move_x + eye_spacer, y_surface_offset + eye_move_y);
                                    } else if (bionic.variant == 2) {
                                        draw_sprite(spr_bionic_eye_2, 2,x_surface_offset+eye_move_x + eye_spacer, y_surface_offset + eye_move_y);
                                    }
                                    break;

                                case "right_eye":
                                    if (bionic.variant == 0) {
                                        draw_sprite(spr_bionics_eye, 0,x_surface_offset+eye_move_x, y_surface_offset + eye_move_y);
                                    } else if (bionic.variant == 1) {
                                        draw_sprite(spr_bionic_eye_2, 0,x_surface_offset+eye_move_x, y_surface_offset + eye_move_y);
                                    } else if (bionic.variant == 2) {
                                        draw_sprite(spr_bionic_eye_2, 4,x_surface_offset+eye_move_x, y_surface_offset + eye_move_y);
                                    }
                                    break;

                                case "left_leg":
                                    if (!complex_livery){
                                        if (armour_type == ArmourType.Normal) {
                                            var sprite_num = 2;
                                            if (specialist_colours >= 2) {
                                                sprite_num = 3;
                                            }
                                            if (bionic.variant == 0) {
                                                draw_sprite(spr_bionics_leg_2, sprite_num, x_surface_offset, y_surface_offset)
                                            } else {
                                                draw_sprite(spr_bionics_leg_3, sprite_num, x_surface_offset, y_surface_offset)
                                            }
                                        }
                                    }
                                    break;

                                case "right_leg":
                                    if (!complex_livery){
                                        if (armour_type == ArmourType.Normal) {
                                            if (bionic.variant == 0) {
                                                draw_sprite(spr_bionics_leg_2, 0, x_surface_offset, y_surface_offset)
                                            } else {
                                                draw_sprite(spr_bionics_leg_3, 0, x_surface_offset, y_surface_offset)
                                            }
                                        }
                                    }
                                    break;
                            }
                        }
                    }
                }
                surface_reset_target();
                shader_set_uniform_i(shader_get_uniform(sReplaceColor, "u_blend_modes"), 1);
                texture_set_stage(shader_get_sampler_index(sReplaceColor, "background_texture"), surface_get_texture(unit_surface));                   
                surface_set_target(unit_surface);                
                draw_surface(bionic_surface, 0,0);
                surface_free(bionic_surface);
                shader_set(sReplaceColor);
                shader_set_uniform_i(shader_get_uniform(sReplaceColor, "u_blend_modes"), 0);                
            }
            // Draw Custom Helmets
            if (armour_type==ArmourType.Normal && !armour_bypass){
                if (unit_role == _role[eROLE.Champion]) {
                    draw_sprite(spr_helm_decorations,1,x_surface_offset,y_surface_offset);
                }
                if (unit_role == _role[eROLE.Sergeant] || unit_role == _role[eROLE.VeteranSergeant]) {
                    draw_sprite(spr_helm_decorations,1,x_surface_offset,y_surface_offset);
                }
            }
            else if (unit_armour=="Terminator Armour" && !armour_bypass){
                if (unit_role == _role[eROLE.Champion]) {
                    draw_sprite(spr_helm_decorations,0,x_surface_offset,y_surface_offset-10);
                }
                if (unit_role == _role[eROLE.Sergeant] || unit_role == _role[eROLE.VeteranSergeant]) {
                    draw_sprite(spr_helm_decorations,0,x_surface_offset,y_surface_offset-10);
                }
            } else if (armour_type == ArmourType.Scout){
                var head_mod = body.head.variation%3;
                if (head_mod == 1){
                    draw_sprite(spr_scout_heads,0,x_surface_offset,y_surface_offset);
                } else if (head_mod==2){
                    draw_sprite(spr_scout_heads,1,x_surface_offset,y_surface_offset);
                }
            }


            if (psy_hood==0) and (armour_type==ArmourType.Normal) and (unit_armour!="") and (unit_role==_role[2]) && (unit_chapter!="Ultramarines") && (unit_chapter!="Blood Angels"){
                var helm_ii,o,yep;
                helm_ii=0;
				yep=0;
                if (scr_has_adv("Tech-Brothers")){
                    helm_ii=2;
                }else if (scr_has_adv("Never Forgive") || obj_ini.progenitor == ePROGENITOR.DARK_ANGELS){
                    helm_ii=3;
                } else if (reverent_guardians) {
                    helm_ii=4;
                }
                draw_sprite(spr_honor_helm,helm_ii,x_surface_offset-2,y_surface_offset-11);     
			}

            // Drawing Robes
            if (
                ((unit_chapter == "Dark Angels") || (obj_ini.progenitor == ePROGENITOR.DARK_ANGELS)) &&
                (unit_role != _role[eROLE.Sergeant]) &&
                (unit_role != _role[eROLE.VeteranSergeant])
            ) {
                robes_bypass = true;
                robes_hood_bypass = true;
            }

            var shield_offset_x = 0;
            var shield_offset_y = 0;
            if (unit_armour=="Terminator Armour"){
                shield_offset_x = -15;
                shield_offset_y = -10;
            } else if (unit_armour=="Tartaros") {
                shield_offset_x = -8;
            }
            if (gear() == "Combat Shield"){
                if (unit_role == _role[eROLE.Champion]){
                    draw_sprite (spr_gear_combat_shield, 1, x_surface_offset + shield_offset_x, y_surface_offset + shield_offset_y);
                } else {
                    draw_sprite (spr_gear_combat_shield, 0, x_surface_offset + shield_offset_x, y_surface_offset + shield_offset_y);
                }
            }

            // Draw hands bellow the weapon sprite;
            for (var i = 1; i <= 2; i++) {
                if (!hand_on_top[i]) then draw_unit_hands(x_surface_offset, y_surface_offset, armour_type, specialist_colours, hide_bionics, i);
            }

            // // Draw weapons
            shader_set(sReplaceColor);
            if (!new_weapon_draw[1]) {
                if (ui_weapon[1]!=0) and (sprite_exists(ui_weapon[1])){
                    if (ui_twoh[1]==false) and (ui_twoh[2]==false){
                        draw_sprite(ui_weapon[1],0,x_surface_offset+ui_xmod[1],y_surface_offset+ui_ymod[1]);                  
                    }
                    if (ui_twoh[1]==true){
                        if (specialist_colours<=1) then draw_sprite(ui_weapon[1],0,x_surface_offset+ui_xmod[1],y_surface_offset+ui_ymod[1]);
                        if (specialist_colours>=2) then draw_sprite(ui_weapon[1],3,x_surface_offset+ui_xmod[1],y_surface_offset+ui_ymod[1]);
                        if (ui_force_both==true){
                            if (specialist_colours<=1) then draw_sprite(ui_weapon[1],0,x_surface_offset+ui_xmod[1],y_surface_offset+ui_ymod[1]);
                            if (specialist_colours>=2) then draw_sprite(ui_weapon[1],1,x_surface_offset+ui_xmod[1],y_surface_offset+ui_ymod[1]);
                        }
                    }
                }
            } else {
                if (ui_weapon[1]!=0) and (sprite_exists(ui_weapon[1])){
                        draw_sprite(ui_weapon[1],0,x_surface_offset+ui_xmod[1],y_surface_offset+ui_ymod[1]);                  
                }
            }
            if (!new_weapon_draw[2]) {
                if (ui_weapon[2]!=0) and (sprite_exists(ui_weapon[2])) and ((ui_twoh[1]==false || ui_force_both==true)){
                    if (ui_spec[2]==false){
                        draw_sprite(ui_weapon[2],1,x_surface_offset+ui_xmod[2],y_surface_offset+ui_ymod[2]);
                    }
                    if (ui_spec[2]==true){
                        if (specialist_colours<=1) then draw_sprite(ui_weapon[2],2,x_surface_offset+ui_xmod[2],y_surface_offset+ui_ymod[2]);
                        if (specialist_colours>=2) then draw_sprite(ui_weapon[2],3,x_surface_offset+ui_xmod[2],y_surface_offset+ui_ymod[2]);                    
                    }
                }
            } else {
                if (ui_weapon[2]!=0) and (sprite_exists(ui_weapon[2])){
                        draw_sprite_flipped(ui_weapon[2],0,x_surface_offset+ui_xmod[2],y_surface_offset+ui_ymod[2]);                  
                }
            }

            // Draw hands above the weapon sprite;
            for (var i = 1; i <= 2; i++) {
                if (hand_on_top[i]) then draw_unit_hands(x_surface_offset, y_surface_offset, armour_type, specialist_colours, hide_bionics, i);
            }

            // if (reverent_guardians=1) then draw_sprite(spr_pack_brazier,1,x_surface_offset,y_surface_offset);
            if (armour_type==ArmourType.Dreadnought){
                draw_sprite(spr_dreadnought_chasis_colors,specialist_colours,x_surface_offset,y_surface_offset);
                var left_arm = dreadnought_sprite_components(weapon_two());
                var colour_scheme  =  specialist_colours<=1 ? 0 : 1;
                draw_sprite(left_arm,colour_scheme,x_surface_offset,y_surface_offset);
                colour_scheme  += 2;
                var right_arm = dreadnought_sprite_components(weapon_one());
                draw_sprite(right_arm,colour_scheme,x_surface_offset,y_surface_offset);
            } 			          
        }else{
            draw_set_color(c_gray);
            draw_text(0,0,string_hash_to_newline("Color swap shader#did not compile"));
        }
        // if (race()!="1"){draw_set_color(38144);draw_rectangle(0,x_surface_offset,y_surface_offset+166,0+231,0);}        
    }
    }catch(_exception) {
        handle_exception(_exception);
    }

    draw_set_alpha(1);

    if (name_role()!=""){
        if (race()=="3"){
            if (string_count("Techpriest",name_role())>0) then draw_sprite(spr_techpriest,0,x_surface_offset,y_surface_offset);
        }else if (race()=="4"){
            if (string_count("Crusader",name_role())>0) then draw_sprite(spr_crusader,0,x_surface_offset,y_surface_offset);
        }else if (race()=="5"){
            if (string_count("Sister of Battle",name_role())>0) then draw_sprite(spr_sororitas,0,x_surface_offset,y_surface_offset);
            if (string_count("Sister Hospitaler",name_role())>0) then draw_sprite(spr_sororitas,1,x_surface_offset,y_surface_offset);
        }else if (race()=="6"){
            if (string_count("Ranger",name_role())>0) then draw_sprite(spr_eldar_hire,0,x_surface_offset,y_surface_offset);
            if (string_count("Howling Banshee",name_role())>0) then draw_sprite(spr_eldar_hire,1,x_surface_offset,y_surface_offset);
        }
        if (string_count("Skitarii",name_role())>0) then draw_sprite(spr_skitarii,0,x_surface_offset,y_surface_offset);
    }
    surface_reset_target();
    /*shader_set_uniform_i(shader_get_uniform(sReplaceColor, "u_blend_modes"), 2);                
    texture_set_stage(shader_get_sampler_index(sReplaceColor, "armour_texture"), sprite_get_texture(spr_leopard_sprite, 0)); */
    //draw_surface(unit_surface, xx+_x1-x_surface_offset,yy+_y1-y_surface_offset);
    //surface_free(unit_surface);
    shader_reset();
    var _complex_sprite_names = struct_get_names(complex_set);
    for (var i=0;i<array_length(_complex_sprite_names);i++){
        var _area = _complex_sprite_names[i];
        if (!is_method(complex_set[$ _area])){
            if (sprite_exists(complex_set[$ _area])){
                sprite_delete(complex_set[$_area]);
            } 
        }
    }
    delete complex_set;
    return new UnitImage(unit_surface);   

}
