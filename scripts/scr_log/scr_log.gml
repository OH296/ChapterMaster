/// @function log_into_file
/// @description Creates an error_log file in ErrorLogs folder and puts _message there.
/// @param {string} _message string to put into the error log.
function log_into_file(_message) {
    if (string_length(_message) > 0) {
        var _entry = string(_message);
        var _date_time = $"{current_day}-{current_month}-{current_year}_{current_hour}{current_minute}{current_second}";
        var _log_file = file_text_open_write("ErrorLogs/" + $"error_{_date_time}.log");
    
        file_text_write_string(_log_file, _entry);
        file_text_close(_log_file);
    }
}

function try_and_report_loop(dev_marker="generic crash",func, turn_end=true, args=[], catch_custom=0, catch_args=[]) {
    #macro MSG_error_message_head $"Your game just encountered and caught an error :("
    #macro MSG_error_message $"The error log is automatically copied into your clipboard and a copy is created at: \nC:>Users>(UserName)>AppData>Local>ChapterMaster>ErrorLogs \n\nPlease, do the following: \n\n1) Create a bug report on the bug-report-forum in our 'Chapter Master Discord' server. \n\n2) Press CTRL+V to paste the error log into the bug report. \n\n3) Title your report by cutting and pasting the first line of the main message (it contains game version and file that caused the error). \n\n4) If for some reason the error log wasn't pasted, find the location that is mentioned above and attach the latest (sort by time) error_*date-time*.log to your bug report. In this case you can name your report as you wish. \n\n\nThank you :)"
    #macro MSG_error_message_ps $"P.S. You can ALT-TAB and try to continue playing - if the error is not severe, the game should continue working, just try to avoid what caused it. \n\nBut it's recommended to wait for a response on the bug-report forum, otherwise you may make the issue worse."

    try{
        method_call(func,args);
    } catch (_exception){
        var _popup_header = $"{MSG_error_message_head} ({dev_marker})\n\n";
        var _popup_message = $"{MSG_error_message}\n\n\n";
        var _popup_ps = MSG_error_message_ps;
        var _player_message = _popup_header + _popup_message + _popup_ps;

        var _formatted_stacktrace = array_to_string_list(_exception.stacktrace);
        var _line_break = LB_92;
        var _full_message = "";
        var _report_title = $"[{global.game_version}] {_exception.stacktrace[0]}\n";

        // var pip = instance_create(0,0,obj_popup);
        // pip.title = _popup_header;
        // pip.text = _popup_message;
        // pip.image = "debug"

        // obj_popup doesn't work if multiple errors are encountered and/or it may get overwritten by other popups, it seems.
        // scr_popup doesn't work if the error caused turn skip to get stuck.
        // show_message() alt-tabs your game though, but there are no other options.
        show_message(_player_message);

        _full_message = $"{_line_break}\n";
        _full_message += $"Caught an Exception ({dev_marker})!\n";
        _full_message += $"Game Version: {global.game_version}; Build Date: {global.build_date}\n\n";
        _full_message += $"{_exception.longMessage}\n";
        _full_message += $"Stacktrace:\n";
        _full_message += $"{_formatted_stacktrace}\n";
        _full_message += $"{_line_break}";

        log_into_file(_full_message);
        clipboard_set_text(_report_title + markdown_codeblock(_full_message));
    
        show_debug_message(_full_message);

        if (is_method(catch_custom)) {
            method_call(catch_custom, catch_args);
        }
    }
}

/// @function handle_exception
/// @description Accepts an exception to display an error and log it.
/// @param {struct} _exception exception struct.
function handle_exception(_exception){
    var _popup_header = $"{MSG_error_message_head}\n\n";
    var _popup_message = $"{MSG_error_message}\n\n\n";
    var _popup_ps = MSG_error_message_ps;
    var _player_message = _popup_header + _popup_message + _popup_ps;

    var _formatted_stacktrace = array_to_string_list(_exception.stacktrace);
    var _line_break = LB_92;
    var _full_message = "";
    var _report_title = $"[{global.game_version}] {_exception.stacktrace[0]}\n";

    show_message(_player_message);
    _full_message = $"{_line_break}\n";
    _full_message += $"Caught an Exception!\n";
    _full_message += $"Game Version: {global.game_version}; Build Date: {global.build_date}\n\n";
    _full_message += $"{_exception.longMessage}\n";
    _full_message += $"Stacktrace:\n";
    _full_message += $"{_formatted_stacktrace}\n";
    _full_message += $"{_line_break}";
    log_into_file(_full_message);
    show_debug_message(_full_message);
    clipboard_set_text(_report_title + markdown_codeblock(_full_message));
}

exception_unhandled_handler(function(_exception) {
    var _full_message = "";
    var _formatted_stacktrace = array_to_string_list(_exception.stacktrace);
    var _line_break = LB_92;
    var _popup_header = $"Your game just encountered a critical error :(\n\n";
    var _player_message = _popup_header + MSG_error_message;
    var _report_title = $"[{global.game_version}] {_exception.stacktrace[0]}\n";

    _full_message = $"{_line_break}\n";
    _full_message += $"Unhandled Exception!\n";
    _full_message += $"Game Version: {global.game_version}; Build Date: {global.build_date}\n\n";
    _full_message += $"{_exception.longMessage}\n";
    _full_message += $"Stacktrace:\n";
    _full_message += $"{_formatted_stacktrace}\n";
    _full_message += $"{_line_break}";

    log_into_file(_full_message);
    clipboard_set_text(_report_title + markdown_codeblock(_full_message));
    show_message(_player_message);
    show_debug_message(_full_message);

    return 0;
});

/// @function markdown_codeblock
/// @description Puts codeblock symbols around a string.
/// @param {string} _message
/// @return {string}
function markdown_codeblock(_message) {
    if (string_length(_message) > 0) {
        var _formatted_message = "```\n" +_message + "\n```";
        return _formatted_message;
    }
    return;
}