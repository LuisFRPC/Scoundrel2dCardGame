# Main class for the Main Scene
extends Node

@onready var hud: CanvasLayer = $Start
@onready var deck: PlayingDeck = $GameManager/Deck
@onready var game_manager: GameManager = $GameManager

# Method to star the game
func new_game():
	# Clear old game
	get_tree().call_group("Slots", "delete_card")
	await get_tree().create_timer(0.01).timeout
	
	hud.show_message("")
	
	# Starts the Deck
	deck.start()
	# Generates a new room throught the Room Manager
	game_manager.start_game()
	

func on_game_lost():
	get_tree().call_group("Cards", "deactivate_card")
	game_manager.end_game()
	hud.show_game_loss()

func on_game_won():
	game_manager.end_game()
	hud.show_game_won()


func select_x_card(card: PlayingCard) -> void:
	pass # Replace with function body.
