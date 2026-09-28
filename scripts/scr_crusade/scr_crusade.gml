//TODO never place the star out of reach of a player fleet, eiter increase allowed response time or find nearer planet
function launch_crusade() {
    var _star_id = scr_random_find(2, true, "", "");
    if (_star_id == noone) {
        LOGGER.error("RE: Crusade, couldn't find a star for the crusade");
        return false;
    } else {
        var _nearest_player_fleet = get_nearest_player_fleet(_star_id.x, _star_id.y);
        if (_nearest_player_fleet == noone) {
            return false;
        }
        _star_id.add_problem("great_crusade", {nearest_player_fleet:_nearest_player_fleet})
        return true;
    }
}
