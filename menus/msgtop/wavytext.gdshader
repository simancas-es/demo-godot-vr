shader_type canvas_item;

uniform float time;
uniform float amplitude = 2.0;
uniform float frequency = 5.0;
uniform float speed = 1.0;

void fragment() {
    //vec2 uv = FRAGCOORD.xy;
    //COLOR = texture(TEXTURE, UV);
}

void vertex() {
    VERTEX.y += sin(VERTEX.x * frequency + TIME * speed) * amplitude;
}