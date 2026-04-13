extends Node3D

@onready var area_hole : AREA_TASK = $AREA3D_HOLE
@onready var wire_pickup : InventoryPickup = $WIRE_PICKUP
@onready var wire_use : InteractionWithInventorySlotSelected = $WIRE_USE

const AREA_TASK := preload("uid://vojndhlaetth")

signal body_entered
signal fence_fixed
signal wire_picked_up
signal wire_repaired

@onready var starter : SYSTEMTASKS_UIDCLASSREF.SystemTasksStarter = $TasksStarter
@onready var sequencer : SEQUENCER = $TaskSequencer

const SEQUENCER := preload("uid://coekj8jimafya")

func _ready() -> void:
	
	starter.activate()
	
	area_hole.body_entered.connect(_on_body_entered)
	wire_pickup.successfully_taken.connect(_on_wire_pick)
	wire_use.validated_item_interaction.connect(_on_wire_interaction)
	
	sequencer.next_in_line.connect(next_task)
	next_task(sequencer.get_current_task())
	pass

func _on_body_entered(...args) -> void:
	body_entered.emit()
	pass

func _on_wire_pick(...args) -> void:
	wire_picked_up.emit()
	pass

func _on_wire_interaction(...args) -> void:
	wire_repaired.emit()
	fence_fixed.emit()
	$FENCE_BROKEN/PATCH.visible = true
	pass

func next_task(task_id : SYSTEMTASKSSETTINGS.UNIT_ID) -> void:
	match task_id:
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_FINDHOLE:
			area_hole.activate()
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_FINDWIRE:
			wire_pickup.get_node("Area3D").activate()
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_REPAIRWIRE:
			wire_use.get_node("Area3D").activate()
	
	pass
	

	
