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
	Q_DEMO_AERATOR,

	#Hillersleben
	Q_HL_SECURITYCHECK_ALL,
	Q_HL_SECURITYCHECK1,
	Q_HL_SECURITYCHECK2,
	Q_HL_SECURITYCHECK3,
	Q_HL_SECURITYCHECK4,
	Q_HL_SECURITYCHECK5,
	Q_HL_SECURITYCHECK6,
	
	#Fence
	Q_HL_FINDWIRE,
	Q_HL_FINDHOLE,
	Q_HL_REPAIRWIRE,
	Q_HL_FIXFENCE,
	
	#--Batch1
	#Vorstellung: player will go aronud the plant as an introduction.
	Q_HL_SEE_RECHEN,
	Q_HL_SEE_FETTFANG,
	Q_HL_SEE_VKB,
	Q_HL_SEE_BB,
	Q_HL_SEE_NKB,
	Q_HL_SEE_RAD,
	Q_HL_SEE_VED,
	Q_HL_SEE_ENTWAESSERUNG,
	Q_HL_SEE_FAULUNG,
	Q_HL_SEE_GASMESSRAUM,
	Q_HL_SEE_BHKW,
	Q_HL_SEE_GASSPEICHER,
	
	#Schlammheizung: mesophilic range
	Q_HL_BHKW_HITEMP, #Schlamm reaching 39,7+
	Q_HL_BHKW_LOTEMP, #Schlamm going 37,8-
	
	#Dekanter
	Q_HL_DEKFOERDERBAND_ENTLEEREN, # 30 Minuten abwarten
	Q_HL_DEKFOERDERBAND_SPILL, # Schlamm nicht entwässert, polymer fehlt
	
	#BB
	Q_HL_NH4_HIGH_BELUEFTET, #Falsche Einstellung
	
	#EIS
	Q_HL_NKB_SCHNECKE_EIS, #Manual operation, ice breaking
	Q_HL_BRAUCHWASSER_EIS, #Close water, empty hoses and pipes
	
	
}


#Ids for specific locator IDs, only for special objects
enum LOCATOR_ID {
	NO_ID,
	PLAYER,
	DEFAULT0,
	DEFAULT1,
	
	#CUSTOM
	DEMO_AERATOR,
	
	#----Hillersleben
	#Daily inspection
	HL_SECURITYCHECK1,
	HL_SECURITYCHECK2,
	HL_SECURITYCHECK3,
	HL_SECURITYCHECK4,
	HL_SECURITYCHECK5,
	HL_SECURITYCHECK6,
	
	#Fence
	HL_FENCE,
	
	
	#Batch1,
	HL_SEE_RECHEN,
	HL_SEE_FETTFANG,
	HL_SEE_VKB,
	HL_SEE_BB,
	HL_SEE_NKB,
	HL_SEE_RAD,
	HL_SEE_VED,
	HL_SEE_ENTWAESSERUNG,
	HL_SEE_FAULUNG,
	HL_SEE_GASMESSRAUM,
	HL_SEE_BHKW,
	HL_SEE_GASSPEICHER,
	
	#Schlammheizung: mesophilic range
	HL_BHKW_HITEMP, #Schlamm reaching 39,7+
	HL_BHKW_LOTEMP, #Schlamm going 37,8-
	
	#Dekanter
	HL_DEKFOERDERBAND_ENTLEEREN, # 30 Minuten abwarten
	HL_DEKFOERDERBAND_SPILL, # Schlamm nicht entwässert, polymer fehlt
	
	#BB
	HL_NH4_HIGH_BELUEFTET, #Falsche Einstellung
	
	#EIS
	HL_NKB_SCHNECKE_EIS, #Manual operation, ice breaking
	HL_BRAUCHWASSER_EIS, #Close water, empty hoses and pipes
	
}

#Group names for locators
enum LOCATOR_GROUP {
	SYSTEMTASKS_UNGROUPED,
	SYSTEMTASKS_PLAYER,
	SYSTEMTASKS_DEFAULT1,
}
