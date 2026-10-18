shader_type canvas_item;

uniform float side_shadow_strength : hint_range(0.0, 1.0) = 0.3;
uniform float bottom_shadow_strength : hint_range(0.0, 1.0) = 0.45;

void fragment() {
	float sides = smoothstep(0.16, 0.5, abs(UV.x - 0.5));
	float bottom = smoothstep(0.42, 1.0, UV.y);
	float shade = (1.0 - sides * side_shadow_strength) * (1.0 - bottom * bottom_shadow_strength);
	// Preserve texture alpha, CanvasModulate darkness, and the real front light.
	COLOR.rgb *= shade;
}
