Shader "Unlit/TextureToVertex"
{
    Properties
    {
        _Texture("Texture", 2D) = "white"{}
        _Resolution("Texture Resolution", Float) = 64
    }

    SubShader
    {
        LOD 100
        Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase" }
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2g
            {
                float4 vertex : SV_POSITION;
                float2 uv  : TEXCOORD0;
            };

            struct g2f
            {
                float4 vertex : SV_POSITION;
                half3 normal : TEXCOORD0;
            };

            
            fixed4 _LightColor0;

            sampler2D _Texture;
            float _Resolution;


            float ColorToValue(fixed4 color) {
                if (color.a == 0.0f) {
                    return 0.0f;
                }

                float num = 0.0f;
                num += color.r;
                num += color.g / 255.0f;
                num += color.b / 255.0f / 255.0f;

                uint alpha = round(color.a * 255.0f);
                int digit = alpha & 0x1f;

                if ((alpha >> 6 & 0x01) == 0x01) { num *= -1.0f; }
                if ((alpha >> 5 & 0x01) == 0x01) { digit *= -1.0f; }

                return num * pow(10, digit);
            }

            half3 ColorToNormal(fixed4 color) {
                half3 normal = half3(-color.r, -color.g, color.b);
                int alpha = round(color.a * 255.0f);

                if ((alpha >> 7 & 0x01) == 0x01) { normal.x *= -1.0f; }
                if ((alpha >> 6 & 0x01) == 0x01) { normal.y *= -1.0f; }
                if ((alpha >> 5 & 0x01) == 0x01) { normal.z *= -1.0f; }

                return normal;
            }

            float3x3 RotateMatrix_X(float u) {
                return float3x3(
                    1, 0, 0,
                    0, cos(u), -sin(u),
                    0, sin(u), cos(u)
                    );
            }

            v2g vert(appdata v)
            {
                v2g o;
                o.vertex = v.vertex;
                o.uv = v.uv;
                return o;
            }

            [maxvertexcount(3)]
            void geom(triangle v2g IN[3], inout TriangleStream<g2f> stream)
            {
                g2f o;
                float d = 1.0f / _Resolution;
                float offset = 1.0f / (_Resolution * 2.0f);

                [unroll]
                for (int i = 0; i < 3; i++) {
                    float2 uv = round(IN[i].uv * _Resolution) * d;
                    uv += offset;
                    
                    o.vertex.xyz = float3(
                        ColorToValue(tex2Dlod(_Texture, float4(uv.x, uv.y, 0, 0))),
                        ColorToValue(tex2Dlod(_Texture, float4(uv.x, uv.y + d, 0, 0))),
                        ColorToValue(tex2Dlod(_Texture, float4(uv.x + d, uv.y, 0, 0)))
                        );

                    o.normal = ColorToNormal(tex2Dlod(_Texture, float4(uv.x + d, uv.y + d, 0, 0)));
                    o.normal = mul(o.normal, RotateMatrix_X(270.0f / 180.0f * 3.1415926535f));

                    o.vertex = UnityObjectToClipPos(o.vertex);
                    o.normal = UnityObjectToWorldNormal(o.normal);
                    stream.Append(o);
                }
                stream.RestartStrip();
            }

            fixed4 frag(g2f i) : SV_Target
            {
                fixed4 color = fixed4(1,1,1,1);
                color.rgb = mul((0.3 * dot(i.normal, _WorldSpaceLightPos0) + 0.3), 2);
                color.rgb *= _LightColor0;
                return color;
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}
