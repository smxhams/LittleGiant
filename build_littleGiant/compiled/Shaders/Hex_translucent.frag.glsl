#version 450
#include "compiled.inc"
#include "std/light.glsl"
#include "std/shirr.glsl"
#include "std/shadows.glsl"
in vec2 texCoord;
in vec3 wnormal;
in vec3 eyeDir;
in vec3 wposition;
out vec4 fragColor[2];
uniform sampler2D ImageTexture;
uniform vec3 backgroundCol;
uniform float envmapStrength;
uniform bool receiveShadow;
uniform vec3 sunCol;
uniform vec3 sunDir;
uniform sampler2DShadow shadowMap;
uniform float shadowsBias;
uniform vec3 eye;
void main() {
vec3 n = normalize(wnormal);
	vec4 ImageTexture_texread_store = texture(ImageTexture, texCoord.xy);
	ImageTexture_texread_store.rgb = pow(ImageTexture_texread_store.rgb, vec3(2.2));

    vec3 vVec = normalize(eyeDir);
    float dotNV = max(dot(n, vVec), 0.0);

	vec3 basecol;
	float roughness;
	float metallic;
	float occlusion;
	float specular;
	float opacity;
	vec3 ImageTexture_Color_res = ImageTexture_texread_store.rgb;
	float ImageTexture_Alpha_res = ImageTexture_texread_store.a;
	basecol = ImageTexture_Color_res;
	roughness = 0.10000000149011612;
	metallic = 0.0;
	occlusion = 1.0;
	specular = 1.0;
	opacity = ImageTexture_Alpha_res - 0.0002;
	if (opacity == 1.0) discard;
	vec3 albedo = surfaceAlbedo(basecol, metallic);
	vec3 f0 = surfaceF0(basecol, metallic);
	vec3 indirect = shIrradiance(n);
	indirect *= albedo;
	indirect += backgroundCol * f0;
	indirect *= occlusion;
	indirect *= envmapStrength;
	vec3 direct = vec3(0.0);
	float svisibility = 1.0;
	vec3 sh = normalize(vVec + sunDir);
	float sdotNL = dot(n, sunDir);
	float sdotNH = dot(n, sh);
	float sdotVH = dot(vVec, sh);
	if (receiveShadow) {
	svisibility = shadowTestCascade(shadowMap, eye, wposition + n * shadowsBias * 10, shadowsBias);
	}
	direct += (lambertDiffuseBRDF(albedo, sdotNL) + specularBRDF(f0, roughness, sdotNL, sdotNH, dotNV, sdotVH) * specular) * sunCol * svisibility;	

	vec4 premultipliedReflect = vec4(vec3(direct + indirect * 0.5) * opacity, opacity);
	float w = clamp(pow(min(1.0, premultipliedReflect.a * 10.0) + 0.01, 3.0) * 1e8 * pow(1.0 - (gl_FragCoord.z) * 0.9, 3.0), 1e-2, 3e3);
	fragColor[0] = vec4(premultipliedReflect.rgb * w, premultipliedReflect.a);
	fragColor[1] = vec4(premultipliedReflect.a * w, 0.0, 0.0, 1.0);
}
