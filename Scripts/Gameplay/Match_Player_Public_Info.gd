extends Resource
class_name Match_Player_Public_Info

var numberOfCards:int = 0:
	set(value):
		numberOfCards = value
		MatchServer.updatePlayerPublicInfoRequest()
var playerName:String = "":
	set(value):
		playerName = value
		MatchServer.updatePlayerPublicInfoRequest()
var playerUnit: Server_Unit:
		set(value):
			playerUnit = value
			MatchServer.updatePlayerPublicInfoRequest()

func loadDictionary(input:Dictionary):
	numberOfCards = input.numberOfCards
	playerName = input.playerName
