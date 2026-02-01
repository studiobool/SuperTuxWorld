using System;
using Godot;

namespace One.Woolly.VoronoiShatter.CSVoronoiAdapter;

// Wrapper for the Godot VoronoiMesh type, containing the Mesh, relative position, and the mesh being fractured.
// This class essentially functions as a struct, so we don't allow the mutation of fields on it.
public partial class AdaptedVoronoiMesh : Node
{
    public ArrayMesh Mesh { get => Instance.Get("mesh").As<ArrayMesh>(); }
    public Vector3 Position { get => Instance.Get("position").AsVector3(); }
    public MeshInstance3D Target { get => Instance.Get("target").As<MeshInstance3D>(); }

    public GodotObject Instance { get; }

    public AdaptedVoronoiMesh(GodotObject instance)
    {
        Instance = instance;

        if (Instance == null)
        {
            throw new ArgumentException("Failed to load VoronoiMesh from the given GodotObject.");
        }
    }

    public static AdaptedVoronoiMesh New()
    {
        return new((GodotObject)GD.Load<GDScript>("res://addons/voronoishatter/voronoi/model/voronoimesh.gd").New());
    }
}