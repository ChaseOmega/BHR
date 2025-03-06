extends Card
class_name  FlankingOpportunity

func _init():
	super()
	hasSpecial = true
	Type = Enums.EffectType.Attack
	
func genericEffectAdditions(user:Server_Unit):
	print("Oh hey I'm an additional effect and the player that called me has the ID of " + str(MatchServer.units.find_key(user).player))
	print("And I'm being called by " + str(MatchServer.multiplayer.get_unique_id()))
	pass

# To use a card's special effect this must pass true
func effectCondition(user:Server_Unit) -> bool: 
	return !MatchServer.getUnitsWithinRangeUnit(4,user,false).is_empty()
	
func effectTargeting(user:Server_Unit):
	var target = await MatchServer.requestPlayerSelectCells(MatchServer.getUnitsWithinRangeUnitAsVector2i(4,user,false),1)
	return target
	
func effect(_input:Server_Unit, target = []):
	if (target == []):
		print ("I need a target")
	else:
		print ("Cool shit happens here!")
		print (target)
	pass
