extends Node2D


signal max_progress
signal palette_changed(palette_index: int)
signal target_hit(card: Card)
signal card_left_screen(card: Card)


@export var level: int:
	get:
		return user_prefs.level
	set(new_level):
		user_prefs.level = new_level
		user_prefs.save()
@export var palette: int:
	get:
		return user_prefs.palette
	set(new_palette):
		user_prefs.palette = new_palette
		user_prefs.save()
		palette_changed.emit(new_palette)


@onready var user_prefs: UserPreferences
@onready var palettes: Palettes = load("res://palettes.tres")

var viewport_size: Vector2

var discarded_cards: int = 0
var target_hit_count: int = 0
var time_started: int = 0
var time_started_rummage: int = 0
var score: int = 0
var bonus_cards: int = 0


func _ready() -> void:
	user_prefs = UserPreferences.load_or_create()
	viewport_size = get_viewport_rect().size
	get_tree().root.size_changed.connect(_on_viewport_resized)
	target_hit.connect(_on_target_hit)
	card_left_screen.connect(_on_card_left_screen)
	max_progress.connect(_on_max_progress)


func _on_target_hit(_card: Card) -> void:
	target_hit_count += 1


func _on_card_left_screen(_card: Card) -> void:
	discarded_cards += 1


func _on_max_progress() -> void:
	bonus_cards += 1


func change_palette() -> void:
	palette = get_next_palette()


func get_next_palette() -> int:
	var num_palettes: int = palettes.palettes.size()
	return (palette + 1) % num_palettes


func _on_viewport_resized() -> void:
	viewport_size = get_viewport_rect().size


func slide_in_screen(node: Node, duration: float) -> Tween:
	var initial_position: Vector2 = node.get_meta("initial_position", Vector2.ZERO)
	#print("metadata: ", initial_position)
	var tween: Tween = node.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(node, "global_position", initial_position, duration)
	return tween


func slide_off_screen(node: Node, duration: float) -> Tween:
	#print("viewport_size: ", viewport_size)
	#print("node: ", node)
	#print("node global position: ", node.global_position)
	#print("node size: ", node.size)
	
	# Distance from the bottom of the node to the top of the screen (y = 0)
	var distance_to_top: float = node.global_position.y + node.size.y
	var distance_to_top_norm: float = distance_to_top / viewport_size.y
	#print("distance to top: ", distance_to_top, " - norm: ", distance_to_top_norm)
	
	# Distance from the top of the node to the bottom of the screen
	var distance_to_bottom: float = viewport_size.y - node.global_position.y
	var distance_to_bottom_norm: float = distance_to_bottom / viewport_size.y
	#print("distance to bottom: ", distance_to_bottom, " - norm: ", distance_to_bottom_norm)
	
	# Distance from the right side of the node to the left of the screen (x = 0)
	var distance_to_left: float = node.global_position.x + node.size.x
	var distance_to_left_norm: float = distance_to_left / viewport_size.x
	#print("distance to left: ", distance_to_left, " - norm: ", distance_to_left_norm)
	
	# Distance from the left side of the node to the right of the screen
	var distance_to_right: float = viewport_size.x - node.global_position.x
	var distance_to_right_norm: float = distance_to_right / viewport_size.x
	#print("distance to right: ", distance_to_right, " - norm: ", distance_to_right_norm)
	
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
	#print("new position: ", new_position)
	
	if not node.has_meta("initial_position"):
		#print("setting metadata: ", node.global_position)
		node.set_meta("initial_position", node.global_position)
	var tween: Tween = node.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(node, "global_position", new_position, duration)
	return tween
