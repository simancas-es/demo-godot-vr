shader_type spatial;

render_mode unshaded, blend_mix, cull_disabled;

uniform sampler2D albedo_texture : source_color;
uniform vec4 back_color : source_color = vec4(0.36, 0.2, 0.1, 1.0);

void fragment() {
    vec4 tex = texture(albedo_texture, UV);

    if (FRONT_FACING) {
        ALBEDO = tex.rgb;
        ALPHA = tex.a;
    } else {
        ALBEDO = back_color.rgb;
        ALPHA = tex.a;
    }
}