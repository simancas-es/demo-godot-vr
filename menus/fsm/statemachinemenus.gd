extends Node
class_name StateMachineMenus
#State machine that allows for more than one starting state
#This allows for paralell states, as long as the different
#starting states can't leave their respective group of states

@export var starting_state: StateMenus
var current_state: StateMenus = null
var history : Array = []

signal updated

func _ready():
	#num_states = starting_states.size()
	#current_states.resize(num_states)
	#for state in current_states:
		#history.append([])	
	pass

func update_children(parent : GameRoot):
	for child : StateMenus in get_children() as Array[StateMenus]:
		child.parent = parent
		child.set_process_input(false)
		#signals from states. Assumes that states will not coincide
		#or be duplicated
		child.go_back.connect(self.back)
		child.change_to.connect(self.change_state)
		
func init(parent: GameRoot) -> void:
	#Signals.register_input_processing.emit(self.process_input)
	update_children(parent)	
	#for index in range(num_states):
	change_state(starting_state)
	

func change_state(new_state: StateMenus) -> void:
	#print("Changing state...", current_state, " to ", new_state )
	if current_state != null:
		history.append(current_state)
		current_state.exit() #execute exit as cleanup
	#TODO HISTORY MEGA BUGGED
	current_state = new_state
	current_state.enter()
	#print("history current:", history)
	#print("current state:", current_state)
	updated.emit()

func back():
	#print("back from ", current_state)
	if history.size() == 0: return
	current_state.exit()
	current_state = history.pop_back()
	current_state.enter()
	#print("Change back to " , current_state)

		
#processes the _ functions from the parent. Fill these ones in the states
func process_physics(delta: float) -> void:
	var new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)

func process_input(event: InputEvent) -> void:
	var new_state = await current_state.process_input(event)
	if new_state:
		change_state(new_state)

func process_frame(delta: float) -> void:
	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)

#func _process(delta: float) -> void:
	#print("current :", current_state)
	#print("history : ", history)
