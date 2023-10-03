# shaders
I swear I know how to write hlsl, DirectX11+12 code.

Posted shaders in this repository include:
- [Compute shader](https://github.com/meganfriedenberg/shaders/blob/main/hlsl/ComputeShader.hlsl) for particles effects.
- [Geometry shader](https://github.com/meganfriedenberg/shaders/blob/main/hlsl/GeometryQuad.hlsl) for drawing billboard quads from a single vertex.
- [Skinned toon shader](https://github.com/meganfriedenberg/shaders/blob/main/hlsl/SkinnedToon.hlsl) mimicking Jet Set Radio's.
- [Deferred lighting](https://github.com/meganfriedenberg/shaders/blob/main/hlsl/deferredLighting.hlsl) where world position, normals, and diffuse are written out to individual textures to be re-read in as render targets on the C++ side.   

![GIF of a character with the toon shader applied.](https://github.com/meganfriedenberg/shaders/blob/main/images/toon.gif?raw=true) 
Toon shader applied to UE4's Manny.


![GIF of deferred lighting showing individual passes.](https://github.com/meganfriedenberg/meganfriedenberg.github.io/blob/master/images/deferredrenderpass.gif?raw=true)
Deferred lighting showing the individual passes: World position, normals, diffuse, by outputting the render targets each pass wrote to from the deferred lighting shader.
