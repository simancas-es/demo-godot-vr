@tool #So that the EditorPlugins see it
extends Node
class_name SignalManager

#Inputs - InputPriority... not used anymore. Check old version from map_transitions.
#signal register_input_processing(function : Callable)
#signal end_input_processing(function : Callable)

#Locks
signal lock_fpv(set_lock : bool) ##Locks input without locking the world
signal capture_mouse
signal release_mouse


#
#signal selected(body : Node)
#signal unselected(body : Node)
#signal camera_focus_on(body : Node)
#signal camera_focus_off(body : Node)

#Topics
signal request_change_topic(topic : TOPICS.LAYER)
signal topic_changed(topic : TOPICS.LAYER)

#INteraction
signal popup_text(popup_object : InfoPopup) ##Scene receives InfoPopup from world
signal activated_event(int) #Events that change the gamestate
signal play_sound(res : String)
signal play_loop(res : String)
signal interaction_message(text : String) #Message after we interact with something, fi a failed interaction.

#Menus
signal menu
signal settings
#signal inventory
signal inventory_action_open
signal credits
#signal enter_introscreen
signal select_env(from : ENVIRONMENTS.ID)

#Messages to screen
signal ui_msg_top(text : float)

#Rooms
#signal precache_zone(id : ENVIRONMENTS.ID)
#signal precache_room(id : ROOMS.ID)
signal change_zone(id : ENVIRONMENTS.ID)
#signal change_room(id : ROOMS.ID)
signal entered_room
signal exit_room

#Requests to states
signal request_change_room(id : ROOMS.ID)
signal request_exit_roomspace


#Camera changes
signal set_fixed_camera(keep_background : bool)
#signal set_falcon_camera
#signal set_env_camera
#signal set_room_camera
signal request_current_fpvmode


#Special
#signal setup_introscreen
signal reset_position

#Tool Signals
signal request_editor_file_json(file_path : String, node : Node)
