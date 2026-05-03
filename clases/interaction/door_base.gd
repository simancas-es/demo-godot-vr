extends Interaction
class_name InteractionDoor
##Script to open doors by interacting with them
##Using keys to unlock will push them to the opened state
##TODO: Lock + Unlock in different positions
const InventoryObjectInformation := INVENTORY_UIDCLASSREF.InventoryObjectInformation
 
@export var DEBUG_PRINT : bool = false

@export var y_degrees_opened : float = -90 ##Degrees while opened push/pull
@export var time_to_open_s : float = 0.3
var original_y_degrees : float

@export var lockable :bool = true ##Whether it can be locked/unlocked
@export var key_item : Array[INVENTORYSETTINGS.ID] ##What item is needed to unlock it



enum LOCK {LOCKED, UNLOCKED}
enum STATUS {CLOSED, OPENED}
##TODO: Other states like being opened or stuck

##Starting state is closed and locked.
@export var _status : STATUS = STATUS.CLOSED
@export var _lock : LOCK = LOCK.LOCKED

const unlock_text := "Unlock [{key}]"
const lock_text := "Lock [{key}]"
const open_text := "Open [{key}]"
const close_text := "Close [{key}]"

func _ready() -> void:
	#hint_text[ENUMS.ACTION.INTERACT] = "Press [{key}] to open..." #TODO hack
	
	activated.connect(on_activated)	
	original_y_degrees = rotation_degrees.y
	
	match _lock:
		LOCK.UNLOCKED: unlock(-1, true)
		LOCK.LOCKED: lock(-1, true)
	match _status:
		STATUS.CLOSED: close()
		STATUS.OPENED: open()
	

func temporarily_disable() -> void:
	monitorable = false
	await get_tree().create_timer(0.1)
	monitorable = true

func unlock(item_id : INVENTORYSETTINGS.ID, force : bool = false) -> void:
	await temporarily_disable()
	if item_id in key_item or force:
		_lock = LOCK.UNLOCKED
	else:
		Signals.interaction_message.emit(tr("Couldn't unlock..."))
	pass

func lock(item_id : INVENTORYSETTINGS.ID, force : bool = false) -> void:
	await temporarily_disable()
	if item_id in key_item or force:
		_lock = LOCK.LOCKED
	else:
		Signals.interaction_message.emit(tr("Couldn't lock..."))
	pass

func open() -> void:
	monitorable = false
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees:y", original_y_degrees + y_degrees_opened, time_to_open_s)
	monitorable = true
	_status = STATUS.OPENED
	pass
	
func close() -> void:
	monitorable = false
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees:y", original_y_degrees, time_to_open_s)
	monitorable = true
	_status = STATUS.CLOSED
	pass

func on_activated(context: InteractionContext) -> void:
	if context == null or context.playerdata == null:
		return
	var item_info : InventoryObjectInformation = context.playerdata.get_inventory().get_selected_obj_info()
	var item_id = -1
	var item_class = INVENTORYSETTINGS.CLASS.DEFAULT
	if item_info != null:
		item_id = item_info.ID
		item_class = item_info.CLASS
		
	if (_status == STATUS.CLOSED) and (_lock == LOCK.LOCKED): #Available for unlocking
		if item_class == INVENTORYSETTINGS.CLASS.KEY:
			unlock(item_id)
	elif (_status == STATUS.CLOSED) and (_lock == LOCK.UNLOCKED): ##Available for unlocking
		if item_class == INVENTORYSETTINGS.CLASS.KEY:
			lock(item_id)
		elif item_id < 0:
			open()
	elif (_status == STATUS.OPENED): #Available for closing
		if item_id < 0:
			close()
	pass
	
##Door Logic. TODO do with a state machine
func available_hint_for_item(playerdata : PlayerData, action : ENUMS.ACTION) -> bool:
	#var item_info : InventoryObjectInformation = playerdata.get_inventory().get_selected_obj_info()
	if action != ENUMS.ACTION.INTERACT : return false
		
	if (_status == STATUS.CLOSED) and (_lock == LOCK.LOCKED): #Available for unlocking
		return true
	elif (_status == STATUS.CLOSED) and (_lock == LOCK.UNLOCKED): ##Available for unlocking
		return true
	elif (_status == STATUS.OPENED): #Available for closing
		return true
	return false

##Door logic. TODO Should use a State machine 
##Returns the unformated string for a possible hint of this item
func get_hint_for_item(playerdata : PlayerData, action : ENUMS.ACTION) -> String:
	if action != ENUMS.ACTION.INTERACT : return ""
	
	var item_info : InventoryObjectInformation = playerdata.get_inventory().get_selected_obj_info()
	var item_id = -1
	var item_class = INVENTORYSETTINGS.CLASS.DEFAULT
	if item_info != null:
		item_id = item_info.ID
		item_class = item_info.CLASS
	
	if (_status == STATUS.CLOSED) and (_lock == LOCK.LOCKED): #Available for unlocking
		#if item_id in key_item:
		if item_class == INVENTORYSETTINGS.CLASS.KEY:
			return tr(unlock_text)
	elif (_status == STATUS.CLOSED) and (_lock == LOCK.UNLOCKED): ##Available for unlocking
		#if item_id in key_item:
		if item_class == INVENTORYSETTINGS.CLASS.KEY:
			return tr(lock_text)
		elif item_id < 0: #Nothing selected
			return tr(open_text)
	elif (_status == STATUS.OPENED): #Available for closing
		#if not item_id in key_item: #If not holding key
		if item_id < 0:#Nothing selected
			return tr(close_text)

	return ""
