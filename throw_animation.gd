class_name ThrowAnimation extends Node2D


@onready var icon: Sprite2D = %Icon
@onready var card: Sprite2D = %Card


var released_icon: Texture2D = load("res://assets/icon_click_1.png")
var clicked_icon: Texture2D = load("res://assets/icon_click_2.png")


func _ready() -> void:
	var icon_size: Vector2 = Card.compute_small_size(Global.viewport_size)
	scale = icon_size
	reset()
	#position = Vector2(100, 100)
	#animate(Vector2(200, 1000))


func animate(to: Vector2) -> void:
	var tween: Tween
	# Display the icon
	tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	tween.set_loops(0)
	tween.tween_property(self, "modulate:a", 1, 0.2)
	tween.parallel().tween_property(icon, "modulate:a", 1, 0.2)
	tween.tween_interval(0.2)
	# Click
	tween.tween_callback(show_clicked)
	# Throw
	tween.tween_interval(0.2)
	## Move to position
	tween.tween_property(self, "global_position", to, 0.5)
	## Release after a bit
	tween.parallel().tween_callback(show_released).set_delay(0.4)
	tween.tween_property(icon, "modulate:a", 0, 0.2)
	# Reset for next loop
	tween.tween_callback(reset)

func show_clicked() -> void:
	icon.texture = clicked_icon
	card.show()


func show_released() -> void:
	icon.texture = released_icon


func reset() -> void:
	position = Vector2.ZERO
	modulate.a = 0
	card.hide()
