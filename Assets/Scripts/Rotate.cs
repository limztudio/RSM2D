using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour{
    public float speed = 1.0f;

    void Start(){
        
    }

    void Update(){
        transform.Rotate(0.0f, 0.0f, speed);
    }
}
