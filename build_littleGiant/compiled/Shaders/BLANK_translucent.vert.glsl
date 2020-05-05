#version 450
in vec4 pos;
in vec2 nor;
out vec3 wnormal;
out vec3 eyeDir;
out vec3 wposition;
out vec3 mposition;
uniform mat3 N;
uniform mat4 WVP;
uniform vec3 eye;
uniform mat4 W;
uniform float posUnpack;
void main() {
vec4 spos = vec4(pos.xyz, 1.0);
wposition = vec4(W * spos).xyz;
mposition = spos.xyz * posUnpack;
	wnormal = normalize(N * vec3(nor.xy, pos.w));
	gl_Position = WVP * spos;
	eyeDir = eye - wposition;
}
