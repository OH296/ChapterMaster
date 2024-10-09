function scr_hit(x1=0, y1=0, x2=0, y2=0) {
	var mouse_consts = return_mouse_consts();
	if (is_array(x1)){
		return point_in_rectangle(mouse_consts[0],mouse_consts[1],x1[0],x1[1],x1[2],x1[3]);
	} else {
		return point_in_rectangle(mouse_consts[0],mouse_consts[1],x1, y1, x2, y2);
	}
	return false;

}

function point_and_click(rect){
	var mouse_consts = return_mouse_consts();
	if (point_in_rectangle(mouse_consts[0], mouse_consts[1], rect[0], rect[1],rect[2], rect[3])){
		var click_check = event_number==ev_gui ? device_mouse_check_button_pressed(0,mb_left) : mouse_check_button_pressed(mb_left);
		return click_check;
	}
	return false;
}

function scr_click_left(){
	return device_mouse_check_button_pressed(0,mb_left) || mouse_check_button_pressed(mb_left);
}

function return_mouse_consts(){
	if (event_number==ev_gui){
		var mouse_const_x = device_mouse_x_to_gui(0);
		var mouse_const_y = device_mouse_y_to_gui(0);
	} else {
		mouse_const_x = mouse_x;
		mouse_const_y = mouse_y;
	}
	return [mouse_const_x,mouse_const_y]
}
function mouse_distance_less(xx, yy, distance){
	var mouse_consts = return_mouse_consts();
	return (point_distance(xx,yy,mouse_consts[0],mouse_consts[1])<=distance)
}
function return_mouse_consts_tooltip(){
	var consts = return_mouse_consts();
	return [consts[0]+20, consts[1]]
}





