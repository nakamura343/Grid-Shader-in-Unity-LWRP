Shader "Custom/TestShader"
{
    Properties{
        _MainTex("Texture", 2D) = "white" {}
        _ScanTex("ScanTexure",2D) = "white"{}

        [HDR] _LineColor("Line Color", Color) = (1,1,1,1)
        [HDR] _LineHeadColor("LineHeadColor", Color) = (1,1,1,1)  //线头的一条线的颜色
        _TailColor("TailColor", color) = (1,0,0,1) //第二种颜色

        _LineWid("LineWid", range(0,0.01)) = 0.0009
        _LineInterValX("LineInterValX", range(0.001,0.1)) = 0.034
        _LineInterValZ("LineInterValZ", range(0.001,0.1)) = 0.036

        _ZoneStart("ZoneStart", range(-1,1.5)) = 0.01  
        _ZoneWid("ZoneWid", range(0,.8)) = 0.185       //0.42
        _TimePassed("TimePassed", float) = 0

        _LineYColor("LineYColor", color) = (1,1,0,1) //
        _LineY("LineY", range(-1,1)) = 0.001
        _OffsetY("OffsetY", range(-15,15)) = 0

        _RadiusOut("RadiusOut", range(-2,2)) = 0 //1
        _RadiusWid("RadiusWid", range(0,5)) = 0  //1.52

    }
    SubShader{
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        pass {
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "unitycg.cginc"

                
            sampler2D _MainTex;
            sampler2D _ScanTex;

            fixed4 _LineColor;
            fixed4 _LineHeadColor;
            fixed4 _TailColor;

            float _LineWid;
            float _LineInterValX;
            float _LineInterValZ;
            float _ZoneStart;
            float _ZoneWid;
            float _TimePassed;

            float _LineY;
            fixed4 _LineYColor;
            float _OffsetY;


            float _RadiusOut;
            float _RadiusWid;

            float3 _ScanCenter;
            float _IsLineScan;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos:POSITION;
                float4 xyz : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //o.pos = UnityObjectToClipPos(float3(v.vertex.x, v.vertex.y, v.vertex.z));
                o.xyz = v.vertex;
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            //线性扫描
            fixed CalculatePercent(float now, float to, float total) {
                return abs(now - to) / total / 2;
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
                float3 pos = IN.worldPos;
                float3 centerPoint = _ScanCenter;

                fixed dis = distance(pos, centerPoint);

                if (dis > Xmin && dis < Xmax) {

                    //lerp的百分比
                    fixed scanPercent = (CalculatePercent(dis, Xmin, Wid)) + 0.22;

                    //区域颜色lerp
                    col = lerp(_TailColor, _LineColor, scanPercent);

                    //计算一共需要画多少条横线，多少条竖线
                    int numx = 1.0f / _LineInterValX;
                    int numz = 1.0f / _LineInterValZ;
                    //画方格线
                    for (int j = 0; j < numx; j++) {
                        if ((IN.xyz.x > -0 + _LineInterValX * j && IN.xyz.x < -0 + _LineInterValX * j + _LineWid)) {
                            col = lerp(_TailColor, _LineColor, scanPercent + 0.2);
                        }
                    }
                    for (int j = 0; j < numz; j++) {
                        if ((IN.xyz.z > -1 + _LineInterValZ * j && IN.xyz.z < -1 + _LineInterValZ * j + _LineWid)) {
                            col = lerp(_TailColor, _LineColor, scanPercent + 0.2);
                        }
                    }

                    //线头的一条线
                    if (dis > Xmax - _LineWid * 100 && dis < Xmax) {
                        col = _LineHeadColor;
                    }
                }

                //画一条等高线
                if (IN.xyz.y > _LineY - _LineWid && IN.xyz.y < _LineY) {
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
                //col = tex2D(_MainTex, IN.uv);

                //在扫描区域内
                if (IN.xyz.x > Xmin && IN.xyz.x < Xmax) {

                    //lerp的百分比
                    fixed scanPercent = CalculatePercent(IN.xyz.x, Xmin, Wid) + .2;

                    //区域颜色lerp
                    col = lerp(col, _LineColor, scanPercent);

                    //计算一共需要画多少条横线，多少条竖线
                    int numx = 1.0f / _LineInterValX;
                    int numz = 1.0f / _LineInterValZ;
                    //画方格线
                    for (int j = 0; j < numx; j++) {
                        if ((IN.xyz.x > -0 + _LineInterValX * j && IN.xyz.x < -0 + _LineInterValX * j + _LineWid)) {
                            col = lerp(_TailColor, _LineColor, scanPercent + 0.2);
                        }
                    }
                    for (int j = 0; j < numz; j++) {
                        if ((IN.xyz.z > -1 + _LineInterValZ * j && IN.xyz.z < -1 + _LineInterValZ * j + _LineWid)) {
                            col = lerp(_TailColor, _LineColor, scanPercent + 0.2);
                        }
                    }

                    //线头的一条线
                    if (IN.xyz.x > Xmax - _LineWid && IN.xyz.x < Xmax) {
                        col = _LineHeadColor;
                    }
                }

                //画一条等高线
                if (IN.xyz.y > _LineY - _LineWid && IN.xyz.y < _LineY) {
                    col = _LineYColor;
                }

                return col;
            }


            fixed4 frag(v2f IN) :COLOR
            {
                if (_IsLineScan == 1) {
                    return frag_Line(IN);
                }
                else {
                    return frag_Circle(IN);
                }
                //return frag_Line(IN);
                //return frag_Circle(IN);
            }
        ENDCG
        }
    }
}