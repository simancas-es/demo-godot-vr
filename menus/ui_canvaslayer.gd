extends CanvasLayer
class_name MenuManager

const MinimapController := preload("res://systems/system-minimap/minimap_controller.gd")
const MinimapMenu := preload("res://menus/minimap/minimap_menu.gd")

#@onready var sm : StateMachine = %SMMenuManager

@onready var pc : PanelContainer = %PanelContainer ##Panelcontainer for all permanent menus
#@onready var pct : PanelContainer = %PanelContainerTemporal ##Panel container for popups to prevent resetting children in pc
@onready var pctv : VBoxContainer = %PanelContainerTemporalVBox
@onready var menu_env : EnvironmentSelector = %EnvironmentSelector
#@onready var menu_settings : MenuSettings = %MenuSettings

@onready var state_inscene : StateMenus = %InScene
@onready var state_envselector : StateMenusEnvSelector = %StateMenuEnvSelector
@onready var state_settings : StateMenus = %StateMenuSettings
@onready var minimap_menu: MinimapMenu = %MinimapMenu


#
#var GameController_locks = 0:
	#set(value):
		#GameController_locks = value
		#iterate_locks()
	#get():
		#return GameController_locks
#
#signal entered_intro_screen
#signal entered_menu_envselector
#signal entered_menu_settings

signal launched_env_change(from : ENVIRONMENTS.ID, target : ENVIRONMENTS.ID)

func _ready() -> void:
	Signals.ui_msg_top.connect(generate_message_top)

func show_minimap(minimap_controller: MinimapController) -> void:
	if minimap_menu == null:
		return
	minimap_menu.show_for(minimap_controller)

func hide_minimap() -> void:
	if minimap_menu == null:
		return
	minimap_menu.close()

func is_minimap_visible() -> bool:
	return minimap_menu != null and minimap_menu.is_open()

func refresh_minimap(minimap_controller: MinimapController) -> void:
	if minimap_menu == null or not minimap_menu.is_open():
		return
	minimap_menu.show_for(minimap_controller)
	
##Generates a message at the top of the screen that vanishes. 
##It doesnt interact with anything and has a timer
func generate_message_top(text : String, timer_s : float = 4.0, _timer_fadeout_s = 0.5) -> void:
	var msgtop_res = await Cache.load_asynchronous(RESOURCES.MSGTOP)
	var msgtop = msgtop_res.instantiate().with(text, timer_s)
	push_warning("generate_message_top function not implemented yet!")
	pctv.add_child.call_deferred(msgtop) ##Adding a children resets the position of all siblings...
	
	pass

##For adding popups and intro dialogs
func add_temporal_dialog(dialog : Dialog) -> void:
	pc.add_child(dialog)	

	
	
func on_popup_info(popup : InfoPopup) -> void:
	pc.add_child(popup)
	Signals.release_mouse.emit() #TODO: This logic should be in the scn itself
	Signals.set_fixed_camera.emit(true)
	popup.closed.connect(on_popup_info_closed)
	
func on_popup_info_closed() -> void:
	var locks = get_tree().get_nodes_in_group("DIALOG_LOCK") #HACK
	for lock in locks:
		if not lock.is_queued_for_deletion(): return
	print("No valid instances left")
	Signals.request_current_fpvmode.emit()
	pass

	#
#
#func iterate_locks():
	#print("Locks: ", GameController_locks)
	#if GameController_locks == 0:
		#ControllerManager.enable_ctrls(true)
		#request_current_fpvmode.emit()
	#else:
		#ControllerManager.enable_ctrls(false)
