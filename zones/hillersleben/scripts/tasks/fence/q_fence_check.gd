extends CONSUMER
const CONSUMER := preload("uid://cjrqcfgi4v8xn")

@onready var area_hole : AREA_TASK = $AREA3D_HOLE
@onready var wire_pickup : InventoryPickup = $WIRE_PICKUP
@onready var wire_use : InteractionWithInventorySlotSelected = $WIRE_USE

const AREA_TASK := preload("uid://vojndhlaetth")

signal body_entered
signal fence_fixed
signal wire_picked_up
signal wire_repaired

@onready var starter : SYSTEMTASKS_UIDCLASSREF.SystemTasksStarter = $TasksStarter


func _ready() -> void:
	sequencer = $TaskSequencer
	area_hole.body_entered.connect(_on_body_entered)
	wire_pickup.successfully_taken.connect(_on_wire_pick)
	wire_use.validated_item_interaction.connect(_on_wire_interaction)

	pass

func start() -> void:
	super()
	starter.activate()
	
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

func _on_next_task(task_id : SYSTEMTASKSSETTINGS.UNIT_ID) -> void:
	match task_id:
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_FINDHOLE:
			if area_hole: area_hole.activate()
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_FINDWIRE:
			if wire_pickup:
				var area = wire_pickup.get_node("Area3D")
				if area: area.activate()
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_REPAIRWIRE:
			if wire_use:
				var area = wire_use.get_node("Area3D")
				if area: area.activate()
	
	pass
	

	
