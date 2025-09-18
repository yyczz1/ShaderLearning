Shader "ElliotYip/15BlinnPhong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DiffuseIntensity ("DiffuseIntensity",Range(0,8)) = 1
        _SpecularIntensity ("SpecularIntensity",Range(0,8)) = 1
        _Shininess ("Shininess",Range(0,8)) = 4
        _SpecularColor("Specular Color",Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
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
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _DiffuseIntensity;
            half _SpecularIntensity;
            half _Shininess;
            fixed4 _SpecularColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 finalCol;
                fixed NDOTL = max(0,dot(i.worldNormal,_WorldSpaceLightPos0));
                fixed4 Diffuse = unity_AmbientSky + _DiffuseIntensity * _LightColor0 * NDOTL;
                fixed3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
                fixed3 H = normalize(V+_WorldSpaceLightPos0);
                fixed4 BlinnSpecular = _SpecularColor * _SpecularIntensity * pow(max(0,dot(i.worldNormal,H)),_Shininess);
                finalCol = Diffuse + BlinnSpecular;
                return finalCol;
            }
            ENDCG
        }
    }
}
