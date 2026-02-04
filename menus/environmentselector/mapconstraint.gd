extends Control
class_name MapConstraint

@onready var map_panel : EnvSelectorMapPanel = %MapPanel
	
var anchors_default_left : float
var anchors_default_top : float
var anchors_default_right : float
var anchors_default_bottom : float

func _ready() -> void:
	anchors_default_left = self.anchor_left
	anchors_default_top = self.anchor_top
	anchors_default_right = self.anchor_right
	anchors_default_bottom = self.anchor_bottom	

	
func tween_anchor(tween : Tween, anchor_name : String, _from : float, to : float,
				 tween_type : Tween.TransitionType,
				 time_s : float = 0.5) -> Tween:
	tween.tween_property(self, anchor_name, to, time_s ).set_trans(tween_type)
	return tween
	

func reset() -> void:
	self.anchor_left = anchors_default_left
	self.anchor_top = anchors_default_top
	self.anchor_right = anchors_default_right
	self.anchor_bottom = anchors_default_bottom
	
	#map_panel.reset()
	map_panel.queue_free()
	map_panel.visible = false
	map_panel = load(RESOURCES.MENU_ENVSELECT_MAP).instantiate()
	add_child(map_panel)
	pass
	
##Generates the animation of a car going from original latlong to end latlong
func make_big()-> void:
	var tween = self.create_tween()
	tween.set_parallel()
	var target = {"anchor_left":0, "anchor_top":0, "anchor_right":1, "anchor_bottom":1}
	for k in target.keys():
		tween_anchor(tween, k, self.get(k), target[k], Tween.TransitionType.TRANS_SINE, 0.5)
	await tween.finished
	pass
	
##Only when it has focus?
func _input(_event: InputEvent) -> void:
	#if Input.is_key_pressed(KEY_0):
		#print("map pressed")
		#make_big()
		#get_viewport().set_input_as_handled()
	pass
