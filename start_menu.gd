extends Control

@onready var continue_button: Button = %ContinueButton
@onready var start_button: Button = %StartButton
@onready var how_to_play_button: Button = %HowToPlayButton
@onready var credits_button: Button = %CreditsButton
@onready var quit_button: Button = %QuitButton
@onready var fade_transition: ColorRect = %FadeTransition


func _ready() -> void:
	if Global.level > 1:  # Player already completed at least one level
		continue_button.show()
		continue_button.grab_focus()
		start_button.text = "RESTART"
		quit_button.focus_neighbor_bottom = continue_button.get_path()
	else:
		continue_button.hide()
		start_button.grab_focus()
		quit_button.focus_neighbor_bottom = start_button.get_path()
		start_button.focus_neighbor_top = quit_button.get_path()
	continue_button.pressed.connect(_on_continue_button_pressed)
	start_button.pressed.connect(_on_start_button_pressed)
	how_to_play_button.pressed.connect(_on_how_to_play)
	credits_button.pressed.connect(_on_credits_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	# Only display the "quit" button on desktop.
	if OS.has_feature("web") or OS.has_feature("mobile"):
		quit_button.hide()


func _on_continue_button_pressed() -> void:
	fade_transition.fade_to_file("res://game.tscn")


func _on_start_button_pressed() -> void:
	Global.level = 1
	if Global.user_prefs.tutorial_started:
		fade_transition.fade_to_file("res://game.tscn")
	else:
		fade_transition.fade_to_file("res://tutorial_1_memorize.tscn")
		Global.user_prefs.tutorial_started = true
		Global.user_prefs.save()


func _on_how_to_play() -> void:
	fade_transition.fade_to_file("res://tutorial_0.tscn")


func _on_credits_pressed() -> void:
	fade_transition.fade_to_file("res://credits.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
