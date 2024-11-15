extends CanvasLayer

@onready var button: TextureButton = %Button

signal button_pressed


func _ready() -> void:
	button.pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	button_pressed.emit()
