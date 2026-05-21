extends Control

#Hacky menu just for changing set targets.
#Rework into different menus.

@onready var info : Control = $Info
@onready var settings : Control = $Settings

var current_menu : Control = info

enum BUTTONS {
	OK,
	UP,
	DOWN,
	RIGHT,
	LEFT,
	M,
	C,
	S,
	ESC
}

		
#info variables
#---nothing, leave as is.

#settings variables
const ROWPANEL := preload("uid://vcqqm7kgypuv")
var settings_target_current_selected : int = -1
@export var settings_target_current_values : Array[float] = [2.0]
const POS_NH4 := 0
var settings_target_column : int
enum SETTINGS_STATE {SELECTING, SELECTED}
var settings_state = SETTINGS_STATE.SELECTING
@onready var settings_vbox := $Settings/VBoxContainer
@export var nh4_target : Label

func show_settings(on : bool) -> void:
	if on:
		settings.visible = true
		current_menu = settings
		settings_state = SETTINGS_STATE.SELECTING
		settings_target_current_selected = -1
		update_selected()
	if not on:
		settings.visible = false
		current_menu = info
		
func change_index(value : int) -> void:
	#up means minus, down means plus, cycle around.
	update_selected()
	if settings_target_current_selected == -1:
		settings_target_current_selected = 0
		return
	settings_target_current_selected =  (settings_target_current_selected + value) % settings_target_current_values.size()	
		
func select_ok() -> void:
		if [0,1,2,3].has(settings_target_current_selected): #HACK. Press ok when something selected
			settings_state = SETTINGS_STATE.SELECTED
			update_selected()
			
func accept_new_value() -> void:
	settings_state = SETTINGS_STATE.SELECTING
	update_selected()
	pass
	
func change_value(value : float) -> void: #HACK we just multiply upwards and downwards
	
	match settings_target_current_selected:
		POS_NH4:
			settings_target_current_values[settings_target_current_selected] += 0.5*value
			
		_:
			pass
	update_selected()
	pass

func update_selected():
	nh4_target.text = "%.1f" % settings_target_current_values[POS_NH4]
	var panels = settings_vbox.get_children()
	for panel : ROWPANEL in panels:
		panel.unselected()
		
	if settings_target_current_selected == -1 :
		get_viewport().gui_release_focus()
		return
		
	
	if panels.is_empty():
		return

	var selected_panel : ROWPANEL = panels[settings_target_current_selected]

	if selected_panel is Control:
		selected_panel.grab_focus()
		if settings_state == SETTINGS_STATE.SELECTED:
			selected_panel.selected()
					
		
	
		
#HACK controls
func pass_controls(button : BUTTONS) -> void:
	if current_menu == info:
		match button:
			BUTTONS.S:
				show_settings(true)
		
		pass
		
	elif current_menu == settings:
		match button:
			BUTTONS.S:
				show_settings(false)
			BUTTONS.ESC:
				show_settings(false)
			BUTTONS.UP:
				if settings_state == SETTINGS_STATE.SELECTING:
					change_index(-1)
				elif settings_state == SETTINGS_STATE.SELECTED:
					change_value(1)
			BUTTONS.DOWN:
				if settings_state == SETTINGS_STATE.SELECTING:
					change_index(+1)
				elif settings_state == SETTINGS_STATE.SELECTED:
					change_value(-1)
			BUTTONS.OK:
				if settings_state == SETTINGS_STATE.SELECTING:
					select_ok()
				elif settings_state == SETTINGS_STATE.SELECTED:
					accept_new_value()
					
				
		pass
	pass
	
	
