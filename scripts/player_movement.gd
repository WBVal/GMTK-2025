class_name PlayerMovement
extends CharacterBody3D

@export_group("Components")
@export var pinch_loop : PinchLoopController
@export var right_hand_anim: HandAnimator

@export_group("Movement Variables")
@export var speed : float = 5.0
@export var jump_vel : float = 7.0
@export var gravity : float = 20.0
@export var sensitivity: float = 0.001
@export var dash_speed: float = 30.0

@onready var pivot: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D

var input_dir: Vector2
var direction: Vector3
var vertical_rotation: float = 0.0

var movement_locked: bool

var is_dashing: bool
var dash_direction: Vector3 = Vector3.ZERO

const BOB_FREQ: float = 3.0
const BOB_AMP: float = 0.1

var t_bob: float

var on_moving_platform_velocity: Vector3 = Vector3.ZERO

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	movement_locked = false
	pinch_loop.on_loop_start.connect(toggle_movement_inputs)
	pinch_loop.on_loop_stop.connect(toggle_movement_inputs)

func _unhandled_input(event: InputEvent) -> void:
	if(movement_locked):
		return
		
	if event is InputEventMouseMotion:
		# Rotation horizontale (le corps)
		rotation.y -= (event as InputEventMouseMotion).relative.x * sensitivity

		# Rotation verticale (le pivot/camera)
		vertical_rotation -= (event as InputEventMouseMotion).relative.y * sensitivity
		vertical_rotation = clamp(vertical_rotation, deg_to_rad(-89.0), deg_to_rad(89.0))
		pivot.rotation.x = vertical_rotation

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("mouse_activate"):
		on_mouse_activate()

func _physics_process(delta: float) -> void:
	if(is_dashing):
		velocity = dash_direction * dash_speed
	else:
		if(!movement_locked):
			if Input.is_action_just_pressed("jump") && is_on_floor():
				velocity.y = jump_vel
			
			input_dir = Input.get_vector("move_left", "move_right", "move_front", "move_back") 
			direction = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
			
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		
			# Head bob
			t_bob += delta * velocity.length() * float(is_on_floor())
			pivot.transform.origin = headbob(t_bob)
		else:
			velocity = Vector3.ZERO
	
	if(not is_on_floor()):
		velocity.y -= gravity * delta
		
	velocity += on_moving_platform_velocity
	
	move_and_slide()
	
	on_moving_platform_velocity = Vector3.ZERO
	
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var other := collision.get_collider()
		if other is Enemy:
			(other as Enemy).on_collision_with_player()

func toggle_movement_inputs() -> void:
	movement_locked = !movement_locked

func on_mouse_activate() -> void:
	pass

func headbob(t: float) -> Vector3:
	var pos: Vector3 = Vector3.ZERO
	pos.y = sin(t * BOB_FREQ) * BOB_AMP
	pos.x = cos(t * BOB_FREQ / 2) * BOB_AMP / 3
	return pos

func stop_dash() -> void:
	camera_3d.fov = 75.0
	is_dashing = false
	velocity = Vector3.ZERO
	right_hand_anim.animate_fist_release()
