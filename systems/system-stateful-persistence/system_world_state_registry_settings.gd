extends Node
class_name SYSTEMSTATEFULPERSISTENCE_SETTINGS

const MANAGER_AUTOLOAD_NAME := "WorldStateManager" #Instantiate the singleton by using ONLY this name, so it can be found.
const BASE_GROUP_IFACES := "PersistentObjectInterfaces"

const SAVE_PATH := "user://SAVES/"

#For use with the SystemWorldStatePersistenceZone
enum PERSISTENTZONES {
	UNKNOWN = 0,
	DEFAULT = 1,
	DEMO_OBSERVATORY = 2,
	
	
}
