extends Node

@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var parent: Control

var initial_scale: Vector2

func _ready() -> void:
	parent = get_parent()
	initial_scale = parent.scale
	parent.mouse_entered.connect(_on_mouse_entered)
	parent.mouse_exited.connect(_on_mouse_exited)
	parent.focus_entered.connect(_on_focus_entered)


func _on_mouse_entered() -> void:
	audio_stream_player.play()
	var original_position: Vector2 = parent.global_position
	parent.pivot_offset = parent.size * initial_scale / 2
	parent.global_position = original_position
	var tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(parent, "scale", initial_scale + Vector2(0.1, 0.1), 0.1)


func _on_mouse_exited() -> void:
	if not is_inside_tree():
		return
	# TODO: this causes race conditions when a parent button is clicked that ends up with the button beeing freed
	# which causes the following log: "start: Target object freed before starting, aborting Tweener."
	var tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(parent, "scale", initial_scale, 0.1)


func _on_focus_entered() -> void:
	audio_stream_player.play()
