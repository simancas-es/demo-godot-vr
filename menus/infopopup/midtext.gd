extends RichTextLabel
class_name InfoPopupMidText

#For this particular Bbcode Object, the youtube strings must be coded as:
##url = youtube:code , because we will be reading youtube: as an indicator

var scrollbar : VScrollBar
#@onready var scrollbar_component : VBoxScrollBar = %VBOXSCROLLBAR

func _ready() -> void:
	meta_clicked.connect(on_meta_clicked)
	pass # Replace with function body.0

func setup(scrollbar_ : VBoxScrollBar):
	scrollbar = scrollbar_.scroll
	
	scrollbar.min_value = 0
	scrollbar.allow_greater = false
	scrollbar.allow_lesser = false
	
	#TODO: Scroll only works on the secondary scrollbar. Detect mousewheel here.
	scrollbar.value_changed.connect(on_scrolling)
	get_tree().get_root().size_changed.connect(resize) 
	#
	resize()

func resize():
	#Resize the scroll bar after loading the whole mini window so that
	#the wrapping is consistent.
	if scrollbar == null:
		push_error("Missing scrollbar in InfoPopup.")
	else:
		scrollbar.max_value = get_line_count() - get_visible_line_count() + 1 +1
		scrollbar.reset_size()
	return
	
func on_scrolling(value : float):
	scroll_to_line(value)

##We want to be able to click links and open youtube vids
func on_meta_clicked(url_string) -> void:
	var parts = url_string.split(":")
	if parts.size() >= 2:
		match parts[0]:
			"youtube": js_launch_video(parts[1])
		
	pass

##Launches a youtube code by using javascript if available.
func js_launch_video(yt_code : String) -> void:
	if JavaScriptBridge:
		var script = "createFloatingYouTubePlayer('%s');" % yt_code
		JavaScriptBridge.eval(script, true)
	else:
		push_warning("Javascript interface not available!")
