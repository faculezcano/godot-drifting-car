tool
extends Spatial

export var wheel_radius: float = 0.5
var wheel_position: Vector3
var suspension_velocity: Vector3
var suspension_force: Vector3
var suspension_damp: float = 1
var suspension_spring_force: float = 1
onready var ray = $RayCast
onready var vehicle_body:RigidBody = get_parent()

func _physics_process(delta):
	var suspension_compression: float = 0
	var old_wheel_position = wheel_position
	
	if(ray.is_colliding()):
		var position = ray.get_collision_point()
		var local_position = to_local(position)
		suspension_compression = local_position.length() / ray.cast_to.length()
		wheel_position = local_position + Vector3(0, wheel_radius, 0)
	else:
		suspension_compression = 0.0
		wheel_position = lerp(wheel_position, ray.cast_to + Vector3(0, wheel_radius, 0), 0.5)

	suspension_velocity = (wheel_position - old_wheel_position)/delta
	
	var force: float = suspension_compression*suspension_spring_force
	if(suspension_velocity.y > 0):
#		force = suspension_compression*suspension_spring_force
		force -= suspension_damp*suspension_velocity.length()
	suspension_force = Vector3(0, max(0, force), 0)

func _process(delta):
	for node in get_children():
		if(node != ray):
			node.transform.origin = wheel_position
