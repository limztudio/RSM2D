using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadowConfig : MonoBehaviour{
    public Color lightColor;
    public RenderTexture[] shadowComponent;
    public Shader shadowCaster;
    public int sampleDensity = 16;

    [HideInInspector]
    public Matrix4x4 lightTransform;
    [HideInInspector]
    public ComputeBuffer sampleTerm;

    private Camera shadowCamera;
    private Camera tempCamera;

    private RenderBuffer[] colorBuffers;


    void Start(){
        if(sampleDensity > 0){
            sampleTerm = new ComputeBuffer(sampleDensity, sizeof(float), ComputeBufferType.Default);
            float[] rawData = new float[sampleTerm.count];
            for(int i = 0, e = sampleTerm.count - 1; i <= e; ++i){
                float ratio = (float)i / (float)e;
                rawData[i] = Mathf.Cos(Mathf.PI * ratio) * 0.5f + 0.5f;
            }
            sampleTerm.SetData(rawData);
        }

        {
            shadowCamera = gameObject.GetComponent<Camera>();
            tempCamera = new GameObject().AddComponent<Camera>();
            tempCamera.enabled = false;

            colorBuffers = new RenderBuffer[shadowComponent.Length];
            for (int i = 0; i < shadowComponent.Length; ++i)
                colorBuffers[i] = shadowComponent[i].colorBuffer;
        }
    }
    void OnDestroy(){
        if(sampleTerm != null)
            sampleTerm.Release();
    }

    void Update(){
        lightTransform = GL.GetGPUProjectionMatrix(shadowCamera.projectionMatrix, true);
        lightTransform *= shadowCamera.worldToCameraMatrix;

        Shader.SetGlobalColor("_LightColor", lightColor);
    }
    void OnRenderImage(RenderTexture source, RenderTexture destination){
        tempCamera.CopyFrom(shadowCamera);
        tempCamera.SetTargetBuffers(colorBuffers, shadowComponent[0].depthBuffer);
        tempCamera.RenderWithShader(shadowCaster, "");

        Graphics.Blit(shadowComponent[0], destination);
    }
}
