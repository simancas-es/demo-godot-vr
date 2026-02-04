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

func _ready() -> void:
	monitoring = false
	collision_layer = ENUMS.COLLISION_LAYER.LADDERS
