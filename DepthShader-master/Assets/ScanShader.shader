
Shader "Custom/ScanShader"
{
    Properties{
        [HDR] _LineColor("Line Color", Color) = (1,1,1,1)
        [HDR] _LineHeadColor("LineHeadColor", Color) = (1,1,1,1)  //线头的一条线的颜色
        _MainColor("MainColor", color) = (0,1,0,1)           //第一种颜色：绿
        _SecondColor("SecondColor", color) = (1,0,0,1) //第二种颜色：红
        _Center("Center", range(-0.51,0.51)) = 0              //中心点y坐标值
        _R("R", range(0,1)) = 0.2                                         //产生渐变的范围值


        _LineWid("LineWid", range(0,0.01)) = 0.01
        _LineInterVal("LineInterVal", range(0.001,0.1)) = 0.001
        _Num("Num", int) = 10


        _ZoneStart("ZoneStart", range(-1,1.5)) = 0.01
        _ZoneWid("ZoneWid", range(0,0.03)) = 0.001
        _TimeLast("TimeLast", float) = 0

        _LineYColor("LineYColor", color) = (1,1,0,1) //
        _LineY("LineY", range(-1,1)) = 0.001


        _OffsetY("OffsetY", range(-15,15)) = 0
    }
        SubShader{
            Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
            pass {
                Blend SrcAlpha OneMinusSrcAlpha
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "unitycg.cginc"
                fixed4 _MainColor;
                fixed4 _SecondColor;
                fixed4 _LineColor;
                fixed4 _LineHeadColor;
                float _Center;
                float _R;

                float _LineWid;
                float _LineInterVal;
                int _Num;
                float _ZoneStart;
                float _ZoneWid;
                float _TimeLast;

                float _LineY;
                fixed4 _LineYColor;

                float _OffsetY;


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
                    o.pos.y -= _OffsetY;
                    //o.pos = UnityObjectToClipPos(v.vertex);
                    //o.pos = UnityObjectToClipPos(float3(v.vertex.x, sin(10 * (v.vertex.x - 2) + 10 * _Time.y), v.vertex.z));
                    o.x = v.vertex.x;
                    o.y = v.vertex.y;
                    o.z = v.vertex.z;
                    return o;
                }



                fixed4 frag(v2f IN) :COLOR
                {
                    float Xmax = _ZoneStart + _TimeLast;
                    float Wid = _ZoneWid;
                    float Xmin = Xmax - Wid;

                    fixed4 col;
                    int num = 20;

                    col = _LineColor;
                    col.a = 0;

                    //扩散之后的区域的整体颜色
                    if (IN.x > Xmin - _LineWid && IN.x < Xmin) {
                        col = _SecondColor;
                    }


                    if (IN.x > Xmin && IN.x < Xmax) {
                        fixed scanPercent = (IN.x - Xmin) / Wid / 2;
                        col = lerp(_SecondColor, _LineColor, scanPercent);

                        int num = 1.0f / _LineInterVal;
                        for (int j = 0; j < num; j++) {
                            if ((IN.x > -0 + _LineInterVal * j && IN.x < -0 + _LineInterVal * j + _LineWid)
                                || (IN.z > -1 + _LineInterVal * j && IN.z < -1 + _LineInterVal * j + _LineWid)) {
                                col = lerp(_SecondColor, _LineColor, scanPercent + 0.2);
                            }
                        }

                        if (IN.x > Xmax - _LineWid && IN.x < Xmax) {
                            col = _LineHeadColor;
                        }
                    }


                    if (IN.y > _LineY - _LineWid && IN.y < _LineY) {
                        col = _LineYColor;
                    }

                    return col;
                }
                ENDCG
            }
    }
}