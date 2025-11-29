figure('Name', 'Trajectory Viewer');
grid on; hold on;
xlabel('X [m]'); ylabel('Y [m]');
title('Real-time trajSet visualization + Collision Info');
axis equal;

% 보기 좋게 약간 padding 준 고정 축 (필요에 따라 조정)
xlim([-20 80]);
ylim([-20 80]);

while true

    cla;  % 그림 초기화
    grid on; hold on;
    
    % === Obstacles predicted path ===
    if evalin('base','exist(''obsVehicle_predPath'',''var'')')
        obsPath = evalin('base','obsVehicle_predPath');
        
        if ~isempty(obsPath)
            nObs = numel(obsPath);
            colors = lines(nObs);  % 장애물마다 다른 색
            
            for i = 1:nObs
                path = obsPath{i};
                if isempty(path), continue; end
                
                % path: [N x 2] = [X, Y]
                X = path(:,1);
                Y = path(:,2);
                
                % 선 + 일부 점에 마커
                plot(X, Y, '-', ...
                    'Color', colors(i,:), ...
                    'LineWidth', 2);           % 선 두께 키움
                
                idx = 1:5:numel(X);            % 5 step마다 마커 찍기
                plot(X(idx), Y(idx), 'o', ...
                    'Color', colors(i,:), ...
                    'MarkerSize', 4, ...
                    'MarkerFaceColor', colors(i,:));
                
                % 장애물 번호 라벨 (마지막 점 근처)
                text(X(end), Y(end), sprintf(' Obs %d', i), ...
                    'Color', colors(i,:), ...
                    'FontSize', 10, ...
                    'FontWeight', 'bold');
            end
        end
    end

    % === (옵션) 충돌한 ego trajectory 시각화 ===
    if evalin('base','exist(''egoVehicle_collidingPath'',''var'')')
        egoCollide = evalin('base','egoVehicle_collidingPath');
        
        if ~isempty(egoCollide)
            for k = 1:numel(egoCollide)
                egoPath = egoCollide{k};
                if isempty(egoPath), continue; end
                
                Xe = egoPath(:,1);
                Ye = egoPath(:,2);
                
                plot(Xe, Ye, 'r-', 'LineWidth', 2.5);       % 빨간 굵은 선
                plot(Xe(end), Ye(end), 'rx', 'MarkerSize', 10, 'LineWidth', 2);
            end
        end
    end
    
    % 범례 (있을 때만)
    % legend는 매 루프마다 새로 만들면 깜빡일 수 있어서 필요하면 핸들 모아서 따로 구성해도 됨
    
    drawnow;
    pause(0.05);
end
