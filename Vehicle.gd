extends RigidBody

var wheels = []
var traction_wheels = []
var steering_wheels = []
var throttle:float = 0.0
var brake:float = 0.0
var steering_limit: float = 45.0
var steering: float = 0.0
var throttle_force = 500

onready var engine: VehicleEngine = $Engine
onready var gearbox: Gearbox = $Gearbox

func _ready():
	wheels.push_back($RRWheel)
	wheels.push_back($RLWheel)
	wheels.push_back($FRWheel)
	wheels.push_back($FLWheel)
	
	traction_wheels.push_back($FRWheel)
	traction_wheels.push_back($FLWheel)
	traction_wheels.push_back($RRWheel)
	traction_wheels.push_back($RLWheel)
	for wheel in traction_wheels:
		wheel.is_traction = true

	steering_wheels.push_back($FRWheel)
	steering_wheels.push_back($FLWheel)
	pass
	
var debug_forces = [
	Vector3(),
	Vector3(),
	Vector3(),
	Vector3(),
]

func _physics_process(delta):
	throttle = Input.get_action_strength("accelerate")
	engine.set_throttle(throttle)
	gearbox.set_input_torque(engine.current_torque)
	gearbox.set_input_rpm(engine.current_rpm)
	brake = Input.get_action_strength("brake")
	var steering = 0.0
	if(Input.is_action_pressed("turn_left")):
		steering = Input.get_action_strength("turn_left")
	if(Input.is_action_pressed("turn_right")):
		steering = -Input.get_action_strength("turn_right")
	
	if(Input.is_action_just_pressed("jump")):
		apply_central_impulse(Vector3(0,1000,0))
		
	if(Input.is_action_pressed("rocket")):
		add_central_force(to_global(Vector3(2000, 0 ,0)))
	
	for wheel in steering_wheels:
		wheel.rotation.y = deg2rad(steering_limit*steering)
	for wheel in wheels:
		wheel.brake_force = brake
	steering_limit = 45 # - min(40, linear_velocity.length())

func _integrate_forces(state):
	var per_wheel_torque = gearbox.output_torque/traction_wheels.size()

	for wheel in wheels:
		var position: Vector3 = wheel.global_transform.origin - global_transform.origin;
		
		if(wheel.is_colliding):
			var weight_on_wheel = max(0, wheel.suspension_force)
			var wheel_tangential_velocity = linear_velocity.dot(wheel.global_transform.basis.x)
			var z_wheel_velocity = linear_velocity.dot(wheel.global_transform.basis.z) * wheel.global_transform.basis.z
			
			var tangential_velocity = angular_velocity.cross(position)
			
			wheel_tangential_velocity += tangential_velocity.dot(wheel.global_transform.basis.x)
			var x_wheel_velocity = wheel_tangential_velocity * wheel.global_transform.basis.x
			z_wheel_velocity += tangential_velocity.dot(wheel.global_transform.basis.z) * wheel.global_transform.basis.z

			if(wheel.is_traction):
				wheel.tangential_velocity = max(throttle*50, wheel_tangential_velocity)
				wheel.rpm = -gearbox.output_rpm*gearbox.output_torque
				wheel.material.friction = min(0.8, max(0.1, smoothstep(30, 0, wheel.tangential_velocity-wheel_tangential_velocity)))
			if(!wheel.is_traction || throttle <= 0):
				wheel.tangential_velocity = wheel_tangential_velocity
				wheel.rpm = -60*wheel_tangential_velocity/wheel.wheel_radius

			var result_friction = wheel.material.friction
			if(wheel.collider.physics_material_override):
				result_friction *= wheel.collider.physics_material_override.friction

			if(wheel.is_traction):
				var direction: Vector3 = wheel.ground_normal.cross(wheel.global_transform.basis.z)
				var force = min(throttle_force, throttle*(per_wheel_torque/wheel.wheel_radius)*result_friction*weight_on_wheel)
				add_force(direction*force, position)

			var x_friction_force = Vector3()
			if(wheel.brake_force > 0):
				x_friction_force = -x_wheel_velocity*result_friction*wheel.brake_force*weight_on_wheel
			else:
				x_friction_force = -x_wheel_velocity*0.01*weight_on_wheel
			var z_friction_force = -z_wheel_velocity*result_friction*weight_on_wheel
			
			state.add_force(x_friction_force+z_friction_force, position)
		
		state.add_force(wheel.ground_normal * wheel.suspension_force, position)
		pass
	pass
