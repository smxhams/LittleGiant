#version 450
#include "compiled.inc"
in vec3 wnormal;
out vec4 fragColor;
void main() {
vec3 n = normalize(wnormal);
	vec3 basecol;
	float roughness;
	float metallic;
	float occlusion;
	float specular;
	float emission;
	basecol = vec3(0.0, 0.3434441387653351, 0.8000000715255737);
	roughness = 0.10000000149011612;
	metallic = 0.0;
	occlusion = 1.0;
	specular = 1.0;
	emission = 5.0;
	fragColor = vec4(basecol, 1.0);
	fragColor.rgb = pow(fragColor.rgb, vec3(1.0 / 2.2));
}
