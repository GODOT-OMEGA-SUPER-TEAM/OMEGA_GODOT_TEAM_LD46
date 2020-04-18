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
export var stats = {
	"speed" : 100,
	"type" : Type.PAWN,
	"in_mob" : false,
	"commitment" : 0 #0 not committed 100 fully commited
}

# Current velocity of the NPC, used to move the NPC during _physics_process.
# To manually move the NPC, set this instead of calling a move function directly.
var velocity = Vector2.ZERO

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
	move_and_slide(velocity)


func _process(_delta):
	if stats.in_mob:
		velocity = (get_mob().position - position).normalized() * stats["speed"]


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
	pass

# Call to make the NPC join the mob.
func join_mob():
	#Global.get_mob().gain_member(self);
	stats.in_mob = true


# Call to make the NPC leave the mob.
func leave_mob():
	stats.in_mob = false


func start_move():
	$WaitTimer.wait_time = rand_range(0.0, 2.0)
	if stats.in_mob:
		return
	# Start moving the NPC in a random cardinal direction.
	# This could be easily changed to moving in a completely random direction if preferred.
	var dir = int(rand_range(0, 4))
	velocity = polar2cartesian(stats["speed"], dir * (TAU / 4))


func stop_move():
	$MoveTimer.wait_time = rand_range(0.0, 2.0)
	# Stop moving the NPC.
	velocity = Vector2.ZERO


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
