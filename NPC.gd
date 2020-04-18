class_name NPC
extends KinematicBody2D

enum Type {
	INSTIGATOR,
	PAWN,
	DEMIHUMAN, # Can break down barricades.
	CLERIC, # Increase mob cohesion.
	ELF, # Increase mob agility.
	ALCHEMIST, # Ability to buff speed.
	SORCERER, # Wall spell to block knights.
	# Wizard(male) witch(female) sorcerer(agnostic)
	# Keep types agnostic
}

var Slogan = [
	"Eggs", #placeholder
	"Milk",
	"Bread"
]

var type_stats = {
	Type.INSTIGATOR : {"speed" : 100, "commitment" : 100, "in_mob" : true},
	Type.PAWN : {"speed" : 50},
	Type.DEMIHUMAN : {"speed" : 100},
	Type.CLERIC : {"speed" : 100},
	Type.ELF : {"speed" : 100},
	Type.ALCHEMIST : {"speed" : 100},
	Type.SORCERER : {"speed" : 100},
}

var in_mob = false
var speed = 100
var type = Type.PAWN
var commitment = 0
var trigger_slogans = []

# Dictionary for any stats that may vary from NPC to NPC.
var stats = {}

# Current velocity of the NPC, used to move the NPC during _physics_process.
# To manually move the NPC, set this instead of calling a move function directly.
var velocity = Vector2.ZERO
var target = Vector2.ZERO

var roam_radius = 150
var slow_radius = 15
var arrive_distance = 70
var follow = false


func _ready():
	# Random number generation will always result in the same values each
	# time the script is restarted, unless we call this function to
	# generate a time-based seed.
	randomize()
	# Generate random slogans that the npc will react to.
	trigger_slogans = [Slogan[randi() % len(Slogan) - 1], Slogan[randi() % len(Slogan) - 1]]
	# When MoveTimer is triggered, the NPC should start moving.
	# warning-ignore-all:return_value_discarded
	$MoveTimer.connect("timeout", self, "start_move")
	# When WaitTimer is triggered, the NPC should stop moving.
	$WaitTimer.connect("timeout", self, "stop_move")
	# Each timer should start the other so the NPC alternates between moving and standing still.
	$MoveTimer.connect("timeout", $WaitTimer, "start")
	$WaitTimer.connect("timeout", $MoveTimer, "start")

	# Randomise the timers.
	$MoveTimer.wait_time = rand_range(0.0, 2.0)
	$WaitTimer.wait_time = rand_range(0.0, 2.0)

	# Set states for type overriding defaults.
	set_stats(type_stats[type])


# Move the NPC by whatever the velocity was set to in other functions.
func _physics_process(_delta):
	if in_mob:
		target = get_mob().global_position

	velocity = Steering.arrive_to(
		velocity,
		global_position,
		target,
		speed) # Add mass for dragging.

	move_and_slide(velocity)
	if not in_mob:
		return
	
	if global_position.distance_to(target) < arrive_distance and not follow:
		set_physics_process(false)
		# Set up timer and wander when not in_mob or for in_mob but with distance to mob larger than x.


func set_stats(stats):
	for stat in stats:
		self[stat] = stats[stat]


func _follow_mob():
	follow = true
	set_physics_process(true)


func _unfollow_mob():
	# Check in which range it is, it may wander in a given radius.
	follow = false


func get_mob():
	var mob = get_node("../Mob")
	return mob


# Should only be called if in_mob is false.
func react(message, mob):
	if trigger_slogans.find(message):
		commitment += 1
	if commitment > 10:
		join_mob()
	# Receive message from chant and decide if joining mob.
	# Mock code to join always and test following.
	join_mob()


# Call to make the NPC join the mob.
func join_mob():
	#Global.get_mob().gain_member(self);
	if in_mob:
		return

	get_mob().gain_member(self);
	self.in_mob = true


# Call to make the NPC leave the mob.
func leave_mob():
	self.in_mob = false


func start_move():
	$WaitTimer.wait_time = rand_range(0.0, 2.0)
	if self.in_mob:
		return

	randomize()
	var random_angle = randf() * TAU
	randomize()
	var random_radius = (randf() * roam_radius) / 2 + roam_radius / 2
	target = global_position + Vector2(cos(random_angle) * random_radius, sin(random_angle) * random_radius)
	slow_radius = target.distance_to(global_position) / 2
	_physics_process(true)


func stop_move():
	$MoveTimer.wait_time = rand_range(0.0, 2.0)
	_physics_process(false)


# Begin an attack at the specified angle in radians.
func attack_angle(angle):
	$Attack.rotation = angle
	$AnimationPlayer.play("attack")


# Begin an attack in the direction of the specified vector.
# For example, attack_vector(Vector2.RIGHT) begins a right-facing attack.
func attack_vector(direction):
	attack_angle(atan2(direction.y, direction.x))


func buff(buff_range):
	pass
