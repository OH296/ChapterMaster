if (num > 0) {
    // Hmmmmmmm
    var stah;
    stah = instance_nearest(x, y, obj_star);
    obj_controller.menu = 0;
    var _p_data = stah.get_planet_data(num);
    if (_p_data.has_problem("recon")) {
        var pop;
        pop = instance_create(0, 0, obj_popup);
        pop.image = "inquisition";
        pop.title = "Investigation Completed";
        pop.text = $"Your marines have scouted out {_p_data.name()} and satisfied the mission requirements.";

        pop.add_option("Reload Marines");
        pop.add_option("Do Nothing");

        scr_event_log("", $"Inquisition Mission Completed: Your Astartes have succesfully scouted  {_p_data.name()}.");

        remove_planet_problem(num, "recon", stah);
    }
}
