extends CanvasLayer

@onready var catch_all_click: TextureButton = %CatchAllClick
@onready var lost_reason_label: Label = %LostReason
@onready var wrong_container: HBoxContainer = %WrongContainer
@onready var card_display_wrong: Control = %CardDisplayWrong
@onready var card_display_correct: Control = %CardDisplayCorrect
@onready var fade_transition: ColorRect = %FadeTransition
@onready var try_again_button: AnimatedButton = %TryAgainButton

@export var wrong_card: Card
@export var valid_card: Card
@export var lost_reason: String


func _ready() -> void:
	fade_transition.show()
	catch_all_click.pressed.connect(_on_button_pressed)
	try_again_button.button_pressed.connect(_on_button_pressed)
	lost_reason_label.text = lost_reason
	card_display_correct.add_child(valid_card)
	valid_card.show_medium()
	if wrong_card:
		card_display_wrong.add_child(wrong_card)
		wrong_card.show_medium()
	else:
		wrong_container.hide()
	fade_transition.fade_in()
	print("time elapsed memorizing: ", Global.time_started_rummage - Global.time_started)
	print("time elapsed rummaging: ", Time.get_ticks_msec() - Global.time_started_rummage)
	print("number of cards discarded: ", Global.discarded_cards)



func _on_button_pressed() -> void:
	fade_transition.fade_to_file("res://game.tscn")
