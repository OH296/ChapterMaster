function scr_role_count(target_role, search_location = "", return_type = "count") {

    var _units = collect_role_group("all", search_location, false,  {role:target_role}, true);

    if (return_type == "units"){
        return _units.units;
    } else if return_type == "count"{
        return _units.number();
    }else if return_type == "group"{
        return _units;
    }
}
