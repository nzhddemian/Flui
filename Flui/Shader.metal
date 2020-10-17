//
//  Shader.metal
//  Flui
//
//  Created by Demian on 27.09.2020.
//  Copyright © 2020 Demian. All rights reserved.
//


#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float2 position [[attribute(0)]];
    float2 textureCoorinates [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 textureCoorinates;
};

//Render to screen
vertex VertexOut vertexShader(constant VertexIn* vertexArray [[buffer(0)]], unsigned int vid [[vertex_id]]) {

    VertexIn vertexData = vertexArray[vid];
    VertexOut vertexDataOut;
    vertexDataOut.position = float4(vertexData.position.x, vertexData.position.y, 0.0, 1.0);
    vertexDataOut.textureCoorinates = vertexData.textureCoorinates.xy;
    return vertexDataOut;
}

float rand(float2 co)
{
    return fract(sin(dot(co.xy ,float2(12.9898,78.236))) * 43758.5453);
}




//float mmm(float2 U, float t) {           // --- texture layer
//// float2 iU = ceil(U/=exp2(t-8.)),              // quadtree cell Id - infinite zoom
//   float2 iU = ceil(U/=exp2(t-8.)*D/(3.+t)),     // quadtree cell Id - with perspective
//          P = .1+.6*R(iU,0.);                  // 1 star position per cell
//    float r = 9.* R(iU,1.).x;                  // radius + proba of star ( = P(r<1) )
//    return r > 1. ? 1. :   length( P - fract(U) ) * 8./(1.+5.*r) ;
//}








fragment float4 visualizeScalar(VertexOut fragmentIn [[stage_in]], texture2d<float, access::sample> tex2d [[texture(0)]],texture2d<float, access::sample> cam [[texture(5)]], constant float &tt [[buffer(3)]],  constant float *ffft [[buffer(4)]], constant float2 &res [[buffer(1)]]) {
    constexpr sampler sampler2d(filter::linear);
    float2 uv = fragmentIn.textureCoorinates;
       float y = uv.y;
       uv.y-=.5;
       uv-=.5;
       
          uv.y*=res.y/res.x;
    
       
   //MARK: FFT
    float x = abs(uv.x)*64;
    int ii = floor(x);
    float ff = fract(x);
    float fft =  mix(ffft[ii]/12.,ffft[ii+1]/12.,smoothstep(0.,1.,ff));
    //MARK: FTT
    
    
    
    
    
     //MARK: STARS
        float4 starCol = float4(0.);
        float size = 10.0;
        float prob = 0.997;
       // float2 res = (tex2d.get_width(), tex2d.get_height());
         
        float2 pos = floor(1.0 / size * fragmentIn.textureCoorinates*res);
        
        float color = 0.0;
        float starValue = rand(pos);
        
        if (starValue > prob)
        {
            float2 center = size * pos + float2(size, size) * 0.5;
            
            float t = 0.9 + 1.2 * sin(tt/15. + (starValue - prob) / (1.0 - prob) * 45.0);
                    
            color = 1.0 - distance(fragmentIn.textureCoorinates*res, center) / (0.5 * size);
            color = color ;//* t / (abs((fragmentIn.textureCoorinates*res).x - center.x)) * t / (abs((fragmentIn.textureCoorinates*res).y - center.y));
        }
       
        
        
        starCol = float4(float3(color), 1.0);
        starCol.g-= 0.2;
        starCol.rb*= starCol.rb;
        //MARK: STARS
        
        
          float2 p = fragmentIn.textureCoorinates;
        //    float2 R = p + float2(0.5, -0.5);
           
        //    float4 tex1 = float4(tex2d.sample(sampler2d, L/res));
        //    float4 tex2 = float4(tex2d.sample(sampler2d, R/res));
        //   float4 fragColor = abs(tex1 - tex2);
        //    fragColor *= 2.0;
        //    fragColor.g=0.;
        //
        float aspect = res.x/res.y;
    float4 fragColoru = float4(tex2d.sample(sampler2d, float2(( (p)).x ,(p).y +.4 + fft ) ));
    float4 fragColord = float4(tex2d.sample(sampler2d, float2(( (p) ).x ,1. -(p).y + fft ) ));
           // fragColor.rb+=fragColor.rb;
             //fragColor.b+=fragColor.r/2;
        float4 coll = float4(0.);
            coll+= fragColoru;
              coll+= fragColord;
    p.y-=.3;
    coll.r*=length(p-.5);
    coll+=(coll*2);
    p.y+=.45;
    //coll*=length(float2(p.x,p.y+1.));
    coll-=smoothstep(.1,.5,length(p-.5));
  //  coll*=length(p-.5);
       // coll-=float4((fragmentIn.textureCoorinates.y+0.3));
        
        coll.b = coll.g;
        coll.g = 0.;
    coll+=coll;
      //coll+=coll;
       // coll.r =float((fragmentIn.textureCoorinates.y+0.1));
       
        // coll-=float4((fragmentIn.textureCoorinates.y));
     
        float spread = 0.1;
   
        float4 f = float4(1.);
  
        //float2 uv = fragmentIn.textureCoorinates;
       
        float4 fanal = coll;
        fanal+=starCol;
       
        return fanal;
}



