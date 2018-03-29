preview_surface = tr_surface_check_auto( preview_surface );

if ( IMGUI_ON && keyboard_check_pressed( vk_f11 ) ) {
    
    scene_window_show = !scene_window_show;
    scene_window_state[1] = scene_window_show;
    
    window_show = !window_show;
    window_state[1] = window_show;
    
    if ( scene_window_show ) scene_window_has_set_size = false;
    
    if ( window_show ) {
        window_has_set_size = false;
        window_page_return = window_page;
    } else {
        control_set( 0, "mouse", "lock time", current_time );
    }
    
}

if ( !instance_exists( obj_imgui ) ) {
    window_show = false;
    scene_window_show = false;
}

if ( window_show && keyboard_check_released( vk_space ) ) {
    window_collapsed = !window_collapsed;
    if ( window_collapsed ) control_set( 0, "mouse", "lock time", current_time );
}

#region PLACEMENT COORDS
if ( instance_exists( obj_camera ) ) {
    place_x = obj_camera.x + lengthdir_x( 30, obj_camera.look_xy_angle );
    place_y = obj_camera.y + lengthdir_y( 30, obj_camera.look_xy_angle );
    place_z = obj_camera.z;
    place_a = 180 - obj_camera.look_xy_angle;
}
#endregion

var _last_instances_over = instances_over;
instances_over = noone;

#region SCENE GRAPH

