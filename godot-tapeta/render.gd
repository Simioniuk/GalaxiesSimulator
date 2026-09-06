extends MultiMeshInstance3D

@export_category("Wydajność")
@export_range(15, 60, 1) var target_fps: int = 30

@export_category("Kulki")
@export var noiseAmount: int = 400
@export var amount: int = 700
@export var ball_radius: float = 0.5
@export var min_scale: float = 0.34
@export var max_scale: float = 1.0
@export var halo_scale: float = 1.1
@export var halo_strength: float = 0.34
@export var emission_energy: float = 2.2

@export_category("Rozmieszczenie")
@export var seed: int = 2137
@export var density: float = 1.0
@export var size: float = 8.0
@export var N: int = 6
@export var S: float = 0.3
@export var randomMin: float = 0.0
@export var randomMax: float = 0.4

@export_category("Mysz")
@export var mouse_enabled: bool = true
@export var mouse_strength: float = 1.8
@export var mouse_radius: float = 1.2
@export var mouse_softening: float = 0.18
@export var mouse_max_acceleration: float = 0.18

@export_category("Powrót do orbity")
@export var return_strength: float = 0.02
@export var return_damping: float = 0.1

@export_category("Fizyka")
@export var w: float = -0.05

var pos: PackedVector3Array = PackedVector3Array()
var vel: PackedVector2Array = PackedVector2Array()
var home_pos: PackedVector2Array = PackedVector2Array()

var instance_transforms: Array[Transform3D] = []

var orbit_angle: float = 0.0

var mouseWorldPosition: Vector3 = Vector3.ZERO
var mousePositionValid: bool = false
var lastMouseScreenPosition: Vector2 = Vector2(-100000.0, -100000.0)


func _ready() -> void:
	Engine.max_fps = target_fps
	Engine.physics_ticks_per_second = target_fps
	createGalaxy()


func _physics_process(delta: float) -> void:
	if mouse_enabled:
		updateMouseWorldPosition()

	updatePhysic(delta)
	updateMultimeshTransforms()


func render() -> void:
	deleteGalaxy()
	createGalaxy()


func deleteGalaxy() -> void:
	pos.clear()
	vel.clear()
	home_pos.clear()
	instance_transforms.clear()

	orbit_angle = 0.0

	if multimesh != null:
		multimesh.instance_count = 0


func createGalaxy() -> void:
	pos.clear()
	vel.clear()
	home_pos.clear()
	instance_transforms.clear()

	orbit_angle = 0.0

	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2.ONE * ball_radius * halo_scale

	var material: StandardMaterial3D = StandardMaterial3D.new()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.vertex_color_use_as_albedo = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_texture = createStarTexture()
	material.albedo_color = Color.WHITE
	material.emission_enabled = true
	material.emission = Color.WHITE
	material.emission_energy_multiplier = emission_energy

	quad.material = material

	var mm: MultiMesh = MultiMesh.new()

	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = quad
	mm.instance_count = amount + noiseAmount

	multimesh = mm

	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed

	createArms(rng)
	createNoise(rng)


func createStarTexture() -> Texture2D:
	var resolution: int = 64

	var image: Image = Image.create(
		resolution,
		resolution,
		true,
		Image.FORMAT_RGBA8
	)

	var half: float = float(resolution - 1) * 0.5

	for y in range(resolution):
		for x in range(resolution):

			var dx: float = (float(x) - half) / half
			var dy: float = (float(y) - half) / half

			var r2: float = dx * dx + dy * dy

			var core: float = exp(-r2 * 42.0)
			var halo: float = exp(-r2 * 4.8) * halo_strength

			var intensity: float = clampf(
				core + halo,
				0.0,
				1.0
			)

			image.set_pixel(
				x,
				y,
				Color(
					intensity,
					intensity,
					intensity,
					intensity
				)
			)

	image.generate_mipmaps()

	var texture: ImageTexture = ImageTexture.create_from_image(image)

	return texture


func createArms(rng: RandomNumberGenerator) -> void:
	for i in range(amount):

		var u: float = rng.randf()
		var v: float = rng.randf_range(randomMin, randomMax)

		var r: float = size * pow(u, density)

		var k: int = rng.randi_range(0, N - 1)

		var angle: float = (
			TAU * float(k) / float(N)
			+ S * (r / size) * TAU
			+ v
		)

		var position: Vector3 = Vector3(
			r * cos(angle),
			rng.randf_range(-0.3, 0.3),
			r * sin(angle)
		)

		var maxR: float = size * density

		var scale_value: float = (
			(maxR - r)
			* (
				rng.randf_range(
					min_scale,
					max_scale
				) / 10.0
			)
			+ rng.randf_range(0.0, 0.2)
		)

		addStar(
			i,
			position,
			scale_value,
			rng
		)


func createNoise(rng: RandomNumberGenerator) -> void:
	for i in range(noiseAmount):

		var angle: float = rng.randf_range(0.0, TAU)

		var u: float = rng.randf()

		var r: float = size * pow(u, density)

		var position: Vector3 = Vector3(
			r * cos(angle),
			rng.randf_range(-0.3, 0.3),
			r * sin(angle)
		)

		var maxR: float = size * density

		var scale_value: float = (
			(maxR - r)
			* (
				rng.randf_range(
					min_scale,
					max_scale
				) / 10.0
			)
			+ rng.randf_range(0.0, 0.2)
		)

		addStar(
			i + amount,
			position,
			scale_value,
			rng
		)


