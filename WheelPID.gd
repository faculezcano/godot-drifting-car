extends Spatial

export var wheel_radius: float = 0.5
export var material: PhysicsMaterial
export var is_traction: bool

var tangential_velocity: float
var rpm: float

var is_colliding: bool
var collider: CollisionObject
var ground_normal: Vector3

var brake_force: float
var suspension_compression: float = 0.0
export var suspension_spring_force: float = 0.0
var _i: float = 0.0
var sum_t: float = 0.0
export var ki: float = 0.0
export var kd: float = 0.0
var suspension_force: float = 0.0
var wheel_position: Vector3
var tire_friction_factor: float = 0.02
onready var ray = $RayCast
#onready var vehicle_body:RigidBody = get_parent()

func _physics_process(delta):
	var old_suspension_compression = suspension_compression
	if(ray.is_colliding()):
		var position = ray.get_collision_point()
		var local_position = to_local(position)
		suspension_compression = lerp(suspension_compression, (ray.cast_to - local_position).length() / ray.cast_to.length(), 0.1)
		wheel_position = lerp(wheel_position, local_position + Vector3(0.0, wheel_radius, 0.0), 1)
		ground_normal = ray.get_collision_normal()
		collider = ray.get_collider()
		is_colliding = true
	else:
		suspension_compression = 0.0
		wheel_position = ray.cast_to + Vector3(0.0, wheel_radius, 0.0)
		ground_normal = Vector3()
		collider = null
		is_colliding = false
	_i += suspension_compression
	sum_t += delta
	var p = suspension_spring_force*suspension_compression
	var i = ki*_i/sum_t
	var d = kd*(suspension_compression - old_suspension_compression)/delta
	suspension_force = p+i+d

func _process(delta):
	for node in get_children():
		if(node != ray):
			node.transform.origin = wheel_position
#			node.rotate(Vector3(0, 0, 1), delta*-tangential_velocity/wheel_radius)
			node.rotate(Vector3(0, 0, 1), (rpm/60)*delta)
			if(!is_colliding):
				tangential_velocity = lerp(tangential_velocity, tangential_velocity*0.9, delta)
	pass
