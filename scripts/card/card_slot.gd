class_name CardSlot
extends Node2D

var slot_number: int
var card: PlayingCard

signal x_card_selected(card_data: PlayingCard, slot_number: int)
signal x_card_canceled(card_data: PlayingCard)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if card == null: return
	if Input.is_action_just_pressed(str(slot_number+1) + "_key") and card.in_game:
		card.play_card()

func start(number: int):
	assert(number != null)
	slot_number = number

func select_card():
	print("7 - Select card (Slot)")
	emit_signal("x_card_selected", card, slot_number)

func cancel_card():
	print("3 - Cancel card (Slot)")
	emit_signal("x_card_canceled", card)

func set_card(new_card: PlayingCard):
	assert(new_card != null)
	remove_card()
	card = new_card
	new_card.card_selected.connect(select_card)
	new_card.card_canceled.connect(cancel_card)
	add_child(card)

func remove_card() -> PlayingCard:
	var temp = card
	remove_child(card)
	card = null
	return temp

func delete_card():
	if card != null:
		card.queue_free()
	card = null

func is_empty():
	return card == null
