extends HBoxContainer
class_name ChoiceButton

@export var textureButton : TextureButton
@export var label : RichTextLabel
#Note: Mouse/filter/ignore for these two
#Or they will interfere with the focus

@export var text : String = "CHOICE"

signal selected(node : ChoiceButton)
signal pressed

func _ready():
	#print("Change label text from ", label.text, " to ",text, self)
	self.focus_mode = Control.FOCUS_ALL #kb and mouse
	label.text = text
	
func focus() -> void:
	textureButton.grab_focus()
	selected.emit(self)

func _on_focus_entered() -> void:
	textureButton.grab_focus()
	selected.emit(self)
	

func _on_focus_exited() -> void:
	#print(text, " hovered NO!")
	#textureButton.release_focus()
	pass
