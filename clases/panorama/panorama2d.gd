class_name PanoramaData extends Node2D

#Class that stores information about the 360x180º panoramas.
#The information is extracted from PanoramaInformationPolygon objects
#	Each area belongs to an area of interest. They must have no rotations 
#	and no scaling or anything. The anchor is at the center of the axis or
#	the upper left corner of the picture. These polygons have in them a 
#	JSON file with all translations that should be stored separatedly.
#	The north point is given by a Node2D object placed at the vertical
#	where the north is located. It is assumed that the vertical is perpendicular
#	to the horizon and that the image is centered.
#	The panorama has to be a TextureRect with a Compressed Image
#	The polygons are subdivided whenever this object loads. This is because
#	we are mapping the 2D space onto a sphere for interaction, and we run
#	into numerical issues due to the haphazard algorithm that we are using.
#	The preferred entry depending on the previous scene can also be specified.
#	If it is not specified then it uses the current player orientation as usual.

#	How to use: Just load the Panorama2D scene and create variations of it.
#	The PanoramaData object must then be described in the ROOMs file.
#	With an unique ID and the SCENE tscn file

@export var name_id : String = "Name"
@export var room_id : ROOMS.ID #Remember to add to the ROOMS file
@export var north_vertical : Node2D
@export var textureRect : TextureRect
@export var entry_focus : Dictionary[ROOMS.ID, Node2D]

#@onready var textureRect : TextureRect = $TextureRect
@onready var polygons : Array[PanoramaInformationPolygon]

#var icon_collection : Array[UI_ICON] = [] #TODO UI_360_ICONS

var texture_img : Texture2D
var L : int #y size
var W : int #x size

#var cut_polygons : Array[PanoramaInformationPolygon]
var MAX_ANGLE_FACTOR  : float = 7.0/360.0 #max xº angles for the whole width
##TODO Use a dynamic angle factor for each polygon width

func _ready() -> void:
	pass

func extract() -> PanoramaData:
	texture_img = $TextureRect.texture
	L = texture_img.get_height()#get_size().y
	W = texture_img.get_width()#get_size().x
	var min_cut_size = max(floori(W*MAX_ANGLE_FACTOR),10) #Provisional
	push_warning("PanoramaData class using a provisional min_cut_size")
	var p : PanoramaInformationPolygon
	
	##TODO Use different grids depending on polygon size for better resolution
	var grid = generate_grid(0, W, 0, L , min_cut_size)
	#var icons : Array[UI_ICON]
	for c in get_children():
		if c is PanoramaInformationPolygon:
			c.init()
			p = c
			if p.active:
				polygons.append(c)
				#icons = p.icons
				p.subdivide_itself(grid)
				
	visible = false

	return self


	
func generate_grid(minx : int, maxx : int, miny : int, maxy : int, size_px : int) -> Array[PackedVector2Array]:
	var grid : Array[PackedVector2Array] = []
	
	#var sections
	var x_w : Array[int]
	var x : int = minx
	while x < maxx:
		x_w.append(x)
		x += size_px
	var y_w : Array[int]
	var y : int = miny
	while y < maxy:
		y_w.append(y)
		y += size_px
		
	grid.resize((x_w.size()-0) * (y_w.size()-0))
	
	#Generate the polygons from the grid. Clockwise 1-2-3-4 for each 4 vertex
	#rowwise: increments y dimension from 0 to size-2
	var xsize = x_w.size()
	var ysize = y_w.size()
	var i : int = 0
	var np : PackedVector2Array
	for xl in range(xsize-1):
		for yl in range(ysize-1):
			np = PackedVector2Array([
										Vector2(x_w[xl], y_w[yl]), #Clockwise
										Vector2(x_w[xl+1], y_w[yl]),
										Vector2(x_w[xl+1], y_w[yl+1]),
										Vector2(x_w[xl], y_w[yl+1])
			])
			grid[i] = np
			i += 1
	
	return grid	
	

func get_cubemap() -> Cubemap:
	var cm = UTILS.create_cubemap_from_texture(texture_img)
	return cm
