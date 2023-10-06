#include "Constants.hlsl"

struct VIn
{
    float3 position : POSITION0;
    float3 normal : NORMAL0;
    float3 tangent : TANGENT0; // normal mapping
    float2 uv : TEXTCOORD0;
};

struct VOut
{
    float4 position : SV_POSITION;
    float2 uv : TEXTCOORD0; 
    float3 normal : NORMAL0; 
    float4 worldPos : WORLDPOS; 
    float3 tangent : TANGENT0;
};

VOut VS(VIn vIn)
{
    VOut output;

  //  output.position = vIn.position;
  // Transform input pos from model to world
    output.position = mul(float4(vIn.position, 1.0), c_modelToWorld); // modelToWorld applied to model gets world
    output.worldPos = output.position;
    // transform position from world to projection space
    output.position = mul(output.position, c_viewProj);

    output.uv = vIn.uv;

    // Transform the normals to world space
    float4 tempPos = mul(float4(vIn.normal, 0.0f), c_modelToWorld);
    // Need to normalize the result, its a direction vector
    output.normal = normalize(float3(tempPos.x, tempPos.y, tempPos.z));
    // can't call Normalize() from enginemath.h, its not a vector3, its a float3

    output.tangent = (normalize(mul(float4(vIn.tangent, 0.0f), c_modelToWorld))).xyz;


    return output;
}

float4 PS(VOut pIn) : SV_TARGET
{
    // sample the Diffuse Texture
    // not sure if float4 or float2 -> actually Sample docs said it defaults to 
    // the struct's color's size which is a float4
    float4 diffusedColor = DiffuseTexture.Sample(DefaultSampler, pIn.uv); // Sample DirectX docs, sampling the texture

    pIn.normal = normalize(pIn.normal); // Renormalize the normal
    pIn.tangent = normalize(pIn.tangent);

    //bi-tangent is the cross product of the normal x tangent
    
    float3 biTangent = normalize(cross(pIn.normal, pIn.tangent));

    //Read the normal from the normal map (texture slot 1) 
    float3 normalMapNormal = TangentTexture.Sample(DefaultSampler, pIn.uv);
    normalMapNormal = ((normalMapNormal) * 2) - 1; // Un-bias

    // Creating the matrix
    float3x3 tbnMatrix = float3x3(pIn.tangent.xyz, biTangent.xyz, pIn.normal.xyz);
    float3 normalMapCasted = normalMapNormal.xyz;

    // Transform
    float3 newNormal = mul(normalMapCasted, tbnMatrix);


    // Go through each of the lights, if enabled, use light to calculate
    float3 worldCasted = float3(pIn.worldPos.x, pIn.worldPos.y, pIn.worldPos.z); // Vector3 for calculations
   // float3 result = float3(0.0f, 0.0f, 0.0f);
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
            float3 reflectedLightDirection = reflect(-surfaceToLight, newNormal);

            float3 diffuseLight = dot(newNormal, surfaceToLight);
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
