class_name NPC
extends KinematicBody2D

var Slogan = [
	"Eggs", #placeholder
	"Milk",
	"Bread"
]

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
	# Define stats for each?
}

# Dictionary for any stats that may vary from NPC to NPC.
var in_mob = false
export var stats = {
	"speed" : 100,
	"type" : Type.PAWN,
	"commitment" : 0 #0 not committed 100 fully commited
}

# Current velocity of the NPC, used to move the NPC during _physics_process.
# To manually move the NPC, set this instead of calling a move function directly.
var velocity = Vector2.ZERO
var target = Vector2.ZERO
var roam_radius = 80.0
var slow_radius = 15.0

func _ready():
	# Random number generation will always result in the same values each
	# time the script is restarted, unless we call this function to
	# generate a time-based seed.
	randomize()
	#generate random slogans that the npc will react to
	stats.trigger_slogans = [Slogan[randi()%len(Slogan)-1], Slogan[randi()%len(Slogan)-1]]
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
	if stats.type == Type.INSTIGATOR:
		stats.commitment = 100
		join_mob();

func _physics_process(_delta):
	# Move the NPC by whatever the velocity was set to in other functions.
	
	if in_mob:
		target = get_mob().global_position
		
	velocity = Steering.arrive_to(
		velocity,
		global_position,
		target,
		stats.speed) #add mass for dragging
	
	move_and_slide(velocity)


func _process(_delta):
	pass

func _follow_mob():
	print("NPC moves")
	set_physics_process(true)

func _unfollow_mob():
	#check in which range it is, it may wander in a given radius
	print("NPC stopped")
	#do not stop immediately, try to reach inner circle (need radius)
	set_physics_process(false)

func get_mob():
	var mob = get_node("../Mob")
	return mob

#should only be called if stats.in_mob false
func react(message, mob):
	if stats.trigger_slogans.find(message):
		stats.commitment += 1
	if stats.commitment > 10:
		join_mob()
	# Receive message from chant and decide if joining mob.
	#mock code to join always and test following
	join_mob()
	pass

# Call to make the NPC join the mob.
func join_mob():
	#Global.get_mob().gain_member(self);
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
	var random_angle = randf() * 2 * PI
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
