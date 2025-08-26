shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;

uniform float interval = 0.5; // the displacement will happen every [interval] seconds

uniform sampler2D noise_offset;
uniform sampler2D noise_grain: repeat_enable;
uniform sampler2D noise_grain2;

const float vignette_inner_radius = 0.2;
const float vignette_outer_radius = 1.5;

uniform sampler2D perlin_noise_cloud: repeat_enable;
uniform sampler2D cell_noise_cloud: repeat_enable;

#define pow2(x) (x * x)
#define iResolution 1.0/SCREEN_PIXEL_SIZE

const int samples = 3;
const float sigma = float(samples) * 0.25;

float gaussian(vec2 i) {
	return 1.0 / (2.0 * PI * pow2(sigma)) * exp(-((pow2(i.x) + pow2(i.y)) / (2.0 * pow2(sigma))));
}

vec3 blur(sampler2D sp, vec2 uv, vec2 scale) {
	vec3 col = vec3(0.0);
	float accum = 0.0;
	float weight;
	vec2 offset;
	for (int x = -samples / 2; x < samples / 2; ++x) {
		for (int y = -samples / 2; y < samples / 2; ++y) {
			offset = vec2(float(x), float(y));
			weight = gaussian(offset);
			col += texture(sp, uv + scale * offset).rgb * weight;
			accum += weight;
		}
	}
	return col / accum;
}

vec3 blur_cloud(sampler2D sp, vec2 uv, vec2 scale) {
	vec3 col = vec3(0.0);
	float accum = 0.0;
	float weight;
	vec2 offset;
	for (int x = -samples / 2; x < samples / 2; ++x) {
		for (int y = -samples / 2; y < samples / 2; ++y) {
			offset = vec2(float(x), float(y));
			weight = gaussian(offset);
			col += texture(sp, uv + scale * offset).rgb * weight;
			accum += weight;
		}
	}
	return col / accum;
}

void fragment() {
	// Wobble
	vec2 uv_offset = vec2(cos(TIME*2.0)*0.01, sin(TIME*2.0)*0.01);
	vec2 uv = SCREEN_UV + 0.001 * texture(noise_offset, SCREEN_UV + uv_offset).xy;
	vec4 original_color = vec4(blur(screen_texture, uv, SCREEN_PIXEL_SIZE), 1.0);
	
	// Clouds
	vec2 grain_uv = vec2(uv.x + TIME * 0.008, uv.y + TIME * 0.002) + vec2(cos(TIME)*0.005, sin(TIME)*0.01);
	vec2 uv2 = vec2(uv.x + TIME * 0.006, uv.y + TIME * 0.001);
	float noise1 = blur_cloud(perlin_noise_cloud, grain_uv, SCREEN_PIXEL_SIZE).r;
	float noise2 = blur_cloud(cell_noise_cloud, uv2, SCREEN_PIXEL_SIZE).r;
	float noise = smoothstep(noise1 * noise2, 0.0, 0.15) * 0.1;
	original_color.rgb = mix(original_color.rgb, vec3(0.96, 0.87, 0.70), noise);

	// Grain
	original_color.rgb -= texture(noise_grain, SCREEN_UV + grain_uv * 2.0).rgb
		+ texture(noise_grain2, SCREEN_UV).rgb;
	original_color = clamp(original_color, 0.0, 1.0);

	// Vignette
	vec2 clip = abs(UV.xy - 0.5) * 2.0;
	float inner_radius = vignette_inner_radius + cos(TIME*0.66)*0.01;
	float outer_radius = vignette_outer_radius + cos(TIME*0.66)*0.05;
	float vignette = 1.0 - (1.0 - length(clip)/outer_radius)/(1.0 - inner_radius);
	original_color.rgb = mix(original_color.rgb, vec3(0.0), vignette);
	
	COLOR = original_color;
}

//https://godotshaders.com/shader/smooth-2d-cloud/