/// @function string_upper_first
/// @description Capitalizes the first character in a string.
/// @param {string} _string The string to be modified.
/// @returns {string} Modified string.

function string_upper_first(_string) {
    try {
        var _first_char;
        var _modified_string;
    
        _first_char = string_char_at(_string, 1);
        _first_char = string_upper( _first_char );
        
        _modified_string = _string;
        _modified_string = string_delete(_modified_string, 1, 1);
        _modified_string = string_insert(_first_char, _modified_string, 1);
    
        return _modified_string;
	}
    catch(_exception) {
		log_into_file(_exception.longMessage);
		log_into_file(_exception.script);
		log_into_file(_exception.stacktrace);
        show_debug_message(_exception.longMessage);
	}
}