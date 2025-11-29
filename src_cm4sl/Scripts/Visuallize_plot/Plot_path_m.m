function Plot_path_m()
figure('Name', 'Trajectory Viewer');
grid on; hold on;
xlabel('X'); ylabel('Y');
title('Real-time trajSet visualization + Collision Info');
axis equal;

while true

    cla;  % 그림 초기화
    grid on; hold on;

    % === Candidate trajectories ===
    if evalin('base','exist(''trajSet'',''var'')')
        trajSet = evalin('base','trajSet');
        for i = 1:numel(trajSet)
            plot(trajSet{i}(:,1), trajSet{i}(:,2), '-', ...
                'Color',[0.6 0.6 0.6]);
        end
    end

    % === Obstacles predicted path ===
    if evalin('base','exist(''obsVehicle_predPath'',''var'')')
        obsPath = evalin('base','obsVehicle_predPath');
        for i = 1:numel(obsPath)
            plot(obsPath{i}(:,1), obsPath{i}(:,2), 'b--'); % dotted blue
        end
    end

    % === Colliding path of Ego ===
    if evalin('base','exist(''egoVehicle_collidingPath'',''var'')')
        collPath = evalin('base','egoVehicle_collidingPath');
        for i = 1:numel(collPath)
            plot(collPath{i}(:,1), collPath{i}(:,2), 'r--');
        end
    end

    % === Optimal trajectory (highlighted green) ===
    if evalin('base','exist(''optimal_trajSet'',''var'')')
        optTraj = evalin('base','optimal_trajSet');
        if ~isempty(optTraj)
            plot(optTraj(:,1), optTraj(:,2), 'g-', ...
                'LineWidth', 2.5); % Green highlight
        end
    end


    % === Ego global position ===
    if evalin('base','exist(''ego_global_position'',''var'')')
        egoPos = evalin('base','ego_global_position');  % [x y] 또는 [x y yaw]

        x_e = egoPos(1);
        y_e = egoPos(2);

        plot(x_e, y_e, 'ro', ...
            'MarkerSize', 8, ...
            'MarkerFaceColor', 'r', ...
            'MarkerEdgeColor', 'k');

        % 원하면 yaw까지 쓸 수 있게 남겨둠 (지금은 점만 표시)
        if numel(egoPos) >= 3
            yaw_e = egoPos(3);
            L = 3;
            quiver(x_e, y_e, L*cos(yaw_e), L*sin(yaw_e), 0, 'r', 'LineWidth', 1.5);
        end
    end

    % === Obstacles initial positions ===
    if evalin('base','exist(''obsVehicle_position'',''var'')')
        obsPos = evalin('base','obsVehicle_position');   % cell, each: [x y yaw]

        for i = 1:numel(obsPos)
            p = obsPos{i};          % [x y yaw]
            x_o = p(1);
            y_o = p(2);

            % 위치 마커 (노란 네모)
            plot(x_o, y_o, 's', ...
                'MarkerSize', 7, ...
                'MarkerFaceColor', 'y', ...
                'MarkerEdgeColor', 'k');

            % 인덱스 텍스트
            text(x_o + 0.5, y_o + 0.5, sprintf('Obs %d', i), ...
                'FontSize', 9, 'Color', 'k', 'FontWeight', 'bold');


            yaw_o = p(3);
            L = 3;
            quiver(x_o, y_o, L*cos(yaw_o), L*sin(yaw_o), 0, ...
                'Color', [0 0 0], 'LineWidth', 1.2);
        end
    end

    drawnow;
    pause(0.01);

end

end