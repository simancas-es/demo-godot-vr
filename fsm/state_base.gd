#class_name StateBase
extends Node
const StateBase := FSM_UIDCLASSREF.StateBase
#@export var animation_name: String
#@export var move_speed: float = 400

signal go_back #signal so that the fsm goes to the previous state
signal entered
signal exited

func enter() -> void:
	#play animation on entering this state
	#animations.play(animation_name)
	pass

func exit() -> void:
	pass

func process_input(event: InputEvent) -> StateBase:
	return null

func process_frame(delta: float) -> StateBase:
	return null

func process_physics(delta: float) -> StateBase:
	return null
