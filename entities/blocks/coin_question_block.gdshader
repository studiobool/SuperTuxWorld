// Port of Unity Ice Shader to Godot
// by NekotoArts
// OG Shader here - https://www.youtube.com/watch?v=Gym5JWHgjkk
//
//
// my bruddahs dont dab we just Vossi Bop

shader_type spatial;
render_mode depth_draw_always, specular_schlick_ggx;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float FresnelPower = 2.5;
uniform float FresnelTransparency = 0.5;
uniform vec4 FresnelColor : source_color;
uniform vec4 Color : source_color;
uniform vec3 Tiling = vec3(1.0, 1.0, 0.0);
uniform vec3 Offset = vec3(0.0, 0.0, 0.0);
uniform sampler2D Ice_Texture : source_color;
uniform sampler2D Ice_Texture_2 : source_color;
uniform float RefractionAmount = 1.0;
uniform float Metallic = 0.134;
uniform float Smoothness = 0.627;
uniform float Normals = 0.77;


// TilingAndOffsetUV

vec2 ti1ingN0ffsetFunc(vec2 _uv_tN0, vec2 _offset_tN0){
	return vec2(mod(_uv_tN0.x + _offset_tN0.x, 1.0), mod(_uv_tN0.y + _offset_tN0.y, 1.0));
}

// ReadNormalMap

// Pulled straight from Godot's scene.glsl file
vec3 read_normalmap(in vec3 normalmap, in vec3 normal, in vec3 tangent, in vec3 binormal, in float normaldepth) {
	normalmap.xy = normalmap.xy * 2.0 - 1.0;
	normalmap.z = sqrt(max(0.0, 1.0 - dot(normalmap.xy, normalmap.xy))); //always ignore Z, as it can be RG packed, Z may be pos/neg, etc.
	
	return normalize(mix(normal, tangent * normalmap.x + binormal * normalmap.y + normal * normalmap.z, normaldepth));
}

void vertex() {
// Output:0

}

void fragment() {
// ScalarUniform:23
	float n_out23p0 = FresnelPower;

// Fresnel:22
	float n_out22p0 = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), n_out23p0);

// Texture2D:14
	vec4 n_out39p0 = texture(Ice_Texture, UV);
	vec4 n_out41p0 = texture(Ice_Texture_2, UV);

// Fresnel:13
	float n_in13p3 = FresnelTransparency;
	float n_out40p0 = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 0.25), n_in13p3);

// FloatOp:15
	float n_out38p0 = (n_out40p0 / 1.75) / n_out41p0.x * 1.5;

// ColorUniform:24
	vec3 n_out24p0 = FresnelColor.rgb;
	float n_out24p1 = FresnelColor.a;

// VectorOp:25
	vec3 n_out25p0 = vec3(n_out22p0) * vec3(n_out24p0);

// ColorUniform:5
	vec3 n_out5p0 = Color.rgb;
	float n_out5p1 = Color.a;

// Input:29
	vec3 n_out29p0 = vec3(UV, 0.0);

// VectorUniform:31
	vec3 n_out31p0 = Tiling;

// VectorOp:30
	vec3 n_out30p0 = n_out29p0 * n_out31p0;

// VectorUniform:28
	vec3 n_out28p0 = Offset;

// TilingAndOffsetUV:27
	vec3 n_out27p0;
	{
		n_out27p0 = vec3(ti1ingN0ffsetFunc(n_out30p0.xy, n_out28p0.xy), 0);
	}

// Texture:11
	vec3 n_out11p0;
	float n_out11p1;
	{
		vec4 Ice_Texture_tex_read = texture(Ice_Texture, n_out27p0.xy);
		n_out11p0 = Ice_Texture_tex_read.rgb;
		n_out11p1 = Ice_Texture_tex_read.a;
	}

// Input:9
	vec3 n_out9p0 = vec3(SCREEN_UV, 0.0);

// VectorDecompose:12
	float n_out12p0 = n_out11p0.x;
	float n_out12p1 = n_out11p0.y;
	float n_out12p2 = n_out11p0.z;

// ScalarOp:10
	float n_out10p0 = dot(n_out9p0, vec3(0.333333, 0.333333, 0.333333)) * n_out12p0;

// ScalarOp:17
	float n_out17p0 = dot(n_out9p0, vec3(0.333333, 0.333333, 0.333333)) + n_out10p0;

// VectorOp:13
	vec3 n_out13p0 = n_out9p0 - vec3(n_out17p0);

// ScalarUniform:16
	float n_out16p0 = RefractionAmount;

// VectorOp:14
	vec3 n_out14p0 = n_out13p0 * vec3(n_out16p0);

// VectorOp:15
	vec3 n_out15p0 = n_out14p0 + n_out9p0;

// Input:7

// Texture:8
	vec3 n_out8p0;
	float n_out8p1;
	{
		vec4 SCREEN_TEXTURE_tex_read = texture(SCREEN_TEXTURE, n_out15p0.xy);
		n_out8p0 = SCREEN_TEXTURE_tex_read.rgb;
		n_out8p1 = SCREEN_TEXTURE_tex_read.a;
	}

// VectorOp:20
	vec3 n_out20p0 = n_out11p0 + n_out8p0;

// VectorOp:21
	vec3 n_out21p0 = n_out5p0 * n_out20p0;

// VectorOp:26
	vec3 n_out26p0 = n_out25p0 + n_out21p0;

// ScalarUniform:2
	float n_out2p0 = Metallic;

// ScalarUniform:3
	float n_out3p0 = Smoothness;

// ScalarUniform:4
	float n_out4p0 = Normals;

// ReadNormalMap:18
	vec3 n_out18p0;
	{
		n_out18p0 = read_normalmap(n_out11p0, vec3(n_out4p0), TANGENT, BINORMAL, NORMAL_MAP_DEPTH);
	}

// Output:0
	ALBEDO = n_out26p0;
	ALPHA = n_out38p0;
	METALLIC = n_out2p0;
	SPECULAR = n_out3p0;
	NORMAL = n_out18p0;

}