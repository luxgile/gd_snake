shader_type spatial;
render_mode unshaded,wireframe;

uniform vec4 albedo : source_color = vec4(0.0,0.0,0.0,1.0);
uniform vec4 emissive_color : source_color = vec4(0.0,0.0,0.0,1.0);
uniform float emissive = 0;
uniform float outline_width : hint_range(0.0, 10.0, 0.1) = 3.0;
uniform float noise_mag = 0;
uniform float noise_freq = 0;
uniform float noise_scale = 0;

float rand(vec2 c){
	return fract(sin(dot(c.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float noise(vec2 p, float freq ){
	float unit = 1080./freq;
	vec2 ij = floor(p/unit);
	vec2 xy = mod(p,unit)/unit;
	//xy = 3.*xy*xy-2.*xy*xy*xy;
	xy = .5*(1.-cos(PI*xy));
	float a = rand((ij+vec2(0.,0.)));
	float b = rand((ij+vec2(1.,0.)));
	float c = rand((ij+vec2(0.,1.)));
	float d = rand((ij+vec2(1.,1.)));
	float x1 = mix(a, b, xy.x);
	float x2 = mix(c, d, xy.x);
	return mix(x1, x2, xy.y);
}

float pNoise(vec2 p, int res){
	float persistance = .5;
	float n = 0.;
	float normK = 0.;
	float f = 4.;
	float amp = 1.;
	int iCount = 0;
	for (int i = 0; i<50; i++){
		n+=amp*noise(p, f);
		f*=2.;
		normK+=amp;
		amp*=persistance;
		if (iCount == res) break;
		iCount++;
	}
	float nf = n/normK;
	return nf*nf*nf*nf;
}

void vertex() {
	vec4 clip_position = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	vec3 clip_normal = mat3(PROJECTION_MATRIX) * (mat3(MODELVIEW_MATRIX) * NORMAL);
	
	vec2 offset = normalize(clip_normal.xy) / VIEWPORT_SIZE * 
		clip_position.w * outline_width * 2.0;
		
	vec4 world_pos = MODEL_MATRIX * vec4(VERTEX, 1.0);
	vec3 noise_map = world_pos.xyz * 10. + (TIME * noise_freq);
	float noise = pNoise(noise_map.xz / noise_scale, 10) + 		 pNoise(noise_map.xy / noise_scale, 10);
	offset += noise * noise_mag;


	clip_position.xy += offset;
	
	POSITION = clip_position;
}

void fragment() {
	ALBEDO = albedo.rgb + emissive_color.rgb * emissive;
}