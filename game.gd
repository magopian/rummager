extends Node2D


@onready var menu_button: Button = %MenuButton
@onready var shuffle_button: Button = %ShuffleButton
@onready var cards: Node2D = %Cards
@onready var pick_me_canvas_layer: CanvasLayer = %PickMeCanvasLayer
@onready var card_display: Control = %CardDisplay
@onready var lets_go_button: Button = %LetsGoButton

@onready var card_scene: PackedScene = preload("res://card.tscn")


@export var num_cards: int = 50
@export var background_colors: Array[Color]
@export var colors: Array[Color]
@export var patterns: Array[CompressedTexture2D]
@export var borders: Array[CompressedTexture2D]


var held_card: Card
var card_to_find: Card
var card_datas: Array[Dictionary]
var viewport_size: Vector2
var win_zone_display: Polygon2D


func _ready() -> void:
	viewport_size = get_viewport_rect().size
	menu_button.pressed.connect(_on_menu_button_pressed)
	shuffle_button.pressed.connect(_on_shuffle_button_pressed)
	lets_go_button.pressed.connect(_on_lets_go_button_pressed)
	for i in range(num_cards):
		var card: Card = new_card()
		cards.add_child(card)
		if i == 0:
			card_to_find = card
	pick_me_canvas_layer.show()
	display_card_to_find()
	add_win_zone_display()


func display_card_to_find() -> void:
	var card_to_display: Card = card_to_find.duplicate()
	card_display.add_child(card_to_display)
	card_to_display.position = Vector2(200, 200)
	card_to_display.show_big()
	var tween: Tween = lets_go_button.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_loops()
	tween.tween_property(lets_go_button, "scale", Vector2(1.5, 1.5), 0.5)
	tween.tween_property(lets_go_button, "scale", Vector2.ONE, 0.5)


func new_card() -> Card:
	var card: Card = card_scene.instantiate()
	card.clicked.connect(_on_card_clicked)
	card.left_screen.connect(_on_card_left_screen)
	card.position = get_random_position()
	card.rotation_degrees = randf_range(-20, 20)
	var card_data: Dictionary = random_card()
	# TODO: fail after a given number of tries!
	while card_data in card_datas:
		card_data = random_card()
	card_datas.append(card_data)
	card.data = card_data
	card.update_scale(card.small_scale)
	return card


func random_card() -> Dictionary:
	return {
		"background_color": background_colors.pick_random(),
		"color": colors.pick_random(),
		"pattern_sprite": patterns.pick_random(),
		"border_sprite": borders.pick_random(),
	}


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://start_menu.tscn")


func _on_shuffle_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_lets_go_button_pressed() -> void:
	pick_me_canvas_layer.queue_free()


func _on_card_clicked(card: Card) -> void:
	if !held_card:
		card.pickup()
		held_card = card
		cards.move_child(card, -1)  # The card will be drawn over the others
		win_zone_display.show()


func _on_card_left_screen(card: Card) -> void:
	if card == held_card:
		held_card = null
	if thrown_out_bottom(card):
		if card == card_to_find:
			print("YOU WIN")
		else:
			print("YOU LOOSE, WRONG CARD")
	else:
		if card == card_to_find:
			print("YOU LOOSE, DISCARDED CORRECT CARD")


func thrown_out_bottom(card: Card) -> bool:
	return (0 < card.position.x and
			card.position.x < viewport_size.x and
			card.position.y > viewport_size.y)


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if held_card and !event.pressed:
			if held_card.is_inside_tree():
				held_card.drop(Input.get_last_mouse_velocity())
			held_card = null
			win_zone_display.hide()


func get_random_position() -> Vector2:
	return Vector2(
		randi_range(50, viewport_size.x - 50),  # The cards are 50x50
		randi_range(50, viewport_size.y - 150)  # Leave some extra space for the bottom menu
	)


func add_win_zone_display() -> void:
	var points: PackedVector2Array = [
		Vector2(0, viewport_size.y - 100),
		Vector2(viewport_size.x, viewport_size.y - 100),
		Vector2(viewport_size.x, viewport_size.y),
		Vector2(0, viewport_size.y),
	]
	win_zone_display = Polygon2D.new()
	win_zone_display.polygon = points
	win_zone_display.color = Color("00c9b3")
	win_zone_display.hide()
	add_child(win_zone_display)
	move_child(win_zone_display, 0)


func _on_win_area_body_entered(body: Node2D) -> void:
	print("body entered: ", body)
	if body is Card and body == card_to_find:
		print("YOU WIN")
	else:
		print("YOU LOOSE, wrong card")
