Shader "ElliotCustom/11UIGrey"
{
    Properties
    {
        [PerRendererData]_MainTex("MainTex",2D) = "white"{}
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend ("SrcBlend",int) = 0
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend ("DstBlend",int) = 0

        _Stencil("Stencil Ref",int) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp("Stencil Comparison",int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)]_StencilOp("Stencil Operation",int) = 0
        _StencilReadMask("Stencil ReadMask",int) = 0
        _StencilWriteMask("Stencil WriteMask",int) = 0
        _ColorMask("ColorMask",int) = 15
        [Toggle]_GrayEnabled ("Gray Enable",int) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
        }
        Blend [_SrcBlend] [_DstBlend]
        ColorMask [_ColorMask]
        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ UNITY_UI_CLIP_RECT
            #pragma multi_compile _ _GRAYENABLED_ON

            #include "UnityUI.cginc"
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                fixed2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed2 uv : TEXCOORD0;
                fixed4 color : COLOR;
                float4 localPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            float4 _ClipRect;

            v2f vert(appdata i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.uv = i.uv;
                o.color = i.color;
                o.localPos = i.vertex;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 finalColor;
                finalColor = tex2D(_MainTex, i.uv);
                finalColor *= i.color;

                #if UNITY_UI_CLIP_RECT
                fixed2 rect = step(_ClipRect.xy,i.localPos.xy) * step(i.localPos.xy,_ClipRect.zw);
                finalColor.a *= rect.x*rect.y;
                #endif

                #if _GRAYENABLED_ON
                finalColor.rgb = dot(finalColor.rgb, fixed3(0.22,0.707,0.071));
                #endif
                
                return finalColor;
            }
            ENDCG
        }
    }
}