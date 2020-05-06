static float3 wnormal;
static float4 fragColor[2];

struct SPIRV_Cross_Input
{
    float3 wnormal : TEXCOORD0;
};

struct SPIRV_Cross_Output
{
    float4 fragColor[2] : SV_Target0;
};

float2 octahedronWrap(float2 v)
{
    return (1.0f.xx - abs(v.yx)) * float2((v.x >= 0.0f) ? 1.0f : (-1.0f), (v.y >= 0.0f) ? 1.0f : (-1.0f));
}

float packFloatInt16(float f, uint i)
{
    return (0.06248569488525390625f * f) + (0.06250095367431640625f * float(i));
}

float packFloat2(float f1, float f2)
{
    return floor(f1 * 255.0f) + min(f2, 0.9900000095367431640625f);
}

void frag_main()
{
    float3 n = normalize(wnormal);
    float3 basecol = float3(0.0f, 0.3434441387653350830078125f, 0.80000007152557373046875f);
    float roughness = 0.100000001490116119384765625f;
    float metallic = 0.0f;
    float occlusion = 1.0f;
    float specular = 1.0f;
    float emission = 5.0f;
    float opacity = 0.099799998104572296142578125f;
    if (opacity < 0.99989998340606689453125f)
    {
        discard;
    }
    n /= ((abs(n.x) + abs(n.y)) + abs(n.z)).xxx;
    float2 _105;
    if (n.z >= 0.0f)
    {
        _105 = n.xy;
    }
    else
    {
        _105 = octahedronWrap(n.xy);
    }
    n = float3(_105.x, _105.y, n.z);
    uint matid = 0u;
    if (emission > 0.0f)
    {
        basecol *= emission;
        matid = 1u;
    }
    fragColor[0] = float4(n.xy, roughness, packFloatInt16(metallic, matid));
    fragColor[1] = float4(basecol, packFloat2(occlusion, specular));
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    wnormal = stage_input.wnormal;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.fragColor = fragColor;
    return stage_output;
}
