@tool
class_name PanoramaInformationPolygon extends Polygon2D

#Stores information about regions in the picture.
@export_file("*.json") var filepath_information : String
var information : Dictionary
@export_tool_button("Generate Info Template!") var gen_json_action =  _gen_json


@export var active : bool = true
@export var highlight_hover : bool = false

 ##TODO BITMASK. But there doesnt seem to be a way to do this cleanly...
@export var topic : TOPICS.LAYER = TOPICS.LAYER.ABWASSER


var subdivision : Array = []
var icons : Array[UI_ICON] = []
var texts : Array[UI_TEXT3D] = []
var albedocolor : Color

#This represents a door getting the Player into another Panorama.
#It allows the transition between panoramas when activated.
#Information injected into the information parameter 
@export var is_door : bool = false # is this a door to somewhere
@export var door_to : ROOMS.ID = 0 #-1 means its not a door
#TODO: Danger: it could lead to the user loading rooms outside of the environment...
#TODO: Remove concave shapes and turn them into convex

##Utility to generate a JSON file with the template.
func _gen_json() -> void: 
	var path = get_tree().edited_scene_root.scene_file_path.get_base_dir() + "/" + name + ".json"
	##TODO BUG / might break depending on the OS.
	Signals.request_editor_file_json.emit(path, self)
	return


func _ready() -> void:
	pass

func init() -> void:
	#Getting the text information
	if (filepath_information == "") or not FileAccess.file_exists(filepath_information):
		filepath_information = RESOURCES.INFORMATION_TEMPLATE
	
	if FileAccess.file_exists(filepath_information):
		var data = FileAccess.open(filepath_information, FileAccess.READ)
		var parsed = JSON.parse_string(data.get_as_text())
		if not (parsed is Dictionary): push_error("Bad JSON! %s" % filepath_information)
		information = parsed
			
	
	#Get icons and text
	for c in get_children():
		if c is UI_ICON:
			c.init()
			if not c.visible: continue
			icons.append(c)
		elif c is UI_TEXT3D:
			if not c.visible: continue
			texts.append(c)
	
	subdivision = self.polygon ##Initialization
	self.albedocolor = color

func subdivide_itself(grid : Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	self.subdivision = cut_polygon(self, grid)
	return self.subdivision

##Gets a polygon and cuts it in square sizes of the chosen width.
##A grid is a collection of shapes
##Returns an Array with all the pieces
##Horrid performance		
static func cut_polygon(poly : PanoramaInformationPolygon, grid : Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	var result : Array [PackedVector2Array] = []
	var points : PackedVector2Array = poly.polygon #Ordered Points
	#Get intersections
	var intersect : Array[PackedVector2Array]
	for square : PackedVector2Array in grid:
		intersect = Geometry2D.intersect_polygons(points, square)
		if !intersect.is_empty() :
			#for shape in intersect:
			result.append_array(intersect)	#clockwise/anticlockwise for holes
	return result
