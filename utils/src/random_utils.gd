class_name RandomUtils

# Returns 0, 1
static func rand_abs() -> float: 
	return randf()

# Returns -1, 1
static func rand_real() -> float:
	return (rand_abs() - 0.5) * 2.0

static func rand_sphere() -> Vector3:
	return Vector3(rand_real(), rand_real(), rand_real()).normalized()
