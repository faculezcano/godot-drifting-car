extends Spatial
class_name VehicleEngine

export var max_torque: float = 200.0
export var max_rpm: float = 7500
export var idle_rpm: float = 900
var current_rpm: float = 0.0
var current_torque: float = 0.0
var _target_rpm: float = 0.0
export var rpm_rise_rate: float = 7500
export var rpm_fall_rate: float = 5500
export var throttle: float = 0.0 setget set_throttle

func _ready():
	set_process(true)
	pass

func _process(delta):
	if(_target_rpm > current_rpm):
		current_rpm += rpm_rise_rate*delta
		current_torque = _torque(current_rpm)
	if(_target_rpm < current_rpm):
		current_rpm -= rpm_fall_rate*delta
		current_torque = _torque(current_rpm)

func _torque(rpm: float):	
	return ((-.000004 * pow(rpm, 2) + 0.04 * rpm) / 100) * max_torque

func set_throttle(value: float):
	throttle = clamp(value, 0, 1)
	_target_rpm = lerp(idle_rpm, max_rpm, throttle)
	
