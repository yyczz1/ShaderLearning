Shader "ElliotCustom/16XRay"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Enum(Off,0,On,1)]_ZWrite ("ZWrite",int) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest ("ZTest",int) = 2
        _XRayColor ("XRayColor",Color) = (1,0.5,0,1)
    }
    SubShader
    {
        Pass
        {
            Name "XRay"
            Tags
            {
                "Queue"="Geometry+1"
            }
            Blend one one

            ZWrite off
            ZTest [_ZTest]
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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
            fixed4 _XRayColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
                fixed3 N = normalize(i.worldNormal);
                fixed VDOTN = dot(V,N);
                fixed3 fresnel = 2 * pow(1-VDOTN,2) * _XRayColor;
                fixed v = frac(i.worldPos.y * 20 - _Time.y);
                fixed4 finalCol = fixed4(fresnel,1) * v;
                return finalCol;
            }
            ENDCG
        }

        Pass
        {
            Tags
            {
                "Queue"="Geometry"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _XRayColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed4 finalCol = tex2D(_MainTex, i.uv);
                return finalCol;
            }
            ENDCG
        }        
    }
}