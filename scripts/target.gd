class_name Target
extends Node3D

@export var eyes: Node3D
@export var facing_angle_tolerance_deg: float = 20.0
@export var hand_height_tolerance: float = 0.5
@export var detected_text: Label3D

var player: Player

var in_sight: bool
var distance_to_player: float = INF
var in_player_range: bool
var is_targeted: bool
var is_visible: bool
var is_punchable: bool

func _ready() -> void:
	player = GameManager.Player
	set_punchable(false)

func _process(delta: float) -> void:
	distance_to_player = (player.global_position - global_position).length()
	check_is_visible()
	
	if(distance_to_player > player.detection.detection_range || !is_visible):
		if(in_player_range):
			in_player_range = false
			pop_from_target_list()
			set_punchable(false)
		return
	
	if(distance_to_player <= player.detection.detection_range && !in_player_range):
		in_player_range = true
		player.detection.targets_in_range.append(self)
	
	if(!is_targeted):
		set_punchable(false)
		return
	
	if(is_facing_position(player.global_position)):
		if(absf(player.pinch_loop.get_hand_height() - eyes.global_position.y) <= hand_height_tolerance && player.pinch_loop.is_pinching):
			set_punchable(true)
		

func on_raycast_enter() -> void:
	pass
	
func on_raycast_exit() -> void:
	pass
	
func set_target(value: bool) -> void:
	is_targeted = value

func set_punchable(value: bool) -> void:
	is_punchable = value
	# Code pour animation puncheable, outline etc
	if(detected_text):
		detected_text.visible = value

func is_facing_position(position: Vector3, angle_tolerance_deg: float = facing_angle_tolerance_deg) -> bool:
	var to_position: Vector3 = (position - global_position).normalized()
	var forward: Vector3 = -global_transform.basis.z  # direction "regardée"
	var dot: float = forward.dot(to_position)
	var angle_deg: float = rad_to_deg(acos(clamp(dot, -1.0, 1.0) as float))
	return angle_deg <= angle_tolerance_deg

func check_is_visible() -> void:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	query.from = global_position
	query.to = player.global_position
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.exclude = [self]  # Ignore le joueur lui-même

	var result: Dictionary = space_state.intersect_ray(query)

	# Si rien n'est touché, c'est visible
	if not result.has("collider"):
		is_visible = true
		return
	
	# Si le collider est la target elle-même, c'est visible
	is_visible = result["collider"] == player

func pop_from_target_list() -> void:
	player.detection.targets_in_range.erase(self)
