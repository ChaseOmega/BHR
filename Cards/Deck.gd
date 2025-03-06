extends Resource
class_name Deck

var liveCards: Array[Card] = []
var discard: Array[Card] = []
var allCards: Array[Card] = []

func _init(p_cards: Array[Card] = []):
	liveCards = []
	liveCards.append_array(p_cards)
	discard = []
	allCards = []
	allCards.append_array(p_cards)

func addCardtoLive(cardToAdd: Card):
	liveCards.append(cardToAdd)
	existCheck(cardToAdd)
	
func addCardtoDiscard(cardToAdd: Card):
	discard.append(cardToAdd)
	existCheck(cardToAdd)

func existCheck(cardToCheck: Card):
	if (allCards.find(cardToCheck) == -1):
		print("Adding card!")
		allCards.append(cardToCheck)
		cardToCheck.effecterID = cardToCheck.get_instance_id()

func drawCard() -> Card:
	if (liveCards.is_empty()):
		reloadDeck()
		if liveCards.is_empty():
			return
	var cardToReturn = liveCards.pop_front()
	return cardToReturn

func reloadDeck():
	liveCards.append_array(discard)
	discard.clear()
	

func shuffle():
	liveCards.shuffle()

func drawMultipleCards(drawNumber: int) -> Array[Card]:
	var cardsDrawn: Array[Card] = []
	for x in drawNumber:
		cardsDrawn.append(drawCard())
	return cardsDrawn
