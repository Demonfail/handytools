persistent = true;

scene_window_name = "Scene Graph";
scene_multiselect = false;
scene_window_show = true;
scene_window_collapsed = false;
scene_window_has_set_size = false;
scene_window_width = 280;
scene_window_height = 700;
scene_window_state[0] = false;
scene_window_state[1] = false;


show_hints = true;
show_selected_readout = true;

window_show = EDITOR_START_OPEN;
window_collapsed = false;
window_has_set_size = false;
window_has_set_columns = false;
window_width = 650;
window_height = 700;
window_page = E_EDITOR_PAGE.HOME;
window_page_return = window_page;
window_name = "Editor";
window_state[0] = false;
window_state[1] = false;

instances_selected_filter = false;
instances_object_filter = undefined;
instances_object_list = tr_list_create();

preview_surface = tr_surface_create( 400, 400, "Editor 3D preview" );
preview_object = undefined;
preview_instance = noone;

selected_object = undefined;
selected_instance = noone;

place_x = 0;
place_y = 0;
place_z = 0;
place_a = 0;

delete_fast = false;

floor_select_open = false;

instances_over = noone;

object_list       = return_object_list();
floor_sprite_list = return_floor_texture_list();
wall_sprite_list  = return_wall_texture_list();