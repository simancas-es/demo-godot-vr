extends Area3D

#breakable ice wedge. breaks whenever somethings collides with it of the class "ice breaker"
@onready var ice_wedge_mesh : MeshInstance3D = $MeshInstance3D
@onready var interaction : InteractionWithInventorySlotSelected = $InteractionWithInventorySlotSelected

enum STATE {NORMAL, BROKEN}
var current_state : STATE = STATE.NORMAL

func _ready() -> void:
	interaction.validated_item_interaction.connect(try_break)

func restore() -> void:
	current_state = STATE.NORMAL
	ice_wedge_mesh.visible = false
	interaction.disabled = false
	
	
func try_break() -> void:
	if current_state == STATE.NORMAL:
		#break
		ice_wedge_mesh.visible = false
		interaction.disabled = true
		pass
	current_state = STATE.BROKEN
	pass