func addStar(
	index: int,
	position: Vector3,
	scale_value: float,
	rng: RandomNumberGenerator
) -> void:

	var basis: Basis = Basis.IDENTITY.scaled(
		Vector3.ONE * scale_value
	)

	var transform: Transform3D = Transform3D(
		basis,
		position
	)

	instance_transforms.append(transform)

	multimesh.set_instance_transform(
		index,
		transform
	)

	var t: float = pow(
		rng.randf(),
		3.0
	)

	var temperature: float = (
		lerpf(
			2400.0,
			30000.0,
			t
		) / 100.0
	)

	var star_color: Color = temperatureToColor(
		temperature
	)

	multimesh.set_instance_color(
		index,
		star_color
	)

	pos.append(position)

	var original_position: Vector2 = Vector2(
		position.x,
		position.z
	)

	home_pos.append(original_position)

	var initial_velocity: Vector2 = Vector2(
		-position.z * w,
		position.x * w
	)

	vel.append(initial_velocity)


func updatePhysic(delta: float) -> void:
	orbit_angle = wrapf(
		orbit_angle + w * delta,
		-PI,
		PI
	)

	var cos_angle: float = cos(orbit_angle)
	var sin_angle: float = sin(orbit_angle)

	var w2: float = w * w

	var use_mouse: bool = (
		mouse_enabled
		and mousePositionValid
	)

	var mouse_x: float = mouseWorldPosition.x
	var mouse_z: float = mouseWorldPosition.z

	var mouse_radius2: float = (
		mouse_radius
		* mouse_radius
	)

	var softening2: float = (
		mouse_softening
		* mouse_softening
	)

	var max_mouse_acc2: float = (
		mouse_max_acceleration
		* mouse_max_acceleration
	)

	for i in range(pos.size()):

		var p: Vector3 = pos[i]
		var velocity: Vector2 = vel[i]
		var home: Vector2 = home_pos[i]

		var x: float = p.x
		var z_pos: float = p.z

		var target_x: float = (
			home.x * cos_angle
			- home.y * sin_angle
		)

		var target_z: float = (
			home.x * sin_angle
			+ home.y * cos_angle
		)

		var target_vx: float = -w * target_z
		var target_vz: float = w * target_x

		var ax: float = -w2 * x
		var az: float = -w2 * z_pos

		ax += (
			(target_x - x)
			* return_strength
		)

		az += (
			(target_z - z_pos)
			* return_strength
		)

		ax += (
			(target_vx - velocity.x)
			* return_damping
		)

		az += (
			(target_vz - velocity.y)
			* return_damping
		)

		if use_mouse:

			var dx: float = mouse_x - x
			var dz: float = mouse_z - z_pos

			var d2: float = (
				dx * dx
				+ dz * dz
			)

			if d2 <= mouse_radius2:

				var denom: float = pow(
					d2 + softening2,
					1.5
				)

				var factor: float = (
					mouse_strength
					/ denom
				)

				var mouse_ax: float = dx * factor
				var mouse_az: float = dz * factor

				var mouse_acc2: float = (
					mouse_ax * mouse_ax
					+ mouse_az * mouse_az
				)

				if mouse_acc2 > max_mouse_acc2:

					var scale: float = (
						mouse_max_acceleration
						/ sqrt(mouse_acc2)
					)

					mouse_ax *= scale
					mouse_az *= scale

				ax += mouse_ax
				az += mouse_az

		velocity.x += ax * delta
		velocity.y += az * delta

		x += velocity.x * delta
		z_pos += velocity.y * delta

		p.x = x
		p.z = z_pos

		pos[i] = p
		vel[i] = velocity


func updateMultimeshTransforms() -> void:
	var mm: MultiMesh = multimesh

	for i in range(pos.size()):

		var transform: Transform3D = instance_transforms[i]

		transform.origin = pos[i]

		instance_transforms[i] = transform

		mm.set_instance_transform(
			i,
			transform
		)


func temperatureToColor(
	temperature: float
) -> Color:

	var red: float = 255.0
	var green: float = 0.0
	var blue: float = 0.0

	if (
		temperature > 19.0
		and temperature <= 66.0
	):
		blue = (
			138.5
			* log(temperature - 10.0)
			- 305.04
		)

	elif temperature > 66.0:
		blue = 255.0

	if temperature > 66.0:

		red = (
			329.6
			* pow(
				temperature - 60.0,
				-0.13
			)
		)

		green = (
			288.1
			* pow(
				temperature - 60.0,
				-0.07
			)
		)

	else:

		green = (
			99.5
			* log(temperature)
			- 161.1
		)

	red = clampf(
		red,
		0.0,
		255.0
	)

	green = clampf(
		green,
		0.0,
		255.0
	)

	blue = clampf(
		blue,
		0.0,
		255.0
	)

	return Color(
		red / 255.0,
		green / 255.0,
		blue / 255.0,
		1.0
	)


func updateMouseWorldPosition() -> void:
	var viewport: Viewport = get_viewport()

	var mouse_position: Vector2 = (
		viewport.get_mouse_position()
	)

	if mouse_position == lastMouseScreenPosition:
		return

	lastMouseScreenPosition = mouse_position

	var camera: Camera3D = viewport.get_camera_3d()

	if camera == null:
		mousePositionValid = false
		return

	var ray_origin: Vector3 = (
		camera.project_ray_origin(
			mouse_position
		)
	)

	var ray_direction: Vector3 = (
		camera.project_ray_normal(
			mouse_position
		)
	)

	var galaxy_plane: Plane = Plane(
		Vector3.UP,
		0.0
	)

	var intersection: Variant = (
		galaxy_plane.intersects_ray(
			ray_origin,
			ray_direction
		)
	)

	if intersection == null:
		mousePositionValid = false
		return

	mouseWorldPosition = to_local(
		intersection as Vector3
	)

	mousePositionValid = true
