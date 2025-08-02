class_name MovingPlatform
extends Node3D

@export var move_on_start: bool
@export var speed: float
@export var start_point: Node3D
@export var end_point: Node3D

var target_pos: Vector3
var moving_to_end: bool = true
var is_moving: bool = false

var previous_position: Vector3
var velocity: Vector3 = Vector3.ZERO

var player: Player
var is_player_on: bool

func _ready() -> void:
	if(move_on_start):
		is_moving = true
	target_pos = end_point.global_position
	global_transform.origin = start_point.global_position
	previous_position = global_transform.origin

func _physics_process(delta: float) -> void:
	if(player == null):
		return
		
	if(!player.pinch_loop.is_pinching):
		return
		
	var direction: Vector3 = (target_pos - global_transform.origin).normalized()
	var distance_to_target: float = global_transform.origin.distance_to(target_pos)

	var move_amount: Vector3 = direction * speed * delta

	if move_amount.length() >= distance_to_target:
		# Arrivé à destination, on inverse la direction
		global_transform.origin = target_pos
		moving_to_end = !moving_to_end
		target_pos = end_point.global_position if moving_to_end else start_point.global_position
	else:
		global_transform.origin += move_amount
		
	# Calcul de la vélocité
	velocity = (global_transform.origin - previous_position) / delta
	previous_position = global_transform.origin
	if(player):
		if(is_player_on):
			player.on_moving_platform_velocity = velocity
		else:
			player.on_moving_platform_velocity = Vector3.ZERO

func on_area_entered(body: Node3D) -> void:
	if(body is Player):
		player = body as Player
		is_moving = true
		is_player_on = true

func on_area_exited(body: Node3D) -> void:
	if(body is Player):
		is_player_on = false
