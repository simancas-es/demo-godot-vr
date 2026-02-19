extends Node
#Snap quest for parent

@export var basesystem : Node3D = null

const SnapInteraction = preload("uid://bjh03qtuyod2f")
const Controller = preload("uid://cbkd2d8p88nn2") #aerator_quest_controller.gd
@onready var questcontroller : Controller = basesystem.get_node("ZoneObservatorio/DemoConcreteBasin/AeratorQuestController")


func _ready() -> void:
	var p : SnapInteraction = get_parent()
	p.correct_item_snapped.connect(on_snap_repair)
	pass
	
func on_snap_repair() -> void:
	questcontroller._on_quest_complete()
	pass
