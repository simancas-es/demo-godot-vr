extends Node
#class_name SystemTasksCondition

#Abstract class
enum ERROR {NO_ERROR, ERROR}
#Sets additional parameters in the subclasses
func set_parameters(dict : Dictionary) -> ERROR:
	push_warning("Function not implemented!!")
	return ERROR.ERROR
	
#Abstract function called after _init
func setup() -> void:
	pass

#Default injection
func _init(unit_ids : Dictionary[String,int], tick_frequency_s : float) -> void:
	TICK_FREQUENCY_S = tick_frequency_s
	UNIT_IDS = unit_ids
	
	setup()
	
signal fulfilled

#Represents the conditions to fulfill a task.
#Has logic that checks whether the condition has been met or not

@onready var world_reference : Node = get_tree().root #Where to check for the condition. Mostly scene tree
##Oneshot conditions are fulfilled once. Else they have to always check.
##Example: valve changed: oneshot. valve open: not oneshot
var oneshot : bool = false #Oneshot conditions stay fulfilled once they have been fulfilled once

#Abstract, defined by subclass. Parameters: world : Node, is_oneshot : bool
#	Always take world_reference as Node, and is_oneshot as bool. Returns bool
var fulfill_fun : Callable = Callable() 


var TICK_FREQUENCY_S := SYSTEMTASKSSETTINGS.TICK_FREQUENCY_S #Adapt
var UNIT_IDS : Dictionary[String, int] #Hack

enum STATUS {NOT_FULFILLED, FULFILLED}
var status = STATUS.NOT_FULFILLED 





#Implements whether the condition has been fulfilled or not
func is_fulfilled() -> bool:
	if (status == STATUS.FULFILLED) and oneshot: return true
	
	if not fulfill_fun.is_valid():
		push_warning("Method has not been implemented!!", self)
	else:
		#Else we check whether it is fulfilled in that precise moment
		var result = fulfill_fun.call(world_reference, oneshot)
		if result:
			status = STATUS.FULFILLED
		else:
			status = STATUS.NOT_FULFILLED
		
	
	if status == STATUS.NOT_FULFILLED:
		return false
	elif status == STATUS.FULFILLED:
		return true
	return false
	
func update_status():
	if is_fulfilled():
		fulfilled.emit()
		if oneshot: #Oneshots save their state forever.
			status = STATUS.FULFILLED
			set_process(PROCESS_MODE_DISABLED)
	

#hecking for conditions.
var _time_margin_s : float = 0.0 ##Time since last calculation
func _process(delta: float) -> void: #Only works if its in the scene tree somewhere.
	_time_margin_s -= delta
	if _time_margin_s <= 0.0:
		_time_margin_s += TICK_FREQUENCY_S #TODO: Adaptive frequencies, classbased
		update_status()
