using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DissolveTexture : MonoBehaviour
{
    public Renderer DissolveRenderer;
    private float clipValue;
    public float dissolveSpeed = 0.5f; // 可以调节溶解速度
    private bool isIncreasing = true; // 新增一个布尔变量来控制方向
    private Material dissolveMaterial;

    void Start()
    {
        if (DissolveRenderer != null)
        {
            dissolveMaterial = DissolveRenderer.material;
        }
        else
        {
            Debug.LogError("Renderer component not found on the GameObject.");
        }
    }
    
    
    // Update is called once per frame
    void Update()
    {
        if (isIncreasing)
        {
            clipValue += Time.deltaTime * dissolveSpeed;
            if (clipValue >= 1f)
            {
                clipValue = 1f; // 确保不超过1
                isIncreasing = false; // 到达1后，反转方向
            }
        }
        else
        {
            clipValue -= Time.deltaTime * dissolveSpeed;
            if (clipValue <= 0f)
            {
                clipValue = 0f; // 确保不低于0
                isIncreasing = true; // 到达0后，反转方向
            }
        }
        
        // 将 clipValue 传递给 Shader
        dissolveMaterial.SetFloat("_ClipValue", clipValue);
    }
}
