class_name PopText extends Label


func pop(number: float, from: Vector2, with_angle: float, to: Vector2) -> void:
	prints("poping text and going to:", to)
	global_position = from
	scale = Vector2.ONE * 0.1
	modulate.a = 0
	text = str(round(number * 10))
	set("theme_override_font_sizes/font_size", round(number * 10 + 10))
	set("theme_override_constants/outline_size", clamp(round(number * 2 + 2), 1, 10))
	var real_size: Vector2 = get_minimum_size()
	position -= (real_size / 2)
	pivot_offset = real_size / 2

	var direction: Vector2 = Vector2(number * 20 + 20, 0)  # Corresponds to angle 0
	direction = direction.rotated(with_angle)

	# Animate the "popping" of the number
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	tween.set_parallel(true)
	tween.tween_property(self, "position", position + direction, 1)
	tween.tween_property(self, "modulate:a", 1, 0.3)
	tween.tween_property(self, "scale", Vector2.ONE, 0.6)

	# Animate to the score progress bar
	tween.chain().tween_property(self, "global_position", to, 1)
	tween.tween_property(self, "scale", Vector2.ONE * 0.5, 1)
	tween.tween_property(self, "modulate:a", 0, 1.5)
	await tween.finished
