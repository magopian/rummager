extends Node2D


@onready var menu_button: TextureButton = %MenuButton
@onready var shuffle_button: TextureButton = %ShuffleButton
@onready var cards: Node2D = %Cards
@onready var pick_me_canvas_layer: CanvasLayer = %PickMeCanvasLayer
@onready var level_label: Label = %LevelLabel
@onready var card_display: Control = %CardDisplay
@onready var lets_go_button: AnimatedButton = %LetsGoButton
@onready var zones: CanvasLayer = %Zones
@onready var menu: MarginContainer = %Menu
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var fade_transition: ColorRect = %FadeTransition
@onready var explanation: VBoxContainer = %Explanation

@onready var card_scene: PackedScene = preload("res://card.tscn")


@export var num_cards: int = 10
@export var background_colors: Array[Color]
@export var colors: Array[Color]
@export var patterns: Array[CompressedTexture2D]
@export var borders: Array[CompressedTexture2D]
@export var sound_shuffle: AudioStream
@export var sound_lose: AudioStream
@export var sound_pickup: AudioStream
@export var sound_drop: AudioStream
@export var sound_exit_screen: AudioStream


var held_card: Card
var card_to_find: Card
var card_datas: Array[Dictionary]


func _ready() -> void:
	Global.slide_off_screen(menu, 0)  # Move the menu out of the screen
	fade_transition.show()
	menu_button.pressed.connect(_on_menu_button_pressed)
	shuffle_button.pressed.connect(shuffle)
	pick_me_canvas_layer.button_pressed.connect(_on_lets_go_button_pressed)
	lets_go_button.button_pressed.connect(_on_lets_go_button_pressed)
	for i in range(Global.level * num_cards):
		var card: Card = new_card()
		cards.add_child(card)
		if i == 0:
			card_to_find = card
	pick_me_canvas_layer.show()
	display_card_to_find()
	await fade_transition.fade_in()


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
	card.position = Global.viewport_size / 2
	card.rotation_degrees = randf_range(-20, 20)
	var card_data: Dictionary = random_card()
	# TODO: fail after a given number of tries!
	while card_data in card_datas:
		card_data = random_card()
	card_datas.append(card_data)
	card.data = card_data
	card.call_deferred("show_small")
	return card


func random_card() -> Dictionary:
	return {
		"background_color": background_colors.pick_random(),
		"color": colors.pick_random(),
		"pattern_sprite": patterns.pick_random(),
		"border_sprite": borders.pick_random(),
	}


func _on_menu_button_pressed() -> void:
	fade_transition.fade_to_file("res://start_menu.tscn")


func play_sound(sound: AudioStream) -> AudioStreamPlayer:
	audio_stream_player.stream = sound
	audio_stream_player.play()
	return audio_stream_player


func shuffle() -> void:
	fade_transition.fade_to_file("res://game.tscn", sound_shuffle)


func _on_lets_go_button_pressed() -> void:
	play_sound(sound_shuffle)
	Global.slide_off_screen(level_label, 0.15)
	Global.slide_off_screen(explanation, 0.15)
	Global.slide_in_screen(menu, 0.15)
	var card: Card = card_display.get_child(0)
	await card.scale_to(Vector2.ZERO, 0.5).finished
	pick_me_canvas_layer.queue_free()
	shuffle_cards()


func shuffle_cards() -> void:
	var x: int = 0
	for card in cards.get_children():
		var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		var random_position: Vector2 = get_random_position()
		tween.tween_interval(x * 0.01)
		tween.tween_property(card, "position", random_position, 1)
		x += 1


func _on_card_clicked(card: Card) -> void:
	if !held_card:
		play_sound(sound_pickup)
		card.pickup()
		held_card = card
		cards.move_child(card, -1)  # The card will be drawn over the others
		zones.show()
		Global.slide_off_screen(menu, 0.15)
		


func _on_card_left_screen(card: Card) -> void:
	play_sound(sound_exit_screen)
	if card == held_card:
		held_card = null
	if thrown_out_bottom(card):
		if card == card_to_find:
			Music.play_win()
			fade_transition.fade_to_file("res://you_win.tscn")
		else:
			var you_lose_scene = load("res://you_lose.tscn").instantiate()
			you_lose_scene.lost_reason = "You chose the wrong card"
			you_lose_scene.valid_card = card_to_find.duplicate()
			you_lose_scene.wrong_card = card.duplicate()
			fade_transition.fade_to_node(you_lose_scene, sound_lose)
	else:
		if card == card_to_find:
			var you_lose_scene = load("res://you_lose.tscn").instantiate()
			you_lose_scene.lost_reason = "You discarded the card you were looking for"
			you_lose_scene.valid_card = card_to_find.duplicate()
			fade_transition.fade_to_node(you_lose_scene, sound_lose)


func thrown_out_bottom(card: Card) -> bool:
	return (0 < card.position.x and
			card.position.x < Global.viewport_size.x and
			card.position.y > Global.viewport_size.y)


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if held_card and !event.pressed:
			play_sound(sound_drop)
			if held_card.is_inside_tree():
				held_card.drop(Input.get_last_mouse_velocity())
			held_card = null
			zones.hide()
			Global.slide_in_screen(menu, 0.15)


func get_random_position() -> Vector2:
	return Vector2(
		randi_range(50, Global.viewport_size.x - 50),  # The cards are 50x50
		randi_range(150, Global.viewport_size.y - 150)  # Leave some extra space for the bottom menu
	)
