class_name CardValidation extends ProgressBar


signal on_validation_finished
signal on_validated


@onready var timer: Timer = %Timer
@onready var validating_label: Label = %ValidatingLabel
@onready var animation_player: AnimationPlayer = %AnimationPlayer


func _process(_delta: float) -> void:
	validating_label.text = "Validating:\n" + str(round(value)) + "%"


func is_validating() -> bool:
	return animation_player.is_playing()


func start_validating() -> void:
	animation_player.play("validating")
	await animation_player.animation_finished
	on_validation_finished.emit()


func reset() -> void:
	animation_player.play("RESET")
	animation_player.stop()


func play_validated() -> void:
	animation_player.play("validated")
	await animation_player.animation_finished
	on_validated.emit()
