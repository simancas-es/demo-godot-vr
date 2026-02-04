extends BaseDialog
class_name Dialog

@export var label : Label

signal clicked
	
func init(text : String, lock :bool, timer_s : float) -> void:
	"""Text: text to show
	lock: whether it blocks all other input until dealt with
	timer_s: time in seconds before it disappears. 0 for permanent
	"""
	self.visible = true
	if label == null: return
	label.text = text
	if lock:
		#Signals.activated_dialog_lock.emit()
		pass
	if timer_s > 0:
		var timer = UTILS.create_timer(self, timer_s, true, destroy)
		timer.start()
		
func destroy() -> void:
	#Signals.deactivated_dialog_lock.emit()
	call_deferred("queue_free")
	self.visible = false
#
#func processing_input(event : InputEvent) -> bool:
	#if event.is_action_released("interact"):
		#print("Interactingggggg")
		#get_viewport().set_input_as_handled()
		#return true
	#return false
	
func _input(event: InputEvent) -> void:
	if event.is_action_released("interact"):
		get_viewport().set_input_as_handled()
		clicked.emit()
		destroy()
		
