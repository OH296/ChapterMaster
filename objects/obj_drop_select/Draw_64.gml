if (instance_number(obj_ncombat) == 0) {
    if (instance_number(obj_popup) == 0) {
        w = 660;
        h = 520;
        // Center of the screen
        var _x_center = (camera_width / 2) - (w/2);
        var _y_center = (camera_height / 2) - (h/2);
        if (purge != 1 && !(local_content_slate.XX>=_x_center-local_content_slate.width)){
            main_slate.inside_method = drop_select_draw;
            main_slate.draw(_x_center, _y_center, (660/860), (520/850));

            draw_set_halign(fa_center);
            roster_slate.inside_method = function(){
                if (purge==0){
                    var _xx = roster_slate.XX+(roster_slate.width/2)
                    var _yy  = roster_slate.YY+40;
                    draw_text_transformed(_xx, _yy, "Battle Roster", 2, 2, 0);
                    _yy+=30;            
                    draw_text_ext(_xx, _yy, roster.roster_string, -1, roster_slate.width-30);
                    draw_text_ext(_xx+0.1, _yy+0.1, roster.roster_string, -1, roster_slate.width-30);
                }
            }   
            roster_slate.draw(_x_center+main_slate.width, _y_center, (300/860),(520/850));
        }

        local_content_slate.inside_method=function(){
            var _xx = local_content_slate.XX+(roster_slate.width/2);
            var _yy  = local_content_slate.YY+40;
            var _width = local_content_slate.width;  
            var _heigth = local_content_slate.width;
            draw_text_ext(_xx, _yy, roster.roster_local_string, -1, local_content_slate.width-30);
            draw_text_ext(_xx+0.1, _yy+0.1, roster.roster_local_string, -1, local_content_slate.width-30);     
            if (purge > 0){
                draw_set_halign(fa_center);
                draw_set_font(fnt_40k_30b);

                draw_set_color(c_gray);
                var _exit = draw_unit_buttons([_xx+(_width/2)-40, 559],"Cancel");
                if (point_and_click(_exit)){
                    instance_destroy();
                }

                /*if (instance_exists(p_target)) {
                    if (p_target.p_type[planet_number] = "Shrine") then nup = true;
                }
                */
                // 89,31

                var _local_forces = array_length(roster.full_roster_units);
                for (var i=0;i<array_length(purge_options);i++){
                    var _purge_button = purge_options[i];
                    _purge_button.x1 = _xx+10;
                    _purge_button.width = local_content_slate.width-20;
                    _purge_button.draw();
                    if (_purge_button.clicked()){
                        purge_score = 0;
                        purge=_purge_button.purge_type;
                    }
                }                
            }
        }
        if (purge == 0){
            local_content_slate.draw(_x_center-local_content_slate.width, _y_center, (300/860),(520/850))  
        } else if (purge == 1){
            local_content_slate.draw((camera_width / 2) - (local_content_slate.width/2), _y_center, (300/860),(520/850));
        } else {
            if (local_content_slate.XX>=_x_center-local_content_slate.width){
                local_content_slate.draw(local_content_slate.XX-10, _y_center, (300/860),(520/850));
            } else {
                local_content_slate.draw(local_content_slate.XX, _y_center, (300/860),(520/850))
            }
        }
    }
}