//Fluid Dynamics Render Encoder

struct BufferData {
    float2 positions[5];
    float2 impulses[5];

    float2 impulseScalar;
    float2 offsets;

    float2 screenSize;

    float inkRadius;
};

struct Mouse {
    int inn;
   float2 points[200];
    float2 mouse;
};


 float gaussSplat(float2 p, float r)
{
    return exp(-dot(p, p) / r);
}

#define rnd(x)  fract( 4356.17 * sin( 1e4*x ) )
#define srnd(x) ( 2.* rnd(x) -1. )



//DRAW FFT audio Spect
fragment float4 applyForceScalar(VertexOut fragmentIn [[stage_in]], texture2d<float, access::sample> input [[texture(0)]], constant float &tt [[buffer(3)]],  constant float *ffft [[buffer(4)]], constant float2 &res [[buffer(1)]]) {
    constexpr sampler fluid_sampler(filter::linear);

   
    //float2 res = res;
    float radius = 500.;//bufferData.inkRadius;

    float2 gid = fragmentIn.textureCoorinates * float2(res);
    
    float2 uv = fragmentIn.textureCoorinates;
    float y = uv.y;
    uv.y-=.5;
    uv-=.5;
    
       uv.y*=res.y/res.x;
 
    
    
    float x = abs(uv.x)*64;
    int ii = floor(x);
    float f = fract(x);
    float fft =  mix(ffft[ii]/12.,ffft[ii+1]/12.,smoothstep(0.,1.,f));
      
    float4 color = float4(input.sample(fluid_sampler, float2((gid*.998 + res*.001  ).x,(gid*.998 + res*(.0001 + abs((y))/300.)  ).y) / res));

    float veiw = uv.y + 1.5 + pow(fft,1.1);
      float flot = ((smoothstep(0.92, 1.0, veiw) ));
    //  col+= float3((flot));
    float4 col = float4(((flot)));



    color = mix( float4(col), color, length(float2(0,flot-1.)) );
    
   // }
    if(fragmentIn.textureCoorinates.y>.699){color = float4(0);}
    return color;
}






//////CAM FLYING EFFECT
//fragment float4 applyForceScalar(VertexOut fragmentIn [[stage_in]], texture2d<float, access::sample> input [[texture(0)]], constant BufferData &bufferData [[buffer(1)]],texture2d<float, access::sample> cam [[texture(5)]], constant float &tt [[buffer(3)]]) {
//    constexpr sampler fluid_sampler(filter::linear);
//    constexpr sampler cam_s(filter::linear);
//    float2 impulseScalar = float2(bufferData.impulseScalar);
//    float2 screenSize = float2(bufferData.screenSize);
//    float radius = 500.;//bufferData.inkRadius;
//
//    float2 gid = fragmentIn.textureCoorinates * float2(screenSize);
//
////float4 color = float4(input.sample(fluid_sampler, (float2(gid)*(.998 +sin(tt/12)/1000)+ float2(screenSize)*(.001 +sin(tt/10)/1000) ) / float2(screenSize)));
//    float4 color = float4(input.sample(fluid_sampler, (float2(gid)*(.98 )+ float2(screenSize)*(.01 ) ) / float2(screenSize)));
////    float4 color = float4(input.sample(fluid_sampler, fragmentIn.textureCoorinates));
//    float4 colorr = float4(cam.sample(fluid_sampler, (float2(gid)*.98 + float2(screenSize)*.01 ) / float2(screenSize)));
//    float4 final = color;
//
//  //  for (int i=0; i<1; ++i) {
//        float2 location = float2(bufferData.positions[0]);
//
//       // if (location.x == location.y && location.x == 0) {
//         //   continue;
//       // }
//
//        float2 uv = location - float2(fragmentIn.textureCoorinates).xy * screenSize;
//        float4 splat = float4(impulseScalar,1,1) * gaussSplat(uv, radius);
//    float d =  length(fragmentIn.textureCoorinates-location/screenSize)*2;
//    float4 df = float4(colorr.r);
//    //final = final + df;
//    //final = final + (float4(1e-4 / pow(d,2.)));
//    //colorr*= colorr;
//    final = mix(final , colorr,0.03);
//    //final*=final;
//   // }
//    return final;
//}
////CAM FLYING EFFECT





