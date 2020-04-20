extends Position2D

func _ready() -> void:
	$IdleSprite.visible = true
	$ClickSprite.visible = false
	$AnimationPlayer.playback_speed = 1.0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		$AnimationPlayer.play("click")
#	if event.is_action_pressed("secondary_click"):
#		visible = false
#	if event.is_action_released("secondary_click"):
#		visible = true

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "click":
		$AnimationPlayer.play("idle")
