extends Node


#These signals are for changes in the game state. Used for effects that proc on certain events
#As well as certain animations.
#region Game State Signals
signal UnitsSpawned
signal UnitMoved(unitThatMoved: Server_Unit, locationMovedTo: PackedVector2Array)
signal UnitTeleported(unitThatMoved: Server_Unit, locationMovedTo: Vector2i)
signal UnitAttacked(attackingUnit: Server_Unit)
signal UnitTakesDamage(defendingUnit: Server_Unit, damage:int)
#endregion

#Signals to get input from the player
#region RequestUserInput
signal requestPlayerInputCell(options: Array[Vector2i], numberRequested: int)
signal responsePlayerInputCell(response: Array[Vector2i])
signal requestPlayerInputPlayer(options: Array[int], numberRequested: int)
signal responsePlayerInputPlayer(response: Array[int])
#endregion


#Signals that are used to process player input.
#region UserInput
signal selectCell(cell:Vector2i)
signal selectUnit(unit:Unit)
signal selectPlayer(matchPlayer: Match_Player)
signal moved(cell:Vector2i)
#endregion

#These signals are used to control the UI, such as highlighting cells for player input.
#Do not use these signals to control things outside of the UI, such as gamestate
#region UI Signals
signal RefreshUI
signal highlightCells(cells: Array[Vector2i])
signal requestDisplayInfo(targetEffecter: Effecter)
#endregion
