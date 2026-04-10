extends Button
class_name EnvSelectorLoadButton

signal load_current

func _ready() -> void:
	self.button_up.connect(on_press)
	pass
	
func on_press():
	if self.is_hovered():
		#print("Start big animation of map")
		load_current.emit()
	else:
		#print("Load button up but not hovered")
		pass
	
