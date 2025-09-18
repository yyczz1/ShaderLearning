Shader "ElliotCustom/8Blend"
{
    Properties
    {
        [Header(RenderingMode)]
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("Src Blend",int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("Dst Blend",int) = 1
        [Enum(UnityEngine.Rendering.CullMode)]_CullValue("Cull",int) = 0
        
        [Header(Base)]
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor ("MainColor",Color) = (1,1,1,1)
        _Intensity ("Intensity",Range(-8,8)) = 1
        _MainOffsetX ("Main Offset X",float) = 1
        _MainOffsetY ("Main Offset Y",float) = 1
        
        [Header(Mask)]
        [Toggle]_MaskEnabled("Mask Enabled",int) = 0
        _MaskTex("MaskTex",2D) = "white"{}
        _MaskOffsetX ("Mask Offset X",float) = 1
        _MaskOffsetY ("Mask Offset Y",float) = 1
        
        [Header(Distort)]
        [MaterialToggle(DISTORTENABLED)]_DistortEnabled("Mask Enabled",int) = 0
        _DistortTex("DistortTex",2D) = "white" {}
        _DistortValue("DistortValue",Range(0,1)) = 0
        _DistortOffsetX ("Distort Offset X",float) = 1
        _DistortOffsetY ("Distort Offset Y",float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Blend [_SrcBlend][_DstBlend]
        Cull [_CullValue]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature _ _MASKENABLED_ON 
            #pragma shader_feature _ DISTORTENABLED

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 uv2 : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _MainColor;
            half _Intensity;
            float _MainOffsetX;
            float _MainOffsetY;

            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            float _MaskOffsetX;
            float _MaskOffsetY;
            
            sampler2D _DistortTex;
            float4 _DistortTex_ST;
            float _DistortValue;
            float _DistortOffsetX;
            float _DistortOffsetY;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float2 Disturbance = float2(_MainOffsetX,_MainOffsetY) * _Time.y;
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex) + Disturbance;
                #if _MASKENABLED_ON
                o.uv.zw = TRANSFORM_TEX(v.uv, _MaskTex) + float2(_MaskOffsetX,_MaskOffsetY) * _Time.y;
                #endif

                #if DISTORTENABLED                
                o.uv2 = TRANSFORM_TEX(v.uv, _DistortTex) + float2(_DistortOffsetX,_DistortOffsetY) * _Time.y;
                #endif
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 finalColor;
                fixed2 mainUV = i.uv.xy;
                #if DISTORTENABLED
                fixed4 distortCol = tex2D(_DistortTex, i.uv2);
                mainUV = lerp(i.uv.xy,distortCol,_DistortValue);
                #endif
                
                fixed4 mainCol = tex2D(_MainTex, mainUV);
                finalColor = mainCol * _MainColor * _Intensity;
                
                #if _MASKENABLED_ON
                fixed4 maskCol = tex2D(_MaskTex, i.uv.zw);
                finalColor *= maskCol;
                #endif
                
                
                return finalColor;
            }
            ENDCG
        }
    }
}
