extends Label


@export var score: int:
	set(value):
		if score_to_display == value:
			return
		score_to_display = value
		# We have at most 1360 cards at once, but we can only discard at most roughly half of them
		# if we discard a (background) color. We want our max scale to be 2.
		var new_scale:float = float(value) * 2 / (1360.0 / 2)
		var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
		tween.tween_property(self, "scale", Vector2.ONE * (1 + new_scale), 0.1)
		tween.tween_property(self, "scale", Vector2.ONE, 0.2)


var score_to_display: int = 0


func _ready() -> void:
	pivot_offset = size / 2


func _process(_delta: float) -> void:
	text = str(score_to_display)
