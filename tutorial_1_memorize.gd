extends Node2D


@onready var menu_button: TextureButton = %MenuButton
@onready var cards: Node2D = %Cards
@onready var pick_me_canvas_layer: CanvasLayer = %PickMeCanvasLayer
@onready var card_display: Control = %CardDisplay
@onready var lets_go_button: AnimatedButton = %LetsGoButton
@onready var zones: CanvasLayer = %Zones
@onready var menu: MarginContainer = %Menu
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var fade_transition: ColorRect = %FadeTransition
@onready var explanation: VBoxContainer = %Explanation
@onready var back_to_menu: Button = %BackToMenu
@onready var timer: Timer = %Timer
@onready var camera_shaker: Node2D = %CameraShaker


@onready var card_scene: PackedScene = preload("res://card.tscn")
@onready var throw_animation_scene: PackedScene = load("res://throw_animation.tscn")
@onready var throw_animation: ThrowAnimation = throw_animation_scene.instantiate()
@onready var bottom_middle: Vector2 = Vector2(Global.viewport_size.x / 2, Global.viewport_size.y + 200)


var held_card: Card
var card_to_find: Card
var card_datas: Array[Dictionary]

var card_initial_position: Vector2


func _ready() -> void:
	# Setup
	Global.call_deferred("slide_off_screen", menu, 0)  # Move the menu out of the screen
	zones.slide_out(0)
	Global.call_deferred("slide_off_screen", explanation, 0)  # Move the explanation out of the screen for now.
	fade_transition.show_with_progress("Generating cards")
	back_to_menu.pressed.connect(_on_menu_button_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)
	timer.timeout.connect(zoom_in)
	Global.card_left_screen.connect(_on_card_left_screen)
	
	# Instantiate cards
	var all_permutations: Array[Dictionary] = Global.get_all_permutations()
	all_permutations.shuffle()
	# Generate cards to scroll through.
	generate_cards.call_deferred(10, all_permutations)


func generate_cards(total_num_cards: int, all_permutations: Array[Dictionary]) -> void:
	var small_scale: Vector2 = Card.compute_small_size(Global.viewport_size)
	for _i in total_num_cards:
		var card: Card = new_card(all_permutations)
		card.small_scale = small_scale
		card_display.add_child(card)
		card.position = Vector2(200, 200)
		card.show_medium()
	pick_me_canvas_layer.show()

	# All ready, fade in
	await fade_transition.fade_in()
	scroll_through_cards()


func scroll_through_cards() -> void:
	var delay: float = 0.02
	while delay < 1:  # Slow the scrolling down
		var card: Card = card_display.get_child(0)
		card_display.move_child(card, -1)  # The card will be drawn over the others
		await get_tree().create_timer(delay).timeout
		delay += smoothstep(0, 1.5, delay)
	card_to_find = card_display.get_child(-1)
	card_to_find.to_find = true
	card_to_find.show_big()
	# Enable the click.
	Global.slide_in_screen(explanation, 0.15)
	await get_tree().create_timer(0.5).timeout
	card_to_find.add_child(throw_animation)
	throw_animation.animate_through([bottom_middle, bottom_middle])  # Make it loop continuously through the same "bottom" direction
	pick_me_canvas_layer.button_pressed.connect(_on_lets_go_button_pressed)
	lets_go_button.button_pressed.connect(_on_lets_go_button_pressed)


func new_card(all_permutations: Array[Dictionary]) -> Card:
	var card: Card = card_scene.instantiate()
	card.clicked.connect(_on_card_clicked)
	card.position = Global.viewport_size / 2
	card.rotation_degrees = randf_range(-20, 20)
	var card_data: Dictionary = all_permutations.pop_back()
	card.data = card_data
	return card


func _on_lets_go_button_pressed() -> void:
	pick_me_canvas_layer.button_pressed.disconnect(_on_lets_go_button_pressed)
	lets_go_button.button_pressed.disconnect(_on_lets_go_button_pressed)
	play_sound(Global.sounds.sound_shuffle)
	for card in (card_display.get_children() as Array[Card]):
		card.reparent(cards)
		card.show_small()
	Global.slide_off_screen(explanation, 0.15)
	Global.slide_in_screen(menu, 0.15)
	shuffle_out()
	pick_me_canvas_layer.queue_free()
	# Add the throw animation, ready to be played
	await get_tree().create_timer(2).timeout


func _on_menu_button_pressed() -> void:
	if is_instance_valid(menu_button):
		menu_button.pressed.disconnect(_on_menu_button_pressed)
	if is_instance_valid(back_to_menu):
		back_to_menu.pressed.disconnect(_on_menu_button_pressed)
	fade_transition.fade_to_file("res://start_menu.tscn")


func play_sound(sound: AudioStream) -> AudioStreamPlayer:
	if audio_stream_player.stream.streams_count == 0:
		audio_stream_player.stream.add_stream(0, sound, 1)
	else:
		audio_stream_player.stream.set_stream(0, sound)
	audio_stream_player.play()
	return audio_stream_player


func shuffle_out() -> void:
	var x: int = 0
	var total_num_cards: float = cards.get_child_count()
	var interval: float = 1 / total_num_cards
	for card in (cards.get_children() as Array[Card]):
		if card == card_to_find:
			var special_position: Vector2 = Vector2(Global.viewport_size.x / 2, Global.viewport_size.y / 4)
			card.shuffle(special_position, x * interval)
		else:
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
		if is_instance_valid(throw_animation):
			throw_animation.queue_free()
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
			throw_animation.queue_free()
			Music.play_win()
			await explode_out()
			var well_done_scene: TutorialWellDone = load("res://tutorial_well_done.tscn").instantiate()
			well_done_scene.next_scene = "res://tutorial_2_discard.tscn"
			well_done_scene.message = "You validated the correct card!"
			fade_transition.fade_to_node(well_done_scene)
		else:
			var you_lose_scene: YouLose = load("res://you_lose.tscn").instantiate()
			you_lose_scene.lost_reason = "You chose the wrong card"
			you_lose_scene.valid_card_data = card_to_find.data
			you_lose_scene.wrong_card_data = card.data
			you_lose_scene.next_scene = get_tree().current_scene.scene_file_path
			await explode_out()
			fade_transition.fade_to_node(you_lose_scene, Global.sounds.sound_lose)
	else:
		if card == card_to_find:
			throw_animation.queue_free()
			var you_lose_scene: YouLose = load("res://you_lose.tscn").instantiate()
			you_lose_scene.lost_reason = "You discarded the card you were looking for"
			you_lose_scene.valid_card_data = card_to_find.data
			you_lose_scene.next_scene = get_tree().current_scene.scene_file_path
			await explode_out()
			fade_transition.fade_to_node(you_lose_scene, Global.sounds.sound_lose)
		else:
			card_discarded(card, force)


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
			throw_animation = throw_animation_scene.instantiate()
			card_to_find.add_child(throw_animation)
			card_to_find.show_small()
			throw_animation.animate_through([bottom_middle, bottom_middle])


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
