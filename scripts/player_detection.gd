class_name PlayerDetection
extends Node3D

@export var detection_range: float = 50.0
@export var field_of_view_angle_deg: float = 45.0  # 45° à gauche et droite

var best_target: Target = null
var best_score: float = -INF

var to_target: Vector3
var distance: float
var direction_to_target: Vector3
var alignment: float
var angle_deg: float
var score: float

var targets_in_range: Array[Target]

func _process(delta: float) -> void:
	_update_target()

func _update_target() -> void:
	if is_instance_valid(best_target):
		to_target = best_target.global_position - global_position
		distance = to_target.length()

		if distance > detection_range:
			best_target.set_target(false)
			best_target = null
			best_score = -INF
		else:
			direction_to_target = to_target.normalized()
			alignment = clamp((-global_transform.basis.z).dot(direction_to_target), -1.0, 1.0)
			angle_deg = rad_to_deg(acos(alignment))

			if angle_deg > field_of_view_angle_deg:
				best_target.set_target(false)
				best_target = null
				best_score = -INF
	
	for target in targets_in_range:
		if not target is Node3D:
			continue

		to_target = target.global_position - global_position
		distance = to_target.length()
			
		direction_to_target = to_target.normalized()
		alignment = clamp((-global_transform.basis.z).dot(direction_to_target), -1.0, 1.0)  # 1 = parfaitement centré, -1 = derrière

		angle_deg = rad_to_deg(acos(alignment))
		if angle_deg > field_of_view_angle_deg:
			continue  # En dehors du champ de vision

		# Score : on peut pondérer selon la distance et l'alignement
		score = (-global_transform.basis.z).dot(direction_to_target) / distance  # Plus c'est centré ET proche, mieux c'est
		
		if score > best_score:
			best_score = score
			if(target != best_target):
				if(best_target):
					best_target.set_target(false)
				best_target = target
				best_target.set_target(true)
