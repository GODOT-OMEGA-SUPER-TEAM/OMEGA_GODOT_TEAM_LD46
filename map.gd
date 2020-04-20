extends Node2D

# Reference to level is saved as a variable so levels can be swapped out
# without needing to alter references elsewhere in code.
onready var level = $TestLevel
var tilemap = null

func _ready():
	tilemap = level.get_node("Tilemap")
	# Thinking of an instagator as a NPC type that is always a mob member.
	for _i in range(10):
		var inst_pos = Vector2(rand_range(-100, 100), rand_range(-100, 100))
		# If the instigator would spawn inside a wall, pick a different spawn point.
		while not is_valid_spawn_point(inst_pos):
			inst_pos = Vector2(rand_range(-100, 100), rand_range(-100, 100))
		add_npc(inst_pos, NPC.Type.INSTIGATOR)
	generate_random_npcs(40)


func add_npc(position: Vector2, type):
	var new_npc = load("res://NPC.tscn")
	var npc_instance = new_npc.instance()
	npc_instance.type = type
	npc_instance.position = position
	add_child(npc_instance)

	# Crude test to make sure NPCs don't spawn on other objects.
	npc_instance.move_and_slide(Vector2(0, 0), Vector2(0, 0))
	while npc_instance.get_slide_count() > 0:
		npc_instance.move_and_slide(Vector2(0, 0), Vector2(0, 0))
		npc_instance.position = npc_instance.position + Vector2(rand_range(-10, 10), rand_range(-10, 10))


func generate_random_npcs(amount):
	var map_rect = tilemap.get_used_rect()
	map_rect = Rect2(map_rect.position*16, map_rect.size*16)
	for _i in range(amount):
		var type = NPC.Type.DEMIHUMAN if randf() < 0.5 else NPC.Type.CLERIC
		var npc_pos = Vector2(rand_range(map_rect.position.x, map_rect.end.x), rand_range(map_rect.position.y, map_rect.end.y))
		# If the NPC would spawn inside a wall, pick a different spawn point.
		while not is_valid_spawn_point(npc_pos):
			npc_pos = Vector2(rand_range(map_rect.position.x, map_rect.end.x), rand_range(map_rect.position.y, map_rect.end.y))
		add_npc(npc_pos, type)


# Checks whether a chosen spawn point is inside a wall.
func is_valid_spawn_point(coords):
	var tile_coords = tilemap.world_to_map(coords)
	var cell = tilemap.get_cellv(tile_coords)
	return (cell == -1) # If the cell has an index of -1, it's empty and therefore a valid spawn point.
