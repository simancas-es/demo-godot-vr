extends Node
#class_name SystemTasksUnit
const SystemTasksCondition := SYSTEMTASKS_UIDCLASSREF.SystemTasksCondition
const SystemTasksResult := SYSTEMTASKS_UIDCLASSREF.SystemTasksResult

const SystemTasksUnit := SYSTEMTASKS_UIDCLASSREF.SystemTasksUnit

signal finished(sender : SystemTasksUnit)
#Represents a task unit.
#A task unit has:
#a description
#some conditions to consider it fulfilled
#some results after the conditions have been fulfilled
#some conditions to consider it failed
#some results after it has failed
#
#Conditions can also be other task units that are successful.
#It can happen that a condition can not be fullfilled anymore,
#in this case the task is considered failed.

#TODO: Success/Fail is a dual system, but failing is really succeeding at something else.

@export var unit_id := SYSTEMTASKSSETTINGS.UNIT_ID.UNKNOWN


#ALL/Any reflects order
var success_conditions_all : Array[SystemTasksCondition] = []
var success_conditions_any : Array[SystemTasksCondition] = []
var success_results : Array[SystemTasksResult] = []

var fail_conditions_all : Array[SystemTasksCondition] = []
var fail_conditions_any : Array[SystemTasksCondition] = []
var fail_results : Array[SystemTasksResult] = []

var scall : int
var scany : int
var fcall : int
var fcany : int

#TODO
#var ordered_conditions_success: bool = false #Do the conditions have to happen in order?
#var ordered_conditions_fail: bool = false #


enum STATUS {UNINITIATED, IN_PROGRESS, FAILED, COMPLETED}
var status : STATUS = STATUS.UNINITIATED
var results_executed : bool = false


func initialize_conditions() -> void:
	for c in success_conditions_all + success_conditions_any + fail_conditions_all + fail_conditions_any:
		add_child(c)
		c.fulfilled.connect(update_status)
	for r in success_results + fail_results:
		add_child(r)
		
	scall = len(success_conditions_all)
	scany = len(success_conditions_any)
	fcall = len(fail_conditions_all)
	fcany = len(fail_conditions_any)
	
	#start() #Manually start, since some will be inactive on load
		
	
func start() -> void:
	status = STATUS.IN_PROGRESS
func cancel() -> void:
	status = STATUS.UNINITIATED #Not technically a failure

func update_status() -> void:
	if status != STATUS.IN_PROGRESS : return #Ignore other states
	
	var s_any : bool = true
	var s_all : bool = true
	var f_any : bool = true
	var f_all : bool = true
	
	if (scany + scall) >0:
		if scany>0:
			s_any = false
			#ANY groups require only one of them for the results
			for cond in success_conditions_any:
				if cond.is_fulfilled():
					s_any = true
					break
		
		if scall>0:
			#ALL of them require all of them for the results.
			for cond in success_conditions_all:
				if not cond.is_fulfilled():
					s_all = false
					break
					
		if s_any && s_all:
			status = STATUS.COMPLETED	
			activate_results()	
			return
			
					
		
					
	if (fcany + fcall) >0:	
		if fcany>0:
			f_any = false
			for cond in fail_conditions_any:
				if cond.is_fulfilled():
					f_any = true
					break
					
		if fcall>0:
			for cond in fail_conditions_all:
				if not cond.is_fulfilled():
					f_all = false
					break
	
		if f_any && f_all: #Return priority to failure.
			status = STATUS.FAILED	
			activate_results()		
			return
	
	

func activate_results() -> void:
	if results_executed:	return
	var results_completed = true
	match status:
		STATUS.FAILED:
			for r in fail_results:
				results_completed = results_completed && r.run()
				results_executed = results_completed
		STATUS.COMPLETED:
			for r in success_results:
				results_completed = results_completed && r.run()
				results_executed = results_completed
	if results_executed:
		finished.emit(self)
	
