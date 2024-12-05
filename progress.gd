extends CanvasLayer

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var sparks: GPUParticles2D = %Sparks
@onready var bonus_card_spawn_point: Control = %BonusCardSpawnPoint
@onready var remote_transform_2d: RemoteTransform2D = %RemoteTransform2D


var animating_max: bool = false


func _ready() -> void:
	progress_bar.value = 0
	sparks.emitting = false


func _process(_delta: float) -> void:
	if animating_max:
		return
	var score_to_progress: float = Global.score % 100
	var lerp_to: float = score_to_progress
	if score_to_progress < progress_bar.value:  # We went past the max score, so finish lerping to max score
		lerp_to = progress_bar.max_value + 5  # Add 5 to make sure lerping brings us over the progress_bar.max_value
	progress_bar.value = lerp(progress_bar.value, lerp_to, 0.1)
	if progress_bar.value >= progress_bar.max_value:  # And now animate the "max score reached"
		animating_max = true
		Global.max_progress.emit()


func animate_max(bonus_card: BonusCard, cards_container: Node) -> void:
	prints("Animate max with bonus card:", bonus_card.characteristic, bonus_card.bonus_value)

	# Start the sparks at the end of the progress bar
	sparks.scale = Vector2.ONE
	sparks.lifetime = 1
	sparks.global_position = bonus_card_spawn_point.global_position
	sparks.scale = Vector2.ONE / 3
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
	tween.set_loops(3)
	await tween.finished

	# Animate the sparks to the center of the screen
	remote_transform_2d.remote_path = bonus_card.get_path()  # Animate the bonus card along with the sparks
	bonus_card.scale = Vector2.ONE / 5
	bonus_card.modulate.a = 0
	var tween_sparks: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_sparks.set_parallel(true)
	tween_sparks.tween_property(sparks, "global_position", Global.viewport_size / 2, 1)
	tween_sparks.tween_property(sparks, "scale", Vector2.ONE * 3, 1)
	tween_sparks.tween_property(sparks, "lifetime", 1.5, 1)
	tween_sparks.tween_property(bonus_card, "modulate:a", 1, 1)
	tween_sparks.tween_property(bonus_card, "scale", Vector2.ONE, 1)
	await tween_sparks.finished

	await bonus_card.remove_cards(cards_container, sparks)

	# Reset
	print("reset")
	animating_max = false
	progress_bar.value = 0
	bonus_card.disappear()
