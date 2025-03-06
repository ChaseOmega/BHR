extends Effecter
class_name Card

var typeID:int = 0 
var hasSpecial: bool = false
@export var value: int = 0
@export var source:int
func _init(p_hasSpecial = false, p_requiresTargeting = false):
	hasSpecial = p_hasSpecial

func activationRequest():
	MatchServer.cardActivationRequest.rpc(effecterID)

# Effect generic to cards of a given type
func genericEffect(input:Server_Unit):
	if(Type == Enums.EffectType.Attack):
		print("I'm boosting attack by " + str(value))
	if(Type == Enums.EffectType.Defense):
		print("I'm reducing damage by " + str(value))
	if(Type == Enums.EffectType.Movement):
		print("I'm boosting Movement by " + str(value))
	if(Type == Enums.EffectType.Trap):
		print("I'm waiting to damage by " + str(value))
	if(Type == Enums.EffectType.Special):
		print("I don't have a generic effect")
	genericEffectAdditions(input)

#Effects that should occur after a generic effect. High value cards may accure additional costs for use
#And lower value might give additional benefits.
func genericEffectAdditions(_input:Server_Unit):
	pass

func loadDictionary(input:Dictionary):
	super(input)
	typeID = input.typeID
	value = input.value
	source = input.source
