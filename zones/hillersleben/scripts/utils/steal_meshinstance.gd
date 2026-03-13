extends Node
@export var nodepath : NodePath

func _ready() -> void:
	get_parent().ready.connect(on_ready)
	
func on_ready() -> void:	
	if nodepath:
		var item = get_node(nodepath)
		item.reparent(get_parent())
		
pass
