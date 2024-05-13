classdef MIC_StepperMotor < MIC_Abstract
    % Class to control Benchtop stepper motor.
    % ## Description
    % This device might also be cotroled using the kinesis software.
    % This class give you access to some of the functions in the long list
    % of functions to control this device.
    % To change the setting user need to use the kinesis software, except
    % the jog step size.
    % Please check if you have the following setting on the kinesis
    % software. Open the kinesis software and on all the windows for each
    % motor you should have this setting:
    % Setting, Device Startup Setting, klick on the botton in the Select
    % Actuator Type box, from the popup menu in the top select the device
    % that you wish to control (it could be either HS NanoMax 300 X Axis, 
    % HS NanoMax 300 Y Axis or HS NanoMax 300 Z Axis), then OK and Save.
    % ## Constructor
    % Example: M = MIC_StepperMotor(70850323)
    % Functions: constructor(), goHome(), getPosition(), getStatus(), 
    %            getStatus(), moveJog(), moveToPosition(), setJogStep()
    %            getJogStep(), closeSBC(), delete(), exportState()
    %
    % ## REQUIREMENTS:
    %   MATLAB 2014 or higher
    %   Kinesis software from thorlabs
    %   MIC_Abstract class.
    %   Access to the mexfunctions for this device. (kinesis_SBC_function).
    %
    % CITATION: Mohamadreza Fazel, Lidkelab, 2017.
    
    properties (SetAccess=protected)
        InstrumentName = 'StepperMotor'; %instrument name
    end
    properties
       StartGUI; %starting gui
       SerialN;  %Serial Number, which can be found on the back of the controller.
       % for SEQ controller: 70850323
    end
    
    methods
        function obj = MIC_StepperMotor(SerialNum)
            %constructor start the communications with all three motors and
            %also sets some of the class properties.
            addpath('C:\Users\lidkelab\Documents\MATLAB\matlab-instrument-control\mex64');
            obj=obj@MIC_Abstract(~nargout);
            obj.SerialN = SerialNum;
            Kinesis_SBC_Open(obj.SerialN);
        end
        function goHome(obj,Channel)
            %the stage goes to the origin for the given channel (axis).
            Kinesis_SBC_Home(obj.SerialN,Channel);
        end
        function Position = getPosition(obj,Channel)
            %gives the current position of the stage for the given channel
            %(axis).
            Position = Kinesis_SBC_GetPosition(obj.SerialN,Channel);
        end
        function Status = getStatus(obj,Channel)
           Status = Kinesis_SBC_GetStatusBits(obj.SerialN,Channel); 
        end
        function moveJog(obj,Channel,Direction)
            %move by the given step size in the given direction
            Pos = obj.getPosition(Channel);
            if Pos > 4
               error('It cannot go further than 4mm.'); 
            end
            if Pos < -4
               error('It cannot go further than -4mm.'); 
            end
            Kinesis_SBC_MoveJog(obj.SerialN,Channel,Direction);
        end
        function moveToPosition(obj,Channel,Pos)
           %move to the given position. Note that the range of position is [-4 mm, 4 mm]. 
           Kinesis_SBC_MoveToPosition(obj.SerialN,Channel,Pos); 
        end
        function setJogStep(obj,Channel,Step)
            %setting the step size that you wish to have when you call
            %movejog function. The unit of the step size is in mm.
            if Step > 4
               error('JogStep cannot be larger than 4 mm.') 
            end
            if Step < 0
               error('JogStep cannot be negative.') 
            end
            Kinesis_SBC_SetJogStepSize(obj.SerialN,Channel,Step);
        end
        function Step = getJogStep(obj,Channel)
            %gives the current jog step size in mm.
            Step = Kinesis_SBC_GetJogStepSize(obj.SerialN,Channel);
        end
        function closeSBC(obj)
            %called inside the delete function to close the communication ports for all the motors.
            Kinesis_SBC_Close(obj.SerialN);
            Kinesis_LD_Close(obj.SerialN);
        end
        function delete(obj)
            obj.closeSBC();
            delete(obj.GuiFigure);
            clear obj;
        end
        function [Attributes, Data, Children] = exportState(obj)
            %exportState() method to export current instrument state.
            Attributes.InstrumentName = obj.InstrumentName;
            Attributes.SerialN = obj.SerialN;
            Data = [];
            Children = [];
        end
    end
    methods (Static)
        function unitTest()
            %unittest() function to test the class.
            TestObj = MIC_StepperMotor('70850323');
            fprintf('The comunication with the motors have been successfully initialzed.\n');
            TestObj.goHome(1);
            pause(10);
            Pos = TestObj.getPosition(1);
            if Pos ~= 0
                error('Sorry, goHome() function does not work properly.\n');
            end
            fprintf('goHome and getPosition functions were tested successfully, and channel 1 is home.\n');
            TestObj.moveToPosition(1,1);
            pause(10);
            Pos = TestObj.getPosition(1);
            if Pos ~= 1
                error('Sorry, moveToPosition() function does not work properly.\n');
            end
            fprintf('moveToPosition() function has been successfully tested.\n');
            TestObj.setJogStep(1,1);
            TestObj.getJogStep(1);
            if TestObj.Step ~= 1
               error('Sorry, setJogStep() does not work properly.\n'); 
            end
            fprintf('setJogStep() and getJogStep() functions were tested successfully.\n');
            TestObj.moveJog(1,-1);
            pause(3);
            Pos=TestObj.getPosition(1);
            if Pos ~= 0
                error('Sorry, moveJog() function does not work properly.\n');
            end
            fprintf('moveJog() function was tested successfully.\n');
            TestObj.delete();
            fprintf('The communication port has been closed.\n');
            fprintf('Congrats, the class works well :)\n');
        end
    end
    
end
