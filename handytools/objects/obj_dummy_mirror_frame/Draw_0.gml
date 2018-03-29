if ( global.mirror_render ) exit; //Don't render mirror frames in mirrors

mouse_active_force_colour();
screen_click_handle_fog( global.mirror_render? 128 : 0 );
event_user( DRAW_USER_EVENT );
mouse_active_reset_colour();

if ( !global.screen_click_render ) {
    
    s_shader_end();
    
    matrix_chain_begin();
    matrix_chain_rotate_z( image_angle );
    matrix_chain_translate( x + swell_x, y + swell_y, z );
    matrix_chain_end( matrix_world );
    vertex_submit( mirror_model, pr_trianglestrip, surface_get_texture( grip_get_surface( concat( "mirror", mirror_index ) ) ) );
    
    s_shader_begin( grip_get_shader( grip_current() ) );
    
}