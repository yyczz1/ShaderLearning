Shader "ElliotCustom/19Fog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members fogFactor)
#pragma exclude_renderers d3d11
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float fogFactor : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
                float z = length(_WorldSpaceCameraPos - worldPos);
                #if defined(FOG_LINEAR)
                //(end-z)/(end-start) = z * (-1/(end-start)) + (end / (end / start))
                o.fogFactor = z * unity_FogParams.z + unity_FogParams.w;
                #elif defined(FOG_EXP)
                o.fogFactor = exp2(-unity_FogParams.y * z);
                #elif defined(FOG_EXP2)
                float density = unity_FogParams.x * z;
                o.fogFactor = exp2(-density * density);
                #endif
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                col = lerp(unity_FogColor,col,i.fogFactor);
                #endif
                
                return col;
            }
            ENDCG
        }
    }
}
