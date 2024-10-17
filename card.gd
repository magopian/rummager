class_name Card extends RigidBody2D


signal clicked


@onready var polygon_2d: Polygon2D = $Polygon2D


@export var color: Color = Color("#a22fc9")

var held = false


func _ready() -> void:
	input_event.connect(_on_input_event)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			clicked.emit(self)


func _physics_process(_delta) -> void:
	polygon_2d.color = color
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
