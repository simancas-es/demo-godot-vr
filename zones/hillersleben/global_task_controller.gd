extends Node

## Directs the flow of the tasks
## Strategy here is: This controller has a reference to all task sequencers in the zone.
## The sequencers are initially deactivated, but on fulfilling the specific requirements,
## they are activated by this controller. 
## TODO: Sequence consumers are to not activate the sequencers. They must consume only the signals.
## On fulfilling requirements, Sequencers are activated, and with them the first task, etc.

## In case that there could be more than one task that leads to the same place, this should be somehow accounted for.
## Example is: finding wire before findnig fence hole. Or fixing fence before getting fix fence task. TODO:
## The way tasks are calculated should be restructured, so that there is an event-bus of sorts that records
## Which actions need to be taken.




const TASKID = SYSTEMTASKSSETTINGS.UNIT_ID

#Requirements before we allow other task sequences to start.
const req_vorstellung : Array[TASKID] = []
#const req_security : Array[TASKID] = [TASKID.Q_HL_SEE_GASSPEICHER] #Dropped because its almost a duplicate
const req_fence : Array[TASKID] = [TASKID.Q_HL_SECURITYCHECK_ALL]
const req_temperature : Array[TASKID] = [TASKID.Q_HL_FIXFENCE]
const req_dekanter : Array[TASKID] = [TASKID.Q_HL_BHKW_HITEMP]
const req_nh4 : Array[TASKID] = [TASKID.Q_HL_DEKFOERDERBAND_SPILL, TASKID.Q_HL_DEKFOERDERBAND_ENTLEEREN]
const req_nkb : Array[TASKID] = []#[TASKID.Q_HL_SEE_GASSPEICHER]

const CONSUMER := preload("uid://cjrqcfgi4v8xn")

## CONSUMERS - TASKS
#HACK. TODO: make baseclass or ability
@onready var consumer_vorstellung : CONSUMER = $"../Q_VORSTELLUNG/Sequencer_consumer_vorstellung"
@onready var consumer_security : CONSUMER = $"../SECURITY_CHECKS/Sequencer_consumer"
@onready var consumer_fence : CONSUMER = $"../Q_FENCE_CHECK"
@onready var consumer_bhkwtemp_high : CONSUMER = $"../Q_BHKW/Sequence_consumerHigh"
@onready var consumer_bhkwtemp_low : CONSUMER = $"../Q_BHKW/Sequence_consumerLow"
@onready var consumer_dekanter : CONSUMER = $"../Q_MG/Dekanter/DekanterConsumer"
@onready var consumer_nh4 : CONSUMER = $"../Q_BB/bb_consumer"
@onready var consumer_nkb : CONSUMER = $"../Q_NKB"

##Pairs
@onready var pairs : Dictionary[CONSUMER, Array] = {
	consumer_vorstellung : req_vorstellung,
	#consumer_security : req_security, #Dropped because its almost a duplicate
	consumer_fence : req_fence,
	consumer_bhkwtemp_high : req_temperature,
	consumer_dekanter : req_dekanter,
	consumer_nh4 : req_nh4,
	consumer_nkb: req_nkb
	
}

## Periodiclly checks and updates the consumers.
@onready var timer: Timer
func _ready():
	timer = Timer.new()
	timer.wait_time = 5.0
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
func _on_timer_timeout():
	update()
	
	

func update() -> void:
	for key : CONSUMER in pairs.keys():
		if key == null:
			push_error("Key is null!")
			continue
		if key.started : continue
		var all_completed = true
		var manager : SYSTEMTASKS_UIDCLASSREF.SystemTasksManager = key.sequencer.manager
		if manager == null:
			push_error("Missing manager!")
			continue
		for id in pairs[key]:
			if manager.check_task_status(id) != SYSTEMTASKS_UIDCLASSREF.SystemTasksUnit.STATUS.COMPLETED:
				all_completed = false
				break
		if all_completed:
			key.start()
	
	
	
