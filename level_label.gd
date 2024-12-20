extends Label


func _process(_delta: float) -> void:
	text = "Level: " + str(Global.level) + "\n" + str(Global.level * 10) + " cards"
