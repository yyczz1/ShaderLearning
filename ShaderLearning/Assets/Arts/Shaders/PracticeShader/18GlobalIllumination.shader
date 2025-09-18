Shader "ElliotCustom/18GlobalIllumination"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }

        Pass
        {
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                half3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata v)
            {
                v2f o;
                    TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i);
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "../CGIncludes/MyGlobalIllumination.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                #if defined(LIGHTMAP_ON) || (DYNAMICLIGHTMAP_ON)
                float4 lightmapUV : TEXCOORD2;
                #endif
                fixed3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                #if defined(LIGHTMAP_ON) || (DYNAMICLIGHTMAP_ON)
                float4 lightmapUV : TEXCOORD2;
                #endif
                fixed3 worldNormal : TEXCOORD3;
                UNITY_LIGHTING_COORDS(3,4)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                
                #if defined(LIGHTMAP_ON) 
                o.lightmapUV.xy = v.lightmapUV * unity_LightmapST.xy + unity_LightmapST.zw;
                #endif
                
                #if defined(DYNAMICLIGHTMAP_ON)                
                o.lightmapUV.zw = v.lightmapUV * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
                #endif
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                UNITY_TRANSFER_LIGHTING(o,v.lightmapUV.xy);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                SurfaceOutput o;
                UNITY_INITIALIZE_OUTPUT(SurfaceOutput,o);
                o.Albedo = 1;
                o.Normal = i.worldNormal;
                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

                UnityGIInput giInput;
                UNITY_INITIALIZE_OUTPUT(UnityGIInput,giInput);
                // giInput.light = _LightColor0;
                giInput.light.color = _LightColor0;
                giInput.light.dir = _WorldSpaceLightPos0;
                giInput.worldPos = i.worldPos;
                giInput.worldViewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                giInput.atten = atten;
                giInput.ambient = 0;
                #if defined(LIGHTMAP_ON) || (DYNAMICLIGHTMAP_ON)
                giInput.lightmapUV = i.lightmapUV;
                #endif

                UnityGI gi;
                gi.light.color = _LightColor0;
                gi.light.dir = _WorldSpaceLightPos0;
                gi.indirect.diffuse = 0;
                gi.indirect.specular = 0;
                LightingLambert_GI1(o,giInput,gi);
                
                fixed4 col = LightingLambert1(o,gi);
                return col;
            }
            ENDCG
        }
    }    
}
