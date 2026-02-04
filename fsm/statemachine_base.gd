#class_name StateMachineBase
extends Node
const StateBase := FSM_UIDCLASSREF.StateBase

@export var starting_state: StateBase
var current_state: StateBase = null
var history : Array = []

func _ready():
	pass
	
	
#logic parameter cant have multiple classes...
func update_children():
	for child : StateBase in get_children():
		child.go_back.connect(back)
	pass
		
func init() -> void:
	update_children()
	change_state(starting_state)
	
func change_state(new_state: StateBase) -> void:
	if current_state != null:
		history.append(current_state)
		current_state.exit() #execute exit as cleanup
	current_state = new_state
	current_state.enter()


func back():
	if history.size() == 0: return
	current_state.exit()
	current_state = history.pop_back()
	current_state.enter()


#processes the _ functions from the parent. Fill these ones in the states
func process_physics(delta: float) -> void:
	var new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)

func process_input(event: InputEvent) -> void:
	var new_state = current_state.process_input(event)
	if new_state:
		change_state(new_state,)

func process_frame(delta: float) -> void:
	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state,)
