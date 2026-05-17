shader_type canvas_item;

// --- TEXTURES ---
uniform sampler2D normal_img : repeat_enable, filter_linear_mipmap;
uniform sampler2D height_img : repeat_enable, filter_linear_mipmap;
uniform sampler2D core_gradient : source_color;
uniform sampler2D shadow_gradient : source_color;
uniform sampler2D corona_gradient : source_color;

// --- GLOBAL SETTINGS ---
uniform float thickness_power : hint_range(1.0, 10.0) = 3.0;  
uniform float angular_speed : hint_range(-5.0, 5.0, 0.01) = 2.5;
uniform float radial_speed : hint_range(-5.0, 5.0, 0.01) = 0.0;

// --- LAVA EMISSION ---
uniform float emission_intensity : hint_range(0.0, 10.0) = 2.0; 
uniform float emission_threshold : hint_range(0.0, 1.0) = 0.5;  

// --- CARDINAL LIGHTING ---
uniform float bump_intensity : hint_range(0.0, 5.0) = 1.0;
uniform float light_intensity : hint_range(0.0, 5.0) = 1.0;
uniform float light_falloff : hint_range(0.1, 10.0) = 2.0;
uniform bool light_north_enabled = true;
uniform bool light_south_enabled = true;
uniform bool light_east_enabled = true;
uniform bool light_west_enabled = true;

const vec3 LIGHT_N = vec3(0.0, 1.0, 0.5);
const vec3 LIGHT_S = vec3(0.0, -1.0, 0.5);
const vec3 LIGHT_E = vec3(1.0, 0.0, 0.5);
const vec3 LIGHT_W = vec3(-1.0, 0.0, 0.5);

// --- CORONA ---
uniform bool corona_enabled = true;
uniform float corona_inner_radius : hint_range(0.0, 1.0) = 0.45;
uniform float corona_inner_fade : hint_range(0.01, 1.0) = 0.1;
uniform float corona_outer_radius : hint_range(0.0, 1.0) = 0.75;
uniform float corona_outer_fade : hint_range(0.01, 1.0) = 0.2;
uniform float corona_intensity : hint_range(0.0, 5.0) = 1.0;

// --- SHADOW ---
uniform bool shadow_enabled = true;
uniform float shadow_inner_radius : hint_range(0.0, 1.0) = 0.4;
uniform float shadow_inner_fade : hint_range(0.01, 1.0) = 0.1;
uniform float shadow_outer_radius : hint_range(0.0, 1.0) = 0.5;
uniform float shadow_outer_fade : hint_range(0.01, 1.0) = 0.05;
uniform float shadow_intensity : hint_range(0.0, 5.0) = 1.2;

uniform float body_radius : hint_range(0.1, 1.0) = 0.45;

// --- HELPERS ---
vec2 get_sphere_uv(vec3 p) {
	float longitude = atan(p.z, p.x) / (2.0 * PI) + 0.5;
	float latitude = acos(clamp(p.y, -0.999, 0.999)) / PI;
	return vec2(longitude, latitude);
}

void fragment() {
	vec2 uv = vec2(.5) - UV;
	float r = length(uv) * 2.0;
	
	// --- 1. BODY MASKING ---
	// This ensures lighting math ONLY happens inside the sun's circle.
	float body_mask = smoothstep(body_radius, body_radius - 0.005, r);
	
	vec3 surface_rgb = vec3(0.0);
	
	// Only calculate body if we are inside it
	if (r < body_radius) {
		float z = sqrt(max(0.0, (body_radius * body_radius) - r * r));
		vec3 p3d = normalize(vec3(uv, z));
		vec2 sphere_uv = get_sphere_uv(p3d);

		float time_val = atan(uv.y, uv.x) + (TIME * angular_speed);
		vec2 polar = fract(vec2(time_val / 6.28, r + (TIME * radial_speed)));
		float cycle1 = fract(time_val / 6.28);
		float cycle2 = fract(time_val / 6.28 + 0.5);
		float zoom1 = mix(1, 2.5, cycle1);
		float zoom2 = mix(1, 2.5, cycle2);
		float fade = smoothstep(0.0, 0.5, cycle1) * smoothstep(1.0, 0.5, cycle1);
		
		// Sampling
		vec3 n1 = texture(normal_img, uv / zoom1).rgb;
		vec3 n2 = texture(normal_img, uv / zoom2).rgb;
		vec3 unpacked_n = normalize(mix(n2, n1, fade) * 2.0 - 1.0);
		float h1 = texture(height_img, uv / zoom1).r;
		float h2 = texture(height_img, uv / zoom2).r;
		float height = mix(h2, h1, fade);

		vec3 final_normal = normalize(p3d + (unpacked_n * bump_intensity));
		
		// Lighting (Strictly for Body)
		float diff = 0.0;
		if (light_north_enabled) diff += pow(max(dot(final_normal, normalize(LIGHT_N)), 0.0), light_falloff);
		if (light_south_enabled) diff += pow(max(dot(final_normal, normalize(LIGHT_S)), 0.0), light_falloff);
		if (light_east_enabled)  diff += pow(max(dot(final_normal, normalize(LIGHT_E)), 0.0), light_falloff);
		if (light_west_enabled)  diff += pow(max(dot(final_normal, normalize(LIGHT_W)), 0.0), light_falloff);
		diff *= light_intensity;

		
		vec3 core_rgb = texture(core_gradient, vec2(clamp(height, 0.01, 0.99), 0.0)).rgb;
		float e_mask = smoothstep(emission_threshold - 0.2, emission_threshold + 0.1, height);
		vec3 emission = core_rgb * e_mask * height * emission_intensity;

		// Shadow Ring (Strictly for Body)
		float s_mask_val = 0.0;
		if (shadow_enabled) {
			float s_in = smoothstep(shadow_inner_radius - shadow_inner_fade, shadow_inner_radius, r);
			float s_out = smoothstep(shadow_outer_radius, shadow_outer_radius - shadow_outer_fade, r);
			s_mask_val = clamp(s_in * s_out, 0.0, 1.0);
		}
		vec3 shadow_rgb = texture(shadow_gradient, vec2(clamp(s_mask_val, 0.01, 0.99), 0.0)).rgb;

		// Base Surface Composition
		surface_rgb = (core_rgb * diff) + emission + (core_rgb * 0.1); 
		if (shadow_enabled) surface_rgb = mix(surface_rgb, shadow_rgb, s_mask_val * clamp(shadow_intensity, 0.0, 1.0));
	}

	// Create final color with body alpha
	vec4 final_col = vec4(surface_rgb, body_mask);
	
	// --- 2. THE CORONA (TOTALLY INDEPENDENT) ---
	if (corona_enabled) {
		float c_in = smoothstep(corona_inner_radius - corona_inner_fade, corona_inner_radius, r);
		float c_out = smoothstep(corona_outer_radius, corona_outer_radius - corona_outer_fade, r);
		float corona_mask = clamp(c_in * c_out, 0.0, 1.0);
		
		float corona_uv = clamp(pow(corona_mask, thickness_power), 0.01, 0.99);
		vec3 corona_color = texture(corona_gradient, vec2(corona_uv, 0.0)).rgb;
		float corona_alpha = corona_uv * corona_intensity;
		
		// Use standard screen blending for the corona to keep it separate from body lighting
		final_col.rgb = mix(final_col.rgb, corona_color, corona_alpha);
		final_col.a = max(final_col.a, corona_alpha);
	}
	
	COLOR = final_col;
}