extends CanvasLayer

@onready var progress_bar: ProgressBar = %ProgressBar


func _process(_delta: float) -> void:
	progress_bar.value = Global.score
