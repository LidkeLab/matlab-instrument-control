function SyringeTimerRun(obj,event,SyringePumpObj)
fprintf('Syring pump is running..!\n')
SyringePumpObj.run;
SyringePumpObj.T_start_syringe=clock();
end