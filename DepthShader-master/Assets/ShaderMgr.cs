using System.Collections;
using System.Collections.Generic;
using UnityEngine;


enum ShaderType
{
    Line,
    Circle,
}

public class ShaderMgr : MonoBehaviour
{
    ShaderType st = ShaderType.Circle;

    public Material mat = null;
    public float speed = 50;

    // Start is called before the first frame update
    void Start()
    {
    }

    float time = 0;

    // Update is called once per frame
    void Update()
    {
        time += Time.deltaTime;

        if (Input.GetKeyDown(KeyCode.Space))
        {
            time = 0;
        }

        if(st == ShaderType.Line)
        {
            if (time > 2.0f)
            {
                time = -2f;
            }
        }

        if (st == ShaderType.Circle)
        { 
            if (time > 2.0f)
            {
                time = 0f;
            }
        }


        mat.SetFloat("_TimePassed", time / 100.0f * speed);
    }

}
