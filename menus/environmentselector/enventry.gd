extends TextureButton
class_name EnvEntry

@onready var preview : TextureRect = %Preview
@onready var title_label : Label = %Title
@onready var description_label : Label = %Descriptiontext

var env_id : ENVIRONMENTS.ID
var coordinates_latlong : Vector2

signal entry_selected(id : ENVIRONMENTS.ID, coords : Vector2)
signal entry_doubleclicked(id : ENVIRONMENTS.ID, coords : Vector2)

@export_category("Color")
@export var normal_color: Color = Color.WHITE
@export var hover_color: Color = Color.GRAY
@export var focus_color: Color = Color.YELLOW
@onready var background_panel : Panel = $Panel

func _ready() -> void:
	self.button_up.connect(show_preview)
	description_label.tooltip_text = description_label.text
	
	# Enable focus for the button
	focus_mode = Control.FOCUS_ALL
	# Connect signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

func show_preview():
	#Clicked plus hovered
	if self.is_hovered():
		#print("Show preview on map for id: ", env_id)
		entry_selected.emit(env_id, coordinates_latlong)
	else:
		#print("button up but not hovered")
		pass
	
func _gui_input(_event: InputEvent) -> void:
	if _event is InputEventMouseButton:
		if _event.pressed:
			# Set focus on click
			grab_focus()
	if _event is InputEventMouseButton:
		if _event.double_click and _event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			entry_doubleclicked.emit(env_id, coordinates_latlong)
	pass

func _on_mouse_entered():
	if not has_focus():	background_panel.modulate = hover_color

func _on_mouse_exited():
	# If focused, show focus color; otherwise normal
	if has_focus():
		background_panel.modulate = focus_color
	else:
		if not has_focus():	background_panel.modulate = normal_color

func _on_focus_entered():
	background_panel.modulate = focus_color

func _on_focus_exited():
	background_panel.modulate = normal_color

	
func populate_entry(id : ENVIRONMENTS.ID, title : String, text : String, image : CompressedTexture2D, coor_latlong : Vector2):
	self.title_label.text = title
	self.description_label.text = text
	self.preview.texture = image
	self.coordinates_latlong = coor_latlong
	self.env_id = id
	pass
