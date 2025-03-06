extends Control
class_name cardInterface

@export var player: Match_Player
@export var unit: Server_Unit
@export var CardHolder: HBoxContainer
@export var CardVisualizerBase: PackedScene
@export var GenericButton: Button
@export var SpecialButton: Button
@export var selectedCard: Card

func setup(inputPlayer: Match_Player):
	player = inputPlayer
	refreshValues()
	SignalManager.RefreshUI.connect(refreshValues)
	GenericButton.button_down.connect(selectedCardGenericFunction)
	SpecialButton.button_down.connect(selectedCardSpecialFunction)
	pass

func refreshValues():
	for child in CardHolder.get_children():
		child.queue_free()
	for card in player.cards:
		var cardAdded:EffecterVisualizerMini = CardVisualizerBase.instantiate()
		cardAdded.effecter = card
		cardAdded.primaryPressed.connect(selectCard.bind(card))
		cardAdded.secondaryPressed.connect(MatchServer.displayInfo.bind(card))
		CardHolder.add_child(cardAdded)
	for card in player.publicInfo.numberOfCards - player.cards.size():
		var cardAdded:EffecterVisualizerMini = CardVisualizerBase.instantiate()
		CardHolder.add_child(cardAdded)

func selectCard(cardToSelect:Card):
	print(cardToSelect.name)
	selectedCard = cardToSelect
	GenericButton.show()
	if cardToSelect.hasSpecial:
		SpecialButton.show()
	else:
		SpecialButton.hide()
	if cardToSelect.effectCondition(unit):
		SpecialButton.disabled = false
	else:
		SpecialButton.disabled = true
	pass


func selectedCardGenericFunction():
	if (selectedCard != null):
		MatchServer.cardGenericActivationRequest.rpc(selectedCard.effecterID,unit.cell)

func selectedCardSpecialFunction():
	if (selectedCard != null):
		MatchServer.effectActivationClientPrep(selectedCard,unit)
