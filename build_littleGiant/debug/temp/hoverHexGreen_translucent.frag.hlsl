uniform float4 shirr[7];
uniform float3 backgroundCol;
uniform float envmapStrength;
uniform float3 sunDir;
uniform float3 sunCol;
uniform bool receiveShadow;

static float4 gl_FragCoord;
static float3 wnormal;
static float3 eyeDir;
static float4 fragColor[2];

struct SPIRV_Cross_Input
{
    float3 eyeDir : TEXCOORD0;
    float3 wnormal : TEXCOORD1;
    float4 gl_FragCoord : SV_Position;
};

struct SPIRV_Cross_Output
{
    float4 fragColor[2] : SV_Target0;
};

float3 surfaceAlbedo(float3 baseColor, float metalness)
{
    return lerp(baseColor, 0.0f.xxx, metalness.xxx);
}

float3 surfaceF0(float3 baseColor, float metalness)
{
    return lerp(0.039999999105930328369140625f.xxx, baseColor, metalness.xxx);
}

float3 shIrradiance(float3 nor)
{
    float3 cl00 = float3(shirr[0].x, shirr[0].y, shirr[0].z);
    float3 cl1m1 = float3(shirr[0].w, shirr[1].x, shirr[1].y);
    float3 cl10 = float3(shirr[1].z, shirr[1].w, shirr[2].x);
    float3 cl11 = float3(shirr[2].y, shirr[2].z, shirr[2].w);
    float3 cl2m2 = float3(shirr[3].x, shirr[3].y, shirr[3].z);
    float3 cl2m1 = float3(shirr[3].w, shirr[4].x, shirr[4].y);
    float3 cl20 = float3(shirr[4].z, shirr[4].w, shirr[5].x);
    float3 cl21 = float3(shirr[5].y, shirr[5].z, shirr[5].w);
    float3 cl22 = float3(shirr[6].x, shirr[6].y, shirr[6].z);
    return ((((((((((cl22 * 0.429042994976043701171875f) * ((nor.y * nor.y) - ((-nor.z) * (-nor.z)))) + (((cl20 * 0.743125021457672119140625f) * nor.x) * nor.x)) + (cl00 * 0.88622701168060302734375f)) - (cl20 * 0.2477079927921295166015625f)) + (((cl2m2 * 0.85808598995208740234375f) * nor.y) * (-nor.z))) + (((cl21 * 0.85808598995208740234375f) * nor.y) * nor.x)) + (((cl2m1 * 0.85808598995208740234375f) * (-nor.z)) * nor.x)) + ((cl11 * 1.02332794666290283203125f) * nor.y)) + ((cl1m1 * 1.02332794666290283203125f) * (-nor.z))) + ((cl10 * 1.02332794666290283203125f) * nor.x);
}

float3 lambertDiffuseBRDF(float3 albedo, float nl)
{
    return albedo * max(0.0f, nl);
}

float d_ggx(float nh, float a)
{
    float a2 = a * a;
    float denom = pow(((nh * nh) * (a2 - 1.0f)) + 1.0f, 2.0f);
    return (a2 * 0.3183098733425140380859375f) / denom;
}

float v_smithschlick(float nl, float nv, float a)
{
    return 1.0f / (((nl * (1.0f - a)) + a) * ((nv * (1.0f - a)) + a));
}

float3 f_schlick(float3 f0, float vh)
{
    return f0 + ((1.0f.xxx - f0) * exp2((((-5.554729938507080078125f) * vh) - 6.9831600189208984375f) * vh));
}

float3 specularBRDF(float3 f0, float roughness, float nl, float nh, float nv, float vh)
{
    float a = roughness * roughness;
    return (f_schlick(f0, vh) * (d_ggx(nh, a) * clamp(v_smithschlick(nl, nv, a), 0.0f, 1.0f))) / 4.0f.xxx;
}

void frag_main()
{
    float3 n = normalize(wnormal);
    float3 vVec = normalize(eyeDir);
    float dotNV = max(dot(n, vVec), 0.0f);
    float3 basecol = float3(0.005196626298129558563232421875f, 0.80000007152557373046875f, 0.0f);
    float roughness = 0.100000001490116119384765625f;
    float metallic = 0.0f;
    float occlusion = 1.0f;
    float specular = 1.0f;
    float emission = 5.0f;
    float opacity = 0.099799998104572296142578125f;
    if (opacity == 1.0f)
    {
        discard;
    }
    float3 albedo = surfaceAlbedo(basecol, metallic);
    float3 f0 = surfaceF0(basecol, metallic);
    float3 indirect = shIrradiance(n);
    indirect *= albedo;
    indirect += (backgroundCol * f0);
    indirect *= occlusion;
    indirect *= envmapStrength;
    float3 direct = 0.0f.xxx;
    float svisibility = 1.0f;
    float3 sh = normalize(vVec + sunDir);
    float sdotNL = dot(n, sunDir);
    float sdotNH = dot(n, sh);
    float sdotVH = dot(vVec, sh);
    direct += (((lambertDiffuseBRDF(albedo, sdotNL) + (specularBRDF(f0, roughness, sdotNL, sdotNH, dotNV, sdotVH) * specular)) * sunCol) * svisibility);
    if (emission > 0.0f)
    {
        direct = 0.0f.xxx;
        indirect += (basecol * emission);
    }
    float4 premultipliedReflect = float4(float3(direct + (indirect * 0.5f)) * opacity, opacity);
    float w = clamp((pow(min(1.0f, premultipliedReflect.w * 10.0f) + 0.00999999977648258209228515625f, 3.0f) * 100000000.0f) * pow(1.0f - (gl_FragCoord.z * 0.89999997615814208984375f), 3.0f), 0.00999999977648258209228515625f, 3000.0f);
    fragColor[0] = float4(premultipliedReflect.xyz * w, premultipliedReflect.w);
    fragColor[1] = float4(premultipliedReflect.w * w, 0.0f, 0.0f, 1.0f);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    gl_FragCoord = stage_input.gl_FragCoord;
    wnormal = stage_input.wnormal;
    eyeDir = stage_input.eyeDir;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.fragColor = fragColor;
    return stage_output;
}