if ( scene_window_show ) {
    
    scene_window_state = imguigml_begin( scene_window_name, true,
                                   EImGui_WindowFlags.NoResize |
                                   EImGui_WindowFlags.NoMove );
     
    if ( !scene_window_has_set_size ) {
        imguigml_set_window_pos( scene_window_name, window_width+20, 10 );
        imguigml_set_window_size( scene_window_name, scene_window_width, scene_window_height );
    } else {
        var _w = imguigml_get_window_width(  scene_window_name );
        var _h = imguigml_get_window_height( scene_window_name );
        scene_window_width  = _w;
        scene_window_height = _h;
    }
    		
	var _multiselect = scene_multiselect || keyboard_check( vk_shift );
	var _result = imguigml_checkbox( "Multiple selection", _multiselect );
	if ( _result[0] ) scene_multiselect = _result[1];
	imguigml_same_line();
	if ( imguigml_button( "Deselect all" ) ) ds_map_clear( global.imguigml_build_tree_from_json_focus_map );
    imguigml_separator();
    
    imguigml_begin_child( "child", 0, 0.50*( scene_window_height - 130 ), false,
                            EImGui_WindowFlags.NoTitleBar | 
                            EImGui_WindowFlags.NoResize |
                            EImGui_WindowFlags.NoMove |
                            EImGui_WindowFlags.NoCollapse |
                            EImGui_WindowFlags.HorizontalScrollbar );
					
	imguigml_build_tree_from_json( global.editor_scene_graph, "", global.imguigml_build_tree_from_json_focus_map, _multiselect );
	var _focus_count = ds_map_size( global.imguigml_build_tree_from_json_focus_map );
    
    imguigml_end_child();
    imguigml_separator();
	
	if ( imguigml_tree_node_ex( "Properties", EImGui_TreeNodeFlags.Framed | EImGui_TreeNodeFlags.DefaultOpen ) ) {
        imguigml_begin_child( "child", 0, 0.25*( scene_window_height - 130 ), false,
                                EImGui_WindowFlags.NoTitleBar | 
                                EImGui_WindowFlags.NoResize |
                                EImGui_WindowFlags.NoMove |
                                EImGui_WindowFlags.NoCollapse );
	    
		if ( _focus_count > 0 ) {
			#region Properties
			var _collect_name_list  = ds_list_create();
		    var _collect_count_list = ds_list_create();
			
			var _root_map = ds_map_find_first( global.imguigml_build_tree_from_json_focus_map );
			repeat( _focus_count ) {
			                
				var _properties_list = _root_map[? "properties" ];
                            
                var _size = ds_list_size( _properties_list );
                for( var _i = 0; _i < _size; _i++ ) {
                    var _property_map = _properties_list[| _i ];
                    var _property_name = concat( _property_map[? "name" ], "_", _property_map[? "type" ] );
					var _index = ds_list_find_index( _collect_name_list, _property_name );
					if ( _index < 0 ) {
						ds_list_add( _collect_name_list, _property_name );
						ds_list_add( _collect_count_list, 1 );
					} else {
						_collect_count_list[| _index ]++;
					}
                }
                            
				_root_map = ds_map_find_next( global.imguigml_build_tree_from_json_focus_map, _root_map );
			}
						
			_root_map = ds_map_find_first( global.imguigml_build_tree_from_json_focus_map );
						
			var _size = ds_list_size( _collect_name_list );
			for( var _i = 0; _i < _size; _i++ ) {
				if ( _collect_count_list[| _i ] != _focus_count ) continue;
				var _name = _collect_name_list[| _i ];
				_name = string_copy( _name, 1, string_pos( "_", _name ) - 1 );
							
				if ( _focus_count == 1 ) {
					var _result = [ false, editor_property_value( _root_map, _name ) ];
					switch( editor_property_type( _root_map, _name ) ) {
						case E_EDITOR_PROPERTY.STATIC:
						case E_EDITOR_PROPERTY.SPRITE:
						case E_EDITOR_PROPERTY.OBJECT:
						case E_EDITOR_PROPERTY.SOUND:
							imguigml_text( _name, _result[1] );
						break;
						case E_EDITOR_PROPERTY.FLOAT:
							_result = imguigml_input_float( _name, _result[1] );
						break;
						case E_EDITOR_PROPERTY.INT:
							_result = imguigml_input_int( _name, _result[1] );
						break;
						case E_EDITOR_PROPERTY.STRING:
							_result = imguigml_input_text( _name, _result[1], 30 );
						break;
						case E_EDITOR_PROPERTY.COLOUR:
							if ( imguigml_tree_node( "Colour Picker" ) ) {
								_result = imguigml_color_picker3( "##_", colour_get_red( _result[1] )/255, colour_get_green( _result[1] )/255, colour_get_blue( _result[1] )/255 );
								_result[1] = make_colour_rgb( _result[1]*255, _result[2]*255, _result[3]*255 );
								imguigml_tree_pop();
							}
						break;
						case E_EDITOR_PROPERTY.BOOLEAN:
							_result = imguigml_checkbox( _name, _result[1] );
						break;
					}
					if ( _result[0] ) editor_property_set_value( _root_map, _name, _result[1] );
				} else {
					imguigml_text( _name );
				}
							
			}
						
						
			ds_list_destroy( _collect_name_list );
			ds_list_destroy( _collect_count_list );
			#endregion
		} else {
			imguigml_text( "No node selected" );
		}
                    
        imguigml_end_child();
		imguigml_tree_pop();
	}
    
	imguigml_separator();
            
    if ( imguigml_tree_node_ex( "Operations", EImGui_TreeNodeFlags.Framed | EImGui_TreeNodeFlags.DefaultOpen ) ) {
    	#region Operations
        imguigml_begin_child( "child", 0, 0.25*( scene_window_height - 130 ), false,
        	                    EImGui_WindowFlags.NoTitleBar | 
        	                    EImGui_WindowFlags.NoResize |
        	                    EImGui_WindowFlags.NoMove |
        	                    EImGui_WindowFlags.NoCollapse );
            
        if ( _focus_count == 1 ) {
                
            var _map = ds_map_find_first( global.imguigml_build_tree_from_json_focus_map );
            if ( imguigml_button( "New child" ) ) editor_new_node( _map, UD, concat( "New Child ", irandom( 999999 ) ) );
            if ( imguigml_button( "Duplicate" ) ) {
                var _new_map = tr_map_create();
                ds_map_copy( _new_map, _map );
                var _parent_map = _map[? "parent" ];
                var _parent_list = _parent_map[? "children" ];
                tr_list_add_map( _parent_list, _new_map );
            }
            imguigml_spacing();
                
        }
            
        #region Cut And Paste
        if ( !scene_has_cut ) {
                
        	if ( imguigml_button( "Cut" ) ) {
                
                scene_has_cut = true;
                    
                var _clipboard_list = global.editor_scene_clipboard[? "children" ];
        		var _map = ds_map_find_first( global.imguigml_build_tree_from_json_focus_map );
        		repeat( _focus_count ) {
                    
                    var _parent_map = _map[? "parent" ];
                    var _parent_list = _parent_map[? "children" ];
                    
                    var _size = ds_list_size( _parent_list );
                    for( var _i = 0; _i < _size; _i++ ) {
                        
                        if ( _parent_list[| _i ] == _map ) {
                            _parent_list[| _i ] = undefined;
                            ds_list_delete( _parent_list, _i );
                            break;
                        }
                        
                    }
                        
                    //Move this map to the clipboard
                    _map[? "selected" ] = false;
                    _map[? "parent"   ] = global.editor_scene_clipboard;
                    tr_list_add_map( _clipboard_list, _map );
                        
                    _map = ds_map_find_next( global.imguigml_build_tree_from_json_focus_map, _map );
                }
                
            }
                
        } else {
                
            var _clipboard_list = global.editor_scene_clipboard[? "children" ];
            var _clipboard_size = ds_list_size( _clipboard_list );
                
        	if ( _focus_count == 1 ) {
                if ( imguigml_button( "Paste" ) ) {
                        
                    scene_has_cut = false;
                        
                    //Transfer from the clipboard to the new host map
                    var _parent_map = ds_map_find_first( global.imguigml_build_tree_from_json_focus_map );
                    var _parent_list = _parent_map[? "children" ];
                        
                    for( var _i = 0; _i < _clipboard_size; _i++ ) {
                        var _map = _clipboard_list[| _i ];
                        _map[? "parent" ] = _parent_map;
                        tr_list_add_map( _parent_list, _map );
                    }
                        
                    //Wipe the clipboard
                    for( var _i = 0; _i < _clipboard_size; _i++ ) _clipboard_list[| _i ] = undefined;
                    ds_list_clear( _clipboard_list );
                    _clipboard_size = 0;
                        
                }
            }
                
            //Draw contents of the clipboard
            for( var _i = 0; _i < _clipboard_size; _i++ ) {
                var _map = _clipboard_list[| _i ];
                imguigml_text( editor_property_value( _map, "name" ) );
            }
                
        }
        #endregion
            
        imguigml_spacing();
            
        if ( _focus_count == 1 ) && ( !scene_has_cut ) {
            #region Move
            var _move = false;
            var _move_offset = 0;
            if ( imguigml_button( "Move up"     ) ) { _move = true; _move_offset = -1;            }
            if ( imguigml_button( "Move down"   ) ) { _move = true; _move_offset =  1;            }
            if ( imguigml_button( "Move top"    ) ) { _move = true; _move_offset = VERY_NEGATIVE; }
            if ( imguigml_button( "Move bottom" ) ) { _move = true; _move_offset = VERY_LARGE;    }
                
            if ( _move ) {
                var _parent_map = _map[? "parent" ];
                var _parent_list = _parent_map[? "children" ];
                    
                var _size = ds_list_size( _parent_list );
                for( var _i = 0; _i < _size; _i++ ) {
                        
                    if ( _parent_list[| _i ] == _map ) {
                        _parent_list[| _i ] = undefined;
                        ds_list_delete( _parent_list, _i );
                        break;
                    }
                        
                }
                    
                _i = clamp( _i+_move_offset, 0, _size-1 );
                ds_list_insert( _parent_list, _i, _map );
                ds_list_mark_as_map( _parent_list, _i );
            }
            #endregion
        }
            
        imguigml_spacing();
            
        #region Delete
        if ( imguigml_button( "Delete" ) ) {
                
        	var _map = ds_map_find_first( global.imguigml_build_tree_from_json_focus_map );
        	repeat( _focus_count ) {
                    
                var _parent_map = _map[? "parent" ];
                var _parent_list = _parent_map[? "children" ];
                    
                var _size = ds_list_size( _parent_list );
                for( var _i = 0; _i < _size; _i++ ) {
                        
                    if ( _parent_list[| _i ] == _map ) {
                        ds_list_delete( _parent_list, _i );
                        break;
                    }
                        
                }
                        
                _map = ds_map_find_next( global.imguigml_build_tree_from_json_focus_map, _map );
            }
        }
            
    	#endregion
            
        imguigml_end_child();
        imguigml_tree_pop();
            
        #endregion
    }
    
    imguigml_end();
    
}

