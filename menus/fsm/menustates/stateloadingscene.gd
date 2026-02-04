extends StateMenus
class_name StateMenusLoading
#Loading screen

@onready var state_inscene : StateMenus = %InScene
#@onready var menu_manager : MenuManager = %UI_CanvasLayer

@onready var menu_env : EnvironmentSelector = %EnvironmentSelector

var current_env : ENVIRONMENTS.ID
var target_env : ENVIRONMENTS.ID

func _ready() -> void:
	pass
	
	
func exit():
	super()
	
func enter():
	super()
	parent.pause_game(true) #Dont pause car engine
	#print("Entering Loading State, %s , %s" % [current_env, target_env])
	menu_env.visible = true
	await menu_env.map_loading_anim(current_env, target_env) #HACK
	menu_env.hide_nonmap(true)
	await menu_env.animate_loading_progress() #Load animation	
	await Cache.load_environment(target_env)	
	await parent.change_environment(target_env) #Root	
	
	
	await menu_env.fade_out_loading_screen()
	change_to.emit(state_inscene)
