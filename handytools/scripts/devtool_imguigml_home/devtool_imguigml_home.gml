/// @description Customisation for DEVTOOL's home page

if imguigml_button( "New game instance" ) new_game_instance();
imguigml_same_line();
if imguigml_button( "Quit game" ) game_end();
if ( TRACKER_ON ) {
    imguigml_same_line();
    if imguigml_button( "Tracker dump" ) trace_f( tracker_dump() );
    imguigml_same_line();
    if imguigml_button( "Tracker dump to clipboard" ) { clipboard_set_text( tracker_dump() ); imguigml_popup( "", "Copied to clipboard!" ); }
}
imguigml_new_line();
if ( FPS_ON ) {
    var _result = imguigml_checkbox( "Show FPS", global.fps_show );
    if ( _result[0] ) global.fps_show = _result[1];
}
imguigml_same_line();
var _result = imguigml_checkbox( "Master audio on", global.audio_master_on );
if ( _result[0] ) {
    global.audio_master_on = _result[1];
    audio_master_gain( global.audio_master_volume * global.audio_master_on );
}

repeat( 5 ) imguigml_spacing();
imguigml_separator();
repeat( 5 ) imguigml_spacing();

var _size = ds_list_size( global.master_game_output );
for( var _i = max( 0, _size-5 ); _i < _size; _i++ ) imguigml_text( global.master_game_output[| _i ] );
imguigml_separator();

imguigml_new_line();
imguigml_text( concat( "Current room=", QU, room_get_name( room ), QU, " (", room, ")" ) );