function in_camera_view(rect) {
    var x1 = camera_get_view_x(view_camera[0]);
    var y1 = camera_get_view_y(view_camera[0]);
    var w = x1 + camera_get_view_width(view_camera[0]);
    var h = y1 + camera_get_view_height(view_camera[0]);
    return rectangle_in_rectangle(rect[0], rect[1], rect[2], rect[3], x1, y1, w, h);
}

/// @self Id.Instance.obj_controller
function main_map_move_keys() {
    var view_w = camera_get_view_width(view_camera[0]);
    var view_h = camera_get_view_height(view_camera[0]);
    var x_limits = 0;
    var y_limits = 0;
    if (((menu == eMENU.DEFAULT || menu == eMENU.TURN_END) && formating == 0) || instance_exists(obj_fleet)) {
        var spd = 12 * obj_controller.scale_mod; // player move speed on campaign map
        if (!instances_exist_any([obj_ingame_menu, obj_ncombat])) {
            if (keyboard_check(vk_shift)) {
                spd *= 3;
            } // shift down, increase speed
            var view_x = camera_get_view_x(view_camera[0]) + 2;
            var view_y = camera_get_view_y(view_camera[0]) + 2;

            if ((keyboard_check(vk_left) || (mouse_x <= view_x + (view_w * 0.02)) || keyboard_check(ord("A"))) && (x > x_limits)) {
                var rel_view = view_w > global.default_view_width ? global.default_view_width / 2 : view_w / 2;
                x = (x > view_x + rel_view) ? view_x + rel_view : x;
                x -= spd;
            }
            if ((keyboard_check(vk_right) || (mouse_x >= view_x + (view_w * 0.98)) || keyboard_check(ord("D"))) && (x < (room_width - x_limits))) {
                var rel_view = view_w > global.default_view_width ? global.default_view_width / 2 : view_w / 2;
                x = (x < view_x + view_w - rel_view) ? view_x + view_w - rel_view : x;
                x += spd;
            }
            if ((keyboard_check(vk_up) || (mouse_y <= view_y + (view_h * 0.02)) || keyboard_check(ord("W"))) && (y > y_limits)) {
                var rel_view = view_h > global.default_view_height ? global.default_view_height / 2 : view_h / 2;
                y = (y > view_y + rel_view) ? view_y + rel_view : y;
                y -= spd;
            }
            if ((keyboard_check(vk_down) || (mouse_y >= view_y + (view_h * 0.98)) || keyboard_check(ord("S"))) && (y < room_height - y_limits)) {
                var rel_view = view_h > global.default_view_height ? global.default_view_height / 2 : view_h / 2;
                y = (y < view_y + view_h - rel_view) ? view_y + view_h - rel_view : y;
                y += spd;
            }
        }
    }

    x = clamp(x, x_limits, room_width);
    y = clamp(y, y_limits, room_height);
}

function scr_map_scale() {
    return global.default_view_width / camera_get_view_width(view_camera[0]);
}

