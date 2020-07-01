using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Plane : MonoBehaviour{
    public ShadowConfig shadowConfig;
    public Texture[] shadowComponents;

    private Material curMaterial;

    void Start(){
        curMaterial = gameObject.GetComponent<Renderer>().material;

        curMaterial.SetInt("_SampleCount", shadowConfig.sampleTerm.count);
        curMaterial.SetBuffer("_SampleTerm", shadowConfig.sampleTerm);
    }

    void Update(){
        Matrix4x4 transform = shadowConfig.lightTransform;
        transform *= gameObject.transform.localToWorldMatrix;

        for(int i = 0; i < shadowComponents.Length; ++i)
            curMaterial.SetTexture("_ShadowComponent" + i.ToString(), shadowComponents[i]);

        curMaterial.SetMatrix("_TransformShadow", transform);
    }
}
