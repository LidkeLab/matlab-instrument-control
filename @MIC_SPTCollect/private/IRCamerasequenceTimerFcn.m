function IRCamerasequenceTimerFcn(obj,event,IRCamera)
fprintf('IR starts!!!!\n')
% IRCamera.tIR_start=clock();
% tic
                IRCamera.start_sequence();
                fprintf('IR is done !!\n')
IRCamera.tIR_end=clock();
% IRCamera.t_period=toc
% end 
end