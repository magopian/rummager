extends CanvasLayer


@onready var path_2d: Path2D = %Path2D
@onready var path_follow_2d: PathFollow2D = %PathFollow2D
@onready var target: Sprite2D = %Target
@onready var area_2d: Area2D = %Area2D


func _ready() -> void:
	setup_curve()
	target.modulate.a = 0
	area_2d.body_entered.connect(_on_target_hit)


func setup_curve() -> void:
	var height: float = Global.viewport_size.y - 100
	var width: float = Global.viewport_size.x
	var bottom_left: Vector2 = Vector2(0, height)
	var top_left: Vector2 = Vector2.ZERO
	var top_right: Vector2 = Vector2(width, 0)
	var bottom_right: Vector2 = Vector2(width, height)
	path_2d.curve = Curve2D.new()
	path_2d.curve.add_point(bottom_left, Vector2.ZERO, Vector2.ZERO)
	path_2d.curve.add_point(top_left, Vector2.ZERO, Vector2.ZERO)
	path_2d.curve.add_point(top_right, Vector2.ZERO, Vector2.ZERO)
	path_2d.curve.add_point(bottom_right, Vector2.ZERO, Vector2.ZERO)


func random_target() -> void:
	var random_progress_ratio: float = randf()
	
	var tween_duration: float = compute_tween_duration(path_follow_2d.progress_ratio, random_progress_ratio)
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(path_follow_2d, "progress_ratio", random_progress_ratio, tween_duration)
	tween.parallel().tween_property(target, "modulate:a", 0.5, tween_duration)
	await tween.finished
	Global.new_target.emit(target.global_position)


func compute_tween_duration(ratio1: float, ratio2: float) -> float:
	"""Take two ratios, and return their difference.

	This works because the max difference is 1, which is the longest duration we want.
	"""
	return max(ratio1, ratio2) - min(ratio1, ratio2)


func _on_target_hit(body: Node2D) -> void:
	if body is not Card:
		return
	if body.to_find:
		return
	var speed: float = body.linear_velocity.length()
	if speed < 100:
		return
	Global.target_hit.emit(body)
	body.collision_layer = 0
	var animated_target: Sprite2D = target.duplicate()
	call_deferred("animate_target_hit", animated_target, target.global_position)
	random_target()


func animate_target_hit(animated_target: Sprite2D, initial_position: Vector2) -> void:
	add_child(animated_target)
	animated_target.position = initial_position
	var tween: Tween = animated_target.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.set_parallel()
	tween.tween_property(animated_target, "scale", Vector2.ONE * 1, 0.5)
	tween.tween_property(animated_target, "modulate:a", 0, 0.5)
	await tween.finished
	animated_target.queue_free()
