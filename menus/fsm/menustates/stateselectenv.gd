extends StateMenus
class_name StateMenusEnvSelector
#Environment Selector

@onready var menu_env : EnvironmentSelector = %EnvironmentSelector

@export var state_settings : StateMenus
@onready var state_loading : StateMenusLoading = %Loading

var current_env : ENVIRONMENTS.ID = ENVIRONMENTS.ID.HOCHSCHULE

func _ready() -> void:
	#Signals.change_zone.connect(on_launched_env) ##Kind of duplicated.
	#menu_env.launched_environment.connect(on_launched_env)
	menu_env.launched_environment.connect(on_loading_new_env)

	pass
	
func exit():
	super()	
	menu_env.visible = false
	parent.pause_game(false)
	menu_env.animation_exit_finished.disconnect(closed_envselector)
	
	
func enter():
	ControllerManager.enable_ctrls(false)
	super()
	parent.pause_game(true) #Dont pause car engine
	menu_env.animation_exit_finished.connect(closed_envselector)
	
	menu_env.visible = true
	
	menu_env.init(current_env)
	Signals.release_mouse.emit()
	Signals.set_fixed_camera.emit(true)
	menu_env.enter_animation()
	
func on_loading_new_env(from : ENVIRONMENTS.ID, to : ENVIRONMENTS.ID):
	state_loading.current_env = from
	state_loading.target_env = to		
	ControllerManager.enable_ctrls(false)
	change_to.emit(state_loading)
	

func opened_envselector() -> void:
	pass

func closed_envselector() -> void:
	pass
	

	
func process_input(_event: InputEvent) -> StateMenus:
	###Menu	BUG: Bugs out if pressed too fast
	if Input.is_action_just_pressed("escape"):
		print("Escape pressed while in Environment Selector...")
		get_viewport().set_input_as_handled()
		if !menu_env.isfully_loaded : return
		await menu_env.exit_animation()
		menu_env.isfully_loaded = false
		get_viewport().set_input_as_handled()
		go_back.emit() #Triggers the exit()
	return null