#endregion

#region MAIN WINDOW
if ( window_show ) {
    
    #region KEYBOARD SHORTCUTS
    if ( keyboard_check( vk_shift ) || editor_is_collapsed() ) {
        if ( keyboard_check_released( ord("1") ) ) window_page = E_EDITOR_PAGE.HOME;
        if ( keyboard_check_released( ord("2") ) ) window_page = E_EDITOR_PAGE.PLACE;
        if ( keyboard_check_released( ord("3") ) ) window_page = E_EDITOR_PAGE.INSTANCES;
        //if ( keyboard_check_released( ord("4") ) ) {
        //    window_page = E_EDITOR_PAGE.MOVE;
        //    with( obj_par_3d ) mouse_active_set_relative_values();
        //}
        //if ( keyboard_check_released( ord("5") ) ) {
        //    window_page = E_EDITOR_PAGE.ROTATE;
        //    with( obj_par_3d ) mouse_active_set_relative_values();
        //}
        //if ( keyboard_check_released( ord("6") ) ) window_page = E_EDITOR_PAGE.DELETE;
        //if ( keyboard_check_released( ord("7") ) ) window_page = E_EDITOR_PAGE.LIGHT;
    }
    
    if ( keyboard_check_released( vk_tab ) ) {
        var _ = window_page;
        window_page = window_page_return;
        window_page_return = _;
        if ( window_page == E_EDITOR_PAGE.MOVE ) || ( window_page == E_EDITOR_PAGE.ROTATE ) with( obj_par_3d ) mouse_active_set_relative_values();
    }
    
    if ( keyboard_check_released( vk_control ) ) with( obj_par_3d ) mouse_selected = false;
    #endregion
    
    imguigml_set_next_window_collapsed( window_collapsed );
    window_state = imguigml_begin( window_name, true,
                                   EImGui_WindowFlags.NoResize |
                                   EImGui_WindowFlags.NoMove |
                                   EImGui_WindowFlags.MenuBar );
    if ( !window_state[1] ) {
        window_show = false;
        window_has_set_size = false;
    }
    window_state[0] = window_collapsed;
    
    if ( !window_has_set_size ) {
        imguigml_set_window_pos( window_name, 10, 10 );
        imguigml_set_window_size( window_name, window_width, window_height );
    } else {
        var _w = imguigml_get_window_width( window_name );
        var _h = imguigml_get_window_height( window_name );
        if ( window_width != _w ) window_has_set_columns = false;
        window_width = _w;
        window_height = _h;
    }
    
    if ( !window_collapsed ) {
        
        #region TABS
        imguigml_begin_menu_bar();
        if ( imguigml_menu_item( "1.Home"        ) ) window_page = E_EDITOR_PAGE.HOME;
        if ( imguigml_menu_item( "2.Place"       ) ) window_page = E_EDITOR_PAGE.PLACE;
        if ( imguigml_menu_item( "3.Instances"   ) ) window_page = E_EDITOR_PAGE.INSTANCES;
        //if ( imguigml_menu_item( "4.Move"        ) ) {
        //    window_page = E_EDITOR_PAGE.MOVE;
        //    with( obj_par_3d ) mouse_active_set_relative_values();
        //}
        //if ( imguigml_menu_item( "5.Rotate"      ) ) {
        //    window_page = E_EDITOR_PAGE.ROTATE;
        //    with( obj_par_3d ) mouse_active_set_relative_values();
        //}
        //if ( imguigml_menu_item( "6.Delete"      ) ) window_page = E_EDITOR_PAGE.DELETE;
        //if ( imguigml_menu_item( "7.Light"       ) ) window_page = E_EDITOR_PAGE.LIGHT;
        imguigml_end_menu_bar();
        #endregion
        
        switch( editor_get_page() ) {
			
            case E_EDITOR_PAGE.HOME:
            #region HOME
                
                imguigml_text( "AMIASP Editor" );
                imguigml_text( TITLE + ", " + VERSION + " " + QU + VERSION_NOMIKER + QU );
                imguigml_text( "Built " + DATE + " by " + BUILDER );
                imguigml_new_line();
                repeat( 5 ) imguigml_spacing();
                imguigml_text( "F11 = Open/Close editor window" );
                imguigml_text( "Space = Collapse window" );
                imguigml_text( "Shift = Move slow" );
                imguigml_text( "Q/E = Ascend/descend" );
                imguigml_text( "Left Click/Right Click = Context sensitive" );
                imguigml_text( "Control = Deselect all" );
                imguigml_text( "Shift+Num = Select tool (or click on the tabs)" );
                imguigml_text( "Tab = Return to previous tool" );
                imguigml_new_line();
                repeat( 5 ) imguigml_spacing();
                
                #region EDITOR TOGGLES
                
                var _result = imguigml_checkbox( "Fly", global.editor_fly ); imguigml_same_line();
                if ( _result[0] ) global.editor_fly = _result[1];
                
                var _result = imguigml_checkbox( "Noclip", global.editor_noclip ); imguigml_same_line();
                if ( _result[0] ) global.editor_noclip = _result[1];
                
                var _result = imguigml_checkbox( "Click Surface", global.screen_show_click ); imguigml_same_line();
                if ( _result[0] ) global.screen_show_click = _result[1];
                
                var _result = imguigml_checkbox( "Lighting", global.screen_do_lighting ); imguigml_same_line();
                if ( _result[0] ) global.screen_do_lighting = _result[1];
                
                var _result = imguigml_checkbox( "Dither", global.screen_do_dither ); imguigml_same_line();
                if ( _result[0] ) global.screen_do_dither = _result[1];
                
                var _result = imguigml_checkbox( "DoF", global.screen_do_dof ); imguigml_same_line();
                if ( _result[0] ) global.screen_do_dof = _result[1];
                
                var _result = imguigml_checkbox( "Culling", global.screen_do_culling ); imguigml_same_line();
                if ( _result[0] ) global.screen_do_culling = _result[1];
                
                var _result = imguigml_checkbox( "Show Context Hints", show_hints ); imguigml_same_line();
                if ( _result[0] ) show_hints = _result[1];
                
                var _result = imguigml_checkbox( "Show Selected Details", show_selected_readout ) imguigml_same_line();
                if ( _result[0] ) show_selected_readout = _result[1];
                
                imguigml_separator();
                #endregion
                
                #region CUSTOM TOGGLES
                imguigml_new_line();
                
                var _result = imguigml_checkbox( "Menu", instance_exists( obj_menu ) ); imguigml_same_line();
                if ( _result[0] ) {
                    tr_instance_destroy( obj_subtitle );
                    if ( instance_exists( obj_menu ) ) tr_instance_destroy( obj_menu ) else tr_instance_create( 0, 0, obj_menu );
                }
                
                var _result = imguigml_checkbox( "Draw Walls", global.do_walls ); imguigml_same_line();
                if ( _result[0] ) global.do_walls = _result[1];
                
                var _result = imguigml_checkbox( "Draw Ceiling", global.do_ceiling ); imguigml_same_line();
                if ( _result[0] ) global.do_ceiling = _result[1];
                
                var _result = imguigml_checkbox( "Show Spawners", global.do_ceiling );
                if ( _result[0] ) global.do_spawners = _result[1];
                
                imguigml_new_line();
                #endregion
                
                #region ROOM DIMENSIONS / TEXTURES
                if ( imguigml_begin_popup( "Floor Pop-up" ) ) {
                    
                    if ( imguigml_button( "Cancel" ) ) imguigml_close_current_popup();
                    imguigml_separator();
                    
                    var _size = ds_list_size( floor_sprite_list );
                    for( var _i = 0; _i < _size; _i++ ) {
                        if ( imguigml_button( sprite_get_name( floor_sprite_list[| _i ] ) ) ) {
                            with( obj_floor ) {
                                sprite = other.floor_sprite_list[| _i ];
                                texture = sprite_get_texture( sprite, 0 );
                            }
                            imguigml_close_current_popup();
                        }
                    }
                    
                    imguigml_end_popup();
                }
                
                if ( imguigml_begin_popup( "Wall Pop-up" ) ) {
                    
                    if ( imguigml_button( "Cancel" ) ) imguigml_close_current_popup();
                    imguigml_separator();
                    
                    var _size = ds_list_size( wall_sprite_list );
                    for( var _i = 0; _i < _size; _i++ ) {
                        if ( imguigml_button( sprite_get_name( wall_sprite_list[| _i ] ) ) ) {
                            with( obj_wall ) {
                                sprite = other.wall_sprite_list[| _i ];
                                texture = sprite_get_texture( sprite, 0 );
                            }
                            imguigml_close_current_popup();
                        }
                    }
                    
                    imguigml_end_popup();
                }
                
                if ( imguigml_button( "Set Floor Sprite" ) ) imguigml_open_popup( "Floor Pop-up" );
                imguigml_same_line( 0, 40 );
                if ( imguigml_button( "Set Wall Sprite"  ) ) imguigml_open_popup( "Wall Pop-up"  );
                
                var _w = 0;
                var _h = 0;
                var _d = 0;
                
                with( obj_ceiling ) {
                    _w = x2 - x1;
                    _h = y2 - y1;
                    _d = z;
                }
                
                var _any = false;
                imguigml_push_item_width( 100 );
                imguigml_same_line( 0, 40 );
                var _result = imguigml_input_float( "Width" , _w, 1, 5, 0 ); _w = _result[1]; _any |= _result[0];
                imguigml_same_line( 0, 40 );
                    _result = imguigml_input_float( "Height", _h, 1, 5, 0 ); _h = _result[1]; _any |= _result[0];
                imguigml_same_line( 0, 40 );
                    _result = imguigml_input_float( "Depth" , _d, 1, 5, 0 ); _d = _result[1]; _any |= _result[0];
                imguigml_pop_item_width();
                
                if ( _any ) {
                    with( obj_floor ) tr_instance_destroy();
                    with( obj_ceiling ) tr_instance_destroy();
                    with( obj_wall ) tr_instance_destroy();
                    define_wall(    0,  0,  0,   _w,  0, _d,   spr_tex_wall6  );
                    define_wall(    0,  0,  0,    0, _h, _d,   spr_tex_wall6  );
                    define_wall(   _w,  0,  0,   _w, _h, _d,   spr_tex_wall6  );
                    define_wall(    0, _h,  0,   _w, _h, _d,   spr_tex_wall6  );
                    define_floor(   0,  0, _w,   _h,  0, 32,   spr_tex_floor1 );
                    define_ceiling( 0,  0, _w,   _h, _d, 32,   spr_tex_white  );
                }
                #endregion
                
                #region NAVIGATION
                imguigml_new_line();
                imguigml_separator();
                repeat( 5 ) imguigml_spacing();
                imguigml_new_line();
                imguigml_text( concat( "Room ", global.game_room ) );
            
                imguigml_same_line();
                if ( imguigml_button( "Previous Room" ) ) {
                    unload_current_room();
                    global.game_room--;
                    if ( !load_room_n( global.game_room ) ) {
                        trace_error( "Could not load room " + string( global.game_room ) );
                        global.game_room++;
                        load_room_n( global.game_room );
                    }
                }
                imguigml_same_line();
                if ( imguigml_button( "Next Room" ) ) {
                    unload_current_room();
                    global.game_room++;
                    if ( !load_room_n( global.game_room ) ) {
                        trace_error( "Could not load room " + string( global.game_room ) );
                        global.game_room--;
                        load_room_n( global.game_room );
                    }
                }
                imguigml_same_line();
                if ( imguigml_button( "Save Room" ) ) {
                    var _filename = get_save_filename( "JSON|*.json", "room " + string( global.game_room ) + ".json" );
                    if ( _filename != "" ) {
                        var _file = file_text_open_write( _filename );
                        file_text_write_string( _file, room_encode() );
                        file_text_close( _file );
                        trace_loud( _filename + " SAVED!" );
                    }
                }
                imguigml_same_line();
                if ( imguigml_button( "Save Room (Old)" ) ) {
                    var _filename = get_save_filename( "JSON|*.json", "room " + string( global.game_room ) + ".json" );
                    if ( _filename != "" ) {
                        var _file = file_text_open_write( _filename );
                        file_text_write_string( _file, room_encode_old() );
                        file_text_close( _file );
                        trace_loud( _filename + " SAVED!" );
                    }
                }
                #endregion
                
                #region APPLICATION SURFACE
                
                imguigml_new_line();
                imguigml_new_line();
                imguigml_push_item_width( 120 );
                var _result = imguigml_input_float( "App Surf Width" , global.app_surf_w, 1, 5, 0 );
                if ( _result[0] ) global.app_surf_w = _result[1];
                imguigml_same_line( 0, 60 );
                var _result = imguigml_input_float( "App Surf Height", global.app_surf_h, 1, 5, 0 );
                if ( _result[0] ) global.app_surf_h = _result[1];
                imguigml_pop_item_width();
                
                #endregion
                
            #endregion
            break;
            case E_EDITOR_PAGE.PLACE:
            #region PLACE
                imguigml_columns( 2, "Columns", true );
                
                imguigml_new_line();
                imguigml_image( surface_get_texture( preview_surface ), preview_surface_size, preview_surface_size );
                if ( imguigml_button( "Deselect placement object" ) ) selected_object = undefined;
                imguigml_next_column();
                
                imguigml_begin_child( "child" );
            
                preview_object = undefined;
                var _size = ds_list_size( object_list );
                for( var _i = 0; _i < _size; _i++ ) {
                
                    var _object = object_list[| _i ];
                
                    if ( is_real( _object ) ) {
                        if ( imguigml_radio_button( object_get_pretty_name( _object ), false, selected_object != _object ) ) selected_object = ( selected_object == _object )? undefined : _object;
                        if ( imguigml_is_item_hovered( true ) ) preview_object = _object;
                    } else if ( _object = "SEP" ) {
                        imguigml_separator();
                    } else {
                        imguigml_text( object_list[| _i ] );
                    }
                
                    imguigml_next_column();
                
                }
                imguigml_end_child( "child" );
                
                imguigml_set_column_width( 0, preview_surface_size + 20 );
            
            #endregion
            break;
            case E_EDITOR_PAGE.MOVE:
            case E_EDITOR_PAGE.ROTATE:
            #region MOVE
                imguigml_text( "Filtering by selected" );
                imguigml_new_line();
                
                imguigml_columns( 5, "Columns", true );
                imguigml_text( "Object" );
                imguigml_next_column();
                imguigml_text( "x" );
                imguigml_next_column();
                imguigml_text( "y" );
                imguigml_next_column();
                imguigml_text( "z" );
                imguigml_next_column();
                imguigml_text( "angle" );
                imguigml_next_column();
                imguigml_separator();
                
                with( obj_par_3d ) {
                    if ( !mouse_selected ) continue;
                    
                    var _fine_step = 0.1;
                    var _coarse_step = 2;
                    
                    var _result = imguigml_checkbox( concat( object_get_pretty_name( object_index ), ":", id ), mouse_selected );
                    if ( _result[0] ) mouse_selected = _result[1];
                    
                    imguigml_next_column();
                    var _result = imguigml_input_float( concat( "##x", id ), x, _fine_step, _coarse_step, 1 ); if ( _result[0] ) x = _result[1];
                    imguigml_next_column();
                    var _result = imguigml_input_float( concat( "##y", id ), y, _fine_step, _coarse_step, 1 ); if ( _result[0] ) y = _result[1];
                    imguigml_next_column();
                    var _result = imguigml_input_float( concat( "##z", id ), z, _fine_step, _coarse_step, 1 ); if ( _result[0] ) z = _result[1];
                    imguigml_next_column();
                    var _result = imguigml_input_float( concat( "##a", id ), image_angle, _fine_step, _coarse_step, 1 ); if ( _result[0] ) image_angle = _result[1];
                    imguigml_next_column();
                }
            #endregion
            break;
            case E_EDITOR_PAGE.INSTANCES:
            #region INSTANCES
                
                ds_list_clear( instances_object_list );
                var _any = false;
                with( obj_par_3d ) {
                    if ( ds_list_find_index( other.instances_object_list, object_index ) < 0 ) ds_list_add( other.instances_object_list, object_index );
                    if ( mouse_selected ) _any = true;
                }
                
                if ( imguigml_begin_popup( "Object Filter Pop-up" ) ) {
                    
                    if ( imguigml_button( "Cancel" ) ) imguigml_close_current_popup();
                    if ( imguigml_button( "None" ) ) {
                        instances_object_filter = undefined;
                        imguigml_close_current_popup();
                    }
                    imguigml_separator();
                    
                    var _size = ds_list_size( instances_object_list );
                    for( var _i = 0; _i < _size; _i++ ) {
                        if ( imguigml_button( object_get_pretty_name( instances_object_list[| _i ] ) ) ) {
                            instances_object_filter = instances_object_list[| _i ];
                            imguigml_close_current_popup();
                        }
                    }
                    
                    imguigml_end_popup();
                }
                
                var _result = imguigml_checkbox( "Filter by selected", instances_selected_filter );
                if ( _result[0] ) instances_selected_filter = _result[1];
                imguigml_same_line();
                
                if ( instances_object_filter == undefined ) {
                    if ( imguigml_button( "Filter by object" ) ) imguigml_open_popup( "Object Filter Pop-up" );
                } else {
                    if ( imguigml_button( "Filtering by " + object_get_pretty_name( instances_object_filter ) ) ) imguigml_open_popup( "Object Filter Pop-up" );
                }
                imguigml_same_line();
                if ( imguigml_button( "Select all" ) ) {
                    with( obj_par_3d ) {
                        if ( other.instances_selected_filter && !mouse_selected ) continue;
                        if ( other.instances_object_filter != undefined ) && ( object_index != other.instances_object_filter ) continue;
                        mouse_selected = true;
                    }
                }
                imguigml_same_line();
                if ( imguigml_button( "Deselect all" ) ) {
                    with( obj_par_3d ) {
                        if ( other.instances_selected_filter && !mouse_selected ) continue;
                        if ( other.instances_object_filter != undefined ) && ( object_index != other.instances_object_filter ) continue;
                        mouse_selected = false;
                    }
                }
                imguigml_new_line();
                
                imguigml_columns( 5, "Columns", true );
                imguigml_text( "Object" );
                imguigml_next_column();
                imguigml_text( "x" );
                imguigml_next_column();
                imguigml_text( "y" );
                imguigml_next_column();
                imguigml_text( "z" );
                imguigml_next_column();
                imguigml_text( "angle" );
                imguigml_next_column();
                imguigml_separator();
                
                with( obj_par_3d ) {
                    if ( other.instances_selected_filter && !mouse_selected ) continue;
                    if ( other.instances_object_filter != undefined ) && ( object_index != other.instances_object_filter ) continue;
                    
                    var _fine_step = 0;
                    var _coarse_step = 0;
                    if ( mouse_selected ) {
                        _fine_step = 0.1;
                        _coarse_step = 2;
                    }
                    
                    var _result = imguigml_checkbox( concat( object_get_pretty_name( object_index ), ":", id ), mouse_selected );
                    if ( _result[0] ) mouse_selected = _result[1];
                    
                    if ( imguigml_is_item_hovered( true ) ) {
                        other.instances_over = id;
                        _fine_step = 0.1;
                        _coarse_step = 2;
                    }
                    
                    imguigml_next_column();
                    var _result = imguigml_input_float( concat( "##x", id ), x, _fine_step, _coarse_step, 1 ); if ( _result[0] ) x = _result[1];
                    imguigml_next_column();
                    var _result = imguigml_input_float( concat( "##y", id ), y, _fine_step, _coarse_step, 1 ); if ( _result[0] ) y = _result[1];
                    imguigml_next_column();
                    var _result = imguigml_input_float( concat( "##z", id ), z, _fine_step, _coarse_step, 1 ); if ( _result[0] ) z = _result[1];
                    imguigml_next_column();
                    var _result = imguigml_input_float( concat( "##a", id ), image_angle, _fine_step, _coarse_step, 1 ); if ( _result[0] ) image_angle = _result[1];
                    imguigml_next_column();
                }
                
                imguigml_set_column_width( 0, 220 );
                
            #endregion
            break;
            case E_EDITOR_PAGE.DELETE:
            #region DELETE
                
                if ( imguigml_begin_popup( "Confirm Pop-up" ) ) {
                    if ( imguigml_button( "Cancel" ) ) imguigml_close_current_popup();
                    imguigml_separator();
                    if ( imguigml_button( "Delete All" ) ) with( obj_par_3d ) if ( mouse_selected ) tr_instance_destroy();
                    imguigml_end_popup();
                }
                
                imguigml_text( "Filtering by selected" );
                imguigml_same_line();
                var _result = imguigml_checkbox( "Can right-click delete without selecting the instance", delete_fast );
                if ( _result[0] ) delete_fast = _result[1];
                imguigml_same_line( 0, 150 );
                if ( imguigml_button( "Delete All Selected" ) ) imguigml_open_popup( "Confirm Pop-up" );
                imguigml_new_line();
                
                imguigml_columns( 6, "Columns", true );
                imguigml_text( "Object" );
                imguigml_next_column();
                imguigml_text( "x" );
                imguigml_next_column();
                imguigml_text( "y" );
                imguigml_next_column();
                imguigml_text( "z" );
                imguigml_next_column();
                imguigml_text( "angle" );
                imguigml_next_column();
                imguigml_text( "Delete" );
                imguigml_next_column();
                imguigml_separator();
                with( obj_par_3d ) {
                    if ( mouse_selected ) {
                        var _result = imguigml_checkbox( concat( object_get_pretty_name( object_index ), ":", id ), mouse_selected );
                        if ( _result[0] ) mouse_selected = _result[1];
                        imguigml_next_column();
                        imguigml_text( x );
                        imguigml_next_column();
                        imguigml_text( y );
                        imguigml_next_column();
                        imguigml_text( z );
                        imguigml_next_column();
                        imguigml_text( image_angle );
                        imguigml_next_column();
                        if ( imguigml_button( "X" ) ) tr_instance_destroy( id );
                        imguigml_next_column();
                    }
                }
                    
            #endregion
            break;
            case E_EDITOR_PAGE.LIGHT:
            #region LIGHT
                imguigml_text( "SELECTED" );
                var _any = false;
                with( obj_parent_light ) if ( mouse_selected ) _any = true;
                if ( _any ) {
                    imguigml_columns( 6, "Columns", true );
                    imguigml_text( "Instance" );
                    imguigml_next_column();
                    imguigml_text( "x" );
                    imguigml_next_column();
                    imguigml_text( "y" );
                    imguigml_next_column();
                    imguigml_text( "z" );
                    imguigml_next_column();
                    imguigml_text( "colour" );
                    imguigml_next_column();
                    imguigml_text( "range" );
                    imguigml_next_column();
                    imguigml_separator();
                    with( obj_parent_light ) {
                        if ( mouse_selected ) {
                            if ( imguigml_button( concat( object_get_pretty_name( object_index ), ":", id ) ) ) mouse_selected = !mouse_selected;
                            imguigml_next_column();
                            imguigml_text( x );
                            imguigml_next_column();
                            imguigml_text( y );
                            imguigml_next_column();
                            imguigml_text( z );
                            imguigml_next_column();
                            var _result = imguigml_color_picker3( concat( "colour ", id ), colour_get_red( colour )/255, colour_get_green( colour )/255, colour_get_blue( colour )/255 );
                            colour = make_colour_rgb( _result[1]*255, _result[2]*255, _result[3]*255 );
                            imguigml_next_column();
                            var _result = imguigml_slider_float( concat( "range ", id ), range, 10, 1000 );
                            range = _result[1];
                            imguigml_next_column();
                            imguigml_separator();
                        }
                    }
                    imguigml_set_column_width( 0, 130 );
                    imguigml_set_column_width( 1,  70 );
                    imguigml_set_column_width( 2,  70 );
                    imguigml_set_column_width( 3,  70 );
                    imguigml_set_column_width( 4, 300 );
                }
            #endregion
            break;
        }
        
    }
    
    imguigml_end();
    
}
#endregion

