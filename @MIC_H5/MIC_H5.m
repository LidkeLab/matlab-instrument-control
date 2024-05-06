classdef MIC_H5 
    %MIC_H5 A collection of static methods for working with HDF5 files
    %   See individual methods for details.
    %   doc MIC_H5
    % EXAMPLE:  create a new file, and new group and write data
    %
    %File='TestFile.h5';
    %data=uint16(2^16*rand(256,512,10));
    %MIC_H5.createFile(File)
    %MIC_H5.createGroup(File,'Data')
    %MIC_H5.writeAsync_uint16(File,'Data','data1',data)
    %h5disp(File)
    %
    % REQUIRES:
    %   h5Write_Async.mex64
    %   MATLAB 2011a or newer
    
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
        
        function writeAsync_uint16(File,Group,DataName,Data)
            %Async write to an existing group in an existing H5 file. 
            %Returns immediately to MATLAB
            IsBusy=H5Write_Async(File,Group,DataName,Data);
            while IsBusy
                pause(0.05);
                IsBusy=H5Write_Async(File,Group,DataName,Data);
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

