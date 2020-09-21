// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/TestShader"
{
    Properties{
        [HDR] _LineColor("Line Color", Color) = (1,1,1,1)
        _MainColor("MainColor", color) = (0,1,0,1)           //第一种颜色：绿
        _SecondColor("SecondColor", color) = (1,0,0,1) //第二种颜色：红
        _Center("Center", range(-0.51,0.51)) = 0              //中心点y坐标值
        _R("R", range(0,1)) = 0.2                                         //产生渐变的范围值


        _LineWid("LineWid", range(0,0.01)) = 0.01
        _LineNum("LineNum", range(1,100)) = 10
        _Num("Num", int) = 10


        _ZoneStart("ZoneStart", range(-0.5,1.5)) = 0.01
        _ZoneWid("ZoneWid", range(0,0.5)) = 0.01
        _TimeLast("TimeLast", float) = 0

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
                float _Center;
                float _R;

                float _LineWid;
                int _LineNum;
                int _Num;
                float _ZoneStart;
                float _ZoneWid;
                float _TimeLast;



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
                    //o.pos = UnityObjectToClipPos(float3(v.vertex.x, sin(10 * (v.vertex.x - 2) + 10 * _Time.y), v.vertex.z));
                    o.x = v.vertex.x;
                    o.y = v.vertex.y;
                    o.z = v.vertex.z;
                    return o;
                }



                fixed4 frag(v2f IN) :COLOR
                {
                    float Xmin = _ZoneStart - _TimeLast;
                    float Wid = _ZoneWid;
                    float Xmax = Xmin + Wid;

                    fixed4 col;
                    int num = 20;

                    float div = 1.0 / float(_LineNum * 2);
                    col = _SecondColor;
                    col.a = 0;


                    if (IN.x > Xmin - .001 && IN.x < Xmin) {
                        //col = _LineColor;
                    }


                    if (IN.x > Xmin && IN.x < Xmax) {
                        fixed scanPercent = 1- (IN.x - Xmax) / Wid / 2;
                        col = lerp((1, 0, 0, 1), col, scanPercent);

                        for (int j = 0; j < _LineNum * 4; j++) {
                            if ((IN.x > -1 + div * j && IN.x < -1 + div * j + _LineWid)
                                || (IN.z > -1 + div * j && IN.z < -1 + div * j + _LineWid)) {
                                col = lerp((1, 0, 0, 1), col, scanPercent + 0.3);
                                //col = _LineColor;
                            }
                        }
                    }



                    return col;
                }
                ENDCG
            }
    }
}