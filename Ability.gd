extends TextureButton

# Fill this with names of the UI buttons.
const buttons = ["ability_1"]
const button_names = ["z"]

signal clicked

export var cooldown = 10
export var title = "empty"
export var count = 0

var button_code = ""
var timer := 0.0

onready var cd = $Cooldown

func _ready():
	timer = cooldown
	cd.max_value = cooldown


func _process(delta):
	timer = max(0.0, timer - delta)
	cd.value = timer
	cd.visible = cd.value != 0
	disabled = cd.value != 0


func _input(event):
	if event.is_pressed() and event.is_action(button_code):
		activate_ability()


func activate_ability():
	if count > 0 and timer == 0:
		emit_signal("clicked")
		set_count(count - 1)
		start_cooldown()


func start_cooldown():
	timer = cooldown


func parse_ability(ability):
	cooldown = ability.cooldown
	title = ability.title
	$AbilityIcon.texture = load("res://icon.png")
	set_count(1)
	timer = 0


func remove_ability():
	set_count(count - 1)
	if count == 0:
		title = "empty"
		disabled = true


func set_button(n):
	$Hotkey.text = button_names[n] # button_names[n] TODO
	button_code = buttons[n] # buttons[n] TODO


func set_count(n):
	count = max(0, n)
	$AbilityCount.text = "x%d" % n
	
