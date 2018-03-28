matrix_chain_begin();
matrix_chain_rotate_x( -90 );
matrix_chain_rotate_z( image_angle );
matrix_chain_translate( x, y, z );
matrix_chain_end( matrix_world );
if ( cut ) {
    vertex_submit( dotobj_model( "rope_cut" ), pr_trianglelist, sprite_get_texture( spr_tex_rope, 0 ) );
} else {
    vertex_submit( dotobj_model( "rope" ), pr_trianglelist, sprite_get_texture( spr_tex_rope, 0 ) );
}
matrix_reset_world();