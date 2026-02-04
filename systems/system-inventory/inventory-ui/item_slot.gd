extends Panel
#class_name Inventory_UI_Slot

##Small square from the item slot
##Reacts when hovered and when focused

@onready var button : Button = %Button
@onready var focusanim : Panel = %FocusAnimation

signal focused
signal hovered

func _ready() -> void:
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())#HACK
	if not button.focus_entered.is_connected(on_focus_entered):
		button.focus_entered.connect(on_focus_entered)
	if not button.focus_exited.is_connected(on_focus_exited):
		button.focus_exited.connect(on_focus_exited)
	pass
	
##Sets focus manually. Only one thing can be focused at the same time
func focus(enable : bool) -> void:
	if enable: button.grab_focus()
	#if enable: button.grab_click_focus()
	else:
		button.release_focus()
	
func is_focused() -> bool:
	return button.has_focus()
	
func set_texture(texture : Texture2D) -> void:
	%TextureRect.texture = texture
func set_qty(qty : String):
	%QTY.text = qty
func set_null() -> void:
	%TextureRect.texture = null
	%QTY.text = "" #NO_TRANSLATE
	


func on_focus_entered() -> void:
	focusanim.visible = true
	focused.emit()
	pass

func on_focus_exited() -> void:
	focusanim.visible = false
	pass

func on_hover_entered() -> void:
	pass

func on_hover_exited() -> void:
	pass


	
