Shader "ElliotCustom/21Textures"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [IntRange] _Mipmap ("Mipmap",Range(0,12)) = 0
        [KeywordEnum(Repeat,Clamp)]_WrapMode("_WrapMode",int) = 0
        _CubeMap ("Cubemap",Cube) = "white"{}
        [Normal]_NormalMap ("NormalMap",2D) = "bump"{}
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
            #pragma shader_feature _WRAPMODE_REPEAT _WRAPMODE_CLAMP

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 localPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
                float3 tSpace0 : TEXCOORD4;
                float3 tSpace1 : TEXCOORD5;
                float3 tSpace2 : TEXCOORD6;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _Mipmap;
            samplerCUBE _CubeMap;
            sampler2D _NormalMap;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.localPos = o.vertex.xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);

                half3 worldTangent = UnityObjectToWorldDir(v.tangent);
                fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                half3 worldBinormal = cross(worldTangent,o.worldNormal) * tangentSign;
                o.tSpace0 = float3(worldTangent.x,worldBinormal.x,o.worldNormal.x);
                o.tSpace1 = float3(worldTangent.y,worldBinormal.y,o.worldNormal.y);
                o.tSpace2 = float3(worldTangent.z,worldBinormal.z,o.worldNormal.z);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                #if _WRAPMODE_REPEAT
                i.uv = frac(i.uv);
                #elif _WRAPMODE_CLAMP
                i.uv = clamp(i.uv,0,1);
                #endif

                // fixed3 normalTex = UnpackNormal(tex2D(_NormalMap,i.uv));
                // fixed3 L = _WorldSpaceLightPos0.xyz;
                // half3 normalTexWorldNormal = half3(dot(i.tSpace0,normalTex),dot(i.tSpace1,normalTex),dot(i.tSpace2,normalTex));
                // return max(0,dot(normalTexWorldNormal,L));
                
                float3 V = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 R = reflect(-V,i.worldNormal);
                fixed4 cubemap = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0,R);
                half3 skyColor = DecodeHDR(cubemap,unity_SpecCube0_HDR);
                return  fixed4(skyColor,1);
                
                // float4 uvMipmap = float4(i.uv,0,_Mipmap);
                // fixed4 col = tex2Dlod(_MainTex,uvMipmap);
                // return col;
                
                // float3 V = normalize(UnityWorldSpaceViewDir(i.worldPos));
                // float3 R = reflect(-V,normalize(i.worldNormal));
                // fixed4 cubemap = texCUBE(_CubeMap,R);
                // return cubemap;
            }
            ENDCG
        }
    }
}
