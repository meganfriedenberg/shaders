#include "Constants.hlsl"

#define MAX_SKELETON_BONES 80
cbuffer SkinConstants : register(b3)
{
    float4x4 c_skinMatrix[MAX_SKELETON_BONES];
};

struct VIn
{
    float3 position : POSITION0;
    float3 normal : NORMAL0;
    uint4 boneIndex : BONE0;
    float4 boneWeight : WEIGHT0;
    float2 uv : TEXCOORD0;
};

struct VOut
{
    float4 position : SV_POSITION;
    float3 normal : NORMAL0;
    float2 uv : TEXCOORD0;
};

VOut VS(VIn vIn)
{
    VOut output = (VOut)0;

    float4 inPos = float4(vIn.position, 1.0f);
    float4 pos = mul(inPos, c_skinMatrix[vIn.boneIndex.x]) * vIn.boneWeight.x
        + mul(inPos, c_skinMatrix[vIn.boneIndex.y]) * vIn.boneWeight.y
        + mul(inPos, c_skinMatrix[vIn.boneIndex.z]) * vIn.boneWeight.z
        + mul(inPos, c_skinMatrix[vIn.boneIndex.w]) * vIn.boneWeight.w;
    float4 inNorm = float4(vIn.normal, 0.0f);
    float4 norm = mul(inNorm, c_skinMatrix[vIn.boneIndex.x]) * vIn.boneWeight.x
        + mul(inNorm, c_skinMatrix[vIn.boneIndex.y]) * vIn.boneWeight.y
        + mul(inNorm, c_skinMatrix[vIn.boneIndex.z]) * vIn.boneWeight.z
        + mul(inNorm, c_skinMatrix[vIn.boneIndex.w]) * vIn.boneWeight.w;

    float4 worldPos = mul(pos, c_modelToWorld);
    output.position = mul(worldPos, c_viewProj);
    output.normal = mul(norm, c_modelToWorld);

    output.uv = vIn.uv;
    return output;
}

float4 PS(VOut pIn) : SV_TARGET
{
     float4 diffuseTex = DiffuseTexture.Sample(DefaultSampler, pIn.uv);

     float3 n = normalize(pIn.normal);

     float d = dot(n, c_lightDir); // this is intensity
     d = 0.5f * d + 0.5f;
     d = d * d;

     if (d < 0)
         d = 0;

     // Discretize the intensity, based on a few cutoff points, modify for more 'tooness'
     if (d > 0.7)
         d = 1.0;
     else if (d > 0.3)
         d = 0.5;
     else
         d = 0;


     float4 light = float4(d * c_lightColor, 1.0f);

     return diffuseTex * light;
}
