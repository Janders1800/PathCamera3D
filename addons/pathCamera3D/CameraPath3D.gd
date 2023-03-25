extends Path

class_name PathCamera3D, "res://addons/pathCamera3D/PathCamera3D.png"


export(NodePath) var follow_At: String
export var interpolate_position : bool = true
export var position_speed : float = 1
export var interpolate_rotation : bool = true
export var rotation_speed : float = 1
export(NodePath) var child_path: String

var follow_At_Node: Spatial
var transmit: bool = false

onready var child_path_node: Path
onready var path_node: PathFollow = $Path_Follow
onready var look_at_node : Spatial = $Path_Follow/Final_Look_At
onready var camera_node : Camera = $Path_Follow/Camera_Path


func _ready():
	if not follow_At.empty():
		follow_At_Node = get_node(follow_At)
	
	if not child_path.empty():
		child_path_node = get_node(child_path)
	
		if is_instance_valid(child_path_node) and child_path_node is Path:
			transmit = true
		else:
			printerr("Paht is not of tipe PathCamera3D")


func _process(delta) -> void:
	if not is_instance_valid(follow_At_Node):
		return
	
	if interpolate_position:
		path_node.offset = lerp(path_node.offset, self.curve.get_closest_offset(to_local(follow_At_Node.global_transform.origin)), position_speed * delta)
	else:
		path_node.offset = self.curve.get_closest_offset(to_local(follow_At_Node.global_transform.origin))
	
	if interpolate_rotation:
		look_at_node.look_at(follow_At_Node.global_transform.origin, Vector3.UP)
		
		var a = Quat(camera_node.global_transform.basis)
		var b = Quat(look_at_node.global_transform.basis)
		
		# Interpolate using spherical-linear interpolation (SLERP).
		var c = a.slerp(b, rotation_speed * delta) # find halfway point between a and b
		
		# Apply back
		camera_node.global_transform.basis = Basis(c)
	else:
		camera_node.look_at(follow_At_Node.global_transform.origin, Vector3.UP)
	
	if transmit:
		if has_method("get_child_path"):
			child_path_node.get_child_path().unit_offset = path_node.unit_offset
		else:
			child_path_node.unit_offset = path_node.unit_offset


func get_child_path() -> PathFollow:
	return get_node("Path_Follow") as PathFollow
