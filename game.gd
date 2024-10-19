extends Node2D


@onready var menu_button: Button = %MenuButton
@onready var shuffle_button: Button = %ShuffleButton
@onready var cards: Node2D = %Cards
@onready var pick_me_canvas_layer: CanvasLayer = %PickMeCanvasLayer
@onready var level_label: Label = %LevelLabel
@onready var card_display: Control = %CardDisplay
@onready var lets_go_button: AnimatedButton = %LetsGoButton
@onready var you_win_canvas_layer: CanvasLayer = %YouWinCanvasLayer
@onready var next_level_button: AnimatedButton = %NextLevelButton
@onready var you_lose_canvas_layer: CanvasLayer = %YouLoseCanvasLayer
@onready var lost_reason: Label = %LostReason
@onready var try_again_button: AnimatedButton = %TryAgainButton
@onready var card_display_correct: Control = %CardDisplayCorrect
@onready var card_display_wrong: Control = %CardDisplayWrong
@onready var valid_container: HBoxContainer = %ValidContainer
@onready var wrong_container: HBoxContainer = %WrongContainer
@onready var zones: CanvasLayer = %Zones
@onready var menu_canvas_layer: CanvasLayer = %MenuCanvasLayer

@onready var card_scene: PackedScene = preload("res://card.tscn")


@export var num_cards: int = 10
@export var background_colors: Array[Color]
@export var colors: Array[Color]
@export var patterns: Array[CompressedTexture2D]
@export var borders: Array[CompressedTexture2D]


var held_card: Card
var card_to_find: Card
var card_datas: Array[Dictionary]
var viewport_size: Vector2


func _ready() -> void:
	viewport_size = get_viewport_rect().size
	menu_button.pressed.connect(_on_menu_button_pressed)
	next_level_button.button_pressed.connect(_on_shuffle_button_pressed)
	try_again_button.button_pressed.connect(_on_shuffle_button_pressed)
	shuffle_button.pressed.connect(_on_shuffle_button_pressed)
	lets_go_button.button_pressed.connect(_on_lets_go_button_pressed)
	level_label.text += str(Global.level)
	for i in range(Global.level * num_cards):
		var card: Card = new_card()
		cards.add_child(card)
		if i == 0:
			card_to_find = card
	pick_me_canvas_layer.show()
	display_card_to_find()


func display_card_to_find() -> void:
	var card_to_display: Card = card_to_find.duplicate()
	card_display.add_child(card_to_display)
	card_to_display.show_big()


func animate_button(button: Button) -> void:
	var tween: Tween = button.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_loops()
	tween.tween_property(button, "scale", Vector2(1.5, 1.5), 0.5)
	tween.tween_property(button, "scale", Vector2.ONE, 0.5)


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
		zones.show()
		menu_canvas_layer.hide()
		


func _on_card_left_screen(card: Card) -> void:
	if card == held_card:
		held_card = null
	if thrown_out_bottom(card):
		if card == card_to_find:
			you_win_canvas_layer.show()
			Music.play_win()
			Global.level += 1
		else:
			var correct_card: Card = card_to_find.duplicate()
			card_display_correct.add_child(correct_card)
			correct_card.show_medium()
			var wrong_card: Card = card.duplicate()
			card_display_wrong.add_child(wrong_card)
			wrong_card.show_medium()
			you_lose_canvas_layer.show()
			valid_container.show()
			wrong_container.show()
			lost_reason.text = "You chose the wrong card"
			Global.level = 1
	else:
		if card == card_to_find:
			var correct_card: Card = card_to_find.duplicate()
			card_display_correct.add_child(correct_card)
			correct_card.show_medium()
			you_lose_canvas_layer.show()
			wrong_container.hide()
			lost_reason.text = "You discarded the card you were looking for"
			Global.level = 1


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
			zones.hide()
			menu_canvas_layer.show()


func get_random_position() -> Vector2:
	return Vector2(
		randi_range(50, viewport_size.x - 50),  # The cards are 50x50
		randi_range(50, viewport_size.y - 150)  # Leave some extra space for the bottom menu
	)
