shader_type spatial;

uniform vec3 ripple_origin;
uniform vec3 ripple_direction = vec3(1.0, 0.0, 0.0);
uniform float ripple_speed = 0.2;
uniform float ripple_frequency = 0.4;
uniform float ripple_amplitude = 0.1;
uniform vec3 water_color = vec3(0.4, 0.26, 0.13);

// Multiple flash centers
uniform int flash_center_count;
uniform vec3 flash_centers[8]; // Max 8
uniform float flash_centers_strength[8]; //WARNING! Initialize with ones manually!!
uniform float flash_radius = 3.0;
uniform float flash_intensity = 0.5;
uniform float flash_noise_scale = 15.0;
uniform float flash_speed = 6.0;
uniform float flash_threshold = 0.6;

varying vec3 world_pos_interp;

// Hash and noise functions
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) +
           (c - a) * u.y * (1.0 - u.x) +
           (d - b) * u.x * u.y;
}

void vertex() {
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_pos_interp = world_pos;

    // Ripple effect
    vec2 offset = world_pos.xz - ripple_origin.xz;
    vec2 dir = normalize(ripple_direction.xz);
    float dist_along_dir = dot(dir, offset);
    float wave = sin(dist_along_dir * ripple_frequency - TIME * ripple_speed);
    float height = wave * ripple_amplitude;

    VERTEX.y += height;
}

void fragment() {
    vec3 world_pos = world_pos_interp;
	//vec3 world_pos = world_pos_interp + NODE_POSITION_WORLD;
    vec3 final_color = water_color;

    // Fixed noise value for this fragment
    float base_noise = noise(world_pos.xz * flash_noise_scale) * flash_noise_scale;
    float pulse = sin(base_noise + TIME * flash_speed) * 0.5 + 0.5;
    float brightness = smoothstep(flash_threshold, 1.0, pulse);

    float combined_strength = 0.0;

    for (int i = 0; i < flash_center_count; i++) {
        float dist = distance(world_pos.xz, (MODEL_MATRIX * vec4(flash_centers[i], 1.0)).xz);
        float partial_strength = (1.0 - clamp(dist / flash_radius, 0.0, 1.0)) * flash_centers_strength[i];
        combined_strength += partial_strength; // Use max falloff for sharpest influence
    }
	combined_strength = clamp(combined_strength, 0.0, 1.0);

    float flash_strength = brightness * combined_strength * flash_intensity;

    final_color = mix(water_color, vec3(1.0), flash_strength);

    ALBEDO = final_color;
    SPECULAR = 0.2;
    ROUGHNESS = 0.4;
}
