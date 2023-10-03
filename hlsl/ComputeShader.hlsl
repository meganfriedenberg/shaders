#include "Constants.hlsl"


[numthreads(32, 16, 1)] // thread ratio from hlsl forums
void CS( uint3 DTid : SV_DispatchThreadID )
{
  // update all particles
  /*  for (uint32_t i = 0; i < MAX_PARTICLES; ++i)
    {*/
    // render then update
    uint i = DTid.x;
    //float timeOutt = 3.0;

    float tempTimer = myInput2[i].timer - deltaTime;
    float3 tempVelocity = myInput2[i].vel - (float3(0.0, 0.0, 1.0) * gravity * deltaTime);
    float3 newPos = myInput1[i].pos + tempVelocity * deltaTime;
    float lerped = tempTimer / timeOut;
    float newSize = lerp(endSize, startSize, lerped);
    float newRValue = lerp(endColor[0], startColor[0], lerped);
    float newGValue = lerp(endColor[1], startColor[1], lerped);
    float newBValue = lerp(endColor[2], startColor[2], lerped);
    float newAValue = lerp(endColor[3], startColor[3], lerped);

    myOutput[i].timer = tempTimer;
    myOutput[i].vel = tempVelocity;
    myOutput[i].size = newSize;
    myOutput[i].pos = newPos;
    myOutput[i].color = float4(newRValue, newGValue, newBValue, newAValue);

}