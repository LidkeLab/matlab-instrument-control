

function Calibration(obj)
%create save folder and filenames
if ~exist(obj.SaveDir,'dir');mkdir(obj.SaveDir);end
timenow=clock;
s=['-' num2str(timenow(1)) '-' num2str(timenow(2))  '-' num2str(timenow(3)) '-' num2str(timenow(4)) '-' num2str(timenow(5)) '-' num2str(round(timenow(6)))];
obj.DataDir = obj.SaveDir;

obj.collect_clibImage();
out = obj.clibImage;
[~, idx1(1)] = max(out(200,370:445));
idx1(1)=idx1(1)+370;
[~, idx1(2)] = max(out(200,290:346));
idx1(2)=idx1(2)+290;
[~, idx1(3)] = max(out(200,223:285));
idx1(3)=idx1(3)+223;
[~, idx1(4)] = max(out(200,142:154));
idx1(4)=idx1(4)+142;
[~, idx1(5)] = max(out(200,122:140));
idx1(5)=idx1(5)+122;
[~, idx1(6)] = max(out(200,86:97));
idx1(6)=idx1(6)+86;
[~, idx1(7)] = max(out(200,76:84));
idx1(7)=idx1(7)+76;
idx1

peakWv = [544 586 611.5 696.5 706.7 763.5 811.5];

pfit = polyfit(idx1,peakWv,3);
wv = polyval(pfit,1:length(out));
figure;plot(idx1,peakWv,'*')

SaveDate=datestr(timenow, 'yyyy-mm-dd-HH-MM-SS');
save([H.SaveDir 'Wavelength_Calibration_Data-' SaveDate],'out','time','wv','idx1','peakWv','pfit');
end


