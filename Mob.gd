extends Area2D
# This is for controlling the mob as an entity. NPCs in turn interact with this mob.

signal mob_started_movement
signal mob_stopped_movement

# Steering vars.
export var max_speed := 60
export var slow_radius := 15
var _velocity := Vector2.ZERO
const DISTANCE_THRESHOLD := 6

var target_position: Vector2
var track_cursor := false

# Stats holder for the mob.
var stats = {"speed": 50}

# List of npcs that makes up the mob? 
var members = []

# NPCs that enter $chant_ring will be in this, neutral, enemy, mob units, all of them in this list
var npcs_in_proximity = []

# NOT USED
# State of mob. 
var state = "idle"

func _ready():
	$chant_ring.connect("body_entered", self, "_on_body_entered_chant_ring")
	$chant_ring.connect("body_exited", self, "_on_body_exited_chant_ring")


# MOVEMENT (might be best to move to physics?)
func _process(delta):
	if track_cursor:
		target_position = get_global_mouse_position()
	var dist = global_position.distance_to(target_position)
	
	if dist < DISTANCE_THRESHOLD:
		emit_signal("mob_stopped_movement")
		return
	
	_velocity = Steering.arrive_to(
		_velocity,
		global_position,
		target_position,
		max_speed,
		slow_radius)
	
	self.position += _velocity * delta


func _unhandled_input(event):
	# Mouse steering.
	if event is InputEventMouseButton:
		if event.is_action_pressed("click"): # Follow cursor.
			track_cursor = true
			set_process(true)
			emit_signal("mob_started_movement")
		if event.is_action_released("click"): # Reach click point.
			# A target object may be placed on map upon mouse release.
			track_cursor = false
			target_position = get_global_mouse_position() # GUI will add target on objective.
			set_process(true)


# Currently chants to all npcs within outer ring area.
func chant(message):
	for n in range(npcs_in_proximity.size()):
		npcs_in_proximity[n].chant(message)


func gain_member(npc):
	members.append(npc)
	# warning-ignore-all:return_value_discarded 
	#some errors going on with this
#	connect("mob_started_movement", npc, "_follow_mob")
#	connect("mob_stopped_movement", npc, "_unfollow_mob")
#	print("Mob has %s members" % [members.size()])


func lose_member(npc):
	#some errors going on with this
#	disconnect("mob_started_movement", npc, "_follow_mob")
#	disconnect("mob_stopped_movement", npc, "_unfollow_mob")
	members.erase(npc)


# NOT USED YET
# Changes the mobs state and acts accordingly.
func change_state(new_state):
	if state == "idle":
		pass


# NOT USED YET
# Trigger a npc to execute a random action?
func trigger_npc_action():
	pass


func _on_body_entered_chant_ring(body):
	if not npcs_in_proximity.has(body):
		npcs_in_proximity.append(body)


func _on_body_exited_chant_ring(body):
	if npcs_in_proximity.has(body):
		npcs_in_proximity.remove(npcs_in_proximity.find(body))
