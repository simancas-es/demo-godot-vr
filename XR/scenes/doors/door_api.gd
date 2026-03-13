extends Node3D
const XR_DOORS_UID_CLASSREF = preload("uid://dbtdc5f1qkd3m")

##
## Door API script
##
## @desc:
##     This script exposes the base public API for doors. All door APIs extend
##     from this script and add additional door-specific properties.
##


## Signal emitted when the door handle is grabbed
signal door_grabbed(door)

## Signal emitted when the door handle is released
signal door_released(door)

## Signal emitted when a latched door is opened
signal door_opened(door)

## Signal emitted when a door re-latches
signal door_closed(door)


## Door self-closing force
@export var close_force := 0.0 # (float, 0.0, 1.0, 0.01)

## Door friction
@export var friction := 0.1 # (float, 0.0, 10.0, 0.1)


## Flag to set the door to latch when closed
@export var latch_on_close := true

## Flag to lock the door so the handle will not open it
@export var door_locked := false


func _on_door_grabbed():
	door_grabbed.emit(self)


func _on_door_released():
	door_released.emit(self)


func _on_door_opened():
	door_opened.emit(self)


func _on_door_closed():
	door_closed.emit(self)
