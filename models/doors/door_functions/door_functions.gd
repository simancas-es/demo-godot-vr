extends Node3D
## HACK
##Decoupled door model that is separate from Interaction. TODO: Decouple the InteractionDoors
##TODO: Lock + Unlock in different positions
 
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

var _disabled : bool = false

func _ready() -> void:
	#hint_text[ENUMS.ACTION.INTERACT] = "Press [{key}] to open..." #TODO hack
	original_y_degrees = rotation_degrees.y
	
	match _lock:
		LOCK.UNLOCKED: unlock(-1, true)
		LOCK.LOCKED: lock(-1, true)
	match _status:
		STATUS.CLOSED: close()
		STATUS.OPENED: open()
	

func temporarily_disable() -> void:
	_disabled = false
	await get_tree().create_timer(0.1)
	_disabled = true

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
	_disabled = false
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees:y", original_y_degrees + y_degrees_opened, time_to_open_s)
	_disabled = true
	_status = STATUS.OPENED
	pass
	
func close() -> void:
	_disabled = false
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees:y", original_y_degrees, time_to_open_s)
	_disabled = true
	_status = STATUS.CLOSED
	pass
