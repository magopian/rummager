extends Node2D


@onready var pick_me_canvas_layer: CanvasLayer = %PickMeCanvasLayer
@onready var back_to_menu: Button = %BackToMenu
@onready var next: Button = %Next
@onready var fade_transition: ColorRect = %FadeTransition


func _ready() -> void:
	# Setup
	back_to_menu.pressed.connect(_on_menu_button_pressed)
	next.pressed.connect(_on_menu_button_pressed)
	next.pressed.connect(_on_next_pressed)
	pick_me_canvas_layer.button_pressed.connect(_on_next_pressed)


func _on_menu_button_pressed() -> void:
	if is_instance_valid(back_to_menu):
		back_to_menu.pressed.disconnect(_on_menu_button_pressed)
	fade_transition.fade_to_file("res://start_menu.tscn")


func _on_next_pressed() -> void:
	pick_me_canvas_layer.button_pressed.disconnect(_on_next_pressed)
	next.pressed.disconnect(_on_next_pressed)
	fade_transition.fade_to_file("res://tutorial_1_memorize.tscn")
