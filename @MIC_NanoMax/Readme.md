# MIC_NanoMax: Matlab instrument class for NanoMax stage
Runs both MIC_TCubePiezo and MIC_StepperMotor.
Example: obj=MIC_NanoMax();
Functions: setup_Stage_Piezo, setup_Stage_Stepper, exportState
REQUIREMENTS:
MIC_Abstract.m
MIC_TCubePiezo.m
MIC_StepperMotor.m
MATLAB software version R2016b or later
CITATION: Sandeep Pallikuth, Lidkelab, 2017 & Sajjad Khan, Lidkelab, 2021.
# gui_NanoMax: is the graphical user interface (GUI) for MIC_NanoMax.m
Prevent opening more than one figure for same instrument
if ishandle(obj.GuiFigureStage)
guiFig = obj.GuiFigureStage;
figure(obj.GuiFigureStage);
return
end
Open figure
