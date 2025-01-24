class_name ThrowAnimation extends Node2D


@onready var icon: Sprite2D = %Icon
@onready var card: Sprite2D = %Card


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
	# Throw
	tween.tween_interval(0.2)
	## Move to position
	tween.tween_property(self, "global_position", mid_throw, 0.4)
	## Release after a bit
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_callback(show_released)
	tween.parallel().tween_property(card, "global_position", to, 0.4)
	await tween.finished


func animate_through(to_list: Array[Vector2]) -> void:
	for to in to_list:
		if not is_inside_tree():
			return
		await animate(to)
	animate_through.call_deferred(to_list)


func show_clicked() -> void:
	icon.texture = clicked_icon
	card.show()


func show_released() -> void:
	icon.texture = released_icon


func reset(to: Vector2) -> void:
	position = Vector2.ZERO
	card.position = Vector2.ZERO
	icon.position = Vector2.ZERO
	modulate.a = 0
	card.hide()
	mid_throw = (to - self.global_position) / 2 + self.global_position