function draw_warp_lanes() {
    static routes = [];
    static current_seed = global.game_seed;

    var line_width = 2 * obj_controller.scale_mod;
    var line_alpha = 0.4;

    if (array_length(routes) == 0 || current_seed != global.game_seed) {
        current_seed = global.game_seed;
        routes = [];
        var star_degrade_list = [];
        var total_stars = instance_number(obj_star);
        for (var i = 0; i < total_stars; i++) {
            array_push(star_degrade_list, i);
        }
        for (var i = 0; i < total_stars; i++) {
            var cur_star = instance_find(obj_star, star_degrade_list[i]);
            var this_star = cur_star.id;

            if (array_length(cur_star.warp_lanes) > 0) {
                for (var s = 0; s < total_stars; s++) {
                    if (s == i) {
                        continue;
                    }
                    var check_star = instance_find(obj_star, star_degrade_list[s]);
                    var connection = determine_warp_join(check_star.id, this_star);
                    if (connection) {
                        array_push(routes, [[check_star.x, check_star.y, this_star.x, this_star.y], connection]);
                    }
                }
            }
            array_delete(star_degrade_list, i, 1);
            total_stars--;
            i--;
        }
    }
    var route;
    static warp_image = -1;
    warp_image += 0.5;
    if (warp_image == 58) {
        warp_image = 0;
    }
    for (var i = 0; i < array_length(routes); i++) {
        draw_set_color(c_gray);
        route = routes[i];

        var route_coords = route[0];

        if (route[1] < 4) {
            draw_set_alpha(line_alpha);
            draw_line_width(route_coords[0], route_coords[1], route_coords[2], route_coords[3], line_width);
            draw_set_alpha(1);
        } else if (route[1] == 4) {
            draw_set_color(c_yellow);
            //TODO abstract code as a ratio distance function
            var direction_x = route_coords[2] - route_coords[0];
            var direction_y = route_coords[3] - route_coords[1];
            var forward = direction_x >= 0 ? 1 : -1;
            var downward = direction_y >= 0 ? 1 : -1;
            var total_dist = 80;
            var pythag_dist = sqr(total_dist);
            var sum = (direction_x * forward) + (direction_y * downward);
            var x_ratio = direction_x * forward / sum;
            var y_ratio = direction_y * downward / sum;
            var dist_x = sqrt(pythag_dist * x_ratio) * forward;
            var dist_y = sqrt(pythag_dist * y_ratio) * downward;

            var warp_width = sprite_get_width(spr_warp_storm) * 0.75;
            var warp_height = sprite_get_height(spr_warp_storm) * 0.75;

            for (var s = 0; s < route[1]; s++) {
                draw_set_alpha(line_alpha);
                draw_line_width(route_coords[0], route_coords[1], route_coords[0] + dist_x, route_coords[1] + dist_y, line_width);
                draw_set_alpha(1);
            }

            draw_sprite_centered(spr_warp_storm, warp_image + i, route_coords[0] + dist_x, route_coords[1] + dist_y, 0.75, 0.75, 0, c_white, 1);

            var hit_box = [
                route_coords[0] + dist_x - (warp_width / 2),
                route_coords[1] + dist_y - (warp_height / 2),
                route_coords[0] + dist_x + (warp_width / 2),
                route_coords[1] + dist_y + (warp_height / 2),
            ];

            var _allow_tooltips = !instance_exists(obj_star_select);

            if (_allow_tooltips && instance_exists(obj_fleet_select)) {
                var mouse_consts = return_mouse_consts();

                _allow_tooltips = !obj_fleet_select.currently_entered || (mouse_consts[0] - camera_get_view_x(view_camera[0]) > 300);
            }
            var warp_route_tooltip = "Major warp route to {0} (x4 travel speed for warp capable crafts)\n\nHold Shift and click Left Mouse Button to see destination.";
            if (scr_hit(hit_box)) {
                //TODO centralise this for efficiency so it's only run once at the beggingin of step sequence
                var star_overlap = false;
                with (obj_star) {
                    if (point_distance(mouse_x, mouse_y, x, y) < 20) {
                        star_overlap = true;
                        break;
                    }
                }

                if (!star_overlap) {
                    var to = instance_nearest(route_coords[2], route_coords[3], obj_star);

                    if (_allow_tooltips) {
                        tooltip_draw(string(warp_route_tooltip, to.name));
                    }

                    if (mouse_check_button_pressed(mb_left) && keyboard_check(vk_shift)) {
                        set_map_pan_to_loc(to);
                    }
                }
            }

            for (var s = 0; s < route[1]; s++) {
                draw_set_alpha(line_alpha);
                draw_line_width(route_coords[2] + s, route_coords[3] + s, (route_coords[2] - dist_x + s), (route_coords[3] + s - dist_y), line_width);
                draw_set_alpha(1);
            }
            draw_sprite_centered(spr_warp_storm, warp_image + i, (route_coords[2] - dist_x), (route_coords[3] - dist_y), 0.75, 0.75, 0, c_white, 1);

            hit_box = [
                (route_coords[2] - dist_x) - (warp_width / 2),
                (route_coords[3] - dist_y) - (warp_height / 2),
                (route_coords[2] - dist_x) + (warp_width / 2),
                (route_coords[3] - dist_y) + (warp_height / 2),
            ];
            if (scr_hit(hit_box)) {
                var star_overlap = false;
                with (obj_star) {
                    if (point_distance(mouse_x, mouse_y, x, y) < 20) {
                        star_overlap = true;
                        break;
                    }
                }
                if (!star_overlap) {
                    var to = instance_nearest(route_coords[0], route_coords[1], obj_star);

                    if (_allow_tooltips) {
                        tooltip_draw(string(warp_route_tooltip, to.name));
                    }

                    if (mouse_check_button_pressed(mb_left) && keyboard_check(vk_shift)) {
                        set_map_pan_to_loc(to);
                    }
                }
            }
        }
    }
}

