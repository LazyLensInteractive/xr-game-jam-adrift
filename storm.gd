extends Node3D
class_name StormOverlay

@export var rain_intensity: float = 1.0 :
	set(value):
		rain_intensity = clampf(value, 0.0, 2.0)
		if has_node("RainParticles"):
			$RainParticles.amount = int(400 * rain_intensity)
@export var wind_speed: float = 5.0 :
	set(value):
		wind_speed = clampf(value, 0.0, 10.0)
		if _material:
			_material.direction = Vector3(wind_speed * 0.5, -5.0, 0.0)
@export var lightning_enabled: bool = true
var _material: ParticleProcessMaterial
var _lightning_timer: Timer
func _ready() -> void:
	_setup_rain()
	_setup_lightning()
func _setup_rain() -> void:
	var rain := GPUParticles3D.new()
	rain.name = "RainParticles"
	add_child(rain)
	_material = ParticleProcessMaterial.new()
	_material.gravity = Vector3(0, -30, 0)
	_material.direction = Vector3(wind_speed * 0.5, -5.0, 0.0)
	_material.spread = 5.0
	_material.initial_velocity_min = 10.0
	_material.initial_velocity_max = 15.0
	_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	_material.emission_box_extents = Vector3(30, 5, 30)
	rain.process_material = _material
	var quad := QuadMesh.new()
	quad.size = Vector2(0.02, 0.4)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(0.7, 0.8, 0.9, 0.5)
	quad.material = mat
	rain.draw_pass_1 = quad
	rain.amount = int(400 * rain_intensity)
	rain.lifetime = 1.5
	rain.emitting = true

func _setup_lightning() -> void:
	_lightning_timer = Timer.new()
	_lightning_timer.name = "LightningTimer"
	_lightning_timer.wait_time = randf_range(2.0, 8.0)
	_lightning_timer.timeout.connect(_on_lightning_timeout)
	add_child(_lightning_timer)
	var flash_light := OmniLight3D.new()
	flash_light.name = "LightningFlash"
	flash_light.omni_range = 50.0
	flash_light.light_energy = 0.0
	flash_light.light_color = Color(0.9, 0.95, 1.0)
	add_child(flash_light)
	var flash_overlay := ColorRect.new()
	flash_overlay.name = "ScreenFlash"
	flash_overlay.color = Color(1, 1, 1, 0)
	flash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash_overlay)
	_lightning_timer.start()

func _on_lightning_timeout() -> void:
	if not lightning_enabled:
		return
	var flash_light: OmniLight3D = get_node("LightningFlash")
	var flash_overlay: ColorRect = get_node("ScreenFlash")
	flash_light.light_energy = 3.0
	flash_overlay.color = Color(1, 1, 1, 0.4)
	await get_tree().create_timer(0.1).timeout
	flash_light.light_energy = 0.0
	flash_overlay.color = Color(1, 1, 1, 0)
func start_storm() -> void:
	_lightning_timer.start()
	$RainParticles.emitting = true
func stop_storm() -> void:
	_lightning_timer.stop()
	$RainParticles.emitting = false
