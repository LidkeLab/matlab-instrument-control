% extract h5 files


%The directory o the data
DataDir = 'H:\Data\19-08-24';
%The directory to save chunks
SaveDir = 'H:\Data\19-08-24';
%The name of the file
FileName = 'Cell1-2019-8-24-18-50-16';


%find the name of level
info=h5info('H:\Data\19-08-24\Cell1-2019-8-24-18-50-16.h5');

L=info.Groups(2).Datasets;


%new 
% Data=h5read('H:\Data\19-08-15\Im1_488_im3_520-2019-8-15-19-13-2.h5','/Data/Data_C0120');

nn = size((info.Groups(2).Datasets),1);
for ii=1:nn
dataName= L(ii).Name;  
s=strcat('/Data/',dataName);
Data=h5read('H:\Data\19-08-24\Cell1-2019-8-24-18-50-16.h5',s);

% sequence = sum(Data,3);
sequence = sum(Data(:,:,5:100,:),3); %spectral adjustment 
sequence = squeeze(sequence);
SaveName = cat(2,FileName,sprintf('_#%g',ii));
save(fullfile(SaveDir,SaveName),'sequence','-v7.3')
end

