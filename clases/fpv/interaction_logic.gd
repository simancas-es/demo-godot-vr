extends Node
class_name FPVInteractionLogic

signal updated_interactables
#Actions received
signal player_killed_by(bywhat : String)
signal sent_room_to_fpv(room360 : Room360)

var playerdata : PlayerData = null:
	set(value):
		if playerdata != null:
			if playerdata.get_inventory().changed_currently_selected.is_connected(updated_interactables.emit):
				playerdata.get_inventory().changed_currently_selected.disconnect(updated_interactables.emit)
		if value != null:
			value.get_inventory().changed_currently_selected.connect(updated_interactables.emit)
		playerdata = value
		
		
@onready var area_check : FPVAreaController = %AreaCheck
@onready var raycast_center : FPVENVRAYCAST = %RayCast3D

#FOCUS SETTER. Uses all the Interact options, E, Q ... that an item provides
var _eye_interact : Array[Interaction] = [] ##Interact through camera
var _area_interact : Array[Interaction] = [] ##Interact through position

func get_current_interactable_items() -> Array[Interaction]:
	return _eye_interact + _area_interact

##Adds or removes an item to the interact arrays, returns true if there was a change.
func add_interactable(value : Interaction, array : Array[Interaction]) -> bool:
	if not is_instance_valid(value) : return false
	if not (value is Interaction) : return false
	if value.disabled : return false
	
	var idx : int = array.find(value)
	if idx != -1:
		#array.remove_at(idx) # remove old position
		return false #HACK
	array.push_front(value)
	#
	#if not value.property_list_changed.is_connected(sanitize_interactable.bind(array)):
		#value.property_list_changed.connect(sanitize_interactable.bind(array))
		#
	if not value.tree_exited.is_connected(remove_interactable.bind(value, array)):
		value.tree_exited.connect(remove_interactable.bind(value, array))
	
	return true
func remove_interactable(value : Interaction, array : Array[Interaction]) -> bool:
	var idx = array.find(value)
	if idx > -1 :
		array.remove_at(idx)
		value.dropped_looked_at.emit()
		updated_interactables.emit()
		return true
	return false
	
func sanitize_arrays() -> void:
	sanitize_interactable(_eye_interact)
	sanitize_interactable(_area_interact)
	
##Removes non monitorables
func sanitize_interactable(array : Array[Interaction]) -> void:
	var context = _create_context()
	for it in array:
		if not it.monitorable or not it.is_available_with(context):
			remove_interactable(it, array)
	updated_interactables.emit()
			
func clear_interactables(array : Array[Interaction]) -> bool:
	for item in array:
		if not is_instance_valid(item): continue
		item.dropped_looked_at.emit()
	array.clear()
	updated_interactables.emit()
	return true
	
func _create_context() -> InteractionContext:
	return InteractionContext.from_fpv(playerdata, self, Callable(self, "request_room"))

func request_room(room360: Room360) -> void:
	sent_room_to_fpv.emit(room360)

func _ready() -> void:
	#Focus Env Area
	area_check.area_entered.connect(_update_area_collision)
	area_check.area_exited.connect(_update_area_collision)
	raycast_center.changed_collide.connect(_update_eye_collision)
	raycast_center.changed_collides.connect(_on_rc_changed_collides)

	area_check.killed_by.connect(player_killed_by.emit) #HACK

func _on_rc_changed_collides(nodes : Array[Node]) -> void:
	for n in nodes:
		_update_eye_collision(n)
	pass
	
func _update_eye_collision(node : Interaction) -> void:
	#Update last selected
	if node == null : #BUG
		clear_interactables(_eye_interact) #TODO OPTIMIZE
		updated_interactables.emit()

	else:
		var context = _create_context()
		if node.is_available_with(context):
			if add_interactable(node, _eye_interact):
				node.looked_at.emit(context)
				updated_interactables.emit()

func _update_area_collision(node : Interaction) -> void:
	if area_check.overlaps_area(node): 
		if add_interactable(node, _area_interact):
			node.entered_area.emit()
			updated_interactables.emit()
	elif not area_check.overlaps_area(node):
		if remove_interactable(node, _area_interact):
			node.exited_area.emit()
			updated_interactables.emit()

##Generates the texts for the action hints and passes them to the camera
func get_updated_interactable_action_hints() -> Array[String]:
	return InteractionHintResolver.resolve_strings(get_current_interactable_items(), playerdata)

func get_updated_interactable_action_hint_entries() -> Array[InteractionHint]:
	return InteractionHintResolver.resolve(get_current_interactable_items(), playerdata)

##Selects the first available item from the list of interactables
func interact() -> void:
	for item in _eye_interact:
		if not is_instance_valid(item): continue
		var context := _create_context()
		if  ENUMS.ACTION.INTERACT in item.actions:
			item.activated.emit(context)
		elif ENUMS.ACTION.TAKE in item.actions:
			item.taken.emit(context) ##TODO take and activate actions
		elif ENUMS.ACTION.REMOVE in item.actions:
			item.removed.emit(context)
		
		updated_interactables.emit()
		sanitize_arrays()
		return
		 
	for item in _area_interact:
		if is_instance_valid(item) and ENUMS.ACTION.INTERACT in item.actions:
			item.activated.emit(_create_context())
	updated_interactables.emit()
	sanitize_arrays()
	return

##Listen to changes in the locale
func _notification(what):
	if what == NOTIFICATION_TRANSLATION_CHANGED :
		updated_interactables.emit()
