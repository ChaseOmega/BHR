extends Skill
class_name teleportSkill

func _init():
	super()
	Type = Enums.EffectType.Movement
	
func effectCondition(_user:Server_Unit) -> bool: 
	return true
	
func effectTargeting(user:Server_Unit):
	var target = await MatchServer.requestPlayerSelectCells(MatchServer.getCellsWithinRangeUnitUnoccupied(user.getMobility(),user),1)
	return target
	
func effect(user:Server_Unit, target = []):
	if (target == []):
		print ("I need a target")
	else:
		MatchServer._teleportUnit.rpc(user.cell,target[0])
	pass
