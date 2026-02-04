extends Panel
class_name TopPanelBar

@onready var close_button : Button = %BUTTONCLOSE
@onready var title_label : RichTextLabel = %Title

signal closed

func _ready() -> void:
	close_button.closed.connect(closed.emit) #Propagates up

func set_title(title : String) -> void:
	if is_instance_valid(title_label): title_label.text = title
	pass

func get_title() -> String:
	if is_instance_valid(title_label): return title_label.text
	else: return ""
