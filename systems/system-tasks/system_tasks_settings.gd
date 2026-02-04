extends Node
class_name SYSTEMTASKSSETTINGS
const SystemTasksCondition := SYSTEMTASKS_UIDCLASSREF.SystemTasksCondition
const SystemTasksResult := SYSTEMTASKS_UIDCLASSREF.SystemTasksResult

#Condition type for json.
static func get_conditions_class(name_class : String) -> Script:# HACK: Typed Scripts not available
	match name_class:
		"SystemTasksConditionExisting":
			return SYSTEMTASKS_UIDCLASSREF.SystemTasksConditionExisting
		"SystemTasksConditionFinishedTask":
			return SYSTEMTASKS_UIDCLASSREF.SystemTasksConditionFinishedTask
		"SystemTasksConditionSignal":
			return SYSTEMTASKS_UIDCLASSREF.SystemTasksConditionSignal
		"SystemTasksConditionLocation":
			return SYSTEMTASKS_UIDCLASSREF.SystemTasksConditionLocation
	push_error("Forgot to add the class %s to the SYSTEMTASKSSETTINGS!!!")
	return null

#Result type for json.
static func get_results_class(name_class : String) -> Script: # HACK: Typed Scripts not available
	match name_class:
		"SystemTasksResultPrint":
			return SYSTEMTASKS_UIDCLASSREF.SystemTasksResultPrint
		"SystemTasksResultGiveItem":
				
			return SYSTEMTASKS_UIDCLASSREF.SystemTasksResultGiveItem
		#CUSTOM
		"SystemTasksResultUIPrint":
			return HELPREF.SystemTasksResultUIPrint
	return null
	

const AUTOLOAD_TASKMANAGER := "SYSTEMTASKS_AUTOLOAD_MANAGER"
const BASE_LOCATOR_GROUP := "SYSTEMTASKS_DEFAULT" #Locators will go to this group on creation. Never use this for the task units!
const BASE_COND_SIGNAL_GROUP := "SYSTEMTASKS_COND_SIGNAL_DEFAULT"
const TICK_FREQUENCY_S := 2.0 #Update frequency of the conditions as a default


#Global static values for the tasks system
#Ids used to track active quests
enum UNIT_ID {
	UNKNOWN = -1,
	TESTID_0,
	TESTID_1,
	TESTID_2,
	
	#CUSTOM
	Q_DEMO_AERATOR
}


#Ids for specific locator IDs, only for special objects
enum LOCATOR_ID {
	NO_ID,
	PLAYER,
	DEFAULT0,
	DEFAULT1,
	
	#CUSTOM
	DEMO_AERATOR
	
}

#Group names for locators
enum LOCATOR_GROUP {
	SYSTEMTASKS_UNGROUPED,
	SYSTEMTASKS_PLAYER,
	SYSTEMTASKS_DEFAULT1,
}
