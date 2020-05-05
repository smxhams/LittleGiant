uniform float4x4 ViewProjection;

static float4 gl_Position;
static float3 color;
static float3 col;
static float3 pos;

struct SPIRV_Cross_Input
{
    float3 col : TEXCOORD0;
    float3 pos : TEXCOORD1;
};

struct SPIRV_Cross_Output
{
    float3 color : TEXCOORD0;
    float4 gl_Position : SV_Position;
};

void vert_main()
{
    color = col;
    gl_Position = mul(float4(pos, 1.0f), ViewProjection);
    gl_Position.z = (gl_Position.z + gl_Position.w) * 0.5;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    col = stage_input.col;
    pos = stage_input.pos;
    vert_main();
    SPIRV_Cross_Output stage_output;
    stage_output.gl_Position = gl_Position;
    stage_output.color = color;
    return stage_output;
}
