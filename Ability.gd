extends Control

# Fill this with names of the UI buttons.
const buttons = []
const button_names = []

signal clicked

export var cooldown = 10
export var title = "empty"
export var count = 0

var button_code = ""
var timer = 0

onready var cd = $Cooldown

func _ready():
	timer = cooldown
	cd.rect_size.x = 0
	pass # Replace with function body.


func _process(delta):
	timer = max(0, timer - delta)
	cd.rect_size.x = 32 * (timer / cooldown)


func _input(event):
	if count > 0 and (event.is_pressed() and event.is_action(button_code) or event is InputEventMouseButton and event.pressed):
		emit_signal("clicked")


func start_cooldown():
	timer = cooldown


func parse_ability(ability):
	cooldown = ability.cooldown
	title = ability.title
	$Icon.disabled = false
	$Icon.texture_normal = load("res://icon.png")#+ability.texture) TODO
	$Icon.texture_hover = load("res://icon.png")#+ability.texture) TODO
	count = 1
	timer = 0


func remove_ability():
	count = max(0, count - 1)
	if count == 0:
		title = "empty"
		$Icon.disabled = true


func set_button(n):
	$Label.text = "test" # button_names[n] TODO
	button_code = "test" # buttons[n] TODO
	pass
