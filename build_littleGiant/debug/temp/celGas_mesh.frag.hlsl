Texture2D<float4> ImageTexture;
SamplerState _ImageTexture_sampler;

static float3 wnormal;
static float2 texCoord;
static float4 fragColor[2];

struct SPIRV_Cross_Input
{
    float2 texCoord : TEXCOORD0;
    float3 wnormal : TEXCOORD1;
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
    float4 ImageTexture_texread_store = ImageTexture.Sample(_ImageTexture_sampler, texCoord);
    float3 _82 = pow(ImageTexture_texread_store.xyz, 2.2000000476837158203125f.xxx);
    ImageTexture_texread_store = float4(_82.x, _82.y, _82.z, ImageTexture_texread_store.w);
    float3 ImageTexture_Color_res = ImageTexture_texread_store.xyz;
    float3 basecol = ImageTexture_Color_res;
    float roughness = 0.0f;
    float metallic = 0.0f;
    float occlusion = 1.0f;
    float specular = 0.0f;
    n /= ((abs(n.x) + abs(n.y)) + abs(n.z)).xxx;
    float2 _114;
    if (n.z >= 0.0f)
    {
        _114 = n.xy;
    }
    else
    {
        _114 = octahedronWrap(n.xy);
    }
    n = float3(_114.x, _114.y, n.z);
    fragColor[0] = float4(n.xy, roughness, packFloatInt16(metallic, 0u));
    fragColor[1] = float4(basecol, packFloat2(occlusion, specular));
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    wnormal = stage_input.wnormal;
    texCoord = stage_input.texCoord;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.fragColor = fragColor;
    return stage_output;
}
