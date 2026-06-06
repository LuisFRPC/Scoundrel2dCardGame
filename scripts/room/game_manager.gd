class_name GameManager
extends Node

@onready var next_button: AdvanceButton = $Next
@onready var reroll_button: RerollButton = $Reroll
@onready var current_room: CurrentRoom = $CurrentRoom
@onready var deck: PlayingDeck = $Deck
@onready var discard_pile: Node = $DiscardPile
@onready var discard_pile_pos: Marker2D = $DiscardPile/DiscardPilePosition
@onready var player: Player = $Player

@export var room_size: int
@export var card_scene: PackedScene
# The top card of the discard pile
var current_discard: PlayingCard 

func start_game():
	# Starts Player
	player.ready_player()
	generate_new_room()
	next_button.deactivate()
	reroll_button.activate()

func end_game():
	current_room.deactivate_room()
	next_button.deactivate()
	reroll_button.deactivate()

func generate_new_room():
	reroll_button.decrease_cooldown()
	next_button.deactivate()
	
	var n_of_cards_in_room = current_room.n_of_cards_in_room()
	current_room.organize_room()
	
	var cards: Array[Card] = deck.get_top_n_cards(room_size-n_of_cards_in_room)
	print(cards)
	
	for i in range(cards.size()):
		var new_card = card_scene.instantiate()
		new_card.card_used.connect(use_card)
		current_room.add_card_to_room(new_card)
		new_card.start(cards[i])

func select_x_card(card_data: PlayingCard):
	print("9 - Select card (Game)")
	player.predict_card_effect(card_data)

func cancel_x_card(card_data: PlayingCard):
	print("5 - Cancel card (Game)")
	player.stop_card_prediction(card_data)

func use_card(card: PlayingCard):
	current_room.remove_card(card)
	
	if card.card.suit == Card.Suits.CLUBS or card.card.suit == Card.Suits.SPADES:
		player.take_damage(card)
		
	elif card.card.suit == Card.Suits.HEARTS:
		player.heal(card)
		
	elif card.card.suit == Card.Suits.DIAMONDS:
		player.add_new_armor(card)
	
	if player.current_health <= 0:
		return
	
	if needs_new_room():
		generate_new_room()
		reroll_button.activate()
	elif current_room.n_of_cards_in_room() == 1:
		next_button.activate()
	else:
		reroll_button.deactivate()

func needs_new_room() -> bool:
	return current_room.n_of_cards_in_room() == 0

func refresh_room():
	var array: Array[Card] = []
	var cleaned_room = current_room.clear_room()
	for card in cleaned_room:
		array.append(card.card)
	deck.add_cards_to_deck(array)
	generate_new_room()

# Method that moves a card to the discard pile
# Since, acording to the rules of the game, the players doesn't need to check the
# discarding pile, this method deletes the old card and replaces it with the new one
# The card in the discard pile is a child of Player so it can be rendered
func discard_card(card: PlayingCard):
	# Return if the card is null
	if card == null: return
	# Removes the current card in the discard pile
	discard_pile.remove_child(current_discard)
	# Adds the new card and moves it to position
	discard_pile.add_child(card)
	current_discard = card
	card.position = discard_pile_pos.position
	card.scale = Vector2(2,2)

func discard_cards(cards: Array[PlayingCard]):
	for card in cards:
		discard_card(card)
