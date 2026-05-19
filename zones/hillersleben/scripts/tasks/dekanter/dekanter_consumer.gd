extends "res://zones/hillersleben/scripts/tasks/sequence_consumer.gd"

# First we need to change the polymer feed

# Then after making sure it works, we have to empty the förderband to prevent ice forming.


func _ready() -> void:
	sequencer = $TaskSequencer
	

func start() -> void:
	super()
	
func _on_next_task(task_id : int) -> void:
	match task_id:
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_DEKFOERDERBAND_SPILL:
			pass
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_DEKFOERDERBAND_ENTLEEREN:
			pass
			
	pass
