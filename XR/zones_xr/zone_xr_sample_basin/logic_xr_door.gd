extends Node
const SnapInteraction := preload("uid://bjh03qtuyod2f") #snap_interaction

@onready var snapdoor : SnapInteraction = $".."
@export var basesystem : Node3D
@onready var door : InteractionDoor = basesystem.get_node("ZoneObservatorio/DemoConcreteBasin/Platform_Rusty/Door3D")

func _ready() -> void:
	
	snapdoor.correct_item_snapped.connect(on_correct_snap)
	snapdoor.has_dropped.connect(on_dropped)
	
func on_correct_snap() -> void:
	door.unlock(snapdoor.item_id, true)
	door.open()
	pass

func on_dropped() -> void:
	door.close()
	door.lock(0, true)
