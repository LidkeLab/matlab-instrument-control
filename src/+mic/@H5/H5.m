classdef H5 
% mic.H5 Class: mic.H5 A collection of static methods for working with HDF5 files 
% 
% ## Description q
% The `mic.H5` class is designed for handling HDF5 file operations in MATLAB. 
%  It includes static methods to create files, write data asynchronously, and manage data groups within HDF5 files. 
%  This class leverages MATLAB's capabilities to interact with large datasets efficiently.
% 
% ## Requirements
% - MATLAB 2011a or later
% - `h5Write_Async.mex64` for asynchronous writing operations
% 
% ## Usage Example
% The following example demonstrates how to create an HDF5 file, add a group, and write data asynchronously:
% ```matlab
% % Define the file and data
% File = 'TestFile.h5';
% data = uint16(2^16 * rand(256, 512, 10));
% 
% % Create a new HDF5 file
% mic.H5.createFile(File);
% 
% % Create a new group within the file
% mic.H5.createGroup(File, 'Data');
% 
% % Write data asynchronously to the 'Data' group
% mic.H5.writeAsync_uint16(File, 'Data', 'data1', data);
% 
% % Display the structure of the HDF5 file
% h5disp(File);
% ```
% ## Key Functions
% - **`createFile(File)`:** Creates an empty HDF5 file. If the file already exists, it issues a warning rather than overwriting the existing file.
% - **`createGroup(File, Group)`:** Adds a new group to an existing HDF5 file. If the group already exists, the creation process is skipped to avoid duplication.
% - **`writeAsync_uint16(File, Group, DataName, Data)`:** Initiates an asynchronous data writing process to a specified group within an HDF5 file. This method allows MATLAB to continue executing other commands while data is being written in the background.
% - **`readH5File(FilePath, GroupName)`:** Retrieves data from a specified group within an HDF5 file. This function would be implemented to allow reading of complex datasets stored within the file system.
% ### CITATION: David James Schodt (LidkeLab, 2018)
    
    
    properties
    end
    
    methods
    end
    
    methods (Static)
        
        function createFile(File)
            %Creates an empty H5 file. 
            if exist(File,'file')
                warning('File: %s Already Exists!',File);
            else
                fid=H5F.create(File);
                H5F.close(fid);
            end
        end
        
        function writeAsync_uint16(File,Group,DataName,Data,CompressionLevel)
            %Async write to an existing group in an existing H5 file. 
            %Returns immediately to MATLAB
            if nargin<5
                CompressionLevel=5;
            end
            IsBusy=H5Write_Async(File,Group,DataName,Data,CompressionLevel);
            while IsBusy
                pause(0.05);
                IsBusy=H5Write_Async(File,Group,DataName,Data,CompressionLevel);
            end
        end
        
        function saveWait()
            %wait for Async save. 
            tic
            IsBusy=H5Write_Async();
            while IsBusy
                pause(0.05);
                IsBusy=H5Write_Async();
            end         
            t1 = toc;
            fprintf('H5 Save Time: %.2f s \n', t1)
        end
        
        function createGroup(File,Group)
            %Create a new group in an existing H5 file. 
            plist = 'H5P_DEFAULT';
            fid = H5F.open(File,'H5F_ACC_RDWR',plist);
            gid = H5G.open(fid,'/');
            try %try to open, if so it must exist
                %H5G.open(gid,Group);
                if ~H5L.exists(fid,Group,plist)
                    H5G.create(gid,Group,plist,plist,plist);
                end
            catch ME
                %H5G.create(gid,Group,plist,plist,plist);
                fprintf('Error encountered: %s/n', ME.message);
            end
            
            H5G.close(gid);
            H5F.close(fid);
            fid = H5F.open(File,'H5F_ACC_RDWR',plist);
            gid = H5G.open(fid,Group);
            H5G.close(gid);
            H5F.close(fid);
        end
        
        [H5Structure] = readH5File(FilePath, GroupName)
        
    end
    
end

