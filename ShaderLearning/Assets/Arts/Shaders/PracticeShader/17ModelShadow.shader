Shader "ElliotCustom/17ModelShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Shadow ("Shadow",Vector) = (0,0,0,1)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Geometry"
        }
        LOD 100

        Pass
        {
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
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            
            Stencil
            {
                Ref 100
                Comp NotEqual
                Pass Replace
            }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            fixed4 _Shadow;

            v2f vert(appdata v)
            {
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float worldPosY = worldPos.y;
                worldPos.y = _Shadow.y;
                worldPos.xz += _Shadow.xz + (worldPosY - _Shadow.y);
                v2f o;
                o.pos = mul(UNITY_MATRIX_VP, worldPos);
                return o;
            }

            fixed4 frag(v2f o):SV_Target
            {
                fixed4 c;
                c = 0;
                c.a = _Shadow.w;
                return c;
            }
            ENDCG
        }
    }
}