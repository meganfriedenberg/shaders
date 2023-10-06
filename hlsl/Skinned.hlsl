#include "Constants.hlsl"

struct VIn
{
    float3 position : POSITION0;
    float3 normal : NORMAL0;
    uint4 bones : BONES0;
    float4 weights : WEIGHTS0;
    float2 uv : TEXTCOORD0; 
};

struct VOut
{
    float4 position : SV_POSITION;
    float2 uv : TEXTCOORD0;
    float3 normal : NORMAL0;
    float4 worldPos : WORLDPOS;
};

VOut VS(VIn vIn)
{
    VOut output;

    // Transform the bone vertices from T-Pose to current pose
    float4 skinnedVertex1 = vIn.weights[0] * mul(float4(vIn.position, 1.0), c_skinMatrix[vIn.bones[0]]);
    float4 skinnedVertex2 = vIn.weights[1] * mul(float4(vIn.position, 1.0), c_skinMatrix[vIn.bones[1]]);
    float4 skinnedVertex3 = vIn.weights[2] * mul(float4(vIn.position, 1.0), c_skinMatrix[vIn.bones[2]]);
    float4 skinnedVertex4 = vIn.weights[3] * mul(float4(vIn.position, 1.0), c_skinMatrix[vIn.bones[3]]);
    output.position = skinnedVertex1 + skinnedVertex2 + skinnedVertex3 + skinnedVertex4;


    // Skin the normal
    float4 skinnedNormal1 = vIn.weights[0] * mul(float4(vIn.normal, 0.0), c_skinMatrix[vIn.bones[0]]);
    float4 skinnedNormal2 = vIn.weights[1] * mul(float4(vIn.normal, 0.0), c_skinMatrix[vIn.bones[1]]);
    float4 skinnedNormal3 = vIn.weights[2] * mul(float4(vIn.normal, 0.0), c_skinMatrix[vIn.bones[2]]);
    float4 skinnedNormal4 = vIn.weights[3] * mul(float4(vIn.normal, 0.0), c_skinMatrix[vIn.bones[3]]);
    output.normal = skinnedNormal1 + skinnedNormal2 + skinnedNormal3 + skinnedNormal4;

  //  output.position = vIn.position;
  // Transform input pos from model to world
    output.position = mul(output.position, c_modelToWorld); 
    output.worldPos = output.position;
    // transform position from world to projection space
    output.position = mul(output.position, c_viewProj);

    output.uv = vIn.uv;

    // Transform the normals to world space Lab05d
    float4 tempPos = mul(float4(output.normal, 0.0f), c_modelToWorld);
    // Need to normalize the result, its a direction vector
    output.normal = normalize(float3(tempPos.x, tempPos.y, tempPos.z));
    // can't call Normalize() from enginemath.h, its not a vector3, its a float3



    return output;
}

float4 PS(VOut pIn) : SV_TARGET
{
    // sample the Diffuse Texture
    float4 diffusedColor = DiffuseTexture.Sample(DefaultSampler, pIn.uv); // Sample DirectX docs, sampling the texture
    pIn.normal = normalize(pIn.normal); // Renormalize the normal
    // Go through each of the lights, if enabled, use light to calculate
    float3 worldCasted = float3(pIn.worldPos.x, pIn.worldPos.y, pIn.worldPos.z);
    float3 result = c_ambient;
    for (int i = 0; i < MAX_POINT_LIGHTS; i++)
    {
        if (c_pointLight[i].isEnabled == true)
        {
            // Need the vector FROM surface TO light
            float3 surfaceToLight = normalize(c_pointLight[i].position - worldCasted);

            // Need the vector FROM surface TO camera
            float3 surfaceToCam = normalize(c_cameraPosition - worldCasted);

            // Calculating the reflected vector, PDF noted -lightvector
            float3 reflectedLightDirection = reflect(-surfaceToLight, pIn.normal);

            float3 diffuseLight = dot(pIn.normal, surfaceToLight);
            float3 specularLight = dot(reflectedLightDirection, surfaceToCam);
            diffuseLight = max(diffuseLight, 0.0f); // Use max to clamp dot prods
            specularLight = max(specularLight, 0.0f);

            diffuseLight = c_diffuseColor * diffuseLight; // combine the diffuse
            
            // Calculate specular power
            specularLight = pow(specularLight, c_specularPower);
            specularLight = c_specularColor * specularLight; // Combine the specular

             // Calculate distance falloff
            float distFalloff = 0.0f;
            float fromLighttoPixel = 0.0f;
            // Need to use world position, specified on Piazza by Matt
            fromLighttoPixel = distance(c_pointLight[i].position, worldCasted);
            // Linearly interpolate using smoothstep
            distFalloff = smoothstep(c_pointLight[i].innerRadius, c_pointLight[i].outerRadius, fromLighttoPixel);
            // "Returns 0 if x is less than min; 1 if x is greater than max; otherwise, a value between 0 and 1 if x is in the range [min, max]."
            // But we want: if the distance is >= outerRadius, you want 0.0
            distFalloff = 1 - distFalloff; // correct linear interpolation, now x < min does return 1

            diffuseLight = diffuseLight * distFalloff;
            specularLight = specularLight * distFalloff;


            float3 temp = diffuseLight + specularLight;
            temp = temp * c_pointLight[i].lightColor;
            result = result + temp;
        }
    }

    // Multiply by texture sample, vertex color, and our calculated light
    return diffusedColor * float4(result, 1.0f); 
    
}
