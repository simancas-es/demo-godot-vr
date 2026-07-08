extends MeshInstance3D

enum STATE {NORMAL, BROKEN}
var current_state : STATE = STATE.NORMAL

func restore() -> void:
	current_state = STATE.NORMAL
	self.visible = true
	
func try_break() -> void:
	if current_state == STATE.NORMAL:
		#break
		self.visible = false
		pass
	current_state == STATE.BROKEN
	pass
