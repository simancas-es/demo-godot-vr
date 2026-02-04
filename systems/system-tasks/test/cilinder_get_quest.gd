extends MeshInstance3D

signal clicked

func _init() -> void:
	clicked.connect(give_quest_out)
	
	
func give_quest_out() ->  void:
	print("Giving quest")
	
	
	pass
