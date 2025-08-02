class_name HandAnimator
extends Node

@export var index_animation_player: AnimationPlayer
@export var thumb_animation_player: AnimationPlayer

func animate_index() -> void:
	index_animation_player.play("index")
	await index_animation_player.animation_finished
	index_animation_player.pause()

func animate_thumb() -> void:
	thumb_animation_player.play("thumb")
	await thumb_animation_player.animation_finished
	thumb_animation_player.pause()
	
func animate_index_release() -> void:
	index_animation_player.play("index", -1.0, -1.0)
	await index_animation_player.animation_finished
	index_animation_player.pause()

func animate_thumb_release() -> void:
	thumb_animation_player.play("thumb", -1.0, -1.0)
	await thumb_animation_player.animation_finished
	thumb_animation_player.pause()

func animate_fist() -> void:
	index_animation_player.play("fist", -1.0, 3.0)
	await index_animation_player.animation_finished
	index_animation_player.pause()
	
func animate_fist_release() -> void:
	index_animation_player.play("fist", -1.0, -0.5)
	await index_animation_player.animation_finished
	index_animation_player.pause()
