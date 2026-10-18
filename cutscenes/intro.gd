extends Node2D
## Subtitles, lighting, and the pulse share the voice track's playback clock.

@export_group("Subtitles")
@export var subtitle_track: JSON
## Positive values show all subtitles later; negative values show them earlier.
@export_range(-5.0, 5.0, 0.01) var subtitle_offset_seconds: float = 0.0
@export_group("Front light")
## -1 follows the subtitle marked with "reveal": true; otherwise use audio seconds.
@export_range(-1.0, 120.0, 0.01) var reveal_time_override: float = -1.0
## Extra pause after the marked phrase, before the front light starts turning on.
@export_range(0.0, 5.0, 0.05) var reveal_delay: float = 1.0
@export_range(0.05, 3.0, 0.05) var reveal_duration: float = 0.45
@export_range(0.0, 3.0, 0.05) var front_light_energy: float = 1.15
@export_group("Character shading")
@export_range(0.0, 1.0, 0.05) var side_shadow_strength: float = 0.3
@export_range(0.0, 1.0, 0.05) var bottom_shadow_strength: float = 0.45
@export_group("Back light")
@export var back_light_color: Color = Color(0.28, 0.23, 0.35, 1.0)
@export_range(0.0, 1.0, 0.01) var back_light_energy: float = 0.28
@export_range(0.05, 3.0, 0.05) var pulse_frequency: float = 0.55
@export_range(0.0, 1.0, 0.05) var pulse_depth: float = 0.4
@export_group("Playback")
## Start near a line to tune its timing without replaying the entire recording.
@export_range(0.0, 120.0, 0.05) var start_time: float = 0.0
@export_range(0.1, 3.0, 0.05) var fade_duration: float = 0.6
@export var log_subtitle_times: bool = false
@export_group("Ending")
## Hold after the front light has fully revealed the character.
@export_range(0.0, 5.0, 0.05) var ending_hold_duration: float = 1.0
@export_range(0.1, 3.0, 0.05) var ending_fade_duration: float = 0.7

var playback_time: float = 0.0
var _cues: Array[Dictionary] = []
var _reveal_cue_time: float = -1.0
var _active_cue: int = -1
var _finishing: bool = false
var _audio_finished: bool = false

@onready var _voice: AudioStreamPlayer = $Voice
@onready var _subtitle: Label = $Subtitles/Text
@onready var _front_light: PointLight2D = $FrontLight
@onready var _back_light: ShaderMaterial = $BackGlow.material
@onready var _fade: ColorRect = $Transition/Black
@onready var _character_material: ShaderMaterial = $RatImage.material


func _ready() -> void:
	_load_subtitles()
	_front_light.energy = 0.0
	_subtitle.text = ""
	_fade.color.a = 1.0
	_voice.finished.connect(_on_voice_finished)
	if _voice.stream == null:
		push_error("Intro: assign a voice track to Voice.stream.")
		_finish()
		return
	playback_time = clampf(start_time, 0.0, maxf(_voice.stream.get_length() - 0.05, 0.0))
	_update_timeline(playback_time)
	_voice.play(playback_time)
	create_tween().tween_property(_fade, "color:a", 0.0, fade_duration)


func _process(delta: float) -> void:
	if _finishing:
		return
	if _voice.playing:
		var audio_time := _voice.get_playback_position() + AudioServer.get_time_since_last_mix()
		audio_time -= AudioServer.get_output_latency()
		# Audio callbacks can jitter slightly; the visible timeline only moves forward.
		playback_time = maxf(playback_time, audio_time)
	elif _audio_finished:
		# The final reveal and hold may outlast the recording. Keep them running.
		playback_time += delta
	else:
		return
	_update_timeline(playback_time)
	var reveal_time := _get_reveal_time()
	var hold_end := reveal_time + reveal_duration + ending_hold_duration
	if _audio_finished and (reveal_time < 0.0 or playback_time >= hold_end):
		_finish()


func _update_timeline(audio_time: float) -> void:
	var subtitle_time := audio_time - subtitle_offset_seconds
	var next_cue := -1
	for index in range(_cues.size()):
		var cue := _cues[index]
		if subtitle_time >= float(cue["start"]) and subtitle_time < float(cue["end"]):
			next_cue = index
			break
	if next_cue != _active_cue:
		_active_cue = next_cue
		_subtitle.text = str(_cues[next_cue]["text"]) if next_cue >= 0 else ""
		if log_subtitle_times:
			print("Intro %.2fs | %s" % [audio_time, _subtitle.text])

	var reveal_time := _get_reveal_time()
	var reveal := 0.0
	if reveal_time >= 0.0:
		reveal = smoothstep(0.0, maxf(reveal_duration, 0.01), audio_time - reveal_time)
	_front_light.energy = front_light_energy * reveal
	_character_material.set_shader_parameter("side_shadow_strength", side_shadow_strength)
	_character_material.set_shader_parameter("bottom_shadow_strength", bottom_shadow_strength)
	_back_light.set_shader_parameter("audio_time", audio_time)
	_back_light.set_shader_parameter("glow_color", back_light_color)
	_back_light.set_shader_parameter("energy", back_light_energy)
	_back_light.set_shader_parameter("pulse_frequency", pulse_frequency)
	_back_light.set_shader_parameter("pulse_depth", pulse_depth)


func _get_reveal_time() -> float:
	if reveal_time_override >= 0.0:
		return reveal_time_override
	if _reveal_cue_time >= 0.0:
		return _reveal_cue_time + subtitle_offset_seconds + reveal_delay
	return -1.0


func _on_voice_finished() -> void:
	_audio_finished = true
	playback_time = maxf(playback_time, _voice.stream.get_length())


func _load_subtitles() -> void:
	if subtitle_track == null:
		push_error("Intro: assign a subtitle JSON resource to Subtitle Track.")
		return
	var data: Variant = subtitle_track.data
	if not data is Dictionary or not data.get("cues") is Array:
		push_error("Intro: subtitles must contain a cues array.")
		return
	var last_end := 0.0
	for entry: Variant in data["cues"]:
		if not entry is Dictionary or not entry.has_all(["start", "end", "text"]):
			push_error("Intro: every cue needs start, end, and text.")
			continue
		if not (entry["start"] is float or entry["start"] is int) or not (entry["end"] is float or entry["end"] is int):
			push_error("Intro: subtitle start/end must be numbers in seconds.")
			continue
		var cue_start := float(entry["start"])
		var cue_end := float(entry["end"])
		if cue_start < last_end or cue_end <= cue_start:
			push_error("Intro: subtitle cues must be ordered, non-overlapping, and have end > start.")
			continue
		_cues.append(entry)
		last_end = cue_end
		if bool(entry.get("reveal", false)) and _reveal_cue_time < 0.0:
			_reveal_cue_time = cue_start


func _finish() -> void:
	if _finishing:
		return
	_finishing = true
	_subtitle.text = ""
	var tween := create_tween()
	tween.tween_property(_fade, "color:a", 1.0, ending_fade_duration)
	await tween.finished
	GameManager.finish_intro()