function create_complex_star_routes(player_star) {
    var north = [], east = [], west = [], south = [], central = [];
    with (obj_star) {
        var _home = id == player_star;
        if (_home) {
            if (obj_ini.home_warp_position == 0) {
                //isolated environment
                instance_deactivate_object(id);
                continue;
            }
        }
        var _allow_major = !_home || (obj_ini.home_warp_position == 2 && _home);
        if (_allow_major) {
            if (x < 700) {
                array_push(west, id);
            }
            if (y < 700) {
                array_push(north, id);
            }
            if (x > room_width - 700) {
                array_push(east, id);
            }
            if (y > room_height - 700) {
                array_push(south, id);
            }
            if ((x > 700) && (y > 700) && (x < room_width - 700) && (y < room_height - 700)) {
                array_push(central, id);
            }
        }

        var nearest_star = distance_removed_star(x, y, 1, true, true, false);
        if (determine_warp_join(nearest_star.id, self.id)) {
            array_push(warp_lanes, [distance_removed_star(x, y, 2, true, true, false).name, 1]);
        } else {
            array_push(warp_lanes, [nearest_star.name, 1]);
        }

        if (!irandom(8) || (id == player_star && obj_ini.home_warp_position == 2)) {
            array_push(warp_lanes, [distance_removed_star(x, y, irandom_range(3, 6), true, true, false).name, 1]);
        }
    }
    full_loci = [
        north,
        east,
        west,
        south,
        central,
    ];
    // here is where we set up the warp hubs
    var WarpHub, set, join_set, total_joins;
    for (var i = 0; i < array_length(full_loci); i++) {
        var player_hub_overide = false;
        if (irandom(1)) {
            if (obj_ini.home_warp_position != 2) {
                continue;
            } else {
                if (!array_contains(full_loci[i], player_star)) {
                    continue;
                } else {
                    player_hub_overide = true;
                }
            }
        } else {
            if (array_contains(full_loci[i], player_star)) {
                player_hub_overide = true;
            }
        }
        set = full_loci[i];
        if (array_length(set) == 0) {
            continue;
        }
        if (player_hub_overide) {
            for (var j = 0; j < array_length(set); j++) {
                if (set[j] == player_star) {
                    WarpHub = set[j];
                    break;
                }
            }
        } else {
            WarpHub = array_random_element(set);
        }
        total_joins = 0;
        for (var s = 0; s < array_length(full_loci); s++) {
            if (!irandom(1)) {
                continue;
            }
            join_set = full_loci[s];
            var set_count = array_length(join_set);
            if (s == i || set_count == 0) {
                continue;
            }
            join_star = array_random_element(join_set);
            array_push(WarpHub.warp_lanes, [join_star.name, 4]);
            total_joins++;
            if (total_joins > 3) {
                break;
            }
        }
    }
    instance_activate_object(obj_star);
    var _cluster_builder = new SectorClusterBuilder();
    obj_ini.sector_handler.sector_clusters = _cluster_builder.build();
}


