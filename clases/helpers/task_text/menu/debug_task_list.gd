extends VBoxContainer

const TasksUnit := SYSTEMTASKS_UIDCLASSREF.SystemTasksUnit
# References to managers
var world_task_manager : SYSTEMTASKS_UIDCLASSREF.SystemTasksManager
var task_text_manager : HELPREF.TaskTextManager

# The container that will hold all task UI labels etc
@onready var task_items_container := $ScrollContainer/VBoxContainer
var task_panels : Dictionary[int, PanelContainer] = {} #References in form of task_id - panel

@export_range (8, 256) var font_size : int = 14
@export var filter_only : Array[TasksUnit.STATUS] = [TasksUnit.STATUS.IN_PROGRESS, TasksUnit.STATUS.COMPLETED] #show only

const _text_uninitiated = "Uninitiated"
const _text_inprogress = "In Progress"
const _text_completed = "Completed"
const _text_failed = "Failed"
const _text_unknown = "Unknown"
var _translated = [_text_uninitiated, _text_inprogress, _text_completed, _text_failed, _text_unknown]# HACK. Easy translations export

const STATUSTEXT : Dictionary = {
	TasksUnit.STATUS.UNINITIATED : _text_uninitiated,
	TasksUnit.STATUS.IN_PROGRESS : _text_inprogress,
	TasksUnit.STATUS.COMPLETED : _text_completed,
	TasksUnit.STATUS.FAILED : _text_failed,	
}


func _ready():
	# Grab managers from GameState
	if ! world_task_manager:	world_task_manager = GameState.world_task_manager
	if ! task_text_manager:	task_text_manager = GameState.task_text_manager

	world_task_manager.updated.connect(on_task_manager_updated)
	# Fill the list
	populate_task_list()

func on_task_manager_updated(task_id : int, new_status : int) -> void:
	if not task_id in task_panels:
		return

	if not task_id in world_task_manager.tasks and not task_id in world_task_manager.history:
		push_warning("Task ID %d no longer exists" % task_id)
		remove_task_panel(task_id)
		return

	var panel : PanelContainer = task_panels[task_id]

	#Hack
	var vb = panel.get_child(0)
	var status_label = vb.get_child(2) as Label
	if status_label:
		status_label.text = _get_status_text(new_status)
		_update_status_color(status_label, new_status)
		
	filter_panel_visibility() #HACK, slow
	pass

func remove_task_panel(task_id: int) -> void:
	if not task_panels.has(task_id):
		return
	var panel = task_panels[task_id]
	panel.queue_free()
	task_panels.erase(task_id)

func populate_task_list():
	# Clear previous content
	for c in task_items_container.get_children():
		task_items_container.remove_child(c)
	task_panels.clear()
	
	var tasks = world_task_manager.tasks.keys() + world_task_manager.history.keys()
	for task_id in tasks:
		var task_data = task_text_manager.get_text(task_id, TranslationServer.get_locale())
		var status_enum = world_task_manager.check_task_status(task_id)

		var task_panel = _create_task_panel(task_id, task_data, status_enum)
		task_items_container.add_child(task_panel)
		task_panels[task_id] = task_panel
		
	filter_panel_visibility()

func filter_panel_visibility() -> void:
	for t in task_panels.keys():
		var panel : PanelContainer = task_panels[t]
		if world_task_manager.check_task_status(t) in filter_only:
			panel.visible = true
		else:
			panel.visible = false
	pass
	
	
func _create_task_panel(task_id: int, task_data: Dictionary, status_enum: int) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)

	# Title
	var title_label = Label.new()
	title_label.text = task_data.get("title", "MISSING TITLE")
	title_label.set("theme_override_font_sizes/font_size", font_size)
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(title_label)

	# Description
	var desc_label = Label.new()
	desc_label.text = task_data.get("text", "MISSING TEXT")
	desc_label.set("theme_override_font_sizes/font_size", font_size)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc_label)

	# Status
	var status_label = Label.new()
	status_label.name = "StatusLabel"  # easy reference for dynamic updates
	status_label.text = _get_status_text(status_enum)
	status_label.set("theme_override_font_sizes/font_size", font_size)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(status_label)

	# Color coding
	_update_status_color(status_label, status_enum)

	return panel


func _get_status_text(status_enum: int) -> String:
	var status_text : String = tr(STATUSTEXT.get(status_enum, "Unknown"))
	return status_text

func _update_status_color(label: Label, status_enum: int) -> void:
	match status_enum:
		TasksUnit.STATUS.UNINITIATED:
			label.add_theme_color_override("font_color", Color.GRAY)
		TasksUnit.STATUS.IN_PROGRESS:
			label.add_theme_color_override("font_color", Color.YELLOW)
		TasksUnit.STATUS.FAILED:
			label.add_theme_color_override("font_color", Color.RED)
		TasksUnit.STATUS.COMPLETED:
			label.add_theme_color_override("font_color", Color.GREEN)

#Listen to locale changes
func update_task_text(task_id: int) -> void:
	if not task_panels.has(task_id):
		return

	var panel = task_panels[task_id]
	var task_data = task_text_manager.get_text(task_id,  TranslationServer.get_locale())

	var vbox = panel.get_child(0) as VBoxContainer
	if vbox and vbox.get_child_count() >= 2:
		# Update title
		(vbox.get_child(0) as Label).text = task_data.get("title", "MISSING TITLE")
		# Update description
		(vbox.get_child(1) as Label).text = task_data.get("text", "MISSING TEXT")
		
##Listen to changes in the locale
func _notification(what):
	if what == NOTIFICATION_TRANSLATION_CHANGED :
		for t_id in task_panels.keys():
			update_task_text(t_id)
