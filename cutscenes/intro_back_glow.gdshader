shader_type canvas_item;
render_mode unshaded;

uniform vec4 glow_color : source_color = vec4(0.28, 0.23, 0.35, 1.0);
uniform float energy : hint_range(0.0, 1.0) = 0.28;
uniform float pulse_frequency : hint_range(0.05, 3.0) = 0.55;
uniform float pulse_depth : hint_range(0.0, 1.0) = 0.4;
uniform float audio_time = 0.0;

void fragment() {
	vec2 position = (UV - vec2(0.5, 0.44)) * vec2(1.2, 1.0);
	float halo = exp(-dot(position, position) * 9.0);
	float edge_fade = 1.0 - smoothstep(0.35, 0.55, length(position));
	float pulse = 1.0 - pulse_depth * (0.5 + 0.5 * sin(audio_time * pulse_frequency * 6.283185));
	COLOR = vec4(glow_color.rgb, halo * edge_fade * energy * pulse);
}
