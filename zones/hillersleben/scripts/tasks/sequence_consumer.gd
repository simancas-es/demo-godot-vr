extends Node
##class_name sequence consumer

##ABSTRACT CLASS

const SEQUENCER := preload("uid://coekj8jimafya")
@onready var sequencer : SEQUENCER


func start():
	if sequencer == null:
		push_error("Missing sequencer!")
		return
		
	sequencer.next_in_line.connect(_on_next_task)
	sequencer.active = true
	sequencer.sequencing()
	_on_next_task(sequencer.get_current_task())
	
func _on_next_task(task_id : int) -> void:
	push_warning("Not implemented!")
