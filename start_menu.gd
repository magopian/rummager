extends Control

@onready var continue_button: Button = %ContinueButton
@onready var start_button: Button = %StartButton
@onready var quit_button: Button = %QuitButton
@onready var version_label: Label = %VersionLabel


func _ready() -> void:
	if Global.level > 1:
		continue_button.show()
		continue_button.grab_focus()
		start_button.text = "RESTART"
	else:
		continue_button.hide()
		start_button.grab_focus()
	continue_button.pressed.connect(_on_continue_button_pressed)
	start_button.pressed.connect(_on_start_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	version_label.text += ProjectSettings.get_setting("application/config/version")


func _on_continue_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")


func _on_start_button_pressed() -> void:
	Global.level = 1
	get_tree().change_scene_to_file("res://game.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
