extends Node
##class_name sequence consumer

##ABSTRACT CLASS

const SEQUENCER := preload("uid://coekj8jimafya")
@onready var sequencer : SEQUENCER

var started : bool = false

func start():
	if started: return
	if sequencer == null:
		push_error("Missing sequencer!")
		return
	if not sequencer.next_in_line.is_connected(_on_next_task):
		sequencer.next_in_line.connect(_on_next_task)
	sequencer.active = true
	sequencer.sequencing()
	_on_next_task(sequencer.get_current_task())
	started = true
	
func _on_next_task(task_id : int) -> void:
	push_warning("Not implemented!")
