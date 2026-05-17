shader_type canvas_item;

// Uniforms to control the effect
uniform vec2 center_position = vec2(0.0, 0.0);
uniform float intensity : hint_range(0.3, 2.0) = 1.0;
uniform float fade_radius : hint_range(0.0, 2000.0) = 500.0;
uniform float fade_width : hint_range(0.0, 500.0) = 100.0;

// Varying to get the screen position from vertex to fragment
varying vec2 world_pos;

void vertex() {
	// Calculate global position of the vertex
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	// Get the texture color
	vec4 tex_color = texture(TEXTURE, UV);
	
	// Calculate distance from center
	float dist = distance(world_pos, center_position);
	
	// Create alpha fade based on distance
	float alpha = 1.0 - smoothstep(fade_radius - fade_width, fade_radius + fade_width, dist);
	
	// Apply alpha to texture, but keep the original RGB
	tex_color.a *= alpha;
	
	// !!! Crucial: Multiply by MODULATE to keep node-level colors !!!
	COLOR = (tex_color * COLOR) * intensity;
}