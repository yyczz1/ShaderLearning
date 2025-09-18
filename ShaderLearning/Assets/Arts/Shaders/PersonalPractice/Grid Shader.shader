// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "hitthedog/Grid"
{
   Properties {
      _LineColor("Line Color", Color) = (0.96,0.96,0.96,1)
      _CellColor("Cell Color", Color) = (0,0,0,0)
      [PerRendererData] _MainTex("Albedo (RGB)", 2D) = "white" {}
      [IntRange] _GridSizeX("Grid SizeX", Range(4,20)) = 15
      [IntRange] _GridSizeY("Grid SizeY", Range(4,20)) = 15
      _LineSize("Line Size", Range(0,1)) = 0.15
      _color("Frame Color",Color)=(0.67,0.67,0.67,1)
      _count ("Frame Count", Range(0, 50)) = 10
      _length("Frame Length",Range(0,1))=0.7
      _width("Frame Width",Range(0,1))=0.25
      _lineWidth("LineWidth",Range(0,1))=0.05
      _TillOffsetX ("_TillOffsetX", Range(0, 20)) = 15.5
      _TillOffsetY ("_TillOffsetY", Range(0, 20)) = 15.5
   }

   CGINCLUDE
         float isOk(float x,float y,float _width,float _length,float _lineWidth){
            //中空
            if(( y >_lineWidth && y < _length - _lineWidth) && (x > _lineWidth && x < (_width - _lineWidth))){
               return 2;
            }
            //边框 竖直和垂直方向
            if(( y> _lineWidth && y < _length - _lineWidth) || (x > _lineWidth && x < (_width - _lineWidth))){
               return 1;
            }
            
            //左下角 圆角
            if(y<_lineWidth && x<_lineWidth){
               if(distance(float2(x,y),float2(_lineWidth,_lineWidth))<_lineWidth){
                     return 1;
               }
            }
            //右下角
            if(y<_lineWidth && x>_width -_lineWidth){
               if(distance(float2(x,y),float2(_width -_lineWidth,_lineWidth))<_lineWidth){
                     return 1;
               }
            }
            //左上角
            if(y>_length - _lineWidth && x<_lineWidth){
               if(distance(float2(x,y),float2(_lineWidth,_length - _lineWidth))<_lineWidth){
                     return 1;
               }
            }
            //右上角
            if(y>_length - _lineWidth && x>_width -_lineWidth){
               if(distance(float2(x,y),float2(_width -_lineWidth,_length - _lineWidth))<_lineWidth){
                     return 1;
               }
            }
            return 0;
         }

         #include "UnityCG.cginc"
         struct a2v {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
         };
         
         struct v2f {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
         };

         float4 _LineColor;
         float4 _CellColor;
         sampler2D _MainTex;
         float _GridSizeX;
         float _GridSizeY;
         float _LineSize;

         v2f vert (a2v v) {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
            return o;
         }

         fixed4 _color;
         float _width;
         float _length;
         float _count;
         float _lineWidth;
         float _TillOffsetX;
         float _TillOffsetY;

         fixed4 frag (v2f i) : SV_Target {
            float3 worldPos = mul(unity_ObjectToWorld, i.vertex);
            //float2 uv = i.uv;
            float2 uv = float2(worldPos.x/_TillOffsetX,worldPos.y/_TillOffsetY);

            fixed4 c = float4(0.0,0.0,0.0,0.0);

            float brightness = 1.;

            float gsize = floor(_GridSizeX);

            gsize += _LineSize;

            float gsizeY = floor(_GridSizeY);

            gsizeY += _LineSize;

            float4 color = _CellColor;
            brightness = _CellColor.w;

            if (frac(uv.x*gsize) <= _LineSize || frac(uv.y*gsizeY) <= _LineSize)
            {
               brightness = _LineColor.w;
               color = _LineColor;
            }

            float x=i.uv.x * _count;
            float y=i.uv.y * _count;
            fixed leftOK = isOk(frac(x),frac(y),_width,_length,_lineWidth);
            fixed rightOK = isOk(frac(1-x),frac(y),_width,_length,_lineWidth);
            fixed bottomOK = isOk(frac(y),frac(x),_width,_length,_lineWidth);
            fixed upOK = isOk(frac(1-y),frac(x),_width,_length,_lineWidth);

            if(x < _width && frac(y)<_length && leftOK > 0){
               if(leftOK == 2)
                     return fixed4(1,1,1,1);
               return _color;
            }
            if(x > _count - _width && frac(y)<_length && rightOK > 0){
               if(rightOK == 2)
                     return fixed4(1,1,1,1);
               return _color;
            }
            if(y < _width && frac(x)<_length && bottomOK > 0){
               if(bottomOK == 2)
                     return fixed4(1,1,1,1);
               return _color;
            }
            if(y > _count - _width && frac(x)<_length && upOK > 0){
               if(upOK == 2)
                     return fixed4(1,1,1,1);
               return _color;
            }

            //Clip transparent spots using alpha cutout
            if (brightness == 0.0) {
               clip(c.a - 1.0);
            }


            c = fixed4(color.x*brightness,color.y*brightness,color.z*brightness,brightness);
            return c;
         }
   ENDCG

   SubShader {
         Pass {
            

            Tags {"Queue" = "Transparent" "RenderType" = "Transparent" }
            LOD 100

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
         }
   }
  
}