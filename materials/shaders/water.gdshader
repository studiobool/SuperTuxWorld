shader_type spatial;
render_mode cull_disabled, blend_mix;

uniform float speed : hint_range(-1,1) = 0.0;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
//uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

//colors
uniform sampler2D noise1; //add Godot noise here
uniform sampler2D noise2; //add Godot noise here
uniform sampler2D normalmap : hint_normal; //add Godot noise here, enable as_normalmap

uniform vec4 color : source_color;
uniform vec4 edge_color : source_color;

//foam
uniform float edge_scale = 0.25;
uniform float near = 0.1;
uniform float far = 100.0f;

//waves
uniform vec2 wave_strengh = vec2(0.5, 0.25);
uniform vec2 wave_frequency = vec2(12.0, 12.0);
uniform vec2 time_factor = vec2(1.0, 2.0);

float rim(float depth){
    depth = 2.0f * depth - 1.0f;
    return near * far / (far + depth * (near - far));
}


float waves(vec2 pos, float time){
    return (wave_strengh.y * sin(pos.y * wave_frequency.y + time * time_factor.y)) + (wave_strengh.x * sin(pos.x * wave_frequency.x + time * time_factor.x));
}


void vertex(){
    VERTEX.y += waves(VERTEX.xy, TIME);
}

void fragment() {
    float time = TIME * speed;
    vec3 n1 = texture(noise1, UV + time).rgb;
    vec3 n2 = texture(noise2, UV - time * 0.2).rgb;
    
    vec2 uv_movement = UV * 4.0f; // scale UV map 4x
    uv_movement += TIME * speed * 4.0f; // moves UV
    
    float sum = (n1.r + n2.r) - 1.0f;
    
    
    float z_depth = rim(texture(DEPTH_TEXTURE, SCREEN_UV).x);
    float z_pos = rim(FRAGCOORD.z);
    float diff = z_depth - z_pos;
    
    vec2 displacement = vec2(sum * 0.05);
    diff += displacement.x * 50.0f;
    
    
    vec4 col = mix(edge_color, color, step(edge_scale, diff));
    
    vec4 alpha = vec4(1.0);
    //alpha = texture(SCREEN_TEXTURE, SCREEN_UV + displacement);
    
    
    float fin = 0.0;
    if (sum > 0.0 && sum < 0.4) fin = 0.1;
    if (sum > 0.4 && sum < 0.8) fin = 0.0;
    if (sum > 0.8) fin = 1.0f;
    
    ALBEDO = vec3(fin) + mix(alpha.rgb, col.rgb, color.a);
    
    NORMAL_MAP = texture(normalmap, uv_movement).rgb;
    ROUGHNESS = 0.1;
    SPECULAR = 1.0f;
}


