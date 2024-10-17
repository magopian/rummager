extends Node2D


@onready var menu_button: Button = %MenuButton
@onready var shuffle_button: Button = %ShuffleButton
@onready var cards: Node2D = %Cards

@onready var card_scene: PackedScene = preload("res://card.tscn")


@export var num_cards: int = 5


var held_card: Card
var card_to_find: Card


func _ready() -> void:
	menu_button.pressed.connect(_on_menu_button_pressed)
	shuffle_button.pressed.connect(_on_shuffle_button_pressed)
	for i in range(num_cards):
		var card: Card = card_scene.instantiate()
		card.clicked.connect(_on_card_clicked)
		card.left_screen.connect(_on_card_left_screen)
		card.position = get_random_position()
		card.rotation_degrees = randf_range(-20, 20)
		cards.add_child(card)
		if i == 0:
			card_to_find = card
			# TODO: no need for that when we have proper sprites
			card.color = Color("#ff8b40")


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://start_menu.tscn")


func _on_shuffle_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_card_clicked(card: Card) -> void:
	if !held_card:
		card.pickup()
		held_card = card


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
