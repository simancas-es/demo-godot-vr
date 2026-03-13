extends Label3D
const DoorVR = preload("uid://jc0js3dq6nue")

@export var debug : bool = false
@onready var door : DoorVR = get_parent()

func _ready() -> void:
	set_process(debug)
	
func _process(_delta: float) -> void:
	self.text = "Current_angle : %0.1f°\nTarget_angle: %0.1f°\nHandle_angle: %0.1f°" % [rad_to_deg(door._current_angle),
																						 rad_to_deg(door._target_angle),
																						rad_to_deg(door._handle_rotation_rad)]
