class_name GoblinAnimator
extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func run() -> void:
	animation_player.play("Running")
	
func attack() -> void:
	animation_player.play("Attack")
	
func idle() -> void:
	animation_player.play("Idle")
	
func die() -> void:
	animation_player.play("Dying")
