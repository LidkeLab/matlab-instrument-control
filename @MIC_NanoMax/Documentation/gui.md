
gui_NanoMax: is the graphical user interface (GUI) for MIC_NanoMax.m

Prevent opening more than one figure for same instrument
if ishandle(obj.GuiFigureStage)
guiFig = obj.GuiFigureStage;
figure(obj.GuiFigureStage);
return
end

Open figure
