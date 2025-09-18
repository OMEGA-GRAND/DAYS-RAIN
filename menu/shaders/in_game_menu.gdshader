shader_type canvas_item;

uniform float u_active;

void fragment() {
    float noise = fract(sin(dot(UV * 15.0, vec2(12.7, 78.2))) * 43758.5453);
    float flash = smoothstep(0.6, 1.0, fract((TIME + noise) * 1.));

	if (abs(u_active - 1.0) < 0.001) {
		if (flash > 0.0) {
			COLOR = vec4(.0, .0, .0, 0.5); // белая линия
		} else {
			COLOR = vec4(.0, .0, .0, 0.3);
		}
	} else {COLOR = COLOR - vec4(1.0, 1.0, 1.0, 0.05) * abs(u_active - 1.0);
	}
}