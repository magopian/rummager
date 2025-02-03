class_name ThrowAnimation extends Node2D


@onready var icon: Sprite2D = %Icon
@onready var card: Sprite2D = %Card
@onready var card_validation: CardValidation = %CardValidation


var released_icon: Texture2D = load("res://assets/icon_click_1.png")
var clicked_icon: Texture2D = load("res://assets/icon_click_2.png")
var mid_throw: Vector2
var tween: Tween


func animate(to: Vector2) -> void:
	reset(to)
	# Display the icon
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 1, 0.2)
	tween.tween_interval(0.2)
	# Click
	tween.tween_callback(show_clicked)
	tween.tween_callback(card.show)
	# Throw
	tween.tween_interval(0.2)
	## Move to position
	tween.tween_property(self, "global_position", mid_throw, 0.4)
	## Release after a bit
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_callback(show_released)
	tween.tween_callback(card.show)
	tween.parallel().tween_property(card, "global_position", to, 0.4)
	await tween.finished


func animate_through(to_list: Array[Vector2]) -> void:
	for to in to_list:
		if not is_inside_tree():
			return
		await animate(to)
	animate_through.call_deferred(to_list)


func animate_validation(from: Vector2) -> void:
	reset(Vector2.ZERO)
	card.hide()
	card_validation.hide()
	position = from
	# Display the icon
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 1, 0.2)
	tween.tween_interval(0.2)
	# Click
	tween.tween_callback(show_released)
	# Throw
	tween.tween_interval(0.2)
	## Move to position
	tween.tween_property(self, "position", Vector2.ZERO, 1)
	tween.tween_interval(0.2)
	await tween.finished
	show_clicked()
	await card_validation.start_validating()
	await card_validation.play_validated()
	hide_pointer()
	animate_validation.call_deferred(from)


func show_pointer() -> void:
	icon.show()


func hide_pointer() -> void:
	icon.hide()


func show_clicked() -> void:
	icon.texture = clicked_icon
	show_pointer()


func show_released() -> void:
	show_pointer()
	icon.texture = released_icon


func reset(to: Vector2) -> void:
	position = Vector2.ZERO
	card.position = Vector2.ZERO
	icon.position = Vector2.ZERO
	modulate.a = 0
	card.hide()
	mid_throw = (to - self.global_position) / 2 + self.global_position
