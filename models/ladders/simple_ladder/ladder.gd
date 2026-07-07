extends Area3D
class_name Ladder

##World object that allows to climb upwards
##Collision mask has to be 14 - WORLD_LADDERS
##This is a passive object. All logic is handled in the FPV class

##The intention is:
##Looking towards its front: upwards
##Looking in the direction its facing: downwards
##Looking 45 degree angle down or less: downwards
##Looking 45 degrees angle down or more: upwards 

@export var minimum_looking_angle_deg : float = 45
@export var minimum_horizontal_angle : float = 90
@export var allowed_from_behind : bool = true
@export var allowed_backwards : bool = true

func _ready() -> void:
	monitoring = false
	collision_layer = ENUMS.COLLISION_LAYER.LADDERS


	
