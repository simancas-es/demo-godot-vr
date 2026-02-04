extends StateMenus

#State represents the intro screen with the fixed camera

#@export var intro_dialog : Dialog
var intro_dialog : Dialog
@onready var state_inscene : StateMenus = %InScene
@onready var state_settings : StateMenus = %StateMenuSettings
@onready var state_envselect : StateMenusEnvSelector = %StateMenuEnvSelector

@onready var state_loading : StateMenusLoading = %Loading
@onready var menu_manager : MenuManager = %UI_CanvasLayer


var seen_welcome_message : bool = false
#const welcome_message_text = "Sie spielen eine Demo für eine 3D Virtual Tour\n Bitte anklick oder E Antasten"
const welcome_message_text : String = "You are playing a tech demo for a 3D World / 360º Virtual tour tool\n Continue [{key}]"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func exit() -> void:
	disconnect_signals()
	super()
	if is_instance_valid(intro_dialog): intro_dialog.destroy()
	#Signals.entered_room.disconnect(change_to.emit.bind(state_inroom))
	pass

func enter() -> void:
	connect_signals()
	super()
	ControllerManager.enable_ctrls(true)
	parent.pause_game(false)
	
	
	if not seen_welcome_message:
		var wm : String  = tr(welcome_message_text).format({"key":ENUMS.get_keystring(ENUMS.ACTION.INTERACT)})
		launch_intro_dialog(wm)
		seen_welcome_message = true
	
		await load_introscreen()

@onready var signals_fs : Dictionary[Signal, Callable] = {
	#Signals.settings: menu_manager.on_settings,
	#Signals.select_env: menu_manager.on_select_env,
	Signals.settings: change_to.emit.bind(state_settings),
	Signals.select_env: on_launching_env_selector,
	Signals.change_zone: on_loading_new_env,
	menu_manager.launched_env_change: on_loading_new_env,
	#menu_manager.request_current_fpvmode: on_set_fpvmode
}
func connect_signals() -> void:	
	for s in signals_fs.keys():
		if not s.is_connected(signals_fs[s]):
			s.connect(signals_fs[s])
	pass
	
func disconnect_signals() -> void:
	for s in signals_fs.keys():
		if s.is_connected(signals_fs[s]):
			s.disconnect(signals_fs[s])
	pass

func launch_intro_dialog(text : String) -> void:
	#Welcoming dialog
	intro_dialog = load(RESOURCES.DIALOG_SIMPLE).instantiate()
	intro_dialog.init(text, true,0)
	intro_dialog.clicked.connect(Signals.set_fixed_camera.emit.bind(true))
	menu_manager.add_child(intro_dialog)	
	
func load_introscreen () -> void:
	var introscreen : BaseZone = await parent.change_environment(ENVIRONMENTS.ID.HOCHSCHULE)
	introscreen.setup_introscreen.call_deferred()

func on_launching_env_selector(from : ENVIRONMENTS.ID) -> void:
	state_envselect.current_env = from
	change_to.emit(state_envselect)
	
	
func on_loading_new_env(from : ENVIRONMENTS.ID, to : ENVIRONMENTS.ID):
	state_loading.current_env = from
	state_loading.target_env = to		
	ControllerManager.enable_ctrls(false)
	change_to.emit(state_loading)


func process_input(_event: InputEvent) -> StateMenus:
	##Menu	
	if Input.is_action_just_pressed("escape"):	
		get_viewport().set_input_as_handled()
		return state_settings
	return null
