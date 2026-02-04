extends StateBase
const StateBase := FSM_UIDCLASSREF.StateBase

#TODO Simple death animation

@onready var camera : FPVCamera = %Camera3D
@onready var followp : PathFollow3D = %camera_death_anim_follow
@onready var time_s : float = 1.0 #Time until drop dead

func enter() -> void: ##Plays a small animation
	camera.reparent(followp)
	pass
	
func process_frame(delta: float) -> StateBase:
	followp.progress_ratio += delta/time_s
	return null
