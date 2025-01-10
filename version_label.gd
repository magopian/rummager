extends Button


@onready var line_edit: LineEdit = %LineEdit


var pressed_times: int = 0


func _ready() -> void:
	line_edit.hide()
	text += ProjectSettings.get_setting("application/config/version")
	pressed.connect(_on_button_pressed)
	line_edit.text_changed.connect(_on_text_changed)
	line_edit.text = str(Global.level)


func _on_button_pressed() -> void:
	pressed_times += 1
	if pressed_times >= 7:
		line_edit.show()


func _on_text_changed(new_text: String) -> void:
	Global.level = int(new_text)
