shader_type canvas_item;

// This is controlled by the GDScript
uniform vec2 rolling_offset = vec2(0.0, 0.0);

void fragment() {
	// Center the UV coordinates
	vec2 uv = UV - 0.5;
	
	// Calculate distance from center to make a perfect circle
	float dist = length(uv);
	
	if (dist > 0.5) {
		// Crop out the corners of the square texture
		COLOR.a = 0.0;
	} else {
		// Math to distort the flat image into a 3D sphere bulge
		float z = sqrt(0.25 - dist * dist);
		vec2 distorted_uv = (uv / z) * 0.3; // 0.3 controls the zoom of the texture
		
		// Apply the rolling movement driven by the RigidBody2D velocity
		vec2 final_uv = distorted_uv + rolling_offset;
		
		COLOR = texture(TEXTURE, final_uv);
	}
}