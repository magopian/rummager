class_name TutorialWellDone extends CanvasLayer

@onready var catch_all_click: TextureButton = %CatchAllClick
@onready var fade_transition: ColorRect = %FadeTransition
@onready var next_level_button: AnimatedButton = %NextLevelButton
@onready var back_to_menu: Button = %BackToMenu
@onready var message_label: Label = %MessageLabel


var next_scene: String
var message: String


func _ready() -> void:
	fade_transition.show()
	catch_all_click.pressed.connect(_on_next_level_pressed)
	next_level_button.button_pressed.connect(_on_next_level_pressed)
	back_to_menu.pressed.connect(_on_menu_button_pressed)
	message_label.text = message
	fade_transition.fade_in()


func _on_next_level_pressed() -> void:
	Music.play_theme()
	fade_transition.fade_to_file(next_scene)


func _on_replay_pressed() -> void:
	Music.play_theme()
	fade_transition.fade_to_file(next_scene)


func _on_menu_button_pressed() -> void:
	if is_instance_valid(back_to_menu):
		back_to_menu.pressed.disconnect(_on_menu_button_pressed)
	fade_transition.fade_to_file("res://start_menu.tscn")
