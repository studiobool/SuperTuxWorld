using System;
using System.Collections.Generic;
using Godot;

namespace One.Woolly.VoronoiShatter.CSVoronoiAdapter;

// Adapter for the Godot VoronoiGenerator type. Once instantiated, it can be used to create Voronoi meshes from a given mesh instance.
public class AdaptedVoronoiGenerator
{
    public GodotObject Instance { get; }

    public AdaptedVoronoiGenerator(GodotObject instance)
    {
        Instance = instance;
        if (Instance == null)
        {
            throw new ArgumentException("Failed to load VoronoiGenerator from the given GodotObject.");
        }
    }

    public List<AdaptedVoronoiMesh> CreateFromMesh(MeshInstance3D meshInstance3D, AdaptedVoronoiGeneratorConfig voronoiGeneratorConfig)
    {
        Godot.Collections.Array<GodotObject> resultArray = (Godot.Collections.Array<GodotObject>)Instance.Call("create_from_mesh", meshInstance3D, voronoiGeneratorConfig.Instance);
        var adaptedVoronoiMeshes = new List<AdaptedVoronoiMesh>();
        foreach (Variant result in resultArray)
        {
            adaptedVoronoiMeshes.Add(new AdaptedVoronoiMesh((GodotObject)result));
        }

        return adaptedVoronoiMeshes;
    }

    public static AdaptedVoronoiGenerator New()
    {
        return new((GodotObject)GD.Load<GDScript>("res://addons/voronoishatter/voronoi/utils/voronoigenerator.gd").New());
    }
}