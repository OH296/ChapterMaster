
function SectorHandler() constructor{
	if (instance_exists(obj_ini)) {
	    if (obj_ini.millenium != 0) {
	        check_number = obj_ini.check_number;
	        year_fraction = 0; // 84 per turn
	        year = obj_ini.year;
	        millenium = obj_ini.millenium;
	    }
	}

	static date = function(){
        var yf = "";
        if (year_fraction < 10) {
            yf = "00" + string(obj_controller.year_fraction);
        }
        if ((year_fraction >= 10) && (year_fraction < 100)) {
            yf = "0" + string(year_fraction);
        }
        if (year_fraction >= 100) {
            yf = string(year_fraction);
        }
		return $"{check_number} {yf} {year}.M{millenium}";
	}

	static game_year = function(){
		return (millenium * 1000) + year;
	}

	static increment_date = function(){
        year_fraction += 84;
        if (year_fraction > 999) {
            year += 1;
            year_fraction = 0;
        }
        if (year >= 1000) {
            millenium += 1;
            year -= 1000;
        }		
	}

	static get_time_from_current_year = function(age_from_year){
		return game_year() - age;
	}
}