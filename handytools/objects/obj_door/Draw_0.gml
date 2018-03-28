if ( global.screen_click_render && global.mirror_render ) exit; //Don't render the door on a mirror click surface

mouse_active_force_colour();
screen_click_handle_fog( global.mirror_render? 128 : 0 );

if ( intro_t < 1 ) {
    s_shader_float( "u_fVibrate", lerp( 500, 1, intro_t ) );
    s_shader_float( "u_fGarbage", random(1) );
}

matrix_chain_begin();
matrix_chain_rotate_x( -90 );
matrix_chain_rotate_z( image_angle );
matrix_chain_translate( x, y, z+global.game_swell );
matrix_chain_end( matrix_world );
dotobj_submit( "door" );

mouse_active_reset_colour();

if ( intro_t < 1 ) {
    s_shader_float( "u_fVibrate", 0 );
    s_shader_float( "u_fGarbage", 0 );
}