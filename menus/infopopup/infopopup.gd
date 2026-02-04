extends BaseDialog
class_name InfoPopup

#Class that instantiates a popup with a title, text, scrollbar, and footnote.
#For this particular Bbcode Object, the youtube strings must be coded as:
#url = youtube:code , because we will be reading youtube: as an indicator

#@onready var text : RichTextLabel = %MIDTEXT
#@onready var title : RichTextLabel = %TOPPANEL

@onready var top_panel : TopPanelBar = %TOPPANEL
@onready var mid_text : InfoPopupMidText = %MIDTEXT
@onready var vscrollbar : VBoxScrollBar = %VBOXSCROLLBAR

@onready var animation_in : AnimateMenuScaleIn = %AnimateMenuScaleIn #Tween

var text_as_bbcode : String
var title_as_string : String

signal closed


func init(title_ : String, text_ : String):
	title_as_string = title_
	text_as_bbcode = text_
	
func _ready() -> void:
	self.ready.connect(on_ready)
	top_panel.closed.connect(on_close)
	
	#self.tree_exited.connect(Signals.deactivated_dialog_lock.emit)	
	#Signals.activated_dialog_lock.emit()
	
	animation_in.offset_pivot = get_global_mouse_position() #TODO??
	
	if title_as_string != null and title_as_string != "":
		top_panel.set_title(title_as_string)
	if text_as_bbcode != null and title_as_string != "":
		set_text(text_as_bbcode)
	
func on_ready():
	mid_text.setup.call_deferred(vscrollbar)
	mid_text.resize.call_deferred()
	
	animation_in.animate()
	Signals.play_sound.emit(RESOURCES.SOUND_FLICK_IN)
	
func on_close():
	#Closes the popup if it has to be closed	
	if true:
		queue_free()
		closed.emit()
	
func set_text(content : String) -> void:
	
	if is_instance_valid(mid_text):
		mid_text.text = "" # NO_TRANSLATE
		mid_text.text = content
	pass
	
func get_text() -> String:
	if is_instance_valid(mid_text): return mid_text.text
	else: return ""
