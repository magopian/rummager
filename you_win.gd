extends CanvasLayer

@onready var catch_all_click: TextureButton = %CatchAllClick
@onready var fade_transition: ColorRect = %FadeTransition
@onready var next_level_button: AnimatedButton = %NextLevelButton


func _ready() -> void:
	fade_transition.show()
	catch_all_click.pressed.connect(_on_button_pressed)
	next_level_button.button_pressed.connect(_on_button_pressed)
	fade_transition.fade_in()


func _on_button_pressed() -> void:
	Global.level += 1
	Music.play_theme()
	fade_transition.fade_to_file("res://game.tscn")