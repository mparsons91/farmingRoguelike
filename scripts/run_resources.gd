extends Node
## Autoload: run resources (Wood, Ore) for the current session.
## Reset when the main scene loads.

var wood: int = 0
var ore: int = 0

func add_resource(resource_type: StringName, amount: int) -> void:
	if resource_type == &"wood":
		wood += amount
	elif resource_type == &"ore":
		ore += amount

func get_count(resource_type: StringName) -> int:
	if resource_type == &"wood":
		return wood
	if resource_type == &"ore":
		return ore
	return 0

func reset_for_run() -> void:
	wood = 0
	ore = 0
