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


func _ready() -> void:
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


func _on_card_left_screen(card: Card) -> void:
	if card == held_card:
		held_card = null
	if card == card_to_find:
		print("YOU LOOSE")


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if held_card and !event.pressed:
			if held_card.is_inside_tree():
				held_card.drop(Input.get_last_mouse_velocity())
			held_card = null


func get_random_position() -> Vector2:
	var viewport_size: Vector2 = get_viewport_rect().size as Vector2
	return Vector2(
		randi_range(50, viewport_size.x - 50),  # The cards are 50x50
		randi_range(50, viewport_size.y - 150)  # Leave some extra space for the bottom menu
	)
