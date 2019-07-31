% extract h5 files


%The directory o the data
DataDir = 'H:\Data\19-07-30';
%The directory to save chunks
SaveDir = 'H:\Data\19-07-30';
%The name of the file
FileName = 'Cell1-2019-7-30-16-40-55';


%find the name of level
info=h5info('H:\Data\19-07-30\Cell1-2019-7-30-16-40-55.h5');

L=info.Groups(2).Datasets;


%new 
% Data=h5read('H:\Data\19-07-14\Cell3-2019-7-14-20-26-43.h5','/Data/Data_C0120');

nn = size((info.Groups(2).Datasets),1);
for ii=1:nn
dataName= L(ii).Name;  
s=strcat('/Data/',dataName);
Data=h5read('H:\Data\19-07-30\Cell1-2019-7-30-16-40-55.h5',s);

sequence = sum(Data,3);
sequence = squeeze(sequence);
SaveName = cat(2,FileName,sprintf('_#%g',ii));
save(fullfile(SaveDir,SaveName),'sequence','-v7.3')
end