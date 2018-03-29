 persistent = true;

window_show = false;
window_collapsed = false;
window_has_set_size = false;
window_has_set_columns = false;
window_width = DEFAULT_WINDOW_WIDTH - 160;
window_height = DEFAULT_WINDOW_HEIGHT - 120;
window_page = 0;
window_name = TRACKER_ON? "handytools Devtool + Tracker" : "handytools Devtool";
window_state[0] = false;
window_state[1] = false;

if ( GRIP_ON ) {
    grip_preview = 0;
    grip_preview_surface = tr_surface_create( 480, 480, "Tracker grip preview" );
}

surface_preview = 0;