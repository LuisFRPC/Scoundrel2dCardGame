# Calls of the Button that 
class_name AdvanceButton
extends Button

signal advance_button_pressed

func _ready() -> void:
	disabled = true

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("q_key") and !disabled:
		_on_pressed()

func _on_pressed() -> void:
	emit_signal("advance_button_pressed")

func activate():
	disabled = false

func deactivate():
	disabled = true
