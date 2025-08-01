class_name PinchLoopController
extends Node3D

@export var arm_pivot: Node3D
@export var sensitivity: float
@export var pivot_high_clamp: float
@onready var hand: Node3D = $Hand

var index_pressed: bool
var thumb_pressed: bool
var is_pinching: bool

var arm_rotation: float = 0.0

signal on_loop_start
signal on_loop_stop

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event.is_action_pressed("pinch_index"):
		index_pressed = true
	if event.is_action_released("pinch_index"):
		index_pressed = false
		
	if event.is_action_pressed("pinch_thumb"):
		thumb_pressed = true
	if event.is_action_released("pinch_thumb"):
		thumb_pressed = false
		
	enable_pinch(thumb_pressed && index_pressed)
	
func _unhandled_input(event: InputEvent) -> void:
	if(!is_pinching):
		return
		
	if event is InputEventMouseMotion:
		arm_rotation -= (event as InputEventMouseMotion).relative.y * sensitivity
		arm_pivot.rotation.x = clamp(arm_rotation, 0.0, deg_to_rad(pivot_high_clamp))

func enable_pinch(enabled: bool) -> void:
	if(is_pinching == enabled):
		return
	
	is_pinching = enabled
	
	if(is_pinching):
		on_loop_start.emit()
		print("started pinching")
	else:
		on_loop_stop.emit()
		arm_pivot.rotation.x = 0.0
		print("stopped pinching")

func get_hand_height() -> float:
	return hand.global_position.y
