# Calls of the Button that 
class_name RerollButton
extends Button

## The manager of the room
@export var action_cooldown: int

var cooldown_counter: int = 0

signal reroll_button_pressed

func _ready() -> void:
	disabled = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("e_key") and !disabled:
		_on_pressed()

func _on_pressed() -> void:
	if cooldown_counter <= 0 and !disabled:
		emit_signal("reroll_button_pressed")
		cooldown_counter = action_cooldown
		disabled = true

func decrease_cooldown():
	cooldown_counter -= 1
	if cooldown_counter <= 0:
		disabled = false

func activate():
	disabled = false

func deactivate():
	disabled = true
