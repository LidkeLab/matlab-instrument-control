%Test for MIC_SPTCollect

%Check each Instrument individually with MIC_ classes:
% Andor Camera
A=MIC_AndorCamera();
A.gui
A.delete();

IRCam=MIC_ThorlabsIR();
IRCam.gui
IRCam.delete();

