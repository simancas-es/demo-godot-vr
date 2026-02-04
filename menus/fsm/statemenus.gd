class_name StateMenus
extends Node

#@export var animation_name: String
#@export var move_speed: float = 400

signal go_back #signal so that the fsm goes to the previous state
signal change_to(state : StateMenus)
signal entered
signal exited

func back() -> void:
	#if active:
	go_back.emit()
	pass

#var animations: Node
var parent: GameRoot
#var current_state : StateMenus

#var active : bool = false

func enter() -> void:
	parent.pause_game(true)
	UTILS.pause_node(self, false)
	#play animation on entering this state
	#animations.play(animation_name)
	set_process_input(true)
	pass

func exit() -> void:
	UTILS.pause_node(self, true)
	set_process_input(false)
	pass

func process_input(_event: InputEvent) -> StateMenus:
	return null

func process_frame(_delta: float) -> StateMenus:
	return null

func process_physics(_delta: float) -> StateMenus:
	return null
