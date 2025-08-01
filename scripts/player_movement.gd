class_name PlayerMovement
extends CharacterBody3D

@export_group("Components")
@export var pinch_loop : PinchLoopController

@export_group("Movement Variables")
@export var speed : float = 5.0
@export var gravity : float = 9.8
@export var sensitivity: float = 0.001
@export var dash_speed: float = 30.0
@export var dash_duration: float = 0.2  # Durée en secondes

@onready var pivot: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D

var input_dir: Vector2
var direction: Vector3
var vertical_rotation: float = 0.0

var movement_locked: bool

var is_dashing: bool
var dash_direction: Vector3 = Vector3.ZERO
var dash_timer: float = 0.0

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
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
			velocity = Vector3.ZERO
	else:
		if(not is_on_floor()):
			velocity.y -= gravity * delta
			
		if(movement_locked):
			return
			
		input_dir = Input.get_vector("move_left", "move_right", "move_front", "move_back") 
		direction = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
		
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	
	move_and_slide()

func toggle_movement_inputs() -> void:
	movement_locked = !movement_locked
	print("movement_locked " + str(movement_locked))

func on_mouse_activate() -> void:
	pass
