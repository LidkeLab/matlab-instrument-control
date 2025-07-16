classdef KuriosFilter < mic.abstract

    properties (SetAccess=protected)
        InstrumentName = 'KuriosFilter';
        Serial;
        FilterType;
        BWModes;
    end

    properties
        Wavelength;
        BandwidthMode;
        OutputMode;
        MaxWavelength;
        MinWavelength;
        StartGUI;
    end

    methods
        
        function obj = KuriosFilter(SerialPort)
            s = serialportfind(Tag=SerialPort);
            if isempty(s)
                s = serialport(SerialPort,115200,Tag=SerialPort);
            else
                delete(s);
                s = serialport(SerialPort,115200,Tag=SerialPort);
            end
            
            configureTerminator(s,"CR")
            obj.Serial=s;

            obj.send("*IDN?")
            response = readline(s);
            disp("Opening: " + response);
            
            obj.send("ST?")
            eval(readline(s)+';')
            disp("Initializing...")
            while ST == 0
                obj.send("ST?")
                pause(1)
                eval(readline(s)+';');
            end
            disp("Warm up to 40 degree.")
            while ST == 1
                obj.send("ST?")
                pause(1)
                eval(readline(s)+';')
            end
            if ST == 2
                disp("Ready")
            end


            obj.send("OH?")

            response = readline(s);
            eval(response+';');
            OH_bit = bitget(OH,16:-1:1,'int16');
            if OH_bit(8)==1
                obj.FilterType = 'Visible';
            elseif OH_bit(7)==1
                obj.FilterType = 'NIR';
            end
            
            BWModes = {};
            if OH_bit(16) == 1
                BWModes = [BWModes,'BLACK'];
            end
            if OH_bit(15) == 1
                BWModes = cat(BWModes,'WIDE');
            end
            if OH_bit(14) == 1
                BWModes = cat(BWModes,'MEDIUM');
            end
            if OH_bit(13) == 1
                BWModes = [BWModes,'NARROW'];
            end
            obj.BWModes = BWModes;

            %set output mode to manual
            obj.send("OM=1")
            obj.OutputMode = "Manual";

            %set Bandwidth mode to narrow
            obj.send("BW=8")
            obj.BandwidthMode = "NARROW";

            %get wavelength range
            obj.send("SP?")
            %pause(1)
            eval(readline(s)+';');
            %pause(2)
            eval(readline(s)+';');
            obj.MaxWavelength=WLmax;
            obj.MinWavelength=WLmin;

            %get current wavelength
            obj.send("WL?")
            %pause(0.1)
            eval(readline(s)+';')
            obj.Wavelength = WL;

        end


        function send(obj,Message)
            flush(obj.Serial)
            writeline(obj.Serial,Message)
            pause(0.1)
        end

        function setWavelength(obj,Wavelength)
            Wavelength = round(Wavelength);
            if Wavelength<obj.MinWavelength
                warning("Wavelength is too small, set to %d nm", obj.MinWavelength)
                Wavelength = obj.MinWavelength;
            end
            
            if Wavelength>obj.MaxWavelength
                warning("Wavelength is too large, set to %d nm", obj.MaxWavelength)
                Wavelength = obj.MaxWavelength;
            end

            obj.send("WL="+num2str(Wavelength))
            obj.Wavelength = Wavelength;
        end

        function setBWmode(obj,BWmode)
            if ~ismember(BWmode,obj.BWModes)
                error('mic.KuriosFilter: setBWmode: available bandwidth modes are %s',strjoin(obj.BWModes,','))
            end
             switch BWmode
                 case "BLACK"
                     obj.send("BW=1")
                 case "WIDE"
                     obj.send("BW=2")
                 case "MEDIUM"
                     obj.send("BW=4")
                 case "NARROW"
                     obj.send("BW=8")
             end
             obj.BandwidthMode = BWmode;
        end

        function delete(obj)
            flush(obj.Serial)
            delete(obj.Serial)
        end

        function  [Attributes,Data,Children]=exportState(obj)
            % Export the object current state
            Attributes.Wavelength=obj.Wavelength;
            Attributes.BandwidthMode=obj.BandwidthMode;
            % no Data is saved in this class
            Data=[];
            Children=[];
        end
    end

        methods (Static=true)
        function funcTest(SerialPort)
            % Unit test of object functionality
            
            if nargin<1
                error('mic.KuriosFilter::SerialPort must be defined')
            end
            
            %Creating an Object and Testing setPower, on, off
            fprintf('Creating Object\n')
            TF=mic.KuriosFilter(SerialPort);
            fprintf('Set to minimum wavelength\n')
            TF.setWavelength(TF.MinWavelength);
            fprintf('Delete Object\n')
            %Test Destructor
            delete(TF);
            clear TF;

        end
    end

end