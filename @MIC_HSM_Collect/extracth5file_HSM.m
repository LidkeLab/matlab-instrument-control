% extract h5 files
%find the name of level
info=h5info('H:\Data\19-06-21\Cell1-2019-6-21-21-12-7.h5');

L=info.Groups(2).Datasets;


%new 
Data=h5read('H:\Data\19-06-21\Cell1-2019-6-21-21-12-7.h5','/Data/Data_C0001');
