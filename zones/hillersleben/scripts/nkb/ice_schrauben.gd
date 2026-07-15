extends MeshInstance3D

enum STATE {NORMAL, BROKEN}
var current_state : STATE = STATE.NORMAL

@onready var interaction : InteractionWithInventorySlotSelected = $InteractionWithInventorySlotSelected

signal updated

func _ready() -> void:
	interaction.validated_item_interaction.connect(try_break)
	
func restore() -> void:
	current_state = STATE.NORMAL
	self.visible = true
	updated.emit()
	
func try_break() -> void:
	if current_state == STATE.NORMAL:
		#break
		self.visible = false
		pass
	current_state = STATE.BROKEN
	updated.emit()
	pass
