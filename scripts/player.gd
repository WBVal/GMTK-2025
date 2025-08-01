class_name Player
extends PlayerMovement

@export var health: int = 100
@export var detection: PlayerDetection

func _init() -> void:
	GameManager.Player = self
	
func take_damage(amount: int) -> void:
	health = clampi(health - amount, 0, 100)
	if(health == 0):
		movement_locked = true
		print("Game Over")

func on_mouse_activate() -> void:
	if detection.best_target:
		if(detection.best_target.is_punchable):
			dash_to_target(detection.best_target.eyes.global_position)
	
func dash_to_target(target_position: Vector3) -> void:
	var direction: Vector3 = (target_position - global_position).normalized()
	dash_direction = direction
	dash_timer = dash_duration
	is_dashing = true
