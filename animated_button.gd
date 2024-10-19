class_name AnimatedButton extends Control


signal button_pressed


@onready var button: Button = %Button


@export var text: String = "placeholder"
@export var font_size: int = 40
@export var color: Color = Color("#290143")
@export var outline_color: Color = Color("#fff4b8")
@export var outline_size: int = 8
@export var focus_color: Color = Color("#a22fc9")


func _ready() -> void:
	button.pressed.connect(_on_button_pressed)
	button.text = text
	button.add_theme_color_override("font_hover_pressed_color", focus_color)
	button.add_theme_color_override("font_hover_color", focus_color)
	button.add_theme_color_override("font_pressed_color", focus_color)
	button.add_theme_color_override("font_focus_color", focus_color)
	button.add_theme_color_override("font_color", color)
	button.add_theme_color_override("font_outline_color", outline_color)
	button.add_theme_constant_override("outline_size", outline_size)
	button.add_theme_constant_override("font_size",  font_size)
	button.pivot_offset = Vector2(button.size.x / 2, button.size.y / 2)
	print("button.size: ", text, " - ", button.size)
	print("button.pivot_offset: ", text, " - ", button.pivot_offset)
	
	var tween: Tween = button.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_loops()
	tween.tween_property(button, "scale", Vector2(1.5, 1.5), 0.5)
	tween.tween_property(button, "scale", Vector2.ONE, 0.5)



func _on_button_pressed() -> void:
	button_pressed.emit()
