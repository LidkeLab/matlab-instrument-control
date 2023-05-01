## Installation of PyDcam
- install miniconda from https://docs.conda.io/en/main/miniconda.html
- open Anaconda Powershell Prompt and create a conda environment called 'dcam'   
`conda create -n dcam python=3.9`   
- activate the conda environment   
`conda activate dcam`
- install numpy   
`pip install numpy`
- install opencv-python  
`pip install opencv-python`  
- run the following command to show the installation path of 'dcam' environment   
`conda env list`
## Run PyDcam
- turn on a Hamamatsu camera and open the MATLAB  
- run the following command in Matlab to create a PyDcam obj   
```
envpath = 'path to dcam\python.exe';
cam = MIC_PyDcam(envpath); 
```
