class_name BonusCard extends Sprite2D


@onready var card_container: Node2D = %CardContainer
@onready var background: Sprite2D = %Background
@onready var background_color: Sprite2D = %BackgroundColor
@onready var pattern: Sprite2D = %Pattern
@onready var border: Sprite2D = %Border
@onready var color: Sprite2D = %Color
@onready var cross: Sprite2D = %Cross
@onready var cards_discarded: Label = %CardsDiscarded
@onready var animation_player: AnimationPlayer = %AnimationPlayer


var characteristic: String
var bonus_value: Variant


func _ready() -> void:
	card_container.modulate.a = 0
	cards_discarded.hide()
	match characteristic:
		"background_color":
			background_color.modulate = bonus_value
		"color":
			color.modulate = bonus_value
		"pattern_sprite":
			pattern.texture = bonus_value
		"border_sprite":
			border.texture = bonus_value


func init_random(cards: Node, charac: String= "") -> void:
	characteristic = charac
	if not characteristic:
		characteristic = Card.charac_to_property[Card.characteristics.pick_random()]
	#characteristic = "background_color"  # TODO: remove
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
	await get_tree().create_timer(1).timeout

	# Remove the cards: first select those that have the bonus characteristic
	var cards_to_remove: Array[Card] = []
	for card in (cards_container.get_children() as Array[Card]):
		if card.to_find:  # Don't destroy the card to find!
			continue
		if card.data[characteristic] == bonus_value:
			cards_to_remove.push_back(card)
	var total_cards_to_remove: int = cards_to_remove.size()
	print("cards to remove: ", total_cards_to_remove)

	# Animate the score counting up
	var num_cards_tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	num_cards_tween.tween_property(cards_discarded, "score", total_cards_to_remove, 2)

	# And now animate them.
	var interval: float = 0
	if total_cards_to_remove:
		interval = 1.0 / cards_to_remove.size()
	var tween: Tween
	var x: int = 0
	cards_discarded.show()
	for card in cards_to_remove:
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_interval(x * interval)
		tween.tween_callback(card.reparent.bind(self))
		# Bring all the cards to remove towards the center of the bonus card
		tween.tween_property(card, "position", position, 1)
		x += 1

	# Sparks have a lifetime of 1.5s, and the removal of cards should take 1s.
	# Stop emitting now so the last particles will be dying short after the last card was removed.
	if is_instance_valid(sparks):
		sparks.emitting = false

	await tween.finished
	await get_tree().create_timer(0.5).timeout

	# Then display the "cross stamping" to show that we remove the cards
	animation_player.play("display_cross")
	await animation_player.animation_finished
	await get_tree().create_timer(0.5).timeout
	for card in cards_to_remove:
		if is_instance_valid(card):
			card.queue_free()


func disappear() -> void:
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.5)
	tween.parallel().tween_property(self, "modulate:a", 0, 0.5)
	await tween.finished
	queue_free()
