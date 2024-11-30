class_name BonusCard extends Sprite2D


@onready var card_container: Node2D = %CardContainer
@onready var background: Sprite2D = %Background
@onready var pattern: Sprite2D = %Pattern
@onready var border: Sprite2D = %Border
@onready var color: Sprite2D = %Color


var characteristic: String
var bonus_value


func _ready() -> void:
	card_container.modulate.a = 0
	match characteristic:
		"background_color":
			background.modulate = bonus_value
		"color":
			color.modulate = bonus_value
		"pattern_sprite":
			pattern.texture = bonus_value
			pattern.modulate = Color.BLACK
		"border_sprite":
			border.texture = bonus_value
			border.modulate = Color.BLACK


func init_random(cards: Node) -> void:
	characteristic = Card.charac_to_property[Card.characteristics.pick_random()]
	var random_data: Dictionary = cards.get_children().pick_random().data
	bonus_value = random_data[characteristic]


func display_bonus() -> void:
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(card_container, "modulate:a", 1, 2)
	tween.parallel().tween_property(card_container, "rotation_degrees", 360 * 3, 2)
	await tween.finished

func remove_cards(cards_container: Node) -> void:
	await display_bonus()
	
	var cards_to_remove: Array[Card] = []
	for card in (cards_container.get_children() as Array[Card]):
		if card.to_find:  # Don't destroy the card to find!
			continue
		if card.data[characteristic] == bonus_value:
			cards_to_remove.push_back(card)
	var total_cards_to_remove: int = cards_to_remove.size()
	print("cards to remove: ", total_cards_to_remove)

	var center: Vector2 = Global.viewport_size / 2
	var interval: float = 0
	if total_cards_to_remove:
		interval = 1.0 / cards_to_remove.size()
	prints("remove cards interval:", interval)
	var tween: Tween
	var x: int = 0
	for card in cards_to_remove:
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_interval(x * interval)
		tween.tween_property(card, "position", center, 1)
		tween.parallel().tween_property(card, "scale", Vector2.ZERO, 1)
		tween.tween_callback(card.queue_free)
		x += 1
	await get_tree().create_timer(1.5).timeout


func disappear() -> void:
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.5)
	tween.parallel().tween_property(self, "modulate:a", 0, 0.5)
	await tween.finished
	queue_free()
