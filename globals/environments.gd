extends Node
class_name ENVIRONMENTS

#3D Environments. An environment can have more than one ROOM.ID.
#Each Environment can have a different camera and controls.
#When exiting from a ROOM ID, active environment looks for the 3D position

enum ID {HOCHSCHULE,
		GERWISCH,
		OBSERVATORY,
		HILLERSLEBEN
		
			}

##Make sure that KEYs match
##ZoneInformation Resource files
const ZONEINFORMATION : Dictionary = {
	ID.HOCHSCHULE : "res://zones/hochschule/zonehochschule.tres",
	ID.GERWISCH : "res://zones/gerwisch/zonegerwisch.tres",
	ID.OBSERVATORY : "res://zones/demo_vista/zoneobservatorio.tres",
	ID.HILLERSLEBEN : "res://zones/hillersleben/zonehillersleben.tres"
	}
