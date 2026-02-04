class_name State
extends Node

#@export var animation_name: String
#@export var move_speed: float = 400

signal go_back #signal so that the fsm goes to the previous state

var animations: Node
var parent: Node
var current_states : Array[State]

func enter() -> void:
	#play animation on entering this state
	#animations.play(animation_name)
	pass

func exit() -> void:
	pass

func process_input(event: InputEvent) -> State:
	return null

func process_frame(delta: float) -> State:
	return null

func process_physics(delta: float) -> State:
	return null
