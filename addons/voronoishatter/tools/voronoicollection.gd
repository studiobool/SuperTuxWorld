## A simple wrapper node that contains the fractured meshes generated from a VoronoiShatter node.
@tool
extends Node3D

class_name VoronoiCollection

@export_tool_button("Create Rigid Bodies", "RigidBody3D") var create_rigid_bodies_callback = create_rigid_bodies

func create_rigid_bodies():
    for child in get_children():
        if is_instance_of(child, MeshInstance3D):
            var mesh_instance: MeshInstance3D = child as MeshInstance3D
            mesh_instance.create_convex_collision(true, true)

            for maybe_static in mesh_instance.get_children():
                if is_instance_of(maybe_static, StaticBody3D):
                    var static_body: StaticBody3D = maybe_static
                    var rigid_body = RigidBody3D.new()
                    rigid_body.name = "Rigid_" + mesh_instance.name
                    static_body.replace_by(rigid_body)
                    rigid_body.reparent(self)
                    mesh_instance.reparent(rigid_body)
                    mesh_instance.scale = rigid_body.scale
                    rigid_body.scale = Vector3.ONE
