//first time making my own shader turend out useable 
shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, specular_schlick_ggx;

uniform vec3 deep_color : source_color = vec3(0.015, 0.04, 0.06);
uniform vec3 horizon_color : source_color = vec3(0.30, 0.36, 0.44);
uniform vec3 foam_color : source_color = vec3(0.55, 0.60, 0.62);
uniform float wave_speed = 1.0;
uniform float wave_height = 0.08;
uniform float ripple_strength = 0.4;
uniform float fresnel_power = 3.0;

uniform vec3 trail_center = vec3(0.0, 0.0, 0.0);
uniform float trail_radius = 7.0;
uniform float trail_wavelength = 2.2;
uniform float trail_speed = 1.0;
uniform float trail_strength = 0.5;
uniform float foam_width = 0.6;

varying vec3 world_pos;

float swell(vec2 p, float t) {
	return sin(p.x * 0.30 + t * 0.7) * 0.5
		 + sin(dot(p, vec2(0.21, 0.33)) + t * 0.9) * 0.35;
}

float ripples(vec2 p, float t) {
	return sin(dot(p, vec2(3.1, 4.7)) + t * 2.3) * 0.5
		 + sin(dot(p, vec2(-5.3, 2.9)) - t * 1.7) * 0.35
		 + sin(dot(p, vec2(7.7, -6.1)) + t * 3.4) * 0.25;
}

float hull_wake(vec2 p, float t) {
	float d = length(p - trail_center.xz);
	float fade = smoothstep(trail_radius, 0.0, d);
	float rings = sin(d * trail_wavelength - t * trail_speed * 3.0);
	return rings * fade;
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX.y += swell(world_pos.xz, TIME * wave_speed) * wave_height;
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = world_pos.xz;
	float t = TIME * wave_speed;

	float e = 0.8;
	vec2 sw = vec2(
		swell(p + vec2(e, 0.0), t) - swell(p - vec2(e, 0.0), t),
		swell(p + vec2(0.0, e), t) - swell(p - vec2(0.0, e), t));

	float er = 0.25;
	vec2 rp = vec2(
		ripples(p + vec2(er, 0.0), t) - ripples(p - vec2(er, 0.0), t),
		ripples(p + vec2(0.0, er), t) - ripples(p - vec2(0.0, er), t));

	float ew = 0.3;
	vec2 wk = vec2(
		hull_wake(p + vec2(ew, 0.0), t) - hull_wake(p - vec2(ew, 0.0), t),
		hull_wake(p + vec2(0.0, ew), t) - hull_wake(p - vec2(0.0, ew), t));

	vec3 world_normal = normalize(vec3(
		-(sw.x * 2.0 + rp.x * ripple_strength + wk.x * trail_strength * 14.0),
		6.0,
		-(sw.y * 2.0 + rp.y * ripple_strength + wk.y * trail_strength * 14.0)));

	NORMAL = normalize((VIEW_MATRIX * vec4(world_normal, 0.0)).xyz);

	vec3 view_dir = normalize(-VERTEX);
	float fresnel = pow(1.0 - clamp(abs(dot(view_dir, NORMAL)), 0.0, 1.0), fresnel_power);

	ALBEDO = mix(deep_color, horizon_color, fresnel * 0.75);

	float d = length(p - trail_center.xz);
	float halo = smoothstep(foam_width, foam_width * 0.25, d);
	float ring_foam = max(hull_wake(p, t), 0.0) * 0.15 * smoothstep(trail_radius * 0.6, 0.0, d);
	ALBEDO = mix(ALBEDO, foam_color, clamp(halo * 0.6 + ring_foam, 0.0, 0.8));
	ROUGHNESS = 0.06;
	SPECULAR = 0.7;
	METALLIC = 0.0;
}
