class_name Player
extends PlayerMovement

@export var health: int = 100
@export var detection: PlayerDetection
@export var invincibility_duration: float = 1.0
@export var can_take_dmg: bool = true

func _init() -> void:
	GameManager.Player = self
	
func take_damage(amount: int) -> void:
	if(can_take_dmg):
		print("player took dmg")
		health = clampi(health - amount, 0, 100)
		can_take_dmg = false
		if(health == 0):
			movement_locked = true
			print("Game Over")
			return
		_call_later_reset_cooldown()

func on_mouse_activate() -> void:
	if detection.best_target:
		if(detection.best_target.is_punchable):
			dash_to_target(detection.best_target.eyes.global_position)
	
func dash_to_target(target_position: Vector3) -> void:
	var direction: Vector3 = (target_position - global_position).normalized()
	camera_3d.fov = 85.0
	dash_direction = direction
	is_dashing = true
	right_hand_anim.animate_fist()

func _call_later_reset_cooldown() -> void:
	await get_tree().create_timer(invincibility_duration).timeout
	can_take_dmg = true
