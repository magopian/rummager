class_name PopText extends Path2D


@onready var label: Label = %Label
@onready var animation_player: AnimationPlayer = %AnimationPlayer


@export var text: String
@export var color: Color
@export var outline_color: Color
@export var font_size: int
@export var outline_size: int


func _ready() -> void:
	label.text = text
	if color:
		label.set("theme_override_colors/font_color", color)
	if outline_color:
		label.set("theme_override_colors/font_outline_color", outline_color)
	if font_size:
		label.set("theme_override_font_sizes/font_size", font_size)
	if outline_size:
		label.set("theme_override_constants/outline_size", outline_size)
	label.rotation = -rotation  # "Unrotate" the text so i stays horizontal
	label.position = -(label.size / 2)  # Move the label so its center is at the center of the root node
	label.pivot_offset = label.size / 2  # Scaling happens around the pivot, so center it on the label


func pop() -> void:
	prints("popping:", label.text)
	animation_player.play("pop")
	await animation_player.animation_finished
