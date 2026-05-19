extends "res://zones/hillersleben/scripts/tasks/sequence_consumer.gd"

# First we need to change the polymer feed

# Then after making sure it works, we have to empty the förderband to prevent ice forming.



##HACK. Dekanter logic
@onready var spill : MeshInstance3D = $"../spill"
@onready var snap1 : Node3D = $"../ibc1/snap1"
@onready var snap2 : Node3D = $"../ibc2/snap2"
@onready var intake : SystemPhysicalControlObject = $"../intake"
var _current_snap = 1

signal foerderband_entleert
signal spill_removed
var locator_spill = SYSTEMTASKS_UIDCLASSREF.SystemTasksLocator.new(SYSTEMTASKSSETTINGS.LOCATOR_ID.HL_DEKFOERDERBAND_SPILL)
var locator_foerderband = SYSTEMTASKS_UIDCLASSREF.SystemTasksLocator.new(SYSTEMTASKSSETTINGS.LOCATOR_ID.HL_DEKFOERDERBAND_ENTLEEREN)
	

func _ready() -> void:
	sequencer = $TaskSequencer
	spill.scale = Vector3.ZERO	
	intake.stopped_being_grabbed.connect(_on_intake_let_go)
	
	add_child(locator_spill)
	add_child(locator_foerderband)


func start() -> void:
	super()
	start_spill()
	
func _on_next_task(task_id : int) -> void:
	match task_id:
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_DEKFOERDERBAND_SPILL:
			pass
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_DEKFOERDERBAND_ENTLEEREN:
			pass
			
	pass


func start_spill() -> void:
	var tween = create_tween()
	tween.tween_property(spill, "scale", Vector3.ONE, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
func remove_spill() -> void:
	var tween = create_tween()
	tween.tween_property(spill, "scale", Vector3.ZERO, 3.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	#tween.tween_callback(spill.queue_free)
	spill_removed.emit()

func update_current_snap() -> void:
	var dis1 = (intake.global_position - snap1.global_position ).length()
	var dis2 = (intake.global_position - snap2.global_position ).length()
	
	if (dis1 < dis2) and (dis1 < 0.5):	_current_snap = 1
	if (dis1 > dis2) and (dis2 < 0.5):	_current_snap = 2
	
	#Assuming ibc2 always full:
	if _current_snap == 1 : start_spill()
	if _current_snap == 2 : remove_spill()

func _on_intake_let_go(...args) -> void:
	intake.sleeping = true
	update_current_snap()
	pass
