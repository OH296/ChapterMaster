// This will execute before the first room of the game executes.
gml_pragma("global", "__init_global()");

function __init_global() {
	// set any global defaults
	layer_force_draw_depth(true,0);		// force all layers to draw at depth 0
	draw_set_colour( c_black );
}
