mouse_active_force_colour();
screen_click_handle_fog();

matrix_chain_begin();
matrix_chain_rotate_x( flip + move_flip );
matrix_chain_translate( x, y, z + z_push + z_drop );
matrix_chain_end( matrix_world );
dotobj_submit_animation( "main" );

mouse_active_reset_colour();