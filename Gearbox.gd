extends Node
class_name Gearbox

export var gear: int setget set_gear
export var input_torque: float setget set_input_torque
export var input_rpm: float setget set_input_rpm

export var differential_relation: float = 4.19

export var gears: Array = [
	3.37,
	1.96,
	1.32,
	0.95,
	0.75,
]

var output_torque: float
var output_rpm: float

func set_gear(value: int):
	gear = clamp(value, 0, gears.size())
	output_torque = _output_torque()
	output_rpm = _output_rpm()

func set_input_torque(value: float):
	input_torque = value
	output_torque = _output_torque()

func set_input_rpm(value: float):
	input_rpm = value
	output_rpm = _output_rpm()

func _output_torque():
	if(gear <= 0):
		return 0
	return input_torque*differential_relation*gears[gear-1]

func _output_rpm():
	if(gear <= 0):
		return 0
	return input_rpm/(differential_relation*gears[gear-1])
