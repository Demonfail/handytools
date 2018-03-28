/// @description DOTOBJ service initialisation

if ( DOTOBJ_ON ) {
    trace_f( "OBJ MODEL" );

    global.obj_map               = tr_map_create( "<.obj map>"        , true );
    global.obj_load_map          = tr_map_create( "<.obj load map>"   , true );
    global.obj_vertex_buffer_map = tr_map_create( "<.obj name map>"   , true );
    global.obj_texture_map       = tr_map_create( "<.obj texture map>", true );
}