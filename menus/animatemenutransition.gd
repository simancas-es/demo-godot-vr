extends Node
class_name AnimateMenuScaleIn

@export var offset_pivot : Vector2 #Base
@export var from_center : bool = false
@export var final_value : Vector2 = Vector2(1,1)
@export var init_value : Vector2 = Vector2(0,0)

@export var time_seconds : float = 0.8
@export var tween_type : Tween.TransitionType = Tween.TransitionType.TRANS_EXPO

var parent : Control
var property : String = "scale"
var base_offset_pivot : Vector2

func _ready() -> void:
	parent = get_parent()
	base_offset_pivot = parent.pivot_offset
	
	if from_center:
		set_middle()
	
func set_middle():
	offset_pivot = parent.size/2

func animate():
	parent.pivot_offset = offset_pivot
	parent.set(property, self.init_value)	
	
	var tween = create_tween()
	tween.tween_property(self.parent, self.property, self.final_value, self.time_seconds ).set_trans(self.tween_type)
	
	#parent.pivot_offset = base_offset_pivot
