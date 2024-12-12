class_name AnimatedButton extends Control


signal button_pressed


@onready var button: Button = %Button


@export var text: String = "placeholder"
@export var font_size: int = 40
@export var outline_size: int = 8


func _ready() -> void:
	button.pressed.connect(_on_button_pressed)
	button.text = text
	button.add_theme_constant_override("outline_size", outline_size)
	button.add_theme_constant_override("font_size",  font_size)
	button.pivot_offset = Vector2(button.size.x / 2, button.size.y / 2)
	
	var tween: Tween = button.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_loops()
	tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.5)
	tween.tween_property(button, "scale", Vector2.ONE, 0.5)



func _on_button_pressed() -> void:
	button_pressed.emit()
