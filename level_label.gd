extends Label


func _process(_delta: float) -> void:
	text = "Level: " + str(Global.level)
