extends PanelContainer
#class_name InventoryInspectTextPanel
const InventoryObjectInformation := INVENTORY_UIDCLASSREF.InventoryObjectInformation

@onready var desc : RichTextLabel = %InspectDescBot
@onready var name_object : Label = %InspectNameTop

func _ready() -> void:
	clear_texts()
	
func init(info : InventoryObjectInformation):
	if info == null: clear_texts(); return
	
	var locale = TranslationServer.get_locale()
	var info_texts = info.inspect_translations
	if not locale in info_texts:
		locale = "en"
	if not "en" in info_texts: return
	desc.text = info_texts[locale]["description"]
	name_object.text = info_texts[locale]["name"]

func clear_texts() -> void:
	desc.text = ""#NO_TRANSLATE
	name_object.text = ""#NO_TRANSLATE
