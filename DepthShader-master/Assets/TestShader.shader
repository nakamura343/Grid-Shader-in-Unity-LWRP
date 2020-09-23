﻿Shader "Custom/TestShader"
{
    Properties{
        [HDR] _LineColor("Line Color", Color) = (1,1,1,1)
        [HDR] _LineHeadColor("LineHeadColor", Color) = (1,1,1,1)  //线头的一条线的颜色
        _TailColor("TailColor", color) = (1,0,0,1) //第二种颜色

        _LineWid("LineWid", range(0,0.01)) = 0.0012
        _LineInterValX("LineInterValX", range(0.001,0.1)) = 0.0202
        _LineInterValZ("LineInterValZ", range(0.001,0.1)) = 0.0391

        _ZoneStart("ZoneStart", range(-1,1.5)) = 0.01
        _ZoneWid("ZoneWid", range(0,.8)) = 0.185
        _TimePassed("TimePassed", float) = 0

        _LineYColor("LineYColor", color) = (1,1,0,1) //
        _LineY("LineY", range(-1,1)) = 0.001
        _OffsetY("OffsetY", range(-15,15)) = 0


        _PointX("PointX", range(-2,2)) = 0
        _PointY("PointY", range(-2,2)) = 0
        _PointZ("PointZ", range(-2,2)) = 0


        _RadiusOut("RadiusOut", range(-2,2)) = 0
        _RadiusWid("RadiusWid", range(0,2)) = 0

    }
    SubShader{
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        pass {
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "unitycg.cginc"
            fixed4 _TailColor;
            fixed4 _LineColor;
            fixed4 _LineHeadColor;

            float _LineWid;
            float _LineInterValX;
            float _LineInterValZ;
            float _ZoneStart;
            float _ZoneWid;
            float _TimePassed;

            float _LineY;
            fixed4 _LineYColor;
            float _OffsetY;


            float _PointX;
            float _PointY;
            float _PointZ;
            float _RadiusOut;
            float _RadiusWid;


            //获取随机噪点值，这里使用的因子是原x+时间长度
            //float noise = random(o.pos.x + _Time.y * 0.4);
            //噪点/随机数发生器
            float random(float n) {
                return frac(sin(dot(n, float2(12.9898, 78.233))) * 43758.5453123);
            }


            struct v2f {
                float4 pos:POSITION;
                float y : TEXCOORD0;
                float x : TEXCOORD1;
                float z : TEXCOORD2;
            };
            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //o.pos = UnityObjectToClipPos(float3(v.vertex.x, v.vertex.y, v.vertex.z));
                o.x = v.vertex.x;
                o.y = v.vertex.y - _OffsetY;
                o.z = v.vertex.z;
                return o;
            }

            //线性扫描
            fixed CalculatePercent(float now, float to, float total) {
                return abs(now - to) / total / 2;
            }
            //扩散扫描
            fixed CalculatePercentCricle(float3 now, float3 to, float total) {
                return distance(now, to) / total / 2;
            }



            fixed4 frag_Circle(v2f IN) :COLOR
            {
                //扫描区前端，开始
                float Xmax = _RadiusOut + _TimePassed;
                //扫描区宽度
                float Wid = _RadiusWid;
                //扫描区后端，结束
                float Xmin = Xmax - Wid;
                //返回颜色初始化
                fixed4 col = (0, 0, 0, 0);

                //在扫描区域内
                //if (IN.x > Xmin && IN.x < Xmax) {

                float3 pos = float3(IN.x, 0, IN.z);
                float3 centerPoint = float3(_PointX, _PointY, _PointZ);
                fixed dis = distance(pos, centerPoint);

                if (dis > Xmin && dis < Xmax) {


                    //lerp的百分比
                    //fixed scanPercent = CalculatePercent(IN.x, Xmin, Wid);
                    fixed scanPercent = frac(CalculatePercentCricle(pos, centerPoint, Wid));
                    

                    //区域颜色lerp
                    col = lerp(_TailColor, _LineColor, .5);

                    //计算一共需要画多少条横线，多少条竖线
                    int numx = 1.0f / _LineInterValX;
                    int numz = 1.0f / _LineInterValZ;
                    //画方格线
                    for (int j = 0; j < numx; j++) {
                        if ((IN.x > -0 + _LineInterValX * j && IN.x < -0 + _LineInterValX * j + _LineWid)) {
                            col = lerp(_TailColor, _LineColor, scanPercent + 0.2);
                        }
                    }
                    for (int j = 0; j < numz; j++) {
                        if ((IN.z > -1 + _LineInterValZ * j && IN.z < -1 + _LineInterValZ * j + _LineWid)) {
                            col = lerp(_TailColor, _LineColor, scanPercent + 0.2);
                        }
                    }

                    //线头的一条线
                    if (dis > Xmax - _LineWid && dis < Xmax) {
                        col = _LineHeadColor;
                    }
                }

                //画一条等高线
                if (IN.y > _LineY - _LineWid && IN.y < _LineY) {
                    col = _LineYColor;
                }

                return col;
            }



            fixed4 frag_Line(v2f IN) :COLOR
            {
                //扫描区前端，开始
                float Xmax = _ZoneStart + _TimePassed;
                //扫描区宽度
                float Wid = _ZoneWid;
                //扫描区后端，结束
                float Xmin = Xmax - Wid;
                //返回颜色初始化
                fixed4 col = (0, 0, 0, 0);

                //在扫描区域内
                if (IN.x > Xmin && IN.x < Xmax) {
                    //lerp的百分比
                    fixed scanPercent = CalculatePercent(IN.x, Xmin, Wid);

                    //区域颜色lerp
                    col = lerp(_TailColor, _LineColor, scanPercent);

                    //计算一共需要画多少条横线，多少条竖线
                    int numx = 1.0f / _LineInterValX;
                    int numz = 1.0f / _LineInterValZ;
                    //画方格线
                    for (int j = 0; j < numx; j++) {
                        if ((IN.x > -0 + _LineInterValX * j && IN.x < -0 + _LineInterValX * j + _LineWid)) {
                            col = lerp(_TailColor, _LineColor, scanPercent + 0.2);
                        }
                    }
                    for (int j = 0; j < numz; j++) {
                        if ((IN.z > -1 + _LineInterValZ * j && IN.z < -1 + _LineInterValZ * j + _LineWid)) {
                            col = lerp(_TailColor, _LineColor, scanPercent + 0.2);
                        }
                    }

                    //线头的一条线
                    if (IN.x > Xmax - _LineWid && IN.x < Xmax) {
                        col = _LineHeadColor;
                    }
                }

                //画一条等高线
                if (IN.y > _LineY - _LineWid && IN.y < _LineY) {
                    col = _LineYColor;
                }

                return col;
            }


            fixed4 frag(v2f IN) :COLOR
            {
                //return frag_Line(IN);
                return frag_Circle(IN);
            }
        ENDCG
        }
    }
}