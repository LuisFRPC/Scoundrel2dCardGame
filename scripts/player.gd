class_name Player
extends Node

@onready var armor_position: Marker2D = $ArmorPosition
@onready var hero_health_bar: TextureProgressBar = $CanvasLayer/HeroHealthBar
@onready var hero_blink_bar: TextureProgressBar = $CanvasLayer/HeroBlinkBar
@onready var armor_slot: Sprite2D = $"ArmorSlot"
@onready var canvas_layer: CanvasLayer = $CanvasLayer

## The Max Health of the player
@export var max_health: int
@export var armor_monster_card_offset: int
# The current card that is serving as the current armor
var current_armor: PlayingCard
# The current health of the Player
var current_health: int
# The last card the armor was used against defended
var last_defended: int
# The number of monsters defeated
var n_monsters_defended: int
var blinking_health_tween: Tween
# Signal that goes off when the Player dies (current_heath <= 0)
signal player_death
signal monster_defeated(monster_number: int)
signal dispose_of_cards(cards: Array[PlayingCard])
signal card_finished_action

func ready_player():
	current_health = max_health
	canvas_layer.visible = true
	set_health_ui(current_health)
	current_armor = null
	last_defended = max_health + 1
	n_monsters_defended = 0
	armor_slot.region_enabled = true
	armor_slot.region_rect = Rect2(Vector2(0,32), Vector2(16,16))

# Processes the player taking damage form a card
func take_damage(monster_card: PlayingCard):
	var damage_to_take = calculate_damage(monster_card)
	var full_card_damage = monster_card.get_numerical_value()
	if current_armor != null and full_card_damage < last_defended:
		add_monster_card_to_armor(monster_card)
	else:
		var dispose_card: Array[PlayingCard] = [monster_card]
		emit_signal("dispose_of_cards", dispose_card)
	
	# Calculates damages for instances where the armor isn't enough (0 otherwise)
	current_health = current_health - damage_to_take
	
	# Sets current health
	if current_health <= 0:
		emit_signal("player_death")
	else:
		emit_signal("monster_defeated", full_card_damage)
	set_health_ui(current_health)

func calculate_damage(card: PlayingCard) -> int:
	# Determines if current armor will be used (effective_armor)
	# An armor that last defended a 5 can't defend against a 6 (takes full 6 damage)
	var card_monster_damage = card.get_numerical_value()
	if armor_is_effective(card_monster_damage):
		var damage = card_monster_damage - current_armor.card.number
		if damage < 0:
			damage = 0
		return damage
	return card_monster_damage

func armor_is_effective(monster_attack_power: int) -> bool:
	return monster_attack_power < last_defended and current_armor != null

# Adds the monster card on top of the armor card
# Aesthetic choice to make the player dont forget the last defended enemy
func add_monster_card_to_armor(monster_card: PlayingCard):
	# Moves the moster card to position
	# First resets the position because it will be a child of the location
	monster_card.position = Vector2(0,0)
	monster_card.scale = Vector2(1,1)
	monster_card.position.x += armor_monster_card_offset + n_monsters_defended * armor_monster_card_offset
	monster_card.z_index = current_armor.z_index + 1 + n_monsters_defended
	# Adds the monster to the armor list
	armor_position.add_child(monster_card)
	n_monsters_defended += 1
	last_defended = monster_card.get_numerical_value()

# Switches the old armor card with the new one
# Gets rid of all attatched monster cards
func add_new_armor(new_armor: PlayingCard):
	# Discards all cards in the Armor list (to clear the monster cards stored in there)
	var dispose_card: Array[PlayingCard] = []
	for card in armor_position.get_children():
		armor_position.remove_child(card)
		dispose_card.append(card)
	emit_signal("dispose_of_cards", dispose_card)
	# Adds the new Armor card to the Armor list (resets postion)
	# First resets the position because it will be a child of the location
	new_armor.position = Vector2(0,0)
	new_armor.scale = Vector2(1,1)
	armor_position.add_child(new_armor)
	# Set up new values
	current_armor = new_armor
	last_defended = max_health + 1
	n_monsters_defended = 0
	armor_slot.region_rect = new_armor.card_visuals.get_visual()
	emit_signal("card_finished_action")

# Heals the player by the ammount on the card
# The maximum ammount of heath is determined by max_health
func heal(card: PlayingCard):
	print("current_healt=" + str(current_health))
	# Sums the number of the card to the current health of the player (respecting max_health)
	current_health += card.card.number
	if current_health > max_health:
		current_health = max_health
	# Sets new new heath value and dicards the card
	set_health_ui(current_health)
	var dispose_card: Array[PlayingCard] = [card]
	emit_signal("dispose_of_cards", dispose_card)
	emit_signal("card_finished_action")

func set_health_ui(new_health: int):
	hero_blink_bar.value = new_health
	var tween = get_tree().create_tween()
	tween.tween_property(hero_health_bar, "value", new_health, 1).set_trans(Tween.TRANS_SINE).set_delay(0)
	await tween.finished

func predict_card_effect(card_data: PlayingCard):
	print("9.1 - Predicting")
	var health_variance = 0
	if card_data.card.suit == Card.Suits.CLUBS or card_data.card.suit == Card.Suits.SPADES:
		health_variance -= calculate_damage(card_data)
	elif card_data.card.suit == Card.Suits.HEARTS:
		health_variance += card_data.card.number
	else:
		return
	start_health_blink_preview(health_variance)

func start_health_blink_preview(health_variance: int):
	if blinking_health_tween:
		blinking_health_tween.kill()

	hero_blink_bar.visible = true
	hero_blink_bar.value = current_health + health_variance
	print("9.2 - Making tween")
	blinking_health_tween = get_tree().create_tween()
	blinking_health_tween.set_loops()
	blinking_health_tween.tween_property(hero_health_bar, "tint_progress", Color(1,1,1,0), 0.5).set_delay(0)
	blinking_health_tween.tween_property(hero_health_bar, "tint_progress", Color(1,1,1,1), 0.5).set_delay(0)
	print("blinking")

func stop_card_prediction(card_data: PlayingCard):
	print("5.1 - Stopping blinking")
	stop_health_blink_preview()

func stop_health_blink_preview():
	if !blinking_health_tween:
		return
	blinking_health_tween.kill()
	blinking_health_tween = null
	print("5.2 - Stop blink tween")
	hero_health_bar.tint_progress = Color(1,1,1,1)
	#var tween = get_tree().create_tween()
	#tween.tween_property(hero_health_bar, "tint_progress", Color(1,1,1,1), 0.2)
	#await tween.finished
	
	hero_blink_bar.value = 0
	hero_blink_bar.visible = false
	print("stop blink")
