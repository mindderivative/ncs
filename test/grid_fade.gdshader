shader_type canvas_item;

uniform vec4 major_color : source_color = vec4(1.0, 1.0, 1.0, 0.8);
uniform vec4 minor_color : source_color = vec4(1.0, 1.0, 1.0, 0.3);
uniform float fade_radius = 500.0;
uniform float feathering = 0.5;

void fragment() {
    // 1. Setup Distance Calculation
    vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 pixel_pos = SCREEN_UV * screen_size;
    vec2 screen_center = screen_size * 0.5;
    float dist = distance(pixel_pos, screen_center);
    
    // 2. Determine Alpha Fade
    float alpha_mask = 1.0 - smoothstep(fade_radius * (1.0 - feathering), fade_radius, dist);
    
    // 3. Select Color
    // We use the 'red' channel of the vertex color (from GDScript) to choose
    // which uniform to use. (Major lines = 1.0, Minor lines = 0.5)
    vec4 final_color;
    if (COLOR.r > 0.7) {
        final_color = major_color;
    } else {
        final_color = minor_color;
    }
    
    // 4. Combine and Apply
    final_color.a *= alpha_mask;
    COLOR = final_color;
}