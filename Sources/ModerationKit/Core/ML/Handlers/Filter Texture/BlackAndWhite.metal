//
//  BlackAndWhite.metal
//  LinenAndSole
//
//  Created by PEXAVC on 4/18/19.
//  Copyright © 2019 PEXAVC. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


float3 grayscale(float3 color) {
    // float avg = (color.r + color.g + color.b) / 3.0;
    float avg = 0.3 * color.r + 0.59 * color.g + 0.11 * color.b;
    return float3(avg);
}

kernel void BlackAndWhite(texture2d<float, access::sample> inTexture [[texture(0)]],
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
    
    outTexture.write(float4(grayscale(color.rgb), color.a), gid);
}
