Texture2D<float4> gbuffer0;
SamplerState _gbuffer0_sampler;
uniform float2 texSize;
Texture2D<float4> gbuffer1;
SamplerState _gbuffer1_sampler;

static float2 texCoord;
static float4 fragColor;

struct SPIRV_Cross_Input
{
    float2 texCoord : TEXCOORD0;
};

struct SPIRV_Cross_Output
{
    float4 fragColor : SV_Target0;
};

void frag_main()
{
    float4 accum = gbuffer0.Load(int3(int2(texCoord * texSize), 0));
    float revealage = 1.0f - accum.w;
    if (revealage == 0.0f)
    {
        discard;
    }
    float f = gbuffer1.Load(int3(int2(texCoord * texSize), 0)).x;
    fragColor = float4(accum.xyz / clamp(f, 9.9999997473787516355514526367188e-05f, 5000.0f).xxx, revealage);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    texCoord = stage_input.texCoord;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.fragColor = fragColor;
    return stage_output;
}
