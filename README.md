# shaders
I swear I know how to write hlsl, DirectX11+12 code.

Posted shaders in this repository include:
- [Compute shader](https://github.com/meganfriedenberg/shaders/blob/main/hlsl/ComputeShader.hlsl) for particles effects.
- [Geometry shader](https://github.com/meganfriedenberg/shaders/blob/main/hlsl/GeometryQuad.hlsl) for drawing billboard quads from a single vertex.
- [Skinned toon shader](https://github.com/meganfriedenberg/shaders/blob/main/hlsl/SkinnedToon.hlsl) mimicking Jet Set Radio's.
- [General skinning shader](https://github.com/meganfriedenberg/shaders/blob/main/hlsl/Skinned.hlsl) for joint-bone hierarchy based characters for animation, using skinning weights read in from asset files. 
- [Normal shader](https://github.com/meganfriedenberg/shaders/blob/main/hlsl/Normal.hlsl) for generating normal mapping of textures by calculating the bi-tangent vector and sampling from the tangent texture.
- [Deferred lighting](https://github.com/meganfriedenberg/shaders/blob/main/hlsl/deferredLighting.hlsl) where world position, normals, and diffuse are written out to individual textures to be re-read in as render targets on the C++ side. 

![GIF of a character showing 2D particle clouds falling out of a source sphere.](https://github.com/meganfriedenberg/shaders/blob/main/images/particles.gif?raw=true)   
[Compute shader](https://github.com/meganfriedenberg/shaders/blob/main/hlsl/ComputeShader.hlsl) to update all generated particles using multiple threads.

![GIF of a character with the toon shader applied.](https://github.com/meganfriedenberg/shaders/blob/main/images/toon.gif?raw=true)   
[Toon shader](https://github.com/meganfriedenberg/shaders/blob/main/hlsl/SkinnedToon.hlsl) applied to UE4's Manny.

![Image of a tile showing '3D' texture through normal mapping.](https://github.com/meganfriedenberg/shaders/blob/main/images/normalMapping.png?raw=true)   
Normal mapping of a tile using the [Normal shader](https://github.com/meganfriedenberg/shaders/blob/main/hlsl/Normal.hlsl).


![GIF of deferred lighting showing individual passes.](https://github.com/meganfriedenberg/meganfriedenberg.github.io/blob/master/images/deferredrenderpass.gif?raw=true)
Deferred lighting showing the individual passes: World position, normals, diffuse, by outputting the render targets each pass wrote to from the deferred lighting shader.
