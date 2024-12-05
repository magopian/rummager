class_name BonusCard extends Sprite2D


@onready var card_container: Node2D = %CardContainer
@onready var background: Sprite2D = %Background
@onready var pattern: Sprite2D = %Pattern
@onready var border: Sprite2D = %Border
@onready var color: Sprite2D = %Color
@onready var cross: Sprite2D = %Cross
@onready var animation_player: AnimationPlayer = %AnimationPlayer


var characteristic: String
var bonus_value
var pop_text_scene: PackedScene = preload("res://pop_text.tscn")


func _ready() -> void:
	card_container.modulate.a = 0
	match characteristic:
		"background_color":
			background.modulate = bonus_value
		"color":
			color.modulate = bonus_value
		"pattern_sprite":
			pattern.texture = bonus_value
			#pattern.modulate = Color.BLACK
		"border_sprite":
			border.texture = bonus_value
			#border.modulate = Color.BLACK


func init_random(cards: Node) -> void:
	characteristic = Card.charac_to_property[Card.characteristics.pick_random()]
	characteristic = "pattern_sprite"  # TODO: remove
	var random_data: Dictionary = cards.get_children().pick_random().data
	bonus_value = random_data[characteristic]


func display_bonus() -> void:
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(card_container, "modulate:a", 1, 2)
	tween.parallel().tween_property(card_container, "rotation_degrees", 360 * 3, 2)
	await tween.finished


func remove_cards(cards_container: Node, sparks: GPUParticles2D) -> void:
	# Display the bonus card
	await display_bonus()

	# Remove the cards: first select those that have the bonus characteristic
	var cards_to_remove: Array[Card] = []
	for card in (cards_container.get_children() as Array[Card]):
		if card.to_find:  # Don't destroy the card to find!
			continue
		if card.data[characteristic] == bonus_value:
			cards_to_remove.push_back(card)
	var total_cards_to_remove: int = cards_to_remove.size()
	print("cards to remove: ", total_cards_to_remove)

	# And now animate them.
	var interval: float = 0
	if total_cards_to_remove:
		interval = 1.0 / cards_to_remove.size()
	var tween: Tween
	var x: int = 0
	for card in cards_to_remove:
		#pop_number(x)  # TODO: fix the display and animation
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_interval(x * interval)
		# Bring all the cards to remove towards the center of the bonus card
		tween.tween_property(card, "position", global_position, 1)
		tween.parallel().tween_property(card, "z_index", x + 1, 1)  # Display the card above all the others, but below the cross
		x += 1

	# Sparks have a lifetime of 1.5s, and the removal of cards should take 1s.
	# Stop emitting now so the last particles will be dying short after the last card was removed.
	sparks.emitting = false

	await tween.finished

	# Then display the "cross stamping" to show that we remove the cards
	animation_player.play("display_cross")
	await animation_player.animation_finished
	for card in cards_to_remove:
		card.queue_free()

	await get_tree().create_timer(.5).timeout


func pop_number(number: int) -> void:
	var pop_text: PopText = pop_text_scene.instantiate()
	pop_text.text = str(number)
	pop_text.rotation_degrees = randf_range(-5, 5)
	add_child(pop_text)
	await pop_text.pop()
	pop_text.queue_free()


func disappear() -> void:
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.5)
	tween.parallel().tween_property(self, "modulate:a", 0, 0.5)
	await tween.finished
	queue_free()
