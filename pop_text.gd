class_name PopText extends Label


func pop(number: float, from: Vector2, with_angle: float) -> void:
	global_position = from
	scale = Vector2.ONE * 0.1
	modulate.a = 0
	text = str(round(number * 10))
	set("theme_override_font_sizes/font_size", round(number * 20))
	set("theme_override_constants/outline_size", clamp(round(number * 2), 1, 10))
	var real_size: Vector2 = get_minimum_size()
	position -= (real_size / 2)
	pivot_offset = real_size / 2

	var direction: Vector2 = Vector2(number * 50, 0)  # Corresponds to angle 0
	direction = direction.rotated(with_angle)

	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	tween.set_parallel(true)
	tween.tween_property(self, "position", position + direction, 1)
	tween.tween_property(self, "modulate:a", 1, 0.3)
	tween.tween_property(self, "scale", Vector2.ONE, 0.6)
	tween.chain().tween_property(self, "modulate:a", 0, 1)
	tween.tween_property(self, "position", position, 1)
