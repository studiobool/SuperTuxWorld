## Helper functions to create Voronoi geometry. To use, create a new instance of this node and
## call create_from_mesh() with a MeshInstance3D and VoronoiGeneratorConfig. The best way to use
## this is to store it as a singleton instead of creating a new instance each time to avoid the
## overhead of creating the child node instances.

extends Node

class_name VoronoiGenerator
# These CSGMesh3Ds are used to efficiently perform the clipping logic seen below.
var csg_clip = CSGMesh3D.new()
var csg_mask = CSGMesh3D.new()

func _init() -> void:
    add_child(csg_clip)
    csg_clip.add_child(csg_mask)
    csg_mask.operation = CSGShape3D.OPERATION_INTERSECTION


## End-to-end function that samples points, creates tetrahedra, and generates voronoi cells (asyncronously).
## This is the best way to create fractures from a mesh. REQUIRES THE VoronoiWorker TO WORK!
## Make sure you listen to the signal as described in README.md. 
func create_from_mesh(mesh: MeshInstance3D, options: VoronoiGeneratorConfig) -> Array[VoronoiMesh]:
    var points = sample_points(mesh.mesh, options)
    var tetrahedra = create_delauney_tetrahedra(points)
    # Dictionary[Vector3, int]
    var point_to_index_map: Dictionary[Vector3, int] = {}
    for i in range(len(points)):
        if points[i] not in point_to_index_map:
            point_to_index_map[points[i]] = i

    return generate_voronoi_cells(mesh, tetrahedra, points, point_to_index_map)

## This function is used to sample points inside a bounding box. These points
## can be used for Delauney Tetrahedronization.
func sample_points(mesh: Mesh, options: VoronoiGeneratorConfig) -> Array[Vector3]:
    var aabb = mesh.get_aabb()
    var random_seed = options.random_seed
    var num_samples = options.num_samples
    var sample_points: Array[Vector3] = []
    var rng = RandomNumberGenerator.new()
    var offset = 0
    var texture3d = options.texture

    # Randomly sample points
    for i in range(num_samples):
        # Generate random position in AABB
        rng.seed = random_seed + offset
        var x_norm: float = rng.randf()
        offset += 1
        rng.seed = random_seed + offset
        var y_norm: float = rng.randf()
        offset += 1
        rng.seed = random_seed + offset
        var z_norm: float = rng.randf()
        offset += 1

        var pos_in_aabb = Vector3(x_norm, y_norm, z_norm)

        # If texture3d is provided, use rejection sampling based on texture value
        if texture3d != null:
            # Sample the texture at the normalized position (0-1)
            var texture_value = sample_3d_texture(texture3d, pos_in_aabb)

            # Reject sample if random value is greater than texture value
            rng.seed = random_seed + offset
            offset += 1
            if rng.randf() > texture_value:
                # Skip this sample and try again
                i -= 1
                continue

        # Convert normalized position to world position
        var x: float = aabb.position.x + x_norm * aabb.size.x
        var y: float = aabb.position.y + y_norm * aabb.size.y
        var z: float = aabb.position.z + z_norm * aabb.size.z

        sample_points.append(Vector3(x, y, z))

    # Missing geometry can happen if we don't add the 8 endpoints of the AABB
    var endpoints: Array[Vector3] = []
    for i in range(8):
        endpoints.append(aabb.get_endpoint(i))

    return sample_points + endpoints

## Helper function to sample a Texture3D. Returns value in range 0.0 to 1.0
func sample_3d_texture(texture: Texture3D, normalized_position: Vector3) -> float:
    # Ensure position is in 0-1 range
    var pos = normalized_position.clamp(Vector3.ZERO, Vector3.ONE)

    # Get texture dimensions
    var width = texture.get_width()
    var height = texture.get_height()
    var depth = texture.get_depth()

    # Convert normalized position to texture coordinates
    var tx = int(pos.x * (width - 1))
    var ty = int(pos.y * (height - 1))
    var tz = int(pos.z * (depth - 1))

    # Get color at position
    var color = texture.get_data()[tz].get_pixel(tx, ty)

    # Use grayscale value (or you could use a specific channel or combination)
    # Converting color to grayscale using standard luminance formula
    return color.r * 0.299 + color.g * 0.587 + color.b * 0.114

## Creates a set of tetrahedra from the given point cloud
func create_delauney_tetrahedra(points: Array[Vector3]) -> Array[Tetrahedron]:
    var packed_points_array = PackedVector3Array(points)
    var delauney_indices = Geometry3D.tetrahedralize_delaunay(points)

    if delauney_indices == null or delauney_indices.size() == 0:
        VoronoiLog.err("Failed to tetrahedralize. This probably means all points are coplanar, e.g. the case of a plane or 2D geometry (this algorithm is meant for 3D shapes).")
        return []

    var tetrahedra: Array[Tetrahedron] = []

    # Process tetrahedra. Each tetrahedron has 4 points.
    for i in range(0, delauney_indices.size(), 4):
        var i0: int = delauney_indices.get(i)
        var i1: int = delauney_indices.get(i + 1)
        var i2: int = delauney_indices.get(i + 2)
        var i3: int = delauney_indices.get(i + 3)

        var v0: Vector3 = points[i0]
        var v1: Vector3 = points[i1]
        var v2: Vector3 = points[i2]
        var v3: Vector3 = points[i3]

        var tetrahedron = Tetrahedron.new()
        tetrahedron.vertices = [v0, v1, v2, v3] as Array[Vector3]
        tetrahedron.indices = [i0, i1, i2, i3] as Array[int]
        tetrahedra += [tetrahedron]

    return tetrahedra

