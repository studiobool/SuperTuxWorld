using System;
using Godot;

namespace One.Woolly.VoronoiShatter;

// Adapter for the Godot VoronoiGeneratorConfig type. This class is used to configure the sampling and generation
// of Voronoi meshes.
public partial class AdaptedVoronoiGeneratorConfig : Node
{
    public GodotObject Instance { get; }
    public long RandomSeed
    {
        get => Instance.Get("random_seed").AsInt64();
        set => Instance.Set("random_seed", value);
    }

    public int NumSamples
    {
        get => Instance.Get("num_samples").AsInt32();
        set => Instance.Set("num_samples", value);
    }

    public Texture3D Texture
    {
        get => Instance.Get("texture").As<Texture3D>();
        set => Instance.Set("texture", value);
    }

    public AdaptedVoronoiGeneratorConfig(GodotObject instance)
    {
        Instance = instance;
        if (Instance == null)
        {
            throw new ArgumentException("Failed to load VoronoiGeneratorConfig from the given GodotObject.");
        }
    }

    public static AdaptedVoronoiGeneratorConfig New()
    {
        return new((GodotObject)GD.Load<GDScript>("res://addons/voronoishatter/voronoi/model/voronoigeneratorconfig.gd").New());
    }
}