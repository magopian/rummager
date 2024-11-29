extends CanvasLayer

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var sparks: GPUParticles2D = %Sparks


var animating_max: bool = false


func _ready() -> void:
	sparks.emitting = false


func _process(_delta: float) -> void:
	progress_bar.value = lerp(progress_bar.value, float(Global.score), 0.1)
	if progress_bar.value >= progress_bar.max_value and not animating_max:
		animating_max = true
		animate_max()


func animate_max() -> void:
	print("max!")
	sparks.emitting = true
	# Glow the progress bar
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	var initial_color: Color = progress_bar.get("theme_override_styles/fill").bg_color
	tween.set_parallel(true)
	tween.tween_property(progress_bar, "theme_override_styles/fill:bg_color", Color.WHITE, 0.15)
	tween.tween_property(progress_bar, "scale", Vector2.ONE * 2, 0.15)
	tween.set_parallel(false)
	tween.tween_interval(0.25)
	tween.set_parallel(true)
	tween.tween_property(progress_bar, "theme_override_styles/fill:bg_color", initial_color, 0.15)
	tween.tween_property(progress_bar, "scale", Vector2.ONE, 0.15)
	tween.tween_interval(0.15)
	tween.set_loops(5)
	await tween.finished
	# Animate the sparks to the center of the screen
	var tween_sparks: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_sparks.tween_property(sparks, "global_position", Global.viewport_size / 2, 1)
	tween_sparks.tween_property(sparks, "scale", Vector2.ONE * 5, 2)
	await tween_sparks.finished
	sparks.emitting = false
