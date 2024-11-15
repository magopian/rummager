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
var viewport_size: Vector2


func _ready() -> void:
	viewport_size = get_viewport_rect().size
	slide_off_screen(menu, 0)  # Move the menu out of the screen
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
	card.position = viewport_size / 2
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
	slide_off_screen(level_label, 0.15)
	slide_off_screen(explanation, 0.15)
	slide_in_screen(menu, 0.15)
	var card: Card = card_display.get_child(0)
	await card.scale_to(Vector2.ZERO, 0.5).finished
	pick_me_canvas_layer.queue_free()
	shuffle_cards()


func slide_in_screen(node: Node, duration: float) -> Tween:
	var initial_position: Vector2 = node.get_meta("initial_position", Vector2.ZERO)
	var tween: Tween = node.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(node, "global_position", initial_position, duration)
	return tween


func slide_off_screen(node: Node, duration: float) -> Tween:
	print("viewport_size: ", viewport_size)
	print("node: ", node)
	print("node global position: ", node.global_position)
	print("node size: ", node.size)
	# Distance from the bottom of the node to the top of the screen (y = 0)
	var distance_to_top: float = node.global_position.y + node.size.y
	var distance_to_top_norm: float = distance_to_top / viewport_size.y
	print("distance to top: ", distance_to_top, " - norm: ", distance_to_top_norm)
	
	# Distance from the top of the node to the bottom of the screen
	var distance_to_bottom: float = viewport_size.y - node.global_position.y
	var distance_to_bottom_norm: float = distance_to_bottom / viewport_size.y
	print("distance to bottom: ", distance_to_bottom, " - norm: ", distance_to_bottom_norm)
	
	# Distance from the right side of the node to the left of the screen (x = 0)
	var distance_to_left: float = node.global_position.x + node.size.x
	var distance_to_left_norm: float = distance_to_left / viewport_size.x
	print("distance to left: ", distance_to_left, " - norm: ", distance_to_left_norm)
	
	# Distance from the left side of the node to the right of the screen
	var distance_to_right: float = viewport_size.x - node.global_position.x
	var distance_to_right_norm: float = distance_to_right / viewport_size.x
	print("distance to right: ", distance_to_right, " - norm: ", distance_to_right_norm)
	
	var new_position: Vector2 = node.global_position
	var min_distance_norm: float = min(distance_to_top_norm, distance_to_bottom_norm, distance_to_left_norm, distance_to_right_norm)
	match min_distance_norm:
		distance_to_top_norm:
			new_position.y -= distance_to_top
		distance_to_bottom_norm:
			new_position.y += distance_to_bottom
		distance_to_left_norm:
			new_position.x -= distance_to_left
		distance_to_right_norm:
			new_position.x += distance_to_right
	print("new position: ", new_position)
	
	if node.get_meta("initial_position", Vector2.ZERO) != Vector2.ZERO:  # Only set the initial position if it wasn't set yet
		node.set_meta("initial_position", node.global_position)
	var tween: Tween = node.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(node, "global_position", new_position, duration)
	return tween


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
		slide_off_screen(menu, 0.15)
		


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
			card.position.x < viewport_size.x and
			card.position.y > viewport_size.y)


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if held_card and !event.pressed:
			play_sound(sound_drop)
			if held_card.is_inside_tree():
				held_card.drop(Input.get_last_mouse_velocity())
			held_card = null
			zones.hide()
			slide_in_screen(menu, 0.15)


func get_random_position() -> Vector2:
	return Vector2(
		randi_range(50, viewport_size.x - 50),  # The cards are 50x50
		randi_range(150, viewport_size.y - 150)  # Leave some extra space for the bottom menu
	)