//////PHOTOCIRCLE
//fragment float4 applyForceScalar(VertexOut fragmentIn [[stage_in]], texture2d<float, access::sample> input [[texture(0)]], constant BufferData &bufferData [[buffer(1)]],texture2d<float, access::sample> cam [[texture(5)]], constant float &tt [[buffer(3)]]) {
//    constexpr sampler fluid_sampler(filter::linear);
//    constexpr sampler cam_s(filter::linear);
//    float2 impulseScalar = float2(bufferData.impulseScalar);
//    float2 screenSize = float2(bufferData.screenSize);
//    float radius = 500.;//bufferData.inkRadius;
//
//    float2 gid = fragmentIn.textureCoorinates * float2(screenSize);
//
////float4 color = float4(input.sample(fluid_sampler, (float2(gid)*(.998 +sin(tt/12)/1000)+ float2(screenSize)*(.001 +sin(tt/10)/1000) ) / float2(screenSize)));
//
////    float4 color = float4(input.sample(fluid_sampler, fragmentIn.textureCoorinates));
//    float4 video = float4(cam.sample(fluid_sampler, (float2(gid)) / float2(screenSize)));
//    float4 final = float4(0);
//
//    float speed = 2.0;
//    float split = 0.2;
//
//    float2 uv = (float2(gid)) / float2(screenSize);
//
//    float pixel_w = 0.5 / screenSize.y;
//
//    uv.y -= pixel_w * speed;
//    float4 buffer = float4(input.sample(fluid_sampler,uv));
//
//      float effect_mask = step(uv.y, split);
//
//   // fragColor = mix(buffer, video, effect_mask);
//
//
//
//
//
//    final = mix(buffer, video, effect_mask);
//
//    return final;
//}
//////PHOTOCIRCLE




///DRAW MOV
//fragment float4 applyForceScalar(VertexOut fragmentIn [[stage_in]], texture2d<float, access::sample> input [[texture(0)]], constant BufferData &bufferData [[buffer(1)]], constant float &tt [[buffer(3)]],  constant float *ffft [[buffer(4)]]) {
//    constexpr sampler fluid_sampler(filter::linear);
//
//    float2 impulseScalar = float2(bufferData.impulseScalar);
//    float2 screenSize = float2(bufferData.screenSize);
//    float radius = 500.;//bufferData.inkRadius;
//
//    float2 gid = fragmentIn.textureCoorinates * float2(screenSize);
// //float4 color = float4(input.sample(fluid_sampler, (float2(gid)*(.98 + sin(-tt)/2000) + float2(screenSize)*(.02 + cos(tt)/2000) ) / float2(screenSize)));
//    float4 color = float4(input.sample(fluid_sampler, float2((gid*.998 + screenSize*.001  ).x,(gid*.998 + screenSize*.002  ).y) / screenSize));
//
//    float ovx = (gid.x)/ (screenSize.x);
//    float ovy = (gid.y)*(.98 + sin(-tt)/2000) + (screenSize.y)*(.01 + cos(tt)/2000)/ (screenSize.y);
//    //float4 color = float4(input.sample(fluid_sampler, float2(ovx,ovy)));
//   // float4 color = float4(input.sample(fluid_sampler, fragmentIn.textureCoorinates));
//    float4 final = color;
//
//  //  for (int i=0; i<1; ++i) {
//        float2 location = float2(bufferData.positions[0]);
//
//       // if (location.x == location.y && location.x == 0) {
//         //   continue;
//       // }
//    float4 col = float4(tan(tt*float3(13,11,17))*.5+.5,1);
//       float idx = smoothstep( 9.9, 10., length( float2(gid) - location ) );
//       color = mix( float4(col), color, idx );
//        float2 uv = location - float2(fragmentIn.textureCoorinates).xy * screenSize;
//        float4 splat = float4(impulseScalar,1,1) * gaussSplat(uv, radius);
//
//        final = final + splat;
//   // }
//    return color;
//}
//




