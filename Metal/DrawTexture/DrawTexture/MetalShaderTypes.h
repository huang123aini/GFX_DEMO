//
//  MetalShaderTypes.h
//  DrawTexture
//
//  Created by 黄世平 on 2022/5/16.
//

#ifndef MetalShaderTypes_h
#define MetalShaderTypes_h

#include <simd/simd.h>

typedef enum AAPLVertexInputIndex
{
    VertexInputIndexVertices     = 0,
    VertexInputIndexViewportSize = 1,
} VertexInputIndex;

typedef enum TextureIndex
{
    AAPLTextureIndexBaseColor = 0,
}TextureIndex;

typedef struct
{
    vector_float2 position;
    vector_float2 textureCoordinate;
}Vertex;

#endif /* MetalShaderTypes_h */
