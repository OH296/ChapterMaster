if (instance_number(obj_ncombat) == 0) {
    if (instance_number(obj_popup) == 0) {
        w = 660;
        h = 520;
        // Center of the screen
        var _x_center = (camera_width / 2) - (w/2);
        var _y_center = (camera_height / 2) - (h/2);
        main_slate.inside_method = drop_select_draw;
        main_slate.draw(_x_center, _y_center, (660/860), (520/850));

        draw_set_halign(fa_center);
        roster_slate.inside_method = function(){
            var _xx = roster_slate.XX+(roster_slate.width/2)
            var _yy  = roster_slate.YY+40;
            draw_text_transformed(_xx, _yy, "Battle Roster", 2, 2, 0);
            _yy+=30;            
            draw_text_ext(_xx, _yy, roster.roster_string, -1, roster_slate.width-30);
            draw_text_ext(_xx+0.1, _yy+0.1, roster.roster_string, -1, roster_slate.width-30);
        }   
        roster_slate.draw(_x_center+665, _y_center, (300/860),(520/850));

        local_content_slate.inside_method=function(){
            var _xx = local_content_slate.XX+(roster_slate.width/2);
            var _yy  = local_content_slate.YY+40;             
            draw_text_ext(_xx, _yy, roster.roster_local_string, -1, local_content_slate.width-30);
            draw_text_ext(_xx+0.1, _yy+0.1, roster.roster_local_string, -1, local_content_slate.width-30);            
    
        }

        local_content_slate.draw(_x_center-local_content_slate.width, _y_center, (300/860),(520/850))  
    }
}