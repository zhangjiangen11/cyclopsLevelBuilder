extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	
	await get_tree().process_frame
	
	#var cm: = ControlMesh.new()
	#cm.init_block(AABB(Vector3(0, 0, 0), Vector3(1, 1, 1)))
	
#	var result:IntersectResults = $CyclopsBlocks.intersect_ray_closest($Marker3D.transform.origin, $Marker3D.transform.basis.z)
	var result:IntersectResults = $CyclopsBlocks.intersect_ray_closest(Vector3(-2.827666, 11.78138, -14.39898), Vector3(0.703937, -0.382888, 0.598221))
	
	print(result)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass