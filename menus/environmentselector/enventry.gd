extends TextureButton
class_name EnvEntry

@onready var preview : TextureRect = %Preview
@onready var title_label : Label = %Title
@onready var description_label : Label = %Descriptiontext

var env_id : ENVIRONMENTS.ID
var coordinates_latlong : Vector2

signal entry_selected(id : ENVIRONMENTS.ID, coords : Vector2)

func _ready() -> void:
	self.button_up.connect(show_preview)
	description_label.tooltip_text = description_label.text
	

func show_preview():
	#Clicked plus hovered
	if self.is_hovered():
		#print("Show preview on map for id: ", env_id)
		entry_selected.emit(env_id, coordinates_latlong)
	else:
		#print("button up but not hovered")
		pass
	
func _gui_input(_event: InputEvent) -> void:
	#print("EnvEntry: ", event)
	pass
	
func populate_entry(id : ENVIRONMENTS.ID, title : String, text : String, image : CompressedTexture2D, coor_latlong : Vector2):
	self.title_label.text = title
	self.description_label.text = text
	self.preview.texture = image
	self.coordinates_latlong = coor_latlong
	self.env_id = id
	pass