function SectorClusterBuilder() constructor {
    name_to_id = ds_map_create();
    parent = ds_map_create();
    all_stars = [];
    components = [];
    final_clusters = [];
    MAXCLUSTERS = 8;
    MINCLUSTERS = 5;

    static find = function(_start_id) {
        var _root = _start_id;
        while (parent[? _root] != _root) {
            _root = parent[? _root];
        }
        var _cur = _start_id;
        while (_cur != _root) {
            var _next = parent[? _cur];
            parent[? _cur] = _root;
            _cur = _next;
        }
        return _root;
    };

    static union = function(_a, _b) {
        var _ra = find(_a);
        var _rb = find(_b);
        if (_ra != _rb) {
            parent[? _ra] = _rb;
        }
    };

    static get_centroid = function(_star_ids) {
        var _sx = 0, _sy = 0;
        var _n = array_length(_star_ids);
        for (var i = 0; i < _n; i++) {
            _sx += _star_ids[i].x;
            _sy += _star_ids[i].y;
        }
        return { x: _sx / _n, y: _sy / _n };
    };

    static sort_by_x = function(_a, _b) { return _a.x - _b.x; };
    static sort_by_y = function(_a, _b) { return _a.y - _b.y; };

    static split_component = function(_star_ids) {
        var _n = array_length(_star_ids);
        var _min_x = infinity, _max_x = -infinity, _min_y = infinity, _max_y = -infinity;
        for (var i = 0; i < _n; i++) {
            var _s = _star_ids[i];
            _min_x = min(_min_x, _s.x);
            _max_x = max(_max_x, _s.x);
            _min_y = min(_min_y, _s.y);
            _max_y = max(_max_y, _s.y);
        }
        var _use_x = (_max_x - _min_x) >= (_max_y - _min_y);

        var _sorted = array_create(_n);
        for (var i = 0; i < _n; i++) {
            _sorted[i] = _star_ids[i];
        }
        array_sort(_sorted, _use_x ? sort_by_x : sort_by_y);

        var _mid = _n div 2;
        var _group_a = [];
        var _group_b = [];
        for (var i = 0; i < _n; i++) {
            if (i < _mid) {
                array_push(_group_a, _sorted[i]);
            } else {
                array_push(_group_b, _sorted[i]);
            }
        }
        return [_group_a, _group_b];
    };

    static build = function() {
        // 1. name -> id lookup
        with (obj_star) {
            other.name_to_id[? name] = id;
        }

        // 2. union-find setup
        with (obj_star) {
            other.parent[? id] = id;
            array_push(other.all_stars, id);
        }

        // 3. union stars connected by a warp lane
        with (obj_star) {
            for (var i = 0; i < array_length(warp_lanes); i++) {
                if (warp_lanes[i][0] >= 4){
                    continue;
                }
                var _target_id = other.name_to_id[? warp_lanes[i][0]];
                if (!is_undefined(_target_id)) {
                    other.union(id, _target_id);
                }
            }
        }

        // 4. collect connected components
        var _groups_map = ds_map_create();
        for (var i = 0; i < array_length(all_stars); i++) {
            var _root_key = string(find(all_stars[i]));
            if (!ds_map_exists(_groups_map, _root_key)) {
                _groups_map[? _root_key] = [];
            }
            array_push(_groups_map[? _root_key], all_stars[i]);
        }

        components = [];
        var _key = ds_map_find_first(_groups_map);
        while (!is_undefined(_key)) {
            array_push(components, _groups_map[? _key]);
            _key = ds_map_find_next(_groups_map, _key);
        }
        ds_map_destroy(_groups_map);

        // 5. merge closest components until <= 8
        while (array_length(components) > MAXCLUSTERS) {
            var _best_a = -1, _best_b = -1, _best_dist = infinity;
            for (var a = 0; a < array_length(components); a++) {
                var _ca = get_centroid(components[a]);
                for (var b = a + 1; b < array_length(components); b++) {
                    var _cb = get_centroid(components[b]);
                    var _d = point_distance(_ca.x, _ca.y, _cb.x, _cb.y);
                    if (_d < _best_dist) {
                        _best_dist = _d;
                        _best_a = a;
                        _best_b = b;
                    }
                }
            }
            for (var k = 0; k < array_length(components[_best_b]); k++) {
                array_push(components[_best_a], components[_best_b][k]);
            }
            array_delete(components, _best_b, 1);
        }

        // 6. split largest components until >= 5
        while (array_length(components) < MINCLUSTERS) {
            var _largest_i = 0, _largest_n = 0;
            for (var i = 0; i < array_length(components); i++) {
                var _len = array_length(components[i]);
                if (_len > _largest_n) {
                    _largest_n = _len;
                    _largest_i = i;
                }
            }
            if (_largest_n <= 1) {
                break;
            }
            var _split_result = split_component(components[_largest_i]);
            components[_largest_i] = _split_result[0];
            array_push(components, _split_result[1]);
        }

        // 7. build final named cluster structs
        final_clusters = [];
        for (var i = 0; i < array_length(components); i++) {
            var _members = components[i];
            var _rep = _members[0];
            var _cluster_name = (array_length(_members) == 1)
                ? (_rep.name + " Isolate")
                : (_rep.name + " Sector");
            array_push(final_clusters, {
                name: _cluster_name,
                systems: _members
            });
        }

        ds_map_destroy(parent);
        ds_map_destroy(name_to_id);

        return final_clusters;
    };
}

function set_map_pan_to_loc(target) {
    with (obj_controller) {
        location_viewer.travel_target = [
            target.x,
            target.y,
        ];
        location_viewer.travel_increments = [
            (target.x - x) / 15,
            (target.y - y) / 15,
        ];
        location_viewer.travel_time = 0;
    }
}

function star_box_shape(star = noone) {
    var scale = obj_controller.map_scale;
    if (star == noone) {
        return [
            x - (60 * scale),
            y + (5 * scale),
            x + 60 * scale,
            y - 40 * scale,
        ];
    } else {
        with (star) {
            return [
                x - (60 * scale),
                y + (5 * scale),
                x + 60 * scale,
                y - 40 * scale,
            ];
        }
    }
}
