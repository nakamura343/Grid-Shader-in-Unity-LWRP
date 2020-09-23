using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public enum ShaderType
{
    Line,
    Circle,
}

public class ShaderMgr : MonoBehaviour
{
    public ShaderType st = ShaderType.Circle;

    public Material mat = null;
    public float speed = 50;
    Camera cam;
    float ScanTimer = 0;
    private Vector3 ScanPoint = Vector3.zero;

    // Start is called before the first frame update
    void Awake()
    {
        if (st == ShaderType.Line)
        {
            mat.SetFloat("_IsLineScan", 1);
            speed = 40;
        }
        else
        {
            mat.SetFloat("_IsLineScan", 0);
            speed = 3000;
        }
    }


        // Update is called once per frame
        void Update()
    {
        ScanTimer += Time.deltaTime;

        if (Input.GetKeyDown(KeyCode.Space))
        {
            ScanTimer = 0;
        }

        if(st == ShaderType.Line)
        {
            if (ScanTimer > 2.0f)
            {
                ScanTimer = -3f;
            }
        }

        if (st == ShaderType.Circle)
        { 
            if (ScanTimer > 2.0f)
            {
                //ScanTimer = 0f;
            }
        }

        mat.SetFloat("_TimePassed", ScanTimer / 100.0f * speed);

        RaycastHit hit;
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        if (Input.GetMouseButton(0) && Physics.Raycast(ray, out hit))
        {
            ScanTimer = 0;
            ScanPoint = hit.point;
        }
        mat.SetVector("_ScanCenter", ScanPoint);


    }

}
