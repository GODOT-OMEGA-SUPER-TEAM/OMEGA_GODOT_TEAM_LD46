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

enum States {
	IDLE,
	RUN
}

const SLOGANS = [
	"Eggs", #placeholder
	"Milk",
	"Bread"
]

# Used to periodically check commitment and decrease if too distant.
export (float) var MOB_MAX_DISTANCE = 120.0 
export (int) var COMMITMENT_LOOSE = -2
# Commitment timer is set in inspector and triggers every 15 seconds.

# It could be even easier if we decide a folder structure that groups in folder based on type.
var texture_paths = {
	Type.PAWN: ["res://Sprites/Characters/generic_var1.png", 
				"res://Sprites/Characters/generic_var2.png", 
				"res://Sprites/Characters/generic_var3.png", 
				"res://Sprites/Characters/generic_var4.png", 
				"res://Sprites/Characters/generic_var5.png",
				"res://Sprites/Characters/generic_var6.png"]
}

var type_stats = {
	Type.INSTIGATOR : {"speed" : 50, "commitment" : 12},
	Type.PAWN : {"speed" : 25},
	Type.DEMIHUMAN : {"speed" : 50},
	Type.CLERIC : {"speed" : 50},
	Type.ELF : {"speed" : 50},
	Type.ALCHEMIST : {"speed" : 50},
	Type.SORCERER : {"speed" : 50},
}

var state = States.IDLE
#var direction = "left" setget set_direction

var type_abilities  = {
	Type.INSTIGATOR : {"title" : "AbilityA", "cooldown" : 5, "texture":""},
	Type.PAWN : {"title" : "Chant", "cooldown" : 5, "texture":""},
	Type.DEMIHUMAN : {"title" : "AbilityC", "cooldown" : 5, "texture":""},
	Type.CLERIC : {"title" : "AbilityD", "cooldown" : 5, "texture":""},
	Type.ELF : {"title" : "AbilityE", "cooldown" : 5, "texture":""},
	Type.ALCHEMIST : {"title" : "AbilityF", "cooldown" : 5, "texture":""},
	Type.SORCERER : {"title" : "AbilityG", "cooldown" : 5, "texture":""},
}

var ability = type_abilities[Type.PAWN]
var in_mob = false
var speed = 25
var type = Type.PAWN setget set_type
var commitment = 0
var trigger_slogans = []
var attack_range = 60

# Dictionary for any stats that may vary from NPC to NPC.
var stats = {}

# Current velocity of the NPC, used to move the NPC during _physics_process.
# To manually move the NPC, set this instead of calling a move function directly.
var velocity = Vector2.ZERO
var target = Vector2.ZERO

var roam_radius = 75
var slow_radius = 5.5
var arrive_distance = 35

var queue_clear_cooldown = 0.0
var mob_pathfinding_queue = []

var chant_relocate_cooldown = 0.0

func _ready():
	# Random number generation will always result in the same values each
	# time the script is restarted, unless we call this function to
	# generate a time-based seed.
	change_state(States.IDLE)
	randomize()
	# Generate random slogans that the npc will react to.
	trigger_slogans = [SLOGANS[randi() % len(SLOGANS) - 1], SLOGANS[randi() % len(SLOGANS) - 1]]
	# Timer for generating new wander positions for non-mob members
	# warning-ignore-all:return_value_discarded
	$WanderTimer.connect("timeout", self, "set_new_roam_target")
	# When the  AttackTimer triggered check for enemeies in range and attack if can.
	$AttackTimer.connect("timeout", self, "_on_attack_timer")
	$Attack.connect("body_entered", self, "_on_body_entered")
	# Each timer should start the other so the NPC alternates between moving and standing still.

	#$MoveTimer.connect("timeout", $WaitTimer, "start")
	#$WaitTimer.connect("timeout", $MoveTimer, "start")

	# Randomise the timers.
	$WanderTimer.wait_time = rand_range(0, 2.0)
	$AttackTimer.wait_time = rand_range(0.0, 2.0)

	$WanderTimer.start()

	# Randomize initial commitment.
	commitment = round(rand_range(-10, 1))
	ability = type_abilities[type]
	# Set states for type overriding defaults.
	set_stats(type_stats[type])
	test_commitment()
	set_new_roam_target()
	#print(type," ", commitment," ", in_mob)


