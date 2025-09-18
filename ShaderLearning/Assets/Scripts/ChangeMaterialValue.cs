using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangeMaterialValue : MonoBehaviour
{
    public Renderer CharacterRenderer;
    private float Value;
    public float ChangeSpeed = 0.5f; // 可以调节溶解速度
    public bool IsCycle = true;
    private bool isIncreasing = true; // 新增一个布尔变量来控制方向
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
            if (isIncreasing)
            {
                Value += Time.deltaTime * ChangeSpeed;
                if (Value >= 1f)
                {
                    Value = 1f; // 确保不超过1
                    isIncreasing = false; // 到达1后，反转方向
                }
            }
            else
            {
                Value -= Time.deltaTime * ChangeSpeed;
                if (Value <= 0f)
                {
                    Value = 0f; // 确保不低于0
                    isIncreasing = true; // 到达0后，反转方向
                }
            }
        }

        
        // 将 Value 传递给 Shader
        CharacterMaterial.SetFloat(ChangeValueString, Value);
    }
}
