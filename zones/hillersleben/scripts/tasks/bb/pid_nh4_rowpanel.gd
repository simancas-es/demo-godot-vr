extends Panel


@export var settings_row_color_normal := Color(1.0, 1.0, 1.0, 1.0)
@export var settings_row_color_focus := Color(1.0, 0.967, 0.0, 1.0)
		
var style := StyleBoxFlat.new()

@onready var arrows : Control = $"HBoxContainer/arrows"

func _ready():
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP

	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

	_apply(settings_row_color_normal)


func _on_focus_entered():
	_apply(settings_row_color_focus)


func _on_focus_exited():
	_apply(settings_row_color_normal)

func selected() -> void:
	arrows.modulate.a = 1.0

func unselected() -> void:
	arrows.modulate.a = 0.0
	pass
func _apply(c: Color):
	style.bg_color = c
	add_theme_stylebox_override("panel", style)