#region WINDOW COLLAPSED
if ( window_show && window_collapsed ) {
    
    switch( editor_get_page() ) {
    
        case E_EDITOR_PAGE.PLACE:
            #region SPAWNING
        
            if ( instance_exists( obj_camera ) )
            && ( mouse_check_button_released( mb_right ) )
            && ( selected_object != undefined ) {
                with( tr_instance_create_z( place_x, place_y, place_z, place_a, selected_object ) ) {
                    mouse_selected = true;
                    mouse_active_set_relative_values();
                }
                editor_set_page( E_EDITOR_PAGE.MOVE );
            }
            
            #endregion
        break;
        
    }

}
#endregion

#region PREVIEW INSTANCE HANDLING
if instance_exists( preview_instance ) && ( preview_instance.object_index != preview_object ) {
    tr_instance_destroy( preview_instance );
    preview_instance = noone;
}
            
if ( preview_object != undefined ) && !instance_exists( preview_instance ) {
    preview_instance = tr_instance_create_z( 0, 0, 0, 0, preview_object );
    preview_instance.visible = false;
}
        
with( preview_instance ) image_angle += 0.8;
#endregion

#region SELECTED INSTANCE HANDLING
            
if ( instance_exists( selected_instance ) && ( selected_instance.object_index != selected_object ) ) {
    tr_instance_destroy( selected_instance );
    selected_instance = noone;
}
            
if ( selected_object != undefined ) && !instance_exists( selected_instance ) {
    selected_instance = tr_instance_create_z( 0, 0, 0, 0, selected_object );
    selected_instance.visible = false;
}
            
with( selected_instance ) image_angle += 0.8;
#endregion