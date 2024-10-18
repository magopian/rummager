extends Control


@onready var start_button: Button = %StartButton
@onready var quit_button: Button = %QuitButton
@onready var version_label: Label = %VersionLabel


func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	start_button.grab_focus()
	version_label.text += ProjectSettings.get_setting("application/config/version")



func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
