shader_type canvas_item;
render_mode blend_mix; 
const vec3 sky_color = vec3(0.2, 0.2, 0.4);

void fragment() {
	float alpfa;
	vec2 uv = FRAGCOORD.xy;
	vec2 floa[4] = vec2[4](
		vec2(0.5, 0.0),
		vec2(0.5, 1.0),
		vec2(0.0, 0.5),
		vec2(1.0, 0.5)
	);
	for (int i = 0; i < 4; i++){
		float d = distance(uv, floa[i]);
		if (alpfa > d){
			alpfa = d;
			COLOR = vec4(sky_color, d);
			}
			
	}
}