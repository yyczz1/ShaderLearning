Shader "ElliotCustom/15Lambert"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DiffuseIntensity ("Diffuse Intensity",Range(0,8)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}

        Pass
        {
            Tags{ "LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _DiffuseIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 finalCol = tex2D(_MainTex, i.uv);
                float ambient = unity_AmbientSky;
                fixed kd = _DiffuseIntensity;
                float3 N = normalize(i.worldNormal);
                float3 L = _WorldSpaceLightPos0;
                fixed4 lambert = ambient + kd * _LightColor0 * max(0,dot(N,L));
                finalCol = lambert;
                return finalCol;
            }
            ENDCG
        }

        Pass
        {
            Tags{ "LightMode" = "ForwardAdd"}
            Blend one One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            #pragma skip_variants DIRECTIONAL DIRECTIONAL_COOKIE POINT_COOKIE

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                fixed2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : NORMAL;
                fixed2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            half _DiffuseIntensity;

            v2f vert(appdata i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.uv = i.uv;
                o.worldNormal = UnityObjectToWorldNormal(i.normal);
                o.worldPos = mul(unity_ObjectToWorld,i.vertex);
                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                fixed4 finalColor;
                // float3 lightCoord = mul(unity_WorldToLight,float4(i.worldPos,1)).xyz;
                //fixed atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord));
                UNITY_LIGHT_ATTENUATION(atten,0,i.worldPos);
                fixed3 N = normalize(i.worldNormal);
                fixed3 L = _WorldSpaceLightPos0;
                finalColor = _LightColor0 * max(0,dot(N,L));
                return finalColor;
            }
            
            ENDCG
        }
    }
}
