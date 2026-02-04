@tool
extends EditorPlugin
class_name FileDialogInEditor

var _file_dialog

func _enter_tree():

	add_tool_menu_item('Generate JSON Template', _open_path.bind("", null))
	if not Signals.request_editor_file_json.is_connected(_open_path):
		Signals.request_editor_file_json.connect(_open_path)
	
	_file_dialog = FileDialog.new()
	_file_dialog.mode = Window.MODE_WINDOWED
	_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	_file_dialog.access = FileDialog.ACCESS_RESOURCES

	_file_dialog.filters = ["*.json ; JSON Files"]
	_file_dialog.current_file = "Information.json"
	_file_dialog.current_path = ""
	
	_file_dialog.reset_size()
	_file_dialog.min_size = Vector2(600,400)
	_file_dialog.set_size(Vector2(600, 400))


	var base_control = EditorInterface.get_base_control()
	base_control.add_child(_file_dialog)

	#_file_dialog.file_selected.connect(_on_file_selected)

func _exit_tree():
	_file_dialog.queue_free()

func _open_path(path : String, node : Node):
	if node == null: return
	_file_dialog.current_path = path
	_file_dialog.popup_centered_ratio()
	
	var chosen_path = await _file_dialog.file_selected
	if chosen_path != "":
		_on_file_selected(chosen_path, node)
		

func _on_file_selected(path, node : Node):
	copy_information_template(path)
	node.set("filepath_information", path)
	

##Copies the Panorama Polygons information template to path
func copy_information_template(to : String) -> void:
	var it = RESOURCES.INFORMATION_TEMPLATE
	copy_file(it, to)
	


static func copy_file(src_path: String, dest_path: String) -> bool:
	if not FileAccess.file_exists(src_path):
		push_error("Source file does not exist: " + src_path)
		return false

	var src_file := FileAccess.open(src_path, FileAccess.READ)
	if src_file == null:
		push_error("Failed to open source file: %s " % src_path)
		return false

	var contents := src_file.get_buffer(src_file.get_length())
	src_file.close()

	var dest_file := FileAccess.open(dest_path, FileAccess.WRITE)
	if dest_file == null:
		push_error("Failed to open destination file: %s" % dest_path)
		return false

	dest_file.store_buffer(contents)
	dest_file.close()

	return true
