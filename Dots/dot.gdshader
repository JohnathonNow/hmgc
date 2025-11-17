// Godot shader to increase color vibrance/saturation.
// Attach this to a ShaderMaterial on your Sprite,
// or use it in a CanvasLayer for a post-processing effect.
shader_type canvas_item;

// This uniform variable adds a slider in the Godot inspector
// under "Shader Parameters".
// 1.0 = no change
// > 1.0 = more vibrant
// < 1.0 = less vibrant (desaturated)
// 0.0 = grayscale
uniform float vibrance_boost : hint_range(0.0, 5.0) = 2.5;

// Helper function to convert RGB to HSV
// (Hue, Saturation, Value)
vec3 rgb_to_hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10; // Epsilon to avoid division by zero
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// Helper function to convert HSV back to RGB
vec3 hsv_to_rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	// Get the original color from the texture
	vec4 original_color = COLOR;//texture(TEXTURE, UV);
	
	if (original_color.a > 0.0) {
		// 1. Convert the color to HSV
		// hsv.x = Hue, hsv.y = Saturation, hsv.z = Value
		vec3 hsv = rgb_to_hsv(original_color.rgb);
		
		// 2. Boost the saturation
		hsv.y *= vibrance_boost;
		
		// 3. Clamp the saturation to keep it in the valid 0.0-1.0 range
		hsv.y = clamp(hsv.y, 0.0, 1.0);
		
		// 4. Convert back to RGB
		vec3 new_rgb = hsv_to_rgb(hsv);
		
		// 5. Set the final color, keeping the original alpha (transparency)
		//vec3 final_color = new_rgb * vec3(COLOR.r, COLOR.r, COLOR.r);
		COLOR = vec4(new_rgb, original_color.a) * 1.2;
	} else {
		// If the pixel is fully transparent, just output it
		COLOR = original_color;
	}
}