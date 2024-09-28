/// Step Event

if (press_exclusive(vk_enter)) {
    execute = true;
}

if (press_exclusive(vk_escape)) {
    instance_destroy();
}

if (blink > 0) {
    blink -= delta_time/1000000;
} else if (blink <= 0) {
    blink = 2
}

inputting = keyboard_string;

if (execute && inputting != "") {
    scr_cheatcode(inputting);
    instance_destroy();
}