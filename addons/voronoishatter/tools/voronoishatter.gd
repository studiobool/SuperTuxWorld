## The editor node that allows you to shatter a MeshInstance3D.
@tool
@icon("res://addons/voronoishatter/tools/voronoishatter.svg")
extends Node3D

class_name VoronoiShatter

@export_tool_button("Generate Fracture Meshes", "MeshInstance3D") var execute_action = execute

@export_category("Materials")
## Randomly assign color to each resulting fracture mesh (ignoring any other materials). Good for previewing the fractures.
@export var random_color: bool = true:
    set(value):
        random_color = value
        notify_property_list_changed()

var _inherit_outer_material := false
## Inherit the target mesh's surface materials
@export var inherit_outer_material: bool:
    get: return _inherit_outer_material
    set(value):
        _inherit_outer_material = value
        notify_property_list_changed()
## This material is applied to all clipped/original surfaces
@export var outer_material: StandardMaterial3D
## This material applies to the inner surfaces within the volume
@export var inner_material: StandardMaterial3D

@export_category("Structure")
## The number of samples used to determine the fracture points. Lower samples = bigger pieces (and faster generation). However, a < ~6 sample-size may lead to missing pieces.
@export_range(1, 1024, 1, "hide_slider") var samples: int = 32:
    set(value):
        samples = value
        refresh_view()

## The random seed used to generate the samples.
@export var seed: int = 0:
    set(value):
        seed = value
        refresh_view()

## Cell scale - change the size of the shape that is actually clipped
@export
var cell_scale: float = 1.0

## An optional 3D texture that influences where the samples points are generated.
@export var sample_texture: Texture3D:
    set(value):
        if sample_texture:
            sample_texture.changed.disconnect(refresh_view)

        sample_texture = value
        if sample_texture:
            value.changed.connect(refresh_view)

        refresh_view()

## Randomize the random seed.
@export_tool_button("Randomize seed", "RandomNumberGenerator") var randomize_seed_action = randomize_seed
@export_category("Original Mesh")
## Hide the target mesh after generating the fracture mesh.
@export var hide_original: bool = true
## Delete any fracture mesh children of this node before generation.
@export var delete_existing_fractures: bool = true

const NO_MESH_CHILD = "VoronoiShatter must have a MeshInstance3D as a child."
func randomize_seed():
    seed = randi()

var editable_owner: Node
var voronoi_generator: VoronoiGenerator

func _enter_tree():
    # Plugin initialization
    if Engine.is_editor_hint():
        EditorInterface.get_selection().connect("selection_changed", refresh_view)
        editable_owner = get_tree().get_edited_scene_root()
        voronoi_generator = Engine.get_singleton("EditorVoronoiGenerator") as VoronoiGenerator

func _exit_tree() -> void:
    if Engine.is_editor_hint():
        EditorInterface.get_selection().disconnect("selection_changed", refresh_view)

func get_target_mesh() -> MeshInstance3D:
    for child in get_children():
        if is_instance_of(child, MeshInstance3D):
            return child

    return null

func execute():
    started = Time.get_ticks_usec()
    await get_tree().process_frame

    if delete_existing_fractures:
        for child in get_children():
            if is_instance_of(child, VoronoiCollection):
                child.queue_free()

    generate_fracture_meshes(get_config())

var current_collection
var started = null

func generate_fracture_meshes(config: VoronoiGeneratorConfig):
    var target = get_target_mesh()
    if not target:
        VoronoiLog.err(NO_MESH_CHILD)
        return

    VoronoiLog.log("Creating Voronoi geometry for %s..." % target.name)

    # Create the parent node collection
    current_collection = VoronoiCollection.new()
    current_collection.set_block_signals(true)
    current_collection.name = "Fractured_" + target.name + "_" + str(Time.get_ticks_msec())
    add_child(current_collection)
    current_collection.set_owner(owner)

    if hide_original:
        target.visible = false

    var results := voronoi_generator.create_from_mesh(target, config)
    for result in results:
        create_from_voronoi_mesh(result)
    VoronoiLog.log("Completed in " + str((Time.get_ticks_usec() - started) / 10e5) + " seconds")
    current_collection.set_block_signals(false)

func create_from_voronoi_mesh(voronoi_mesh: VoronoiMesh):
    if voronoi_mesh == null:
        VoronoiLog.err("Skipping creation of null mesh")

    var mesh_instance = MeshInstance3D.new()
    mesh_instance.set_block_signals(true)
    var target = get_target_mesh()
    var mesh = voronoi_mesh.mesh
    mesh_instance.scale = target.scale
    mesh_instance.name = "FracturedPiece_" + str(mesh.get_rid())
    mesh_instance.mesh = mesh
    mesh_instance.position -= voronoi_mesh.position * target.scale
    mesh_instance.scale = Vector3.ONE * cell_scale

    var has_outside_faces = mesh_instance.mesh.get_surface_count() > 1

    if random_color:
        var random_color: Color = Color(randf(), randf(), randf())
        for surface in range(mesh_instance.mesh.get_surface_count()):
            var material = StandardMaterial3D.new()
            material.albedo_color = random_color

            mesh_instance.mesh.surface_set_material(surface, material)
    else:
        if has_outside_faces:
                if not inherit_outer_material:
                    for surface_id in range(1, mesh_instance.mesh.get_surface_count()):
                        mesh_instance.mesh.surface_set_material(surface_id, outer_material)

        if inner_material:
                mesh_instance.mesh.surface_set_material(0, inner_material)

    call_deferred("_deferred_add_child", mesh_instance)

func _deferred_add_child(mesh_instance: MeshInstance3D):
    current_collection.add_child(mesh_instance)
    mesh_instance.set_owner(owner)
    mesh_instance.set_block_signals(false)

func get_config() -> VoronoiGeneratorConfig:
    var config = VoronoiGeneratorConfig.new()
    config.num_samples = samples
    config.random_seed = seed
    config.texture = sample_texture
    return config

# INTERNAL FUNCTIONS - for showing things in the editor, e.g.
var sample_visualizers: Array[CSGSphere3D] = []

func refresh_view():
    if not Engine.is_editor_hint() or not is_instance_valid(voronoi_generator):
        return

    for visualizer in sample_visualizers:
        visualizer.queue_free()

    sample_visualizers = []

    var target = get_target_mesh()
    if not EditorInterface.get_selection().get_selected_nodes().has(self) or not target:
        return

    var config = get_config()
    var material = StandardMaterial3D.new()
    material.albedo_color = Color.RED
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.disable_receive_shadows = true

    for sample in voronoi_generator.sample_points(target.mesh, config):
        var sphere = CSGSphere3D.new()
        sphere.set_block_signals(true)
        sphere.material = material
        sphere.radius = 0.02
        sphere.rings = 4
        sphere.radial_segments = 4
        sphere.position = sample + target.position
        sphere.cast_shadow = false
        sample_visualizers += [sphere]
        add_child(sphere)

func _get_configuration_warnings():
    if not get_target_mesh():
        return [NO_MESH_CHILD]
