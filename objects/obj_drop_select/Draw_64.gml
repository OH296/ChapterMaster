if (instance_number(obj_ncombat) == 0) {
    if (instance_number(obj_popup) == 0) {
        w = 660;
        h = 520;
        // Center of the screen
        var _x_center = (camera_width / 2) - (w/2);
        var _y_center = (camera_height / 2) - (h/2);
        main_slate.inside_method = drop_select_draw;
        main_slate.draw(_x_center, _y_center, (660/860), (520/850));
    }
}