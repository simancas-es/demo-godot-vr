extends "res://zones/hillersleben/scripts/tasks/sequence_consumer.gd"

# First we need to change the polymer feed

# Then after making sure it works, we have to empty the förderband to prevent ice forming.



##HACK. Dekanter logic
@onready var spill : MeshInstance3D = $"../spill"
@onready var snap1 : Node3D = $"../ibc1/snap1"
@onready var snap2 : Node3D = $"../ibc2/snap2"
@onready var intake : SystemPhysicalControlObject = $"../intake"
var _current_snap = 1
const LIGHT := preload("uid://bjn6ld6vbr26b")
@onready var info_light : LIGHT = $"../info_light"

const BUTTON := preload("uid://bskfg6cqrrb1w")
@onready var dek_button : BUTTON = $"../dek-button"
@onready var fb_button : BUTTON = $"../fb-button"

class STATE:
	var dekanter_on : bool = true
	var foerderband_on : bool = true
	var time_s : float = 0 #time since foerderband is on and dekanter is off
var state := STATE.new()


## TASK- LOGIC
signal foerderband_entleert
signal spill_removed
var locator_spill = SYSTEMTASKS_UIDCLASSREF.SystemTasksLocator.new(SYSTEMTASKSSETTINGS.LOCATOR_ID.HL_DEKFOERDERBAND_SPILL)
var locator_foerderband = SYSTEMTASKS_UIDCLASSREF.SystemTasksLocator.new(SYSTEMTASKSSETTINGS.LOCATOR_ID.HL_DEKFOERDERBAND_ENTLEEREN)
	

func _ready() -> void:
	sequencer = $TaskSequencer
	spill.scale = Vector3.ZERO	
	intake.stopped_being_grabbed.connect(_on_intake_let_go)
	
	dek_button.on.connect(start_dekanter)
	dek_button.off.connect(start_dekanter.bind(false))
	
	fb_button.on.connect(start_foerderband)
	fb_button.off.connect(start_foerderband.bind(false))
	
	
	add_child(locator_spill)
	add_child(locator_foerderband)
	
	start_dekanter()
	start_foerderband()


func start() -> void:
	super()
	start_dekanter()
	start_spill()
	
func _on_next_task(task_id : int) -> void:
	match task_id:
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_DEKFOERDERBAND_SPILL:
			pass
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_DEKFOERDERBAND_ENTLEEREN:
			pass
			
	pass


#LOGIC

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
	if _current_snap == 1 and state.dekanter_on: start_spill()
	if _current_snap == 2 : remove_spill()

func _on_intake_let_go(...args) -> void:
	intake.sleeping = true
	update_current_snap()
	pass
	
	
func start_dekanter(on : bool = true) -> void:
	state.dekanter_on = on
	if on:
		info_light.activate()
		info_light.change_color(Color.GREEN)
	elif not on:
		info_light.change_color(Color.ORANGE)
	
	update_current_snap()
	
func start_foerderband(on : bool = true) -> void:
	state.foerderband_on = on
	

func _process(delta: float) -> void:
	if not state.dekanter_on and state.foerderband_on:
		state.time_s += delta
	elif state.dekanter_on : state.time_s = 0.0
	pass
