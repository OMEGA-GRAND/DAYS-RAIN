shader_type canvas_item;

uniform float value : hint_range(0.01, 1);
uniform float u_active = 0.0;

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(UV, center);
    float alpha = smoothstep(0.05, 0.8, dist);

    COLOR = vec4(vec3(0.0), alpha  * value);
}