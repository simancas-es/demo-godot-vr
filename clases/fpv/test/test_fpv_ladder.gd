extends Node3D
@onready var fpv : FPV = $FPV

func _ready() -> void:
	test_ladder_logic()
	fpv.set_mode_environment()
	
##A : movedir.z (z for s, -z for w, b cosfw, c, whether looking >-45 degrees up
func ladder_logic(a, b, c) -> int:
	return int(2 * ((1 + a) * (1 + b) / 4 + (1 - a) * (1 - b) * (1 + c) / 8) - 1)

##cos fw1= player looking in the same direction as ladder front
##cos fw-1= player looking towards the ladder
##cos fw1 (away from) : s: up,   w : down
##cos fw-1 (towards)  : s: down, w : looking_up
func test_ladder_logic() -> void:
	assert(ladder_logic(1, 1, -1) == 1)
	assert(ladder_logic(1, 1, 1) == 1)
	assert(ladder_logic(1, -1, -1) == -1)	
	assert(ladder_logic(1, -1, -1) == -1)	
	assert(ladder_logic(-1, 1, -1) == -1)	
	assert(ladder_logic(-1, 1, 1) == -1)	
	assert(ladder_logic(-1, -1, -1) == -1)	
	assert(ladder_logic(-1, -1, 1) == 1)
	
	#floats #TODO: Doesnt work with floats
	#assert(ladder_logic(0.6, 0.7, -1) > 0)
	#assert(ladder_logic(1, 1, 1) == 1)
	#assert(ladder_logic(1, -1, -1) == -1)	
	#assert(ladder_logic(1, -1, -1) == -1)	
	#assert(ladder_logic(-1, 1, -1) == -1)	
	#assert(ladder_logic(-1, 1, 1) == -1)	
	#assert(ladder_logic(-1, -1, -1) == -1)	
	#assert(ladder_logic(-1, -1, 1) == 1)
