class_name Card extends RigidBody2D


signal clicked(card: Card)
signal left_screen(card: Card)


@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D
@onready var background: Polygon2D = %Background
@onready var pattern: Sprite2D = %Pattern
@onready var border: Sprite2D = %Border


@export var background_color: Color
@export var color: Color
@export var pattern_sprite: CompressedTexture2D
@export var border_sprite: CompressedTexture2D


var held = false


func _ready() -> void:
	input_event.connect(_on_input_event)
	visible_on_screen_notifier_2d.screen_exited.connect(_on_exit_screen)
	background.color = background_color
	pattern.texture = pattern_sprite
	pattern.modulate = color
	border.texture = border_sprite
	border.modulate = color


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			clicked.emit(self)


func _on_exit_screen() -> void:
	left_screen.emit(self)
	queue_free()


func _physics_process(_delta) -> void:
	if held:
		global_transform.origin = get_global_mouse_position()


func pickup() -> void:
	if held:
		return
	freeze = true
	held = true


func drop(impulse=Vector2.ZERO) -> void:
	if held:
		freeze = false
		apply_central_impulse(impulse)
		held = false
