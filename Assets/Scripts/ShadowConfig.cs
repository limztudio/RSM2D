using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using UnityEngine;

public class ShadowConfig : MonoBehaviour{
    public RenderTexture[] shadowComponent;
    public Shader shadowCaster;
    [HideInInspector]
    public Matrix4x4 lightTransform;

    private Camera shadowCamera;
    private Camera tempCamera;

    private RenderBuffer[] colorBuffers;


    void Start(){
        shadowCamera = gameObject.GetComponent<Camera>();
        tempCamera = new GameObject().AddComponent<Camera>();
        tempCamera.enabled = false;

        colorBuffers = new RenderBuffer[shadowComponent.Length];
        for(int i = 0; i < shadowComponent.Length; ++i)
            colorBuffers[i] = shadowComponent[i].colorBuffer;
    }

    void Update(){
        lightTransform = GL.GetGPUProjectionMatrix(shadowCamera.projectionMatrix, true);
        lightTransform *= shadowCamera.worldToCameraMatrix;
    }
    void OnRenderImage(RenderTexture source, RenderTexture destination){
        tempCamera.CopyFrom(shadowCamera);
        tempCamera.SetTargetBuffers(colorBuffers, shadowComponent[0].depthBuffer);
        tempCamera.RenderWithShader(shadowCaster, "");

        Graphics.Blit(shadowComponent[0], destination);
    }
}
