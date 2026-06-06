class_name CurrentRoom
extends Node2D

@export var card_slot_scene: PackedScene
var selected_card_pointer: int = -1
var slots: Array[CardSlot]
var pointer_changed = false

signal x_card_selected(card: PlayingCard)
signal x_card_canceled(card: PlayingCard)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(get_child_count()):
		var new_slot = card_slot_scene.instantiate()
		#new_slot.card_used.connect(use_card)
		get_child(i).add_child(new_slot)
		new_slot.start(i)
		new_slot.add_to_group("Slots")
		new_slot.x_card_selected.connect(select_x_card)
		new_slot.x_card_canceled.connect(cancel_x_card)
		slots.append(new_slot)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("a_key_left_card"):
		print("#################")
		move_card(-1)
	elif Input.is_action_just_pressed("d_key_left_card"):
		print("#################")
		move_card(1)

func move_card(increment: int):
	print("1 - Started moving")
	var card = get_card_in_filled_slot(selected_card_pointer)
	if card != null:
		card.cancel_card()
	selected_card_pointer = clamp(selected_card_pointer+increment, 0, n_of_cards_in_room() - 1)
	pointer_changed = true
	get_card_in_filled_slot(selected_card_pointer).select_card()

func n_of_cards_in_room() -> int:
	var count = 0
	for slot in slots:
		if !slot.is_empty():
			count +=1
	return count

func add_card_to_room(new_card: PlayingCard):
	for slot in slots:
		if slot.is_empty():
			slot.set_card(new_card)
			break

func select_x_card(card_data: PlayingCard, slot_number: int):
	print("8 - Select card (Current Room)")
	if !pointer_changed:
		selected_card_pointer = slot_number
	pointer_changed = false
	highlight_x_slot(slot_number)
	emit_signal("x_card_selected", card_data)

func cancel_x_card(card_data: PlayingCard):
	print("4 - Cancel card (Current Room)")
	turn_off_room_highlights()
	emit_signal("x_card_canceled", card_data)

# Pushes cards to the right in the room
func organize_room():
	if n_of_cards_in_room() <= 0:
		return
	var last_empty_slot = 0
	for slot in slots:
		if last_empty_slot == slot.slot_number and !slots[last_empty_slot].is_empty():
			last_empty_slot += 1
		elif !slot.is_empty():
			slots[last_empty_slot].set_card(slot.remove_card())
			last_empty_slot += 1

func clear_room() -> Array[PlayingCard]:
	var room_cards: Array[PlayingCard]
	for slot in slots:
		room_cards.append(slot.remove_card())
	return room_cards

func remove_card(card: PlayingCard):
	selected_card_pointer -= 1
	for slot in slots:
		if !slot.is_empty() and slot.card.equals(card):
			slot.remove_card()

func deactivate_room():
	for slot in slots:
		if !slot.is_empty():
			slot.card.deactivate_card()

func highlight_x_slot(slot_number: int):
	turn_off_room_highlights()
	if !slots[slot_number].is_empty():
		slots[slot_number].card.highlight_on()

func turn_off_room_highlights():
	for slot in slots:
		if !slot.is_empty():
			slot.card.highlight_off()

func get_card_in_filled_slot(slot_number: int) -> PlayingCard:
	var counter = 0
	for slot in slots:
		if counter == slot_number and !slot.is_empty():
			return slot.card
		elif slot.is_empty():
			slot_number +=1
		counter += 1
	return null
