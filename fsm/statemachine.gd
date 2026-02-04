class_name StateMachine
extends Node
#State machine that allows for more than one starting state
#This allows for paralell states, as long as the different
#starting states can't leave their respective group of states

@export var starting_states: Array[State]
var current_states: Array[State] = []
var num_states : int

func _ready():
	num_states = starting_states.size()
	current_states.resize(num_states)
	
#logic parameter cant have multiple classes...
func update_children(parent : CharacterBody3D, animations : Node, logic):
	for child in get_children():
		child.parent = parent
		child.animations = animations
		child.logic = logic
		child.current_states = current_states
		
func init(parent: CharacterBody3D, animations: Node, logic) -> void:
	update_children(parent, animations, logic)
	
	for index in range(num_states):
		change_state(starting_states[index], index)

func change_state(new_state: State, index : int) -> void:
	if current_states[index]:
		current_states[index].exit()

	current_states[index] = new_state
	current_states[index].enter()
	#print("current states", current_states)

#processes the _ functions from the parent. Fill these ones in the states
func process_physics(delta: float) -> void:
	for index in range(num_states):
		var new_state = current_states[index].process_physics(delta)
		if new_state:
			change_state(new_state, index)

func process_input(event: InputEvent) -> void:
	for index in range(num_states):
		var new_state = current_states[index].process_input(event)
		if new_state:
			change_state(new_state, index)

func process_frame(delta: float) -> void:
	for index in range(num_states):
		var new_state = current_states[index].process_frame(delta)
		if new_state:
			change_state(new_state, index)
