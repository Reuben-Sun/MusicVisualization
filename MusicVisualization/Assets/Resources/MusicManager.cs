using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MusicManager : MonoBehaviour
{
    public float resetTime = 0.5f;

    private AudioSource _audioSource;
    private float[] _musicArray;
    private readonly int _musicArrayShaderId = Shader.PropertyToID("_MusicArray");
    private readonly int _sumNumShaderId = Shader.PropertyToID("_SumNum");
    private float curTime;
    private int sampleNum = 256;
    void Start()
    {
        _audioSource = GetComponent<AudioSource>();
        _musicArray = new float[sampleNum];
        curTime = 0;
    }

    
    void Update()
    {
        if (_audioSource == null)
        {
            return;
        }

        curTime += Time.deltaTime;
        if (curTime > resetTime)
        {
            _audioSource.GetSpectrumData(_musicArray, 0, FFTWindow.BlackmanHarris);
            float sum = 0;
            foreach (var f in _musicArray)
            {
                sum += f;
            }
            Shader.SetGlobalFloat(_sumNumShaderId, (float)sum/_musicArray.Length);
            Shader.SetGlobalFloatArray(_musicArrayShaderId, _musicArray);
            curTime = 0;
        }
        
    }
}