## Create voronoi cell meshes using the circumcenters of the given tetrahedra
func generate_voronoi_cells(clipping_mesh: MeshInstance3D, tetrahedra: Array[Tetrahedron], points: Array[Vector3], point_index_map: Dictionary) -> Array[VoronoiMesh]:
    # Map: Site Index -> List of Circumcenters (potential Voronoi cell vertices)
    # Dictionary[int, Array[Vector3]]
    var potential_cell_vertices: Dictionary[int, Array] = {}

    for tetrahedron in tetrahedra:
        var center: Vector3 = tetrahedron.try_calculate_tetrahedron_circumcenter()

        if center != null:
            for point_index in tetrahedron.indices:
                # Is this point one of our target Voronoi sites?
                # Check efficiently if point_index corresponds to a key in point_index_map values
                # A reverse lookup or checking if points[point_index] is a site is needed.
                var current_point: Vector3 = points[point_index]
                # Efficient check if this point is a site
                if point_index_map.has(current_point):
                    # Get the index used as key for potential_cell_vertices
                    var site_list_index: int = point_index_map[current_point]

                    if !potential_cell_vertices.has(site_list_index):
                        potential_cell_vertices[site_list_index] = [] as Array[Vector3]

                    potential_cell_vertices[site_list_index] += [center]

    var cells: Array[VoronoiCell] = []

    for key in potential_cell_vertices:
        var voronoi_cell = VoronoiCell.new()

        # Re-create the aray from the vertices (I know, I know... but the type system is just a bit wonky in GDScript)
        for vertex in potential_cell_vertices[key]:
            voronoi_cell.vertices += [vertex] as Array[Vector3]
        voronoi_cell.site = points[key]
        cells += [voronoi_cell]

    return create_geometry_from_sites(clipping_mesh, cells)

# Creates Voronoi cells from the given points by clipping them against a given mesh.
func create_geometry_from_sites(mesh_instance: MeshInstance3D, cells: Array[VoronoiCell]) -> Array[VoronoiMesh]:
    var voronoi_meshes: Array[VoronoiMesh] = []
    for cell in cells:
        # Didn't find enough circumcenters to generate the sites from
        if not cell.is_valid():
            continue

        # Some of these circumcenters may be outside the shape of the mesh, so clip them to size
        var clipped_hull: VoronoiMesh = clip_to_mesh(cell.vertices, mesh_instance.mesh)

        if not clipped_hull:
            continue

        # Add the clipped mesh as the result
        voronoi_meshes += [clipped_hull]

    return voronoi_meshes

# Creates a mesh out of the points and clips it against the given mask_mesh
func clip_to_mesh(points: Array, mask_mesh: Mesh) -> VoronoiMesh:
    var center = mask_mesh.get_aabb().get_center()

    csg_mask.mesh = mask_mesh

    var shape_3d: ConvexPolygonShape3D = ConvexPolygonShape3D.new()
    shape_3d.set_points(PackedVector3Array(points))
    csg_clip.mesh = shape_3d.get_debug_mesh()
    
    # Now safe to access result
    csg_clip._update_shape()
   
    var resulting_mesh: ArrayMesh = csg_clip.bake_static_mesh()

    if not is_instance_valid(resulting_mesh):
        VoronoiLog.err("ClipCellToMesh: CSG result mesh is invalid for cell centered at %s." % center)
        return null
    
    if resulting_mesh.get_surface_count() == 0:
        return null

    var offset = resulting_mesh.get_aabb().get_center()
    resulting_mesh = recenter_mesh_origin(resulting_mesh)

    var voronoi_mesh = VoronoiMesh.new()
    voronoi_mesh.mesh = resulting_mesh
    voronoi_mesh.position = - offset

    return voronoi_mesh

func recenter_mesh_origin(mesh: ArrayMesh) -> ArrayMesh:
    var combined_aabb = mesh.get_aabb()
    var center = combined_aabb.get_center()

    var new_mesh = ArrayMesh.new()

    for surface in range(mesh.get_surface_count()):
        var arr = mesh.surface_get_arrays(surface)
        var vertices = arr[Mesh.ARRAY_VERTEX]

        if not len(vertices):
            continue

        # Offset all vertices by -center
        for i in range(vertices.size()):
            vertices[i] -= center

        # Preserve material
        var material = mesh.surface_get_material(surface)

        # Re-add the adjusted surface to the new mesh
        new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
        new_mesh.surface_set_material(surface, material)

    return new_mesh
