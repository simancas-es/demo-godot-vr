@tool
extends "res://XR/scenes/interactables/objects/item_pickable.gd"

const SAMPLER_AREA := preload("uid://da5ajj1xsgk0e")
@onready var area_beaker : Area3D = $Area3D_Beaker

var current_sample : String = ""
@onready var liquid : MeshInstance3D = $BeakerSampler/Liquid

func _ready():
	super()
	if Engine.is_editor_hint():
		return
	area_beaker.touched_water.connect(_on_water_enter)
	area_beaker.area_entered.connect(_on_area_entered) #Area of tip of beaker
	clear()

func _on_area_entered(area: Node3D) -> void:
	if is_instance_of(area, InteractionWithInventorySlotSelected): #HACK
		if (current_sample == "vkb") and area.reaction_id == INVENTORYSETTINGS.ID.SAMPLE_VKB:
			area.validated_item_interaction.emit()
			clear()
		elif (current_sample == "bb") and area.reaction_id == INVENTORYSETTINGS.ID.SAMPLE_BB:
			area.validated_item_interaction.emit()
			clear()
		elif (current_sample == "msb") and area.reaction_id == INVENTORYSETTINGS.ID.SAMPLE_MSB:
			area.validated_item_interaction.emit()
			clear()
		elif (current_sample == "nkb") and area.reaction_id == INVENTORYSETTINGS.ID.SAMPLE_NKB:
			area.validated_item_interaction.emit()
			clear()
		
	pass

func clear() -> void:
	liquid.visible = false
	current_sample = ""

func _on_water_enter(type : String) -> void:
	var mat : StandardMaterial3D = liquid.get_active_material(0)
	match type:
		"vkb":
			current_sample = "vkb"
			if mat: mat.albedo_color = Color(0.639, 0.286, 0.643, 1.0)
			liquid.visible = true
			pass
		
		"bb":
			current_sample = "bb"
			if mat: mat.albedo_color = Color(0.439, 0.573, 0.745, 1.0)
			liquid.visible = true
			pass
		
		"msb":
			current_sample = "msb"
			if mat: mat.albedo_color = Color(0.439, 0.573, 0.745, 1.0)
			liquid.visible = true
			pass
		
		"nkb":
			current_sample = "nkb"
			if mat: mat.albedo_color = Color(0.6, 0.851, 0.918, 1.0)
			liquid.visible = true
			pass
		"clear":
			clear()
		
	pass
