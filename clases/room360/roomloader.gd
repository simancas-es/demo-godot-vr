extends Interaction
class_name RoomLoader

##It's an area so it should be on the area layer for interaction.

@export var room_id : ROOMS.ID #Room associated with this loader
var north_reference : Node3D = null ##Injected
const _hint_interact_text = "Press [{key}] to enter 360º room!"


func _ready() -> void:
	hint_text[ENUMS.ACTION.INTERACT] = tr(_hint_interact_text)
	
	add_to_group(GROUPS.ID.ROOMLOADER)
	tree_entered.connect(on_enter_tree)
	tree_exited.connect(on_exit_tree)
	
	on_enter_tree()
	
	
func on_enter_tree() -> void:
	activated.connect(on_activate)
	looked_at.connect(on_looked_at)
	dropped_looked_at.connect(on_dropped_lookedat)
	var data = await Cache.load_room(room_id) # Hack
	if not data.get_parent(): add_child(data)
	data.visible = false
	
func on_exit_tree() -> void:
	activated.disconnect(on_activate)
	looked_at.disconnect(on_looked_at)
	dropped_looked_at.disconnect(on_dropped_lookedat)
	
func on_activate(_by_player : PlayerData, _il : FPVInteractionLogic):
	#Signals.request_change_room.emit(room_id)
	var room360 = await create_room_object(room_id)
	##Send the created room to the interaction logic so that it alters the fpv
	change_room(room360, _il)


func on_looked_at(_by_player : PlayerData):
	##TODO asynchronous load
	pass	

func on_dropped_lookedat():
	pass
	
func create_room_object(id : ROOMS.ID, _force_rebuild : bool = false) -> Room360:
	var room360 = await Room360.create_room(id, north_reference)
	return room360
	
func change_room(room360 : Room360, il : FPVInteractionLogic) -> void:
	if not room360.get_parent():
		add_child(room360)
	if not room360.request_change_internal_room.is_connected(change_room.bind(il)):
		room360.request_change_internal_room.connect(change_room.bind(il), CONNECT_ONE_SHOT )
	il.sent_room_to_fpv.emit(room360)
