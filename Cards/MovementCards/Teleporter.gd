extends Card
class_name  Teleporter

func _init():
	super()
	hasSpecial = true
	Type = Enums.EffectType.Movement
	
func genericEffectAdditions(user:Server_Unit):
	print("Oh hey I'm an additional effect and the player that called me has the ID of " + str(MatchServer.players.find_key(user)))
	print("And I'm being called by " + str(MatchServer.multiplayer.get_unique_id()))
	pass

# To use a card's special effect this must pass true
func effectCondition(_user:Server_Unit) -> bool: 
	return true
	
func effectTargeting(user:Server_Unit):
	var target = await MatchServer.requestPlayerSelectCells(MatchServer.getCellsWithinRangeUnitUnoccupied(10,user),1)
	return target
	
func effect(user:Server_Unit, target = []):
	if (target == []):
		print ("I need a target")
	else:
		MatchServer._teleportUnit.rpc(user.cell,target[0])
	pass
