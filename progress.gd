extends CanvasLayer

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var sparks: GPUParticles2D = %Sparks
@onready var bonus_card_spawn_point: Control = %BonusCardSpawnPoint


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


func animate_max(bonus_card: Card, cards_container: Node) -> void:
	print("Animate max with bonus card: ", bonus_card.data)

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
	sparks.add_child(bonus_card)
	bonus_card.show_small()
	bonus_card.modulate.a = 0
	var tween_sparks: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_sparks.tween_property(sparks, "global_position", Global.viewport_size / 2, 1)
	tween_sparks.tween_property(sparks, "scale", Vector2.ONE * 3, 1)
	tween_sparks.set_parallel(true)
	tween_sparks.tween_property(sparks, "lifetime", 1.5, 1)
	tween_sparks.tween_property(bonus_card, "modulate:a", 1, 1)
	await tween_sparks.finished

	# Sparks have a lifetime of 1.5s, and the removal of cards should take 1s.
	# Stop emitting now so the last particles will be dying short after the last card was removed.
	sparks.emitting = false

	await remove_cards(bonus_card, cards_container)

	# Reset
	print("reset")
	animating_max = false
	progress_bar.value = 0
	var bonus_card_tween: Tween = bonus_card.scale_to(Vector2.ZERO, 0.5)
	bonus_card_tween.set_parallel(true)
	bonus_card_tween.tween_property(bonus_card, "modulate:a", 0, 0.5)
	await bonus_card_tween.finished
	bonus_card.queue_free()


func remove_cards(bonus_card: Card, cards_container: Node) -> void:
	var cards_to_remove: Array[Card] = []
	var characteristics: Array[String] = ["background_color", "color", "pattern_sprite", "border_sprite"]
	for charac in characteristics:
		var bonus_charac = bonus_card.data[charac]
		if not bonus_charac:
			continue
		for card in (cards_container.get_children() as Array[Card]):
			if card.to_find:  # Don't destroy the card to find!
				continue
			if card.data[charac] == bonus_charac:
				cards_to_remove.push_back(card)
	var total_cards_to_remove: int = cards_to_remove.size()
	print("cards to remove: ", total_cards_to_remove)

	var center: Vector2 = Global.viewport_size / 2
	var interval: float = 0
	if total_cards_to_remove:
		interval = 1 / cards_to_remove.size()
	var tween: Tween
	for card in cards_to_remove:
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.set_parallel(true)
		tween.tween_interval(interval)
		tween.tween_property(card, "position", center, 1)
		tween.tween_property(card, "scale", Vector2.ZERO, 1)
		tween.set_parallel(false)
		tween.tween_callback(card.queue_free)
	await get_tree().create_timer(1.5).timeout
