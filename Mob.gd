extends Area2D
# This is for controlling the mob as an entity. NPCs in turn interact with this mob.

signal mob_started_movement
signal mob_stopped_movement

# Steering vars.
export var max_speed := 120.0
export var slow_radius := 30.0
var _velocity := Vector2.ZERO
const DISTANCE_THRESHOLD := 3.0

var target_position: Vector2
var track_cursor := false

# Stats holder for the mob.
var stats = {"speed": 100}

# List of npcs that makes up the mob? 
var members = []

# State of mob.
var state = "idle"

func _ready():
	set_process(false)

# MOVEMENT 

func _unhandled_input(event):
	# Mouse steering.
	if event is InputEventMouseButton:
		if event.pressed: #follow cursor.
			track_cursor = true
			set_process(true)
			emit_signal("mob_started_movement")
		if event.is_action_released('click'): # Reach click point.
			# A target object may be placed on map upon mouse release.
			track_cursor = false
			target_position = get_global_mouse_position() # GUI will add target on objective.
			set_process(true)
	
	if event.is_action_pressed("secondary_click"): #just for test
		chant('Join the protest') #message should bring some info to make the NPC decide


func _process(delta):
	if track_cursor:
		target_position = get_global_mouse_position()
	var dist = global_position.distance_to(target_position)
	
	if dist < DISTANCE_THRESHOLD:
		set_process(false)
		emit_signal("mob_stopped_movement")
		return
	
	_velocity = Steering.arrive_to(
		_velocity,
		global_position,
		target_position,
		max_speed,
		slow_radius)
	
	self.position += _velocity * delta
	#print(self.position)
	
# GROUP

func chant(message):
	var nearby_bodies = $OuterArea.get_overlapping_bodies()
	for body in nearby_bodies:
		if body.is_in_group("npc"):
			body.react(message, self)
	# For npc in bodies in ChantArea call.
	pass

func gain_member(npc):
	members.append(npc)
	connect("mob_started_movement", npc, "_follow_mob")
	connect("mob_stopped_movement", npc, "_unfollow_mob")
	print("Mob has %s members" % [members.size()])


func lose_member(npc):
	#remove from array
	disconnect("mob_started_movement", npc, "_follow_mob")
	disconnect("mob_stopped_movement", npc, "_unfollow_mob")
	pass


# Changes the mobs state and acts accordingly.
func change_state(new_state):
	if state == "idle":
		pass
	pass


# Trigger a npc to execute a random action?
func trigger_npc_action():
	pass
