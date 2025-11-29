figure;
hPlot = plot(0,0,'b.-');  % 빈 plot 핸들 생성
grid on;
xlabel('D (lateral)');
ylabel('S (longitudinal)');
title('Path in D-S Plane');
axis equal;

while true
    % logData 존재 확인
    if evalin('base','exist(''logData'',''var'')')
        logData = evalin('base','logData');
        
        if ~isempty(logData)
            s = logData(:,1);
            d = logData(:,2);
            
            set(hPlot, 'XData', d, 'YData', s);
            drawnow;  % 실시간 갱신
        end
    end
    
    pause(0.05);  % 20Hz 업데이트
end
