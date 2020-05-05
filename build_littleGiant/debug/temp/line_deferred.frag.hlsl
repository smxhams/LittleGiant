static float4 fragColor[2];
static float3 color;

struct SPIRV_Cross_Input
{
    float3 color : TEXCOORD0;
};

struct SPIRV_Cross_Output
{
    float4 fragColor[2] : SV_Target0;
};

void frag_main()
{
    fragColor[0] = float4(1.0f, 1.0f, 0.0f, 1.0f);
    fragColor[1] = float4(color, 1.0f);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    color = stage_input.color;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.fragColor = fragColor;
    return stage_output;
}
