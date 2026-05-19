shader_type spatial;

render_mode unshaded, cull_disabled, blend_mix, depth_draw_opaque;

uniform float noise_scale : hint_range(0.1, 10.0) = 3.0;
uniform float edge_threshold : hint_range(0.0, 1.0) = 0.5;
uniform float edge_softness : hint_range(0.001, 0.2) = 0.05;
uniform float blob_speed : hint_range(0.0, 5.0) = 1.0;
uniform float displacement_strength : hint_range(0.0, 0.3) = 0.05;

uniform vec3 blob_color : source_color = vec3(0.1, 0.6, 1.0);

// Random + noise
float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898,78.233))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
           (c - a) * u.y * (1.0 - u.x) +
           (d - b) * u.x * u.y;
}

float fbm(vec2 p, float t) {
    float n = 0.0;
    n += noise(p + t);
    n += noise(p * 2.0 - t * 0.5) * 0.5;
    n += noise(p * 4.0 + t * 0.25) * 0.25;
    return n / 1.75;
}

void vertex() {
    float t = TIME * blob_speed;

    vec2 uv = UV;
    vec2 centered = uv - 0.5;

    float n = fbm(uv * noise_scale, t);

    // Slight vertical wobble (liquid feel)
    VERTEX.y += (n - 0.5) * displacement_strength;
}

void fragment() {
    float t = TIME * blob_speed;

    vec2 uv = UV;
    vec2 centered = uv - 0.5;

    float dist = length(centered);

    float n = fbm(uv * noise_scale, t);

    // Distorted edge
    float edge = dist + (n - 0.5) * 0.3;

    float alpha = smoothstep(edge_threshold, edge_threshold - edge_softness, edge);

    // Sharpen slightly
    alpha = pow(alpha, 1.2);

    ALBEDO = blob_color;
    ALPHA = alpha;
}