extends Node
class_name ROOMS

enum ID {NONE,
		DEMO_VISTA,
		FIELD,
		DEMO_VLT3,
			}

const SCENES : Dictionary = {
	ID.DEMO_VISTA : "res://zones/demo_vista/rooms/vista_outside/vista_outside.tscn",
	ID.DEMO_VLT3 : "res://zones/demo_vista/rooms/vista_vlt3/vista_vlt3-inside.tscn"
	}
