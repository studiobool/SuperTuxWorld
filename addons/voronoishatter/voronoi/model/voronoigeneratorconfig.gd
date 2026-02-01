## Configuration options for using VoronoiGenerator
extends Object

class_name VoronoiGeneratorConfig

# The seed influencing sample point placement
var random_seed: int
# The number of samples to intersperse in the AABB
var num_samples: int
# (optional) A 3D texture to finely control the seed placement
var texture: Texture3D