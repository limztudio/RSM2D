using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Plane : MonoBehaviour{
    public ShadowConfig shadowConfig;
    public Texture shadowMap0;

    private Material curMaterial;

    void Start(){
        curMaterial = gameObject.GetComponent<Renderer>().material;
    }

    void Update(){
        Matrix4x4 transform = shadowConfig.lightTransform;
        transform *= gameObject.transform.localToWorldMatrix;

        curMaterial.SetTexture("_ShadowMap0", shadowMap0);
        curMaterial.SetMatrix("_TransformShadow", transform);
    }
}
