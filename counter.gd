extends Label


@export var score: int = 0


func _process(_delta: float) -> void:
	text = str(score)
