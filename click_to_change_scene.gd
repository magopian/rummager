extends CanvasLayer

@onready var control: Control = %Control

signal button_pressed


func _ready() -> void:
	control.gui_input.connect(_on_gui_input)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		button_pressed.emit()
