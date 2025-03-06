extends Control
class_name Match_Visualization_Player
@export var player: Match_Player
@export var playerName: Label
@export_group("Stats")
@export var statLineAttack: Label
@export var statLineDefense: Label
@export var statLineMobility: Label
@export_group("")
@export var HealthText: Label
@export var HealthBar: ProgressBar
@export var CardHolder: HBoxContainer
@export var CardVisualizerBase: PackedScene

func setup(inputPlayer: Match_Player):
	player = inputPlayer
	SignalManager.RefreshUI.connect(refreshValues)
	pass

func refreshValues():
	playerName.text = player.publicInfo.playerName
	statLineAttack.text = "Attack: " + str(player.playerUnit.publicInfo.displayAttack)
	statLineDefense.text = "Defense: " + str(player.playerUnit.publicInfo.displayDefense)
	statLineMobility.text = "Mobility: " + str(player.playerUnit.publicInfo.displayMobility)
	HealthText.text = str(player.playerUnit.publicInfo.displayHealth) + "/" + str(player.playerUnit.publicInfo.displayMaxHealth)
	HealthBar.ratio = 1
	for child in CardHolder.get_children():
		child.queue_free()
	for card in player.cards:
		var cardAdded:EffecterVisualizerMini = CardVisualizerBase.instantiate()
		cardAdded.effecter = card
		CardHolder.add_child(cardAdded)
	for card in player.publicInfo.numberOfCards - player.cards.size():
		var cardAdded:EffecterVisualizerMini = CardVisualizerBase.instantiate()
		CardHolder.add_child(cardAdded)
		
