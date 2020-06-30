using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using UnityEngine;

public class ShadowConfig : MonoBehaviour{
    public Shader shadowCaster;
    [HideInInspector]
    public Matrix4x4 lightTransform;

    private Camera shadowCamera;


    void Start(){
        shadowCamera = gameObject.GetComponent<Camera>();
        shadowCamera.SetReplacementShader(shadowCaster, "");
    }

    void Update(){
        lightTransform = GL.GetGPUProjectionMatrix(shadowCamera.projectionMatrix, true);
        lightTransform *= shadowCamera.worldToCameraMatrix;
    }
}
