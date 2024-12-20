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
@onready var timer: Timer = %Timer
@onready var camera_shaker: Node2D = %CameraShaker
@onready var progress: CanvasLayer = %Progress
@onready var target: CanvasLayer = %Target

@onready var card_scene: PackedScene = preload("res://card.tscn")


@export var num_cards: int = 10
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
	# Setup
	#Global.score = 99 # TODO: REMOVE
	Global.slide_off_screen(menu, 0)  # Move the menu out of the screen
	zones.slide_out(0)
	fade_transition.show()
	menu_button.pressed.connect(_on_menu_button_pressed)
	shuffle_button.pressed.connect(_on_shuffle_clicked)
	pick_me_canvas_layer.button_pressed.connect(_on_lets_go_button_pressed)
	lets_go_button.button_pressed.connect(_on_lets_go_button_pressed)
	Global.max_progress.connect(_on_max_progress)
	timer.timeout.connect(zoom_in)

	# Instantiate cards
	var all_permutations: Array[Dictionary] = get_all_permutations()
	all_permutations.shuffle()
	var level_num_cards: int = Global.level * num_cards
	# Make sure we never try to instantiate more cards than we have.
	var total_num_cards: int = min(level_num_cards, all_permutations.size())
	var instantiated_cards: Array[Card] = []
	for _i in range(total_num_cards):
		var card: Card = new_card(all_permutations)
		instantiated_cards.append(card)
	card_to_find = instantiated_cards[0]
	card_to_find.to_find = true
	instantiated_cards.shuffle()
	for card in instantiated_cards:
		cards.add_child(card)
	pick_me_canvas_layer.show()
	display_card_to_find()

	# All ready, fade in
	await fade_transition.fade_in()
	Global.time_started = Time.get_ticks_msec()


func display_card_to_find() -> void:
	var card_to_display: Card = card_to_find.duplicate()
	card_display.add_child(card_to_display)
	card_to_display.position = Vector2(200, 200)
	card_to_display.show_big()


func animate_button(button: Button) -> void:
	var tween: Tween = button.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_loops()
	tween.tween_property(button, "scale", Vector2(1.5, 1.5), 0.5)
	tween.tween_property(button, "scale", Vector2.ONE, 0.5)


func get_all_permutations() -> Array[Dictionary]:
	var permutations: Array[Dictionary] = []
	for background_color in Palettes.background_colors:
		for color in Palettes.foreground_colors:
			for pattern in patterns:
				for border in borders:
					permutations.push_back({
						"background_color": Global.palettes.get_color(Global.palette, background_color),
						"color":  Global.palettes.get_color(Global.palette, color),
						"pattern_sprite": pattern,
						"border_sprite": border,
					})
	return permutations


func new_card(all_permutations: Array[Dictionary]) -> Card:
	var card: Card = card_scene.instantiate()
	card.clicked.connect(_on_card_clicked)
	card.left_screen.connect(_on_card_left_screen)
	card.position = Global.viewport_size / 2
	card.rotation_degrees = randf_range(-20, 20)
	var card_data: Dictionary = all_permutations.pop_back()
	card_datas.append(card_data)
	card.data = card_data
	card.call_deferred("show_small")
	return card


func _on_menu_button_pressed() -> void:
	menu_button.pressed.disconnect(_on_menu_button_pressed)
	fade_transition.fade_to_file("res://start_menu.tscn")


func play_sound(sound: AudioStream) -> AudioStreamPlayer:
	if audio_stream_player.stream.streams_count == 0:
		audio_stream_player.stream.add_stream(0, sound, 1)
	else:
		audio_stream_player.stream.set_stream(0, sound)
	audio_stream_player.play()
	return audio_stream_player


func _on_shuffle_clicked() -> void:
	shuffle_button.pressed.disconnect(_on_shuffle_clicked)
	await unshuffle().finished
	fade_transition.fade_to_file("res://game.tscn", sound_shuffle)


func _on_lets_go_button_pressed() -> void:
	pick_me_canvas_layer.button_pressed.disconnect(_on_lets_go_button_pressed)
	lets_go_button.button_pressed.disconnect(_on_lets_go_button_pressed)
	play_sound(sound_shuffle)
	Global.slide_off_screen(level_label, 0.15)
	Global.slide_off_screen(explanation, 0.15)
	Global.slide_in_screen(menu, 0.15)
	shuffle_out()
	var card: Card = card_display.get_child(0)
	var tween: Tween = card.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(card, "global_position", Global.viewport_size / 2, 0.5)
	await card.scale_to(Vector2.ZERO, 0.5).finished
	pick_me_canvas_layer.queue_free()
	Global.time_started_rummage = Time.get_ticks_msec()

	# Random target to aim at when discarding a card
	target.random_target()


func shuffle_out() -> void:
	var x: int = 0
	var total_num_cards: float = cards.get_child_count()
	var interval: float = 1 / total_num_cards
	for card in (cards.get_children() as Array[Card]):
		card.shuffle(get_random_position(), x * interval)
		x += 1


func unshuffle() -> Tween:
	var x: int = 0
	var tween: Tween
	var total_num_cards: float = cards.get_child_count()
	var interval: float = 1 / total_num_cards
	for card in (cards.get_children() as Array[Card]):
		tween = card.unshuffle(1, x * interval)
		x += 1
	return tween


func explode_out() -> void:
	var tween: Tween
	var x: int = 0
	var total_num_cards: float = cards.get_child_count()
	var interval: float = 1 / total_num_cards
	for card in (cards.get_children() as Array[Card]):
		if card != card_to_find:
			tween = card.explode_out(x * interval)
		else:
			tween = card.unshuffle(2, 0)
		x += 1
	await tween.finished


func _on_card_clicked(card: Card) -> void:
	if !held_card:
		play_sound(sound_pickup)
		card.pickup()
		held_card = card
		cards.move_child(card, -1)  # The card will be drawn over the others
		timer.start()


func zoom_in() -> void:
	held_card.zoom_in()
	zones.slide_in(0.15)
	Global.slide_off_screen(menu, 0.15)


func _on_card_left_screen(card: Card) -> void:
	Global.discarded_cards += 1
	play_sound(sound_exit_screen)

	var force: float = card.get_force()
	print("force: ", force)

	if card == held_card:
		card.held = false
		drop_card()
	if thrown_out_bottom(card):
		if card == card_to_find:
			Music.play_win()
			await explode_out()
			fade_transition.fade_to_file("res://you_win.tscn")
		else:
			var you_lose_scene = load("res://you_lose.tscn").instantiate()
			you_lose_scene.lost_reason = "You chose the wrong card"
			you_lose_scene.valid_card = card_to_find.duplicate()
			you_lose_scene.wrong_card = card.duplicate()
			await explode_out()
			fade_transition.fade_to_node(you_lose_scene, sound_lose)
	else:
		if card == card_to_find:
			var you_lose_scene = load("res://you_lose.tscn").instantiate()
			you_lose_scene.lost_reason = "You discarded the card you were looking for"
			you_lose_scene.valid_card = card_to_find.duplicate()
			await explode_out()
			fade_transition.fade_to_node(you_lose_scene, sound_lose)
		else:
			add_score(round(force))
			card_discarded(card, force)


func thrown_out_bottom(card: Card) -> bool:
	return (0 < card.position.x and
			card.position.x < Global.viewport_size.x and
			card.position.y > Global.viewport_size.y)


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if held_card and !event.pressed:
			timer.stop()
			play_sound(sound_drop)
			if held_card.is_inside_tree():
				held_card.drop(Input.get_last_mouse_velocity())
			drop_card()


func drop_card() -> void:
	timer.stop()
	held_card = null
	zones.slide_out(0.15)
	Global.slide_in_screen(menu, 0.15)


func get_random_position() -> Vector2:
	return Vector2(
		randf_range(50, Global.viewport_size.x - 50),  # The cards are 50x50
		randf_range(150, Global.viewport_size.y - 150)  # Leave some extra space for the bottom menu
	)


func card_discarded(card: Card, force: float) -> void:
	camera_shaker.apply_shake(force)
	card.discard(force)


func add_score(score: int) -> void:
	Global.score += round(score)
	print("score: ", Global.score)

func _on_max_progress() -> void:
	progress.animate_max(cards)
