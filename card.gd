class_name Card extends RigidBody2D


signal clicked(card: Card)
signal left_screen(card: Card)


@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D
@onready var background: Sprite2D = %Background
@onready var pattern: Sprite2D = %Pattern
@onready var border: Sprite2D = %Border


@export var small_scale: Vector2 = Vector2(0.16, 0.16)
@export var medium_scale: Vector2 = Vector2(0.5, 0.5)
@export var data: Dictionary


var held = false
var tween: Tween


func _ready() -> void:
	input_event.connect(_on_input_event)
	visible_on_screen_notifier_2d.screen_exited.connect(_on_exit_screen)
	compute_small_size(get_viewport_rect().size)
	get_viewport().physics_object_picking_sort = true
	init_from_data()


func compute_small_size(viewport_size: Vector2) -> void:
	var smallest_size: int = min(viewport_size.x, viewport_size.y)
	viewport_size.normalized()
	# smallest_size = 414 => small_scale = 0.16
	var scale_size: float = smallest_size * 0.16 / 414
	small_scale = Vector2(scale_size, scale_size)


func init_from_data() -> void:
	background.modulate = data["background_color"]
	pattern.texture = data["pattern_sprite"]
	pattern.modulate = data["color"]
	border.texture = data["border_sprite"]
	border.modulate = data["color"]


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			clicked.emit(self)
			get_viewport().set_input_as_handled()


func _on_exit_screen() -> void:
	left_screen.emit(self)
	call_deferred("queue_free")


func _physics_process(_delta) -> void:
	if held:
		global_transform.origin = get_global_mouse_position()


func pickup() -> void:
	if held:
		return
	freeze = true
	held = true
	show_big()


func show_big() -> void:
	animate_scale(Vector2(1, 1))
	position = Vector2(200, 200)
	animate_card()


func animate_card() -> void:	
	tween = get_tree().create_tween().bind_node(self).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_loops()
	tween.tween_property(self, "rotation_degrees", rotation_degrees + 5, 1)
	tween.tween_property(self, "rotation_degrees", rotation_degrees - 5, 1)


func show_small() -> void:
	animate_scale(small_scale)
	if tween:
		tween.stop()


func show_medium() -> void:
	update_scale(medium_scale)
	freeze = true
	position = Vector2(100, 100)
	animate_card()


func drop(impulse=Vector2.ZERO) -> void:
	if held:
		freeze = false
		apply_central_impulse(impulse)
		held = false
		show_small()


func update_scale(new_scale: Vector2) -> void:
	for child in get_children():
		child.scale = new_scale


func animate_scale(new_scale: Vector2) -> void:
	var scale_tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	for child in get_children():
		scale_tween.tween_property(child, "scale", new_scale, 0.15)
