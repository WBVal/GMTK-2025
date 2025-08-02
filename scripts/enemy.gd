class_name Enemy
extends EnemyNavigation

@export var targetable: Target
@export var animator: GoblinAnimator

@export var chase_threshold_dist: float
@export var contact_distance: float
@export var attack_damage: int = 10
@export var attack_cooldown: float = 2.0

var can_attack: bool = true
var dead: bool = false

enum State{RUNNING, IDLE, DYING, ATTACK}
var current_state: State = State.IDLE

func _ready() -> void:
	can_chase = true
	animator.idle()

func _process(delta: float) -> void:
	if(dead):
		return
		
	if(chasing):
		if(targetable.distance_to_player <= navigation_agent_3d.target_desired_distance):
			attack_player()
		else:
			update_state(State.RUNNING)
	else:
		update_state(State.IDLE)
	
	if targetable.is_visible && targetable.distance_to_player <= chase_threshold_dist:
		if(targetable.is_facing_position(targetable.player.global_position)):
			set_chasing_position(targetable.player.global_position)
		if chasing:
			set_chasing_position(targetable.player.global_position)

func on_collision_with_player() -> void:
	if(targetable.player.is_dashing):
		targetable.player.stop_dash()
		on_punched()

func on_punched() -> void:
	dead = true
	can_attack = false
	can_chase = false
	targetable.detected_text.visible = false
	# Animate
	animator.die()
	await animator.animation_player.animation_finished
	targetable.pop_from_target_list()
	queue_free()
	

func attack_player() -> void:
	if not can_attack || targetable.player.is_dashing:
		return

	animator.attack()
	await animator.animation_player.animation_finished
	can_chase = false
	chasing = false
	targetable.player.take_damage(attack_damage)
	can_attack = false
	# Lancer le cooldown en arrière-plan
	_call_later_reset_cooldown()

func _call_later_reset_cooldown() -> void:
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	can_chase = true

func update_state(state: State) -> void:
	if(state == current_state):
		return
		
	current_state = state
	
	match state:
		State.IDLE:
			print("idle")
			animator.idle()
		State.RUNNING:
			print("run")
			animator.run()
