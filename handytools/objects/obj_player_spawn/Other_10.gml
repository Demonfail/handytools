matrix_chain_begin();
matrix_chain_rotate_x( -90 );
matrix_chain_scale( 0.6, 1, 1 );
matrix_chain_rotate_z( image_angle + 270 );
matrix_chain_translate( x, y, z );
matrix_chain_end( matrix_world );
vertex_submit( obj_model( "prism" ), pr_trianglelist, sprite_get_texture( spr_tex_white, 0 ) );
matrix_reset_world();