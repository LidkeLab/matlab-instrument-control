classdef MIC_APTPiezoXYZ < MIC_Abstract
    % Class to control the XYZ movement of Thorlabs APT piezo stage on sequential microscope
    %
    %
    %
    % REQUIREMENTS:
    % MATLAB 2014 or higher
    % MIC_Abstract class.
    % MIC_APTPiezo class.
    % Access to the mexfunctions for this APTPiezo class.
    properties
        Position;
        Max_X; % micron
        Max_Y; % micron
        Max_Z; % micron      
        PiezoX;
        PiezoY;
        PiezoZ;
        Posoffset=2; % micron
        PiezoLargeStep=0.15;   %Large Piezo step (micron)
        PiezoSmallStep=0.05 ;  %Small Piezo step (micron)
    end
    properties (SetAccess = protected)
        InstrumentName='APTPiezoXYZ' % Descriptive Instrument Name
    end
    properties
        StartGUI    % to pop up gui by creating an object for this class
    end
    
    methods
        function obj=MIC_APTPiezoXYZ()
            % Constructor for the class
            piezoX=MIC_APTPiezo('81850186','84850145');
            piezoY=MIC_APTPiezo('81850193','84850146');
            piezoZ=MIC_APTPiezo('81850176','84850203');
            piezoX.OneStepPoint=0.040425;
            piezoY.OneStepPoint=0.040425;
            piezoZ.OneStepPoint=0.04053;
            piezoX.setup;
            piezoY.setup;
            piezoZ.setup;
            obj.Max_X=double(piezoX.MaxTravel);
            obj.Max_Y=double(piezoY.MaxTravel);
            obj.Max_Z=double(piezoZ.MaxTravel);
            
            obj.PiezoX=piezoX;
            obj.PiezoY=piezoY;
            obj.PiezoZ=piezoZ;
            obj.gui()
                        
        end
        
        function delete(obj)
            % Destructor for the class
            obj.PiezoX.delete;
            obj.PiezoY.delete;
            obj.PiezoZ.delete;
        end
        
        function setPosition(obj,X)
           % Moves the stage to the desired XYZ position
           x=X(1);
           y=X(2);
           z=X(3);
           
           if x<0 || x>obj.Max_X
               error('APTPiezoXYZ:InvalidX','X position must be between 0 and %f um.',obj.Max_X);
           end
           if y<0 || y>obj.Max_Y
               error('APTPiezoXYZ:InvalidY','Y position must be between 0 and %f um.',obj.Max_Y);
           end
           if z<0 || z>obj.Max_Z
               error('APTPiezoXYZ:InvalidZ','Z position must be between 0 and %f um.',obj.Max_Z);
           end
           obj.PiezoX.setPosition(x+obj.Posoffset);
           obj.PiezoY.setPosition(y+obj.Posoffset);
           obj.PiezoZ.setPosition(z+obj.Posoffset);
           obj.Position=[x,y,z];
        end
        
        
        function center(obj)
            % Center the stage in XYZ
            X(1) = floor(obj.Max_X/2);
            X(2) = floor(obj.Max_Y/2);
            X(3) = floor(obj.Max_Z/2);
            obj.setPosition(X);
        end

        function [Attributes,Data,Children]=exportState(obj)
            % Export the object current state
            Attributes=[];
            
            % no Data is saved in this class
            Data=[];
            Children=[];
        end
        
      % ..................................................
      
        %X direction
            function movePiezoUpLargeX(obj)
            obj.PiezoX.setPosition(obj.PiezoLargeStep+obj.Posoffset);
            end
            function movePiezoDownLargeX(obj)
            obj.PiezoX.setPosition(-obj.PiezoLargeStep+obj.Posoffset);
            end
            function movePiezoUpSmallX(obj)
            obj.PiezoX.setPosition(obj.PiezoSmallStep+obj.Posoffset);
            end
            function movePiezoDownSmallX(obj)
            obj.PiezoX.setPosition(-obj.PiezoSmallStep+obj.Posoffset);
            end
        %Y direction
            function movePiezoUpLargeY(obj)
            obj.PiezoY.setPosition(obj.PiezoLargeStep+obj.Posoffset);
            end
            function movePiezoDownLargeY(obj)
            obj.PiezoY.setPosition(-obj.PiezoLargeStep+obj.Posoffset);
            end
            function movePiezoUpSmallY(obj)
            obj.PiezoY.setPosition(obj.PiezoSmallStep+obj.Posoffset);
            end
            function movePiezoDownSmallY(obj)
            obj.PiezoY.setPosition(-obj.PiezoSmallStep+obj.Posoffset);
            end
        %Z direction
            function movePiezoUpLargeZ(obj)
            obj.PiezoZ.setPosition(obj.PiezoLargeStep+obj.Posoffset);
            end
            function movePiezoDownLargeZ(obj)
            obj.PiezoZ.setPosition(-obj.PiezoLargeStep+obj.Posoffset);
            end
            function movePiezoUpSmallZ(obj)
            obj.PiezoZ.setPosition(obj.PiezoSmallStep+obj.Posoffset);
            end
            function movePiezoDownSmallZ(obj)
            obj.PiezoZ.setPosition(-obj.PiezoSmallStep+obj.Posoffset);
            end
            % End Stage Controls ____________________________
        
        
    end
    methods (Static)
        function Success=unitTest()
          
            try
                fprintf('Creating Object\n')
                APTXYZ=MIC_APTPiezoXYZ(); 
                fprintf('Centering the stage\n')
                APTXYZ.center();
                pause(.1)
                APTXYZ.exportState();
                APTXYZ.gui;
                pause(2)
                delete(guiFig);
                APTXYZ.delete;
                Success=1;
            catch
                Success=0;
            end
            
        end
    end
    
end