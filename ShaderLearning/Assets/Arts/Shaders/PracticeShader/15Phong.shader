Shader "ElliotCustom/15Phong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_DiffuseIntensity ("DiffuseIntensity",Range(0,8)) = 1
        _SpecularColor ("SpecularColor",Color) = (1,1,1,1) 
        _SpecularIntensity ("SpecularIntensity",Range(0,8)) = 1
        _Shininess ("Shininess",Range(0,8)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

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
				o.worldNormal = UnityObjectToWorldNormal(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 finalCol;
				half KD = _DiffuseIntensity;
				half NDOTL = max(0,dot(i.worldNormal,_WorldSpaceLightPos0));
				fixed4 Diffuse = unity_AmbientSky + KD * _LightColor0 * NDOTL;

				float3 V = normalize(_WorldSpaceCameraPos-i.worldPos);
                // float3 R = normalize((2 * i.worldNormal * NDOTL)-_WorldSpaceLightPos0);
                float3 R = reflect(-_WorldSpaceLightPos0,normalize(i.worldNormal));
                fixed4 Specular = pow(max(0,dot(V,R)),_Shininess) * _SpecularColor * _SpecularIntensity;
                finalCol = Specular + Diffuse;
                return finalCol;
            }
            ENDCG
        }
    }
}
