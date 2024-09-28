function log_into_file(_message) {
    var _entry = string(_message);
    var _log_file = file_text_open_append("message_log.log");
    file_text_write_string(_log_file, _entry + "\n");
    file_text_close(_log_file);
}
