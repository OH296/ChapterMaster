function scr_zoom() {

	// Zooms the view in or out when executed

    if (zoomed) {
        zoomed=0;
        view_set_visible(0, true);
        view_set_visible(1, false);
        if (instance_exists(obj_cursor)) {
            obj_cursor.image_xscale=1;
            obj_cursor.image_yscale=1;
        }
    } else {
        zoomed=1;
        view_set_visible(0, false);
        view_set_visible(1, true);
        if (instance_exists(obj_cursor)) {
            obj_cursor.image_xscale=2;
            obj_cursor.image_yscale=2;
        }
    }
}

function scr_zoom_keys(){
//this is cahnges the zoom based on scolling but you can set it how ever you like
if (press_exclusive(vk_add) || press_exclusive(187) || press_exclusive(24)){
    var view_w = camera_get_view_width(view_camera[0]);
    var view_h = camera_get_view_height(view_camera[0]);
    camera_set_view_size(view_camera[0], view_w*1.1, view_h*1.1);
}
if (press_exclusive(vk_subtract)){
    var view_w = camera_get_view_width(view_camera[0]);
    var view_h = camera_get_view_height(view_camera[0]);
    camera_set_view_size(view_camera[0], view_w*0.9, view_h*0.9);
}
exit;
zoom_level = clamp(zoom_level + (((mouse_wheel_down() - mouse_wheel_up())) * 0.1), 0.5, 2);

//Get current size
var view_w = camera_get_view_width(view_camera[0]);
var view_h = camera_get_view_height(view_camera[0]);

//Set the rate of interpolation
var rate = 0.2;

//Get new sizes by interpolating current and target zoomed size
var new_w = lerp(view_w, zoom_level * default_zoom_width, rate);
var new_h = lerp(view_h, zoom_level * default_zoom_height, rate);

//Apply the new size
camera_set_view_size(view_camera[0], new_w, new_h);

var vpos_x = camera_get_view_x(view_camera[0]);
var vpos_y = camera_get_view_y(view_camera[0]);

//change coordinates of camera so zoom is centered
var new_x = lerp(vpos_x,vpos_x+(view_w - zoom_level * default_zoom_width)/2, rate);
var new_y = lerp(vpos_y,vpos_y+(view_h - zoom_level * default_zoom_height)/2, rate);

}
/*zoom_level = 1;

//Get the starting view size to be used for interpolation later
default_zoom_width = camera_get_view_width(view_camera[0]);
default_zoom_height = camera_get_view_height(view_camera[0]);


