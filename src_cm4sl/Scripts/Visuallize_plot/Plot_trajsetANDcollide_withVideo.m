%% Trajectory Viewer + Video Recording (V7 Clean)

fig = figure('Name','Trajectory Video Recorder', ...
             'Position',[100 100 1920 1080]);  % 픽셀 크기 고정

axis equal; grid on; hold on;

title('Real-time Path planning visualization');

% --- VideoWriter 설정 ---
outputVideo = VideoWriter('path_planning_visualization_FHD_4.mp4','MPEG-4');
outputVideo.FrameRate = 10;
open(outputVideo);

% --- 해상도 고정 (Paper settings) ---
fig.PaperUnits    = 'points';
fig.PaperPosition = [0 0 1920 1080];
fig.PaperSize     = [1920 1080];

for frame = 1:120

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

    % --- Candidate trajectories: Gray Lines ---
    if evalin('base','exist(''trajSet'',''var'')')
        trajSet = evalin('base','trajSet');
        if ~isempty(trajSet)
            for i = 1:numel(trajSet)
                plot(trajSet{i}(:,1), trajSet{i}(:,2), '-', ...
                     'Color',[0.6 0.6 0.6]);
            end
        end
    end

    % --- Optimal trajectory: Green Bold Line ---
    if evalin('base','exist(''optimal_trajSet'',''var'')')
        optTraj = evalin('base','optimal_trajSet');
        if ~isempty(optTraj)
            plot(optTraj(:,1), optTraj(:,2), 'g-', 'LineWidth', 2.5);
        end
    end

    % --- Obstacle Predicted Path: Blue Dashed ---
    if evalin('base','exist(''obsVehicle_predPath'',''var'')')
        obsPath = evalin('base','obsVehicle_predPath');
        if ~isempty(obsPath)
            for i = 1:numel(obsPath)
                plot(obsPath{i}(:,1), obsPath{i}(:,2), 'b--');
            end
        end
    end

    % --- Collision Path of Ego: Red Dashed ---
    if evalin('base','exist(''egoVehicle_collidingPath'',''var'')')
        collPath = evalin('base','egoVehicle_collidingPath');
        if ~isempty(collPath)
            for i = 1:numel(collPath)
                plot(collPath{i}(:,1), collPath{i}(:,2), 'r--', 'LineWidth', 2);
            end
        end
    end

    % --- Ego Vehicle: Black Rectangle (with yaw) ---
    ego_exists  = evalin('base','exist(''ego_global_position'',''var'')');
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

    % --- Obstacle Vehicles: Blue Rectangles (with yaw) ---
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

    % --- 카메라 / 축 제어: ego 기준 전방/후방/측면 시야 박스 설정 ---
    if ego_exists && ego_has_yaw
        range_forward  = 50;   % ego 앞쪽 50m
        range_backward = 30;   % ego 뒤쪽 30m
        range_side     = 30;   % ego 좌우 30m

        % Ego 로컬 좌표계에서의 시야 박스 코너 (x: 앞/뒤, y: 좌/우)
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

    % --- Legend ---
    legend(legendHandles, legendNames, 'Location','best');

    % --- 화면 업데이트 & 동영상 프레임 저장 ---
    drawnow;
    frameData = getframe(fig);          % 현재 figure 캡처
    writeVideo(outputVideo, frameData); % 비디오에 프레임 추가

    pause(0.01);  % 너무 빡세지 않게 약간 딜레이 (필요 없으면 줄여도 됨)

end

close(outputVideo);
disp('Video saved: trajectory_view.mp4');


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
