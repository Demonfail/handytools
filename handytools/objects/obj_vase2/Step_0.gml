event_inherited();

if ( global.game_got_hammer ) mouse_interactible = true;
if ( mouse_clicked ) {
    repeat( 20 ) {
        var _inst = tr_instance_create_z( x+0.5, y+0.5, z + random_range( -2.5, 7 ), 0, obj_shard );
        with( _inst ) {
            dotobj = choose( dotobj_model( "shard3_vase2" ), dotobj_model( "shard4_vase2" ) );
            var _angle = random( 360 );
            var _v = random_range( 2, 3 );
            velocity_x = lengthdir_x( _v, _angle );
            velocity_y = lengthdir_y( _v, _angle );
            velocity_z = random_range( 1, 4 );
        }
    }
    audio_play_sound_at( snd_vase_break, x, y, z, 100, 300, 1, false, 1 );
    tr_instance_destroy();
}