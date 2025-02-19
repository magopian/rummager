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


var held_card: Card
var card_to_find: Card
var card_datas: Array[Dictionary]

var card_initial_position: Vector2


func _ready() -> void:
	# Setup
	#Global.score = 99 # TODO: REMOVE
	Global.slide_off_screen(menu, 0)  # Move the menu out of the screen
	zones.slide_out(0)
	fade_transition.show_with_progress("Generating cards")
	menu_button.pressed.connect(_on_menu_button_pressed)
	shuffle_button.pressed.connect(_on_shuffle_clicked)
	pick_me_canvas_layer.button_pressed.connect(_on_lets_go_button_pressed)
	lets_go_button.button_pressed.connect(_on_lets_go_button_pressed)
	Global.max_progress.connect(_on_max_progress)
	timer.timeout.connect(zoom_in)
	Global.card_left_screen.connect(_on_card_left_screen)
	Global.target_hit.connect(_on_target_hit)

	# Instantiate cards
	var all_permutations: Array[Dictionary] = Global.get_all_permutations()
	all_permutations.shuffle()
	var level_num_cards: int = Global.level * num_cards
	# Make sure we never try to instantiate more cards than we have.
	var total_num_cards: int = min(level_num_cards, all_permutations.size())
	generate_cards.call_deferred(total_num_cards, all_permutations)


func generate_cards(total_num_cards: int, all_permutations: Array[Dictionary]) -> void:
	var instantiated_cards: Array[Card] = []
	var time_since_last_frame: int = Time.get_ticks_msec()
	for i in range(total_num_cards):
		var card: Card = new_card(all_permutations)
		instantiated_cards.append(card)
		var current_time: int = Time.get_ticks_msec()
		if current_time - time_since_last_frame > 16:  # 60fps -> 16ms per frame
			# Pause every physics frame so the game can continue updating (eg the progress bar)
			# otherwise it would just freeze until all the cards are generated.
			await get_tree().physics_frame
			var generation_progress: float = i * 100.0 / total_num_cards
			fade_transition.progress_value = generation_progress
			time_since_last_frame = current_time
	card_to_find = instantiated_cards[0]
	card_to_find.to_find = true
	instantiated_cards.shuffle()
	for card in instantiated_cards:
		cards.add_child(card)
		card.call_deferred("show_small")
	fade_transition.progress_value = 100
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


func new_card(all_permutations: Array[Dictionary]) -> Card:
	var card: Card = card_scene.instantiate()
	card.clicked.connect(_on_card_clicked)
	card.position = Global.viewport_size / 2
	card.rotation_degrees = randf_range(-20, 20)
	var card_data: Dictionary = all_permutations.pop_back()
	card_datas.append(card_data)
	card.data = card_data
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
	fade_transition.fade_to_file("res://game.tscn", Global.sounds.sound_shuffle)


func _on_lets_go_button_pressed() -> void:
	pick_me_canvas_layer.button_pressed.disconnect(_on_lets_go_button_pressed)
	lets_go_button.button_pressed.disconnect(_on_lets_go_button_pressed)
	play_sound(Global.sounds.sound_shuffle)
	Global.slide_off_screen(level_label, 0.15)
	Global.slide_off_screen(explanation, 0.15)
	Global.slide_in_screen(menu, 0.15)
	shuffle_out()
	var card: Card = card_display.get_child(0)
	var tween: Tween = card.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(card, "global_position", Global.viewport_size / 2, 0.5)
	await card.scale_to(Vector2.ZERO, 0.5)
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
		play_sound(Global.sounds.sound_pickup)
		card.pickup()
		held_card = card
		cards.move_child(card, -1)  # The card will be drawn over the others
		card_initial_position = card.global_position
		timer.start()


func zoom_in() -> void:
	var distance_travelled: float = (held_card.global_position - card_initial_position).length()
	if distance_travelled > 100:
		# We moved the held card, so don't zoom in.
			return
	held_card.zoom_in()
	zones.slide_in(0.15)
	Global.slide_off_screen(menu, 0.15)


func _on_card_left_screen(card: Card) -> void:
	play_sound(Global.sounds.sound_exit_screen)
	var force: float = card.get_force()
	if card == held_card:
		card.held = false
		drop_card()
	if thrown_out_bottom(card):
		if card == card_to_find:
			Music.play_win()
			await explode_out()
			fade_transition.fade_to_file("res://you_win.tscn")
		else:
			var you_lose_scene: YouLose = load("res://you_lose.tscn").instantiate()
			you_lose_scene.lost_reason = "You chose the wrong card"
			you_lose_scene.valid_card_data = card_to_find.data
			you_lose_scene.wrong_card_data = card.data
			await explode_out()
			fade_transition.fade_to_node(you_lose_scene, Global.sounds.sound_lose)
	else:
		if card == card_to_find:
			var you_lose_scene: YouLose = load("res://you_lose.tscn").instantiate()
			you_lose_scene.lost_reason = "You discarded the card you were looking for"
			you_lose_scene.valid_card_data = card_to_find.data
			await explode_out()
			fade_transition.fade_to_node(you_lose_scene, Global.sounds.sound_lose)
		else:
			add_score(round(force))
			card_discarded(card, force)


func _on_target_hit(card: Card) -> void:
	Global.score += 5
	var eject_angle: float = card.linear_velocity.angle() + PI + (PI / 10)
	var eject_position: Vector2 = card.global_position.clamp(Vector2.ZERO, Global.viewport_size)
	card.pop_number(5, eject_position, eject_angle)



func thrown_out_bottom(card: Card) -> bool:
	return (0 < card.position.x and
			card.position.x < Global.viewport_size.x and
			card.position.y > Global.viewport_size.y)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if held_card and !event.pressed:
			play_sound(Global.sounds.sound_drop)
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


func _on_max_progress() -> void:
	progress.animate_max(cards)
