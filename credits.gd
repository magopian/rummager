extends Control


@onready var menu_button: Button = %MenuButton
@onready var click_to_change_scene: CanvasLayer = %ClickToChangeScene


func _ready() -> void:
	menu_button.pressed.connect(_on_menu_pressed)
	click_to_change_scene.button_pressed.connect(_on_menu_pressed)


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://start_menu.tscn")
