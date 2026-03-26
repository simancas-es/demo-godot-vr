extends BaseDialog
class_name EnvironmentSelector

var current_lat : float
var current_long : float
var current_env : ENVIRONMENTS.ID

var currently_selected : ENVIRONMENTS.ID

@onready var load_button : EnvSelectorLoadButton = %LOADENV
@onready var map_constraint : MapConstraint = %MapConstraint
@onready var entry_list : EnvSelectorEntryContainer = %ScrollEntryContainer

signal launched_environment(from : ENVIRONMENTS.ID, to : ENVIRONMENTS.ID)

signal animation_enter_finished
signal animation_exit_finished

var isfully_loaded : bool = false


var default_position : Vector2

func _ready() -> void:
	load_button.load_current.connect(load_current)
	entry_list.change_current_selected.connect(on_update_selection)	
	entry_list.load_current.connect(load_current)
	default_position = position
	#position.x = -self.size.x
	visible = false
	set_process_input(false)



	
##Caches the selected environment scene while it plays a small animation.
func load_current() -> void:
	#Do a little check
	
	#Menu anchors to 0,0 to take whole screen
		#map object to whole screen with text at bottom
		#Loaded instance pre-loads a number of panoramas as well.
		#After it ends
		
	launched_environment.emit(current_env, currently_selected)
	#print("Launching current env: ", currently_selected)
	pass
	
	
func on_update_selection(env : ENVIRONMENTS.ID):
	currently_selected = env
	#Show Preview on MapPanel.
	map_preview(current_env, currently_selected)
	pass

##Updates this menu. Sets originsl lat and long
func init(new_env : ENVIRONMENTS.ID) -> void:
	current_env = new_env
	current_lat = Cache.LOADED_ENVIRONMENTS_INFO[current_env].latitude
	current_long = Cache.LOADED_ENVIRONMENTS_INFO[current_env].longitude

	##Resets visibility
	hide_nonmap(false)
	##Reset MapPanel
	map_constraint.reset()

	pass
	
	
##Animation where the pieces enter from the side
func enter_animation() -> bool:
	set_process_input(false)
	isfully_loaded = false
	var type : Tween.TransitionType = Tween.TransitionType.TRANS_EXPO
	var tween = create_tween()
	position.x = -size.x
	visible = false
	var enter_f : Callable = func(value): position.x = value;
	tween.tween_method(enter_f, -size.x, default_position.x, 0.9).set_trans(type)
	# BUG If a child is added to the Parent container while this tweens it flickers at pos 0.0
	tween.pause()
	set_visible.call_deferred(true)
	#visible = true
	tween.play()
	
	await tween.finished
	isfully_loaded = true	
	#print("Entering animation done... Current coordinates (lat,long): %s, %s" % [current_lat, current_long])
	map_constraint.map_panel.generate_starting_position(current_lat, current_long)
	
	animation_enter_finished.emit()
	set_process_input(true)
	return true


##Animation of the selecting menu going to the left.
func exit_animation() -> bool:
	set_process_input(false)
	isfully_loaded = false
	var type : Tween.TransitionType = Tween.TransitionType.TRANS_EXPO
	var tween = create_tween()
	position.x = default_position.x
	visible = true
	var exit_f : Callable = func(value): position.x = value;
	tween.tween_method(exit_f, default_position.x, -size.x, 0.9).set_trans(type)
	await tween.finished
	isfully_loaded = true
	visible = false
	
	animation_exit_finished.emit()

	return true

##Shows 
func map_preview(from_env : ENVIRONMENTS.ID, to_env : ENVIRONMENTS.ID):
	init(from_env)	
	var to_lat = Cache.LOADED_ENVIRONMENTS_INFO[to_env].latitude
	var to_long = Cache.LOADED_ENVIRONMENTS_INFO[to_env].longitude
	
	#print("Animating map preview...")
	map_constraint.map_panel.generate_anim(current_lat, current_long, to_lat, to_long)
	
	pass
	
##Hides everything that is not the big map
func hide_nonmap(hidden_ : bool) -> void:
	entry_list.visible = not hidden_
	load_button.visible = not hidden_
	
	pass
	
##Makes the map section big and prepares it for the travel animation.
func map_loading_anim(from_env : ENVIRONMENTS.ID, to_env : ENVIRONMENTS.ID):
	set_process_input(false)
	init(from_env)
	var to_lat = Cache.LOADED_ENVIRONMENTS_INFO[to_env].latitude
	var to_long = Cache.LOADED_ENVIRONMENTS_INFO[to_env].longitude	
	await map_constraint.map_panel.generate_anim(current_lat, current_long, to_lat, to_long)
	await map_constraint.make_big()
	await map_constraint.map_panel.zoom_pivot(current_lat, current_long, to_lat, to_long)
	
	#animation_exit_finished.emit()
	pass

##Makes the van cross the map	
func animate_loading_progress() -> void:
	set_process_input(false)
	await map_constraint.map_panel.animate_loading_screen()
	pass

##Fades into nothing
func fade_out_loading_screen() -> void:
	set_process_input(false)

	self.modulate = Color.WHITE
	var tween : Tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1.0)
	await tween.finished
	self.visible = false
	self.modulate = Color.WHITE
	map_constraint.map_panel.reset()
	#released_lock.emit()
	#
#func _input(_event: InputEvent) -> void:
	####Menu	BUG: Bugs out if pressed too fast
	#if Input.is_action_just_pressed("escape"):
		#print("Escape pressed while in Environment Selector...")
		#get_viewport().set_input_as_handled()
		#if !isfully_loaded : return
		#await exit_animation()
		#isfully_loaded = false
		#get_viewport().set_input_as_handled()
		##animation_exit_finished.emit()
		##released_lock.emit()
		
