#version 450
#include "compiled.inc"
#include "std/gbuffer.glsl"
in vec2 texCoord;
in vec3 wnormal;
out vec4 fragColor[2];
uniform vec3 param_RGB;
uniform sampler2D ImageTexture;
void main() {
vec3 n = normalize(wnormal);
	vec4 ImageTexture_texread_store = texture(ImageTexture, texCoord.xy);
	ImageTexture_texread_store.rgb = pow(ImageTexture_texread_store.rgb, vec3(2.2));
	vec3 basecol;
	float roughness;
	float metallic;
	float occlusion;
	float specular;
	float emission;
	float opacity;
	float Mix_fac = 1.0;
	vec3 RGB_Color_res = param_RGB;
	vec3 ImageTexture_Color_res = ImageTexture_texread_store.rgb;
	vec3 Mix_Color_res = mix(RGB_Color_res, ImageTexture_Color_res, Mix_fac);
	float ImageTexture_Alpha_res = ImageTexture_texread_store.a;
	basecol = Mix_Color_res;
	roughness = 0.10000000149011612;
	metallic = 0.0;
	occlusion = 1.0;
	specular = 1.0;
	emission = 1.0;
	opacity = ImageTexture_Alpha_res - 0.0002;
	if (opacity < 0.9999) discard;
	n /= (abs(n.x) + abs(n.y) + abs(n.z));
	n.xy = n.z >= 0.0 ? n.xy : octahedronWrap(n.xy);
	uint matid = 0;
	if (emission > 0) { basecol *= emission; matid = 1; }
	fragColor[0] = vec4(n.xy, roughness, packFloatInt16(metallic, matid));
	fragColor[1] = vec4(basecol, packFloat2(occlusion, specular));
}
