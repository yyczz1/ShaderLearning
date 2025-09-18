using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangeMaterialVector : MonoBehaviour
{
    public Renderer CharacterRenderer;
    private Vector3 Value;
    public Vector3 ChangeSpeed = new Vector3(0, 0f, 0.3f);// 可以调节溶解速度
    public bool IsCycle = true;
    private Vector3 isIncreasing = Vector3.one;// 新增一个布尔变量来控制方向
    private Material CharacterMaterial;
    public string ChangeValueString;

    void Start()
    {
        if (CharacterRenderer != null)
        {
            CharacterMaterial = CharacterRenderer.material;
        }
        else
        {
            Debug.LogError("Renderer component not found on the GameObject.");
        }
    }
    
    
    // Update is called once per frame
    void Update()
    {
        if (IsCycle)
        {
            // 分别处理 x、y、z 三个分量
            // X 分量
            if (isIncreasing.x > 0)
            {
                Value.x += Time.deltaTime * ChangeSpeed.x;
                if (Value.x >= 1f)
                {
                    Value.x = 1f;
                    isIncreasing.x = -1f; // 反转方向
                }
            }
            else
            {
                Value.x -= Time.deltaTime * ChangeSpeed.x;
                if (Value.x <= 0f)
                {
                    Value.x = 0f;
                    isIncreasing.x = 1f; // 反转方向
                }
            }

            // Y 分量
            if (isIncreasing.y > 0)
            {
                Value.y += Time.deltaTime * ChangeSpeed.y;
                if (Value.y >= 1f)
                {
                    Value.y = 1f;
                    isIncreasing.y = -1f;
                }
            }
            else
            {
                Value.y -= Time.deltaTime * ChangeSpeed.y;
                if (Value.y <= 0f)
                {
                    Value.y = 0f;
                    isIncreasing.y = 1f;
                }
            }
            
            // Z 分量
            if (isIncreasing.z > 0)
            {
                Value.z += Time.deltaTime * ChangeSpeed.z;
                if (Value.z >= 1f)
                {
                    Value.z = 1f;
                    isIncreasing.z = -1f;
                }
            }
            else
            {
                Value.z -= Time.deltaTime * ChangeSpeed.z;
                if (Value.z <= 0f)
                {
                    Value.z = 0f;
                    isIncreasing.z = 1f;
                }
            }
        }

        
        // 将 Value 传递给 Shader
        CharacterMaterial.SetVector(ChangeValueString, Value);
    }
}
