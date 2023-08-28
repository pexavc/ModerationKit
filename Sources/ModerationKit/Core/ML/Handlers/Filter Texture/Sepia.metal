//
//  Sepia.metal
//  LinenAndSole
//
//  Created by PEXAVC on 4/18/19.
//  Copyright © 2019 PEXAVC. All rights reserved.
//
#include <metal_stdlib>
using namespace metal;

kernel void Sepia(texture2d<float, access::sample> inTexture [[texture(0)]],
                          texture2d<float, access::write> outTexture [[texture(1)]],
                          uint2 gid [[thread_position_in_grid]])
{
    if (gid.x >= outTexture.get_width() ||
        gid.y >= outTexture.get_height()) {
        return;
    }
    float w = float(inTexture.get_width());
    float h = float(inTexture.get_height());
    float2 uv = float2(gid) * float2(1.0/w, 1.0/h);
    
    constexpr sampler s(address::clamp_to_edge, filter::linear, coord::normalized);
    
    float4 color = inTexture.sample(s, uv);
    float adjust = 0.65;
    
    float3 colorSepia = color.rgb * float3x3(1.0 - (0.607 * adjust), 0.769 * adjust, 0.189 * adjust,
                  0.349 * adjust, 1.0 - (0.314 * adjust), 0.168 * adjust,
                  0.272 * adjust, 0.534 * adjust, 1.0 - (0.869 * adjust));
    
    outTexture.write(float4(colorSepia, color.a), gid);
}