# Move the NPC by whatever the velocity was set to in other functions.
func _physics_process(delta):
	if in_mob:
		chant_relocate_cooldown -= delta
		
		# REPLACE if NPC is already inside mobs' chant_ring, they don't need to move to the exact center!
		# Wander randomly inside the mob's radius if he's near the mob
		if get_mob().npcs_in_proximity.has(self):
			if chant_relocate_cooldown < 0.0:
				target = get_mob().global_position + Vector2(randf() * 500.0 - 250.0, randf() * 500.0 - 250.0)
				chant_relocate_cooldown = 0.5
		# Pathfind to the mob if the npc is far away from it
		else:
			# Clean path nodes that are close to the npc
			while mob_pathfinding_queue.size() and mob_pathfinding_queue[0].distance_squared_to(global_position) < 4 * 4:
				mob_pathfinding_queue.remove(0)
			
			if mob_pathfinding_queue.size():
				target = mob_pathfinding_queue[0]
				#global_position = global_position.move_toward(target, 1.0)
				#move_and_slide((target - global_position).normalized() * 500.0)
				#print(target)
			else:
				mob_pathfinding_queue = get_tree().current_scene.get_simple_path(global_position, get_mob().global_position)
	
	# If the NPC is close to his target, then reset his target
	if target.distance_squared_to(global_position) < 1:
		target = global_position
	
	velocity = Steering.arrive_to(
		velocity,
		global_position,
		target,
		speed) # Add mass for dragging.
	velocity = move_and_slide(velocity)

	#self.direction = Steering.direction_4_way(velocity.angle())
	
	# The char is originally looking to the left
	# So flip him when his velocity is pointing to the right
	$Sprite.flip_h = velocity.x > 0

	if velocity.length() < 0.7:
		change_state(States.IDLE)
	else:
		change_state(States.RUN)

	#move_and_slide((target - global_position).normalized() * 50.0)
	if get_slide_count():
		queue_clear_cooldown = min(queue_clear_cooldown, 0.5)

	if queue_clear_cooldown < 0.0:
		mob_pathfinding_queue.resize(0)
		queue_clear_cooldown = 0.5 + randf() * 0.25

	queue_clear_cooldown -= delta

	# This causes big issues.
	#if global_position.distance_to(target) < arrive_distance and not follow:
		#set_physics_process(false)
		#$MoveTimer.start()
		# Set up timer and wander when not in_mob or for in_mob but with distance to mob larger than x.


func _process(_delta):
	$Label.text = str(commitment)
	if in_mob:
		$TempSprite.default_color = Color(.2, .9, .2)
	else:
		$TempSprite.default_color = Color(.2, .2, .2)


func set_stats(new_stats):
	for stat in new_stats:
		self[stat] = new_stats[stat]


func change_state(new_state):
	if new_state == state:
		return
	state = new_state
	match state:
		States.IDLE:
			velocity = Vector2.ZERO # just to be sure
			$SpriteAnimationPlayer.play("idle")
		States.RUN:
			$SpriteAnimationPlayer.play("run")


#func _follow_mob():
#	follow = true
#	set_physics_process(true)
#
#
#func _unfollow_mob():
#	# Check in which range it is, it may wander in a given radius.
#	follow = false


func get_mob():
	var mob = get_node("../Mob")
	return mob


func chant(message):
#	if !in_mob:
#		return
	var nearby_bodies = $Attack.get_overlapping_bodies()
	for body in nearby_bodies:
		if body.is_in_group("npc"):
			body.react(message, self)


# Receive message from chant and decide if joining mob
func react(message, mob):
	var change_amount = 2 if trigger_slogans.find(message) else -1
	commitment_change(change_amount)


