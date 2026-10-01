/// @param {string} _name
/// @param {Real} _timer
/// @param {struct} _data
function Problem(_name, _timer, _data) constructor {
    p_id = _name;
    timer = _timer;
    data = _data;
    uid = scr_uuid_generate();
    delete_mission = false;
    f_type = eP_FEATURES.MISSION;
    stage_id = "";
    if (struct_exists(data, "stage")){
        stage_id = data.stage;
    }
    if (struct_exists(data, "members")){
        members = data.members;
    }
    static has_data = function(key){
        return struct_exists(data, key);
    }
    static description = function(){
        var _n = mission_name_key(p_id);
        _n = _n == "" ? p_id : _n;
        return _n;
    }
    static __popup_delete = function(){
        with(obj_popup){
            popup_default_close();
        }
        __check_delete();
    }

    static find_func_ref = function(trigger_string){
        var _func_string = "__" + p_id + "_" + trigger_string;
        return _func_string;
    }

    static has_func = function(trigger_string){
        var _func_string = find_func_ref(trigger_string);
        return struct_exists(self,_func_string);
    }
    static find_func = function(trigger_string){
        var _func_string = find_func_ref(trigger_string);
        if (struct_exists(self,_func_string)){
            return self[$ _func_string]
        }
        return undefined;
    }

    static __popup_choice = function(trigger_string){
        var _func = find_func(trigger_string);
        if (!is_undefined(_func)){
            return method(self, _func);
        }
        return undefined;
    }
    static __handle_triggered_mission_func = function(func){
        if (!is_undefined(func)){
            __refresh_data();
            try {
                func();
            } catch (_exception) {
                delete_mission = true;
                ERROR_HANDLER.handle_exception(_exception);
            }
        }
        __check_delete();
        obj_controller.location_viewer.update_mission_log();
    }

    //requires the completion and required_months flag to be in the data struct
    static __increment_mission_completion = function() {
        if (!struct_exists(data, "completion")) {
            data.completion = 0;
        }
        data.completion++;
        if (!struct_exists(data, "required_months") || data.required_months <= 0) {
            LOGGER.error("Invalid required_months in mission_data");
            return 0;
        }
        return (data.completion / data.required_months) * 100;
    }

    static __inquisition_mission_options = function(){
        var _options = [
            {
                str1: "Accept",
                choice_func: function(){
                    var _mission = pop_data.mission
                    var _func_str = _mission.find_func_ref("accept");
                    if (struct_exists(_mission, _func_str)){
                        _mission[$ _func_str]();
                    } 
                    obj_controller.demanding = 0;
                }
            },
        ];
        if (!obj_controller.demanding){
            array_push(_options, {
                str1: "Refuse",
                choice_func: function(){
                    pop_data.mission.delete_mission = true;
                    popup_default_close();
                }
            })
        }
        return _options
    }
}