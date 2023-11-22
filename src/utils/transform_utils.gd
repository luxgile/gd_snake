class_name TransformUtils

static func forward(transform: Transform3D) -> Vector3:
	return -transform.basis.z

static func right(transform: Transform3D) -> Vector3:
	return transform.basis.x

static func up(transform: Transform3D) -> Vector3:
	return transform.basis.z

static func local_dir(transform: Transform3D, dir: Vector3) -> Vector3:
	return dir.x * right(transform) + dir.y * up(transform) + dir.z * forward(transform)
