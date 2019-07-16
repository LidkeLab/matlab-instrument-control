% extract h5 files
%find the name of level
info=h5info('H:\Data\19-07-14\Cell2-2019-7-14-15-1-23.h5');

L=info.Groups(2).Datasets;


%new 
Data=h5read('H:\Data\19-07-14\Cell3-2019-7-14-20-26-43.h5','/Data/Data_C0120');

nn = size((info.Groups(2).Datasets),1);
for ii=1:nn
    for jj  
Data=h5read('H:\Data\19-07-14\Cell3-2019-7-14-20-26-43.h5','/Data/Data_C0120');
sequence = sum(Data,3);

end