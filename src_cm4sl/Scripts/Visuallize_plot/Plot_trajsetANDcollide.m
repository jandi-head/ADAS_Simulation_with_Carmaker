figure('Name', 'Trajectory Viewer');
grid on; hold on;
xlabel('X'); ylabel('Y');
title('Real-time trajSet visualization + Collision Info');
axis equal;

while true

    cla;  % 그림 초기화
    grid on; hold on;

    % ====== Legend용 dummy handle들 먼저 생성 (항상 같은 Legend) ======
    h_cand = plot(nan, nan, '-',  'Color',[0.6 0.6 0.6]);         % Candidate Trajectories
    h_opt  = plot(nan, nan, 'g-', 'LineWidth', 2.5);              % Optimal Trajectory
    h_pred = plot(nan, nan, 'b--');                               % Obstacle Predicted Path
    h_coll = plot(nan, nan, 'r--', 'LineWidth', 2);               % Collision Path

    legendHandles = [h_cand, h_opt, h_pred, h_coll];
    legendNames   = {'Candidate Trajectories', ...
                     'Optimal Trajectory', ...
                     'Obstacle Predicted Path', ...
                     'Collision Path'};

    % ====== 실제 데이터 시각화 ======

    % === Candidate trajectories: Gray Lines ===
    if evalin('base','exist(''trajSet'',''var'')')
        trajSet = evalin('base','trajSet');
        if ~isempty(trajSet)
            for i = 1:numel(trajSet)
                plot(trajSet{i}(:,1), trajSet{i}(:,2), '-', ...
                     'Color',[0.6 0.6 0.6]);
            end
        end
    end

    % === Optimal trajectory: Green Bold Line ===
    if evalin('base','exist(''optimal_trajSet'',''var'')')
        optTraj = evalin('base','optimal_trajSet');
        if ~isempty(optTraj)
            plot(optTraj(:,1), optTraj(:,2), 'g-', 'LineWidth', 2.5);
        end
    end

    % === Obstacle Predicted Path: Blue Dashed ===
    if evalin('base','exist(''obsVehicle_predPath'',''var'')')
        obsPath = evalin('base','obsVehicle_predPath');
        if ~isempty(obsPath)
            for i = 1:numel(obsPath)
                plot(obsPath{i}(:,1), obsPath{i}(:,2), 'b--');
            end
        end
    end

    % === Collision Path of Ego: Red Dashed ===
    if evalin('base','exist(''egoVehicle_collidingPath'',''var'')')
        collPath = evalin('base','egoVehicle_collidingPath');
        if ~isempty(collPath)
            for i = 1:numel(collPath)
                plot(collPath{i}(:,1), collPath{i}(:,2), 'r--', 'LineWidth', 2);
            end
        end
    end

    % === Ego Vehicle: Black Rectangle (with yaw) ===
    ego_exists = evalin('base','exist(''ego_global_position'',''var'')');
    ego_has_yaw = false;
    if ego_exists
        egoPos = evalin('base','ego_global_position');
        if numel(egoPos) >= 3
            x_e   = egoPos(1);
            y_e   = egoPos(2);
            yaw_e = egoPos(3);
            ego_has_yaw = true;

            drawCar(x_e, y_e, yaw_e, 4.0, 1.8, 'k');
        end
    end

    % === Obstacle Vehicles: Blue Rectangles (with yaw) ===
    if evalin('base','exist(''obsVehicle_position'',''var'')')
        obsPos = evalin('base','obsVehicle_position');
        if ~isempty(obsPos)
            for i = 1:numel(obsPos)
                p = obsPos{i};  % [x, y, yaw]
                drawCar(p(1), p(2), p(3), 4.0, 1.8, 'b');
                text(p(1)+1, p(2)+1, sprintf('Obs %d',i), ...
                    'FontSize', 8, 'Color', 'k');
            end
        end
    end


    %     ego 진행방향 기준 전방 70, 후방 50, 측면 50 보이도록 설정 ===
    if ego_exists && ego_has_yaw
        range_forward  = 50;   % ego 앞쪽 70m
        range_backward = 30;   % ego 뒤쪽 50m
        range_side     = 30;   % ego 좌우 50m

        % Ego 로컬 좌표계에서의 시야 박스 코너 (x: 앞/뒤, y: 좌/우)
        % 앞쪽 +x, 왼쪽 +y라고 가정
        local_corners = [ range_forward,  range_side;   % 앞-좌
            range_forward, -range_side;   % 앞-우
            -range_backward, -range_side;  % 뒤-우
            -range_backward,  range_side]';% 뒤-좌   (2x4)

        % 회전 행렬 (월드 좌표로 변환)
        R = [cos(yaw_e), -sin(yaw_e);
            sin(yaw_e),  cos(yaw_e)];

        global_corners = R * local_corners + [x_e; y_e];

        x_min = min(global_corners(1,:));
        x_max = max(global_corners(1,:));
        y_min = min(global_corners(2,:));
        y_max = max(global_corners(2,:));

        xlim([x_min, x_max]);
        ylim([y_min, y_max]);
    end

    % === Legend ===
    legend(legendHandles, legendNames, 'Location','best');

    drawnow;
    pause(0.01);

end


% ===== Car Drawing Function =====
function drawCar(x, y, yaw, L, W, color)
    % x, y  : 차량 중심 좌표
    % yaw   : 차량 진행 방향 (rad)
    % L, W  : 차량 길이, 폭
    % color : 외곽선 색

    hl = L/2;  % half length
    hw = W/2;  % half width

    % 로컬 차량 좌표계에서의 코너 (앞이 +x 방향)
    corners = [ hl,  hw;
                hl, -hw;
               -hl, -hw;
               -hl,  hw]';

    % 회전 행렬
    R = [cos(yaw) -sin(yaw);
         sin(yaw)  cos(yaw)];

    % Global 좌표계로 변환
    corners_global = R * corners + [x; y];

    % 사각형 닫기
    corners_global = [corners_global, corners_global(:,1)];

    % 차량 외곽선 그리기
    plot(corners_global(1,:), corners_global(2,:), ...
         'Color', color, 'LineWidth', 1.5);
end
