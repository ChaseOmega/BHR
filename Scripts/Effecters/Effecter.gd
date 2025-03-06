extends displayable
class_name Effecter
var effecterID: int = -1

func effectCondition(input:Server_Unit) -> bool:
	return false

func effectTargeting(_input:Server_Unit):
	pass

# Effect specific to that individual card
func effect(_input:Server_Unit, _target = []):
	pass

func loadDictionary(input:Dictionary):
	effecterID = input.effecterID
	Type = input.Type
