class_name EnemyNavigation
extends CharacterBody3D

@export var speed: float = 3.0
@export var navigation_agent_3d: NavigationAgent3D

var can_chase: bool
var chasing: bool
var direction: Vector3
var destination: Vector3
var local_destination: Vector3

func _ready() -> void:
	navigation_agent_3d.navigation_finished.connect(stop_chasing)

	
func _physics_process(delta: float) -> void:
	if(can_chase):
		destination = navigation_agent_3d.get_next_path_position()
		local_destination = destination - global_position
		direction = local_destination.normalized()
		if(local_destination != Vector3.ZERO):
			look_at(Vector3(destination.x, global_position.y, destination.z))
		
		velocity = direction * speed
		
		if(global_position.distance_to(navigation_agent_3d.target_position) <= navigation_agent_3d.target_desired_distance):
			stop_chasing()
			velocity = Vector3.ZERO
			
	if(not is_on_floor()):
		velocity.y -= 9.8 * delta
	
	move_and_slide()

func set_chasing_position(target_pos: Vector3) -> void:
	navigation_agent_3d.target_position = target_pos
	if(navigation_agent_3d.is_target_reachable()):
		can_chase = true
		chasing = true
	else:
		velocity = Vector3.ZERO
		can_chase = false
		chasing = false

func stop_chasing() -> void:
	chasing = false
	can_chase = false
