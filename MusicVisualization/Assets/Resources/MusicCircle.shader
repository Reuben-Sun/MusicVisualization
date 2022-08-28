Shader "Music/MusicCircle"
{
    Properties
    {
        [MainTexture] _BaseMap("Albedo", 2D) = "white" {}
        [MainColor] _BaseColor("BaseColor", Color) = (1,1,1,1)
        _Intensity("Intensity", float) = 5
        _BlockSize("BlockSize", float) = 0.05
        _Threshold("Threshold", float) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"}

        Pass
        {
            Name "ShadorToy"
            Tags { "LightMode" = "UniversalForward" }
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
        
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            struct Attributes
            {
                float4 vertex: POSITION;    
                float2 uv: TEXCOORD0;       
            };

            struct Varyings
            {
                float4 pos: SV_POSITION;        
                float2 uv: TEXCOORD0;           
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;
            float _MusicArray[256];
            float _Intensity;
            float _BlockSize;
            float _SumNum;
            float _Threshold;
            CBUFFER_END
            
            TEXTURE2D(_BaseMap);    SAMPLER(sampler_BaseMap);

            //绘制圆环
            float3 renderCircle(float2 uv)
            {
                //坐标
                float2 xy = uv - float2(0.5f, 0.5f);
                
                float d = distance(uv, float2(0.5, 0.5));
                float arcU = atan2(xy.x, xy.y) / PI;
                arcU = arcU * 0.5 + 0.5;
                
                //得到音乐强度
                int id = arcU * 256;
                float radius = 0.3;
                float val = _MusicArray[id] * arcU * _Intensity;
                //绘制外圈
                float outRval = id % 2 == 0 ? -0.005 : val;
                float outR = abs(d - radius);
                float3 outRcolor = step(outR , outRval + 0.005);
                
                //绘制内核
                float3 inColor = 0;
                
               
                
                return outRcolor + inColor;
            }

            //绘制点阵
            float3 renderPointBlock(float2 uv, float sum)
            {
                 //绘制点阵背景
                float block = _BlockSize;
                float col1 = fmod(uv.x, 2 * block);
                col1 = step(block, col1);
                float col2 = fmod(uv.y, 2 * block);
                col2 = step(block, col2);
                float3 blockColor1 = float3(0, 0, 0);
                float3 blockColor2 = float3(5 * sum * sum, 10 * sum * sum * sum, sum);
                float3 bgColor = lerp(uv.y * blockColor1, uv.y * blockColor2, col1 * col2);
                return bgColor;
            }
            
            Varyings vert(Attributes v)
            {
                Varyings o = (Varyings)0;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                o.pos = vertexInput.positionCS;
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                float sum = _SumNum * _Intensity;
                float3 color = renderCircle(i.uv);
                
                float3 finalColor = color;
                if(sum > _Threshold)
                {
                    float3 color2 = renderCircle(i.uv + sum * 0.3);
                    finalColor.g = color2.g;
                }
                finalColor += renderPointBlock(i.uv, sum);
                return float4(finalColor, 1);
            }
            ENDHLSL
        }
    }
}
