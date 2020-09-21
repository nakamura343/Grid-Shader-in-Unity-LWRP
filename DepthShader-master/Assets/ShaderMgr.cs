using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderMgr : MonoBehaviour
{

    public Material mat = null;
    public float speed = 10;

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


        mat.SetFloat("_TimeLast", time / 100.0f * speed);
    }

}