# Call to make the NPC join the mob.
func join_mob():
	#Global.get_mob().gain_member(self);
	if in_mob:
		return
	$Sprite.modulate = Color(1, 0, 0)
	get_mob().gain_member(self);
	self.in_mob = true
	$TempSprite.default_color = "f80202" # temp


# Call to make the NPC leave the mob.
func leave_mob():
	$Sprite.modulate = Color(1, 1, 1)
	get_mob().lose_member(self)
	self.in_mob = false
	$TempSprite.default_color = "6680ff" # temp

# This generates a new position for when the NPC is roaming
func set_new_roam_target():
	# Mob members don't wander
	if self.in_mob:
		return
	
	randomize()
	var random_angle = randf() * TAU
	var random_radius = (randf() * roam_radius) / 2 + roam_radius / 2
	target = global_position + Vector2(cos(random_angle) * random_radius, sin(random_angle) * random_radius)
	slow_radius = target.distance_to(global_position) / 2
	
	$WanderTimer.wait_time = rand_range(2, 4)
	$WanderTimer.start()


#func start_move():
#	if self.in_mob:
#		return
#
#	randomize()
#	var random_angle = randf() * TAU
#	var random_radius = (randf() * roam_radius) / 2 + roam_radius / 2
#	target = global_position + Vector2(cos(random_angle) * random_radius, sin(random_angle) * random_radius)
#	slow_radius = target.distance_to(global_position) / 2
#	change_state(States.RUN)
#	set_physics_process(true)

#
#func stop_move():
#	target = global_position
#	change_state(States.IDLE)
#	randomize()
#	$MoveTimer.wait_time = rand_range(4.0, 6.0) # Force stop to use idle state.
#	$MoveTimer.start()
#	#set_physics_process(false)


# Begin an attack at the specified angle in radians.
func attack_angle(angle):
	$Attack.rotation = angle
	$AnimationPlayer.play("attack")


# Begin an attack in the direction of the specified vector.
# For example, attack_vector(Vector2.RIGHT) begins a right-facing attack.
func attack_vector(new_direction):
	attack_angle(atan2(new_direction.y, new_direction.x))


func _on_attack_timer():
	$Attack.set_physics_process(true)
	$AttackTimer.wait_time = rand_range(1.0, 2.0)
	$AttackTimer.start()


func _on_body_entered(body):
	var damage = -1
	if body.get("in_mob") == null:
		return
	if in_mob == body.in_mob:
		return
	if !in_mob:
		damage = 1
		if commitment > 0:
			return
	elif body.commitment > 0: # Not in mob, indifferent.
		return
	# Otherwise not in mob and against it.

	attack_vector(body.position - position)
	body._on_attacked(damage) # Use specific NPC damage.


func _on_attacked(damage):
	commitment_change(-damage)


func test_commitment():
	if commitment < 10:
		if in_mob:
			leave_mob()
	elif commitment >= 10:
		if not in_mob:
			join_mob()


func commitment_change(damage):
	commitment += damage
	if in_mob:
		get_mob().emit_signal("npc_commitment_incremented", damage)
	test_commitment()
	var new_commitment_change = load("res://commitment_change.tscn")
	var commitment_change_instance = new_commitment_change.instance()
	commitment_change_instance.damage = damage
	commitment_change_instance.position = position
	add_child(commitment_change_instance)


#func set_direction(new_direction):
#	if new_direction == "up" or new_direction == "down" or new_direction == direction:
#		return
#
#	direction = new_direction
#	$Sprite.flip_h = !$Sprite.flip_h


func set_type(new_type):
	if type == new_type:
		return
	type = new_type
	
	# Load random texture associated with type.
	var paths = texture_paths[type] if texture_paths.has(type) else texture_paths[Type.PAWN]
	randomize()
	var index = randi() % paths.size() 
	$Sprite.texture = load(paths[index])
	# Load outline sprite (add sprites above or edit the path string).


# NOT USED YET
func buff(buff_range):
	pass


func _on_CommitmentTimer_timeout() -> void:
	if not in_mob:
		return
	if global_position.distance_to(get_mob().global_position) > MOB_MAX_DISTANCE:
		commitment_change(COMMITMENT_LOOSE)
