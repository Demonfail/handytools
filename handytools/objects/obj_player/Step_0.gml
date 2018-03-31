var _is_moving = ( abs( velocity_x ) + abs( velocity_y ) > 0.35 );

var _debug_factor = 1;
if ( DEVELOPMENT ) {
    if ( keyboard_check( vk_shift ) ) _debug_factor = 0.1;
} else {
    z = 50;
}
if ( keyboard_check( ord( "J" ) ) ) {
    instance_create_z( x, y, z, random( 360 ), obj_qubicle );
    trace( "Deer count=", instance_number( obj_qubicle ), ", FPS=", fps );
}

if ( global.editor_fly ) {
    if ( control_get_on( 0, "state", "ascend"  ) ) z += 2 * _debug_factor;
    if ( control_get_on( 0, "state", "descend" ) ) z -= 2 * _debug_factor;
}
    
var _vpara = 0;
var _vperp = 0;
if ( control_get_on( 0, "state", "strafe left"  ) ) _vperp = -acceleration;
if ( control_get_on( 0, "state", "strafe right" ) ) _vperp =  acceleration;
if ( control_get_on( 0, "state", "forwards"     ) ) _vpara =  acceleration;
if ( control_get_on( 0, "state", "backwards"    ) ) _vpara = -acceleration;
    
if ( !_is_moving )
&& (  control_get_pressed( 0, "state", "strafe left"  )
   || control_get_pressed( 0, "state", "strafe right" )
   || control_get_pressed( 0, "state", "forwards"     )
   || control_get_pressed( 0, "state", "backwards"    ) ) {
    footstep_time = VERY_NEGATIVE;
    view_bob_start_time = current_time;
}
    
if ( _vpara != 0 ) {
    velocity_x += lengthdir_x( _vpara, obj_camera.look_xy_angle ) * _debug_factor;
    velocity_y += lengthdir_y( _vpara, obj_camera.look_xy_angle ) * _debug_factor;
}
    
if ( _vperp != 0 ) {
    velocity_x += lengthdir_x( _vperp, obj_camera.look_xy_angle-90 ) * _debug_factor;
    velocity_y += lengthdir_y( _vperp, obj_camera.look_xy_angle-90 ) * _debug_factor;
}

velocity_x *= damping;
velocity_y *= damping;

if ( !place_meeting( x + velocity_x, y + velocity_y, obj_par_solid ) ) || editor_is_open() {
        
    x += velocity_x;
    y += velocity_y;
        
} else if ( global.editor_noclip ) {
        
    x += velocity_x;
    y += velocity_y;
        
} else {
        
    var _sign_x = sign( velocity_x );
    repeat( abs( velocity_x ) ) {
        if ( !place_meeting( x + _sign_x, y, obj_par_solid ) ) {
            x += _sign_x;
        } else {
            break;
        }
    }
        
    var _sign_y = sign( velocity_y );
    repeat( abs( velocity_y ) ) {
        if ( !place_meeting( x, y + _sign_y, obj_par_solid ) ) {
            y += _sign_y;
        } else {
            break;
        }
    }
        
}

with( obj_camera ) {
    x = other.x;
    y = other.y;
    z = other.z;
}