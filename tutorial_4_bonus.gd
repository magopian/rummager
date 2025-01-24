extends Node2D


@onready var menu_button: TextureButton = %MenuButton
@onready var cards: Node2D = %Cards
@onready var pick_me_canvas_layer: CanvasLayer = %PickMeCanvasLayer
@onready var memorize_card_display: Control = %MemorizeCardDisplay
@onready var cards_and_target_container: HBoxContainer = %CardsAndTargetContainer
@onready var card_display: Control = %CardDisplay
@onready var bonus_card_container: Control = %BonusCardContainer
@onready var bonus_charactheristic: Label = %BonusCharactheristic
@onready var lets_go_button: AnimatedButton = %LetsGoButton
@onready var zones: CanvasLayer = %Zones
@onready var menu: MarginContainer = %Menu
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var fade_transition: ColorRect = %FadeTransition
@onready var explanation: VBoxContainer = %Explanation
@onready var back_to_menu: Button = %BackToMenu
@onready var timer: Timer = %Timer
@onready var camera_shaker: Node2D = %CameraShaker
@onready var progress: CanvasLayer = %Progress
@onready var target: CanvasLayer = %Target


@onready var card_scene: PackedScene = preload("res://card.tscn")
@onready var bonus_card_scene: PackedScene = preload("res://bonus_card.tscn")
@onready var all_permutations: Array[Dictionary]


var held_card: Card
var card_to_find: Card
var card_datas: Array[Dictionary]

var card_initial_position: Vector2
var bonus_properties: Array = Card.properties


func _ready() -> void:
	# Setup
	Global.score = 99
	Global.call_deferred("slide_off_screen", menu, 0)  # Move the menu out of the screen
	zones.slide_out(0)
	Global.call_deferred("slide_off_screen", explanation, 0)  # Move the explanation out of the screen for now.
	fade_transition.show_with_progress("Generating cards")
	back_to_menu.pressed.connect(_on_menu_button_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)
	Global.max_progress.connect(_on_max_progress)
	timer.timeout.connect(zoom_in)
	Global.card_left_screen.connect(_on_card_left_screen)
	Global.target_hit.connect(_on_target_hit)
	all_permutations = Global.get_all_permutations()
	all_permutations.shuffle()
	# Generate cards.
	generate_card_to_find.call_deferred()
	animate_bonus.call_deferred()

	pick_me_canvas_layer.button_pressed.connect(_on_lets_go_button_pressed)
	lets_go_button.button_pressed.connect(_on_lets_go_button_pressed)


func animate_bonus() -> void:
	var all_permutations_copy: Array[Dictionary] = all_permutations.duplicate()
	for card in card_display.get_children():
		card.queue_free()
	generate_discard_cards(10)
	var bonus_card: BonusCard = bonus_card_scene.instantiate()
	var property: String = bonus_properties.pop_front()
	bonus_properties.append(property)
	bonus_card.init_random(card_display, property)
	match bonus_card.characteristic:
		"background_color":
			bonus_charactheristic.text = "(Match by background color)"
		"color":
			bonus_charactheristic.text = "(Match by drawing color)"
		"pattern_sprite":
			bonus_charactheristic.text = "(Match by pattern type)"
		"border_sprite":
			bonus_charactheristic.text = "(Match by border type)"
	bonus_card_container.add_child(bonus_card)
	prints("Animate max with bonus card:", bonus_card.characteristic, bonus_card.bonus_value)
	bonus_card.scale = bonus_card.scale / 2
	await bonus_card.remove_cards(card_display, null)
	enable_click()
	#await bonus_card.disappear()
	bonus_card.queue_free()
	all_permutations = all_permutations_copy
	animate_bonus()


func enable_click() -> void:
	Global.slide_in_screen(explanation, 0.15)


func generate_card_to_find() -> void:
	var small_scale: Vector2 = Card.compute_small_size(Global.viewport_size)
	# Create the card to memorize
	card_to_find = new_card()
	card_to_find.small_scale = small_scale
	memorize_card_display.add_child(card_to_find)
	card_to_find.position = memorize_card_display.size / 2
	card_to_find.show_medium()


func generate_discard_cards(num_cards: int) -> void:
	var small_scale: Vector2 = Card.compute_small_size(Global.viewport_size)
	for _i in num_cards:
		var card: Card = new_card()
		card.small_scale = small_scale
		card_display.add_child(card)
		card.position = card_display.size / 2
		card.show_small()
	pick_me_canvas_layer.show()

	# All ready, fade in
	await fade_transition.fade_in()


func new_card() -> Card:
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
	# Reparent the card to memorize, and place it  lowest so it's at the bottom of the pile
	card_to_find.reparent(cards)
	card_to_find.show_small()
	# Reparent all the other cards to discard
	for card in (card_display.get_children() as Array[Card]):
		card.reparent(cards)
	# Hide explanation, display menu: game time.
	Global.slide_off_screen(explanation, 0.15)
	Global.slide_in_screen(menu, 0.15)
	shuffle_out()
	# Random target to aim at when discarding a card
	target.random_target()
	pick_me_canvas_layer.queue_free()
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
		if x <= 1:
			# Both the card to find (index 0) and the lowest discard card (index 1) will be positioned at the "special position"
			# which means that the card to find will be just below the lowest card to discard
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
			var well_done_scene: TutorialWellDone = load("res://tutorial_well_done.tscn").instantiate()
			well_done_scene.next_scene = "res://game.tscn"
			well_done_scene.message = "You reached the end of the tutorial!"
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
			var you_lose_scene: YouLose = load("res://you_lose.tscn").instantiate()
			you_lose_scene.lost_reason = "You discarded the card you were looking for"
			you_lose_scene.valid_card_data = card_to_find.data
			you_lose_scene.next_scene = get_tree().current_scene.scene_file_path
			await explode_out()
			fade_transition.fade_to_node(you_lose_scene, Global.sounds.sound_lose)
		else:
			add_score(round(force))
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


func _on_target_hit(card: Card) -> void:
	Global.score += 5
	var eject_angle: float = card.linear_velocity.angle() + PI + (PI / 10)
	var eject_position: Vector2 = card.global_position.clamp(Vector2.ZERO, Global.viewport_size)
	card.pop_number(5, eject_position, eject_angle)


func _on_max_progress() -> void:
	progress.animate_max(cards)
