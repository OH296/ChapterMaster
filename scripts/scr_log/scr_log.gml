function log_into_file(_message) {
    var _entry = string(_message);
    var _log_file = file_text_open_append("message_log.log");
    file_text_write_string(_log_file, _entry + "\n");
    file_text_close(_log_file);
}


function try_and_report_loop(dev_marker="generic crash",func, turn_end=true){
    try{
        func();
    } catch (_exception){
        if (turn_end || instance_exists(obj_turn_end) ){
            scr_popup($"debug message {dev_marker}", $"please report the following on the debug forum on the game discord \n{_exception}", "debug")
        } else {
            pip=instance_create(0,0,obj_popup);
            pip.title=$"debug message {dev_marker}";
            pip.text=$"please report the following on the debug forum on the game discord \n {_exception} ";
            pip.image = "debug"
        }
        log_into_file(_exception.longMessage);
        log_into_file(_exception.script);
        log_into_file(_exception.stacktrace);
        show_debug_message(_exception.longMessage);     
    }
}

