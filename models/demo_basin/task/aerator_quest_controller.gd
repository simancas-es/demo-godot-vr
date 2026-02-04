extends Node

@export var state: DEMO_BASIN.BasinState
@onready var quest: InteractionWithInventorySlotSelected = %QuestAerator

#TaskSystem
var locator := SYSTEMTASKS_UIDCLASSREF.SystemTasksLocator.new("DEMO_AERATOR")
var starter := SYSTEMTASKS_UIDCLASSREF.SystemTasksStarter.new()
signal aerator_repaired

func _ready():
	quest.validated_item_interaction.connect(_on_quest_complete)
	
	#TaskSystem
	starter.task_id = SYSTEMTASKSSETTINGS.UNIT_ID.Q_DEMO_AERATOR
	add_child(starter)
	add_child(locator)
	
func _on_quest_complete():
	state.aerator_ok[1] = true
	aerator_repaired.emit()
