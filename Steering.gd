extends Node

const DEFAULT_MASS := 2.0
const DEFAULT_MAX_SPEED := 400.0
const DEFAULT_SLOW_RADIUS := 50.0

static func follow(
		velocity: Vector2,
		global_position: Vector2,
		target_position: Vector2,
		max_speed := DEFAULT_MAX_SPEED,
		mass := DEFAULT_MASS
) -> Vector2:
	
	var desired_velocity := (target_position - global_position).normalized() * max_speed
	var steering := (desired_velocity - velocity) / mass
	return velocity + steering


static func arrive_to(
		velocity: Vector2,
		global_position: Vector2,
		target_position: Vector2,
		max_speed := DEFAULT_MAX_SPEED,
		slow_radius := DEFAULT_SLOW_RADIUS,
		mass := DEFAULT_MASS
) -> Vector2:
	var to_target: = global_position.distance_to(target_position)
	var desired_velocity: = (target_position - global_position).normalized() * max_speed
	if to_target < slow_radius:
		desired_velocity *= (to_target / slow_radius) * 0.8 + 0.2
	var steering: = (desired_velocity - velocity) / mass
	return velocity + steering


static func direction_4_way(angle: float) -> String:
	angle = fposmod(angle, TAU)
	if angle < TAU * 1 / 8:
		return "right"
	if angle < TAU * 3 / 8:
		return "down"
	if angle < TAU * 5 / 8:
		return "left"
	if angle < TAU * 7 / 8:
		return "up"
	return "right"
