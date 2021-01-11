extends Path

class_name PathCamera3D, "res://addons/pathCamera3D/PathCamera3D.png"


export(NodePath) var follow_At
export var interpolate_position : bool = true
export var position_speed : float = 1
export var interpolate_rotation : bool = true
export var rotation_speed : float = 1


onready var follow_At_Node: Spatial = get_node(follow_At)
onready var path_Node: PathFollow = $Path_Follow
onready var look_At_Node : Spatial = $Path_Follow/Final_Look_At
onready var camera_Node : Camera = $Path_Follow/Camera_Path


func _process(delta) -> void:
	if interpolate_position:
		path_Node.offset = lerp(path_Node.offset, self.curve.get_closest_offset(to_local(follow_At_Node.global_transform.origin)), position_speed * delta)
	else:
		path_Node.offset = self.curve.get_closest_offset(to_local(follow_At_Node.global_transform.origin))
	
	if interpolate_rotation:
		look_At_Node.look_at(follow_At_Node.global_transform.origin, Vector3.UP)
		
		var a = Quat(camera_Node.global_transform.basis)
		var b = Quat(look_At_Node.global_transform.basis)
		
		# Interpolate using spherical-linear interpolation (SLERP).
		var c = a.slerp(b, rotation_speed * delta) # find halfway point between a and b
		
		# Apply back
		camera_Node.global_transform.basis = Basis(c)
	else:
		camera_Node.look_at(follow_At_Node.global_transform.origin, Vector3.UP)
