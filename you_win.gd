extends CanvasLayer

@onready var catch_all_click: TextureButton = %CatchAllClick
@onready var fade_transition: ColorRect = %FadeTransition
@onready var next_level_button: AnimatedButton = %NextLevelButton


func _ready() -> void:
	fade_transition.show()
	catch_all_click.pressed.connect(_on_button_pressed)
	next_level_button.button_pressed.connect(_on_button_pressed)
	fade_transition.fade_in()
	print("time elapsed memorizing: ", Global.time_started_rummage - Global.time_started)
	print("time elapsed rummaging: ", Time.get_ticks_msec() - Global.time_started_rummage)
	print("number of cards discarded: ", Global.discarded_cards)


func _on_button_pressed() -> void:
	Global.level += 1
	Music.play_theme()
	fade_transition.fade_to_file("res://game.tscn")
