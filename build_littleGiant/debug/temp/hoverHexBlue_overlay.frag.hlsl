static float3 wnormal;
static float4 fragColor;

struct SPIRV_Cross_Input
{
    float3 wnormal : TEXCOORD0;
};

struct SPIRV_Cross_Output
{
    float4 fragColor : SV_Target0;
};

void frag_main()
{
    float3 n = normalize(wnormal);
    float3 basecol = float3(0.0f, 0.3434441387653350830078125f, 0.80000007152557373046875f);
    float roughness = 0.100000001490116119384765625f;
    float metallic = 0.0f;
    float occlusion = 1.0f;
    float specular = 1.0f;
    float emission = 5.0f;
    fragColor = float4(basecol, 1.0f);
    float3 _40 = pow(fragColor.xyz, 0.4545454680919647216796875f.xxx);
    fragColor = float4(_40.x, _40.y, _40.z, fragColor.w);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    wnormal = stage_input.wnormal;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.fragColor = fragColor;
    return stage_output;
}
