extends Spatial

onready var camera: Camera = $Camera
onready var vehicle = $Vehicle

var cameraAnchor;

func _ready():
	cameraAnchor = vehicle.find_node('CameraAnchor');

func _process(delta):
	var cameraPosition: Vector3 = vehicle.to_global(Vector3(-7, 0, 0)) + Vector3(0, 2, 0)
	#camera.global_transform = camera.global_transform.interpolate_with(cameraAnchor.global_transform, 0.1)
	camera.global_transform.origin = lerp(camera.global_transform.origin, cameraPosition, 0.1);
	camera.global_transform = camera.global_transform.looking_at(vehicle.global_transform.origin, Vector3(0, 1, 0))
