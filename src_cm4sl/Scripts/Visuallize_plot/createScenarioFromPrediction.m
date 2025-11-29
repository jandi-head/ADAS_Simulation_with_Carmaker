function scenario = createScenarioFromPrediction(obsVehicle_predPath, obsVehicle_position, T)
% createScenarioFromPrediction
%   obsVehicle_predPath : {Nobs x 1} cell, 각 셀은 [N x 2] = [X Y]
%   obsVehicle_position : {Nobs x 1} cell, 각 셀은 [X_init, Y_init, yaw_init]
%   T                   : 전체 예측 시간 [s] (checkCollide에서 쓰는 T 그대로 넣어주면 됨)
%
%   반환값:
%     scenario          : drivingScenario 객체
%
%   필요:
%     Automated Driving Toolbox

    scenario = drivingScenario;

    car_length = 4.5;
    car_width  = 2.0;
    car_height = 1.5;

    nObs = numel(obsVehicle_predPath);

    for i = 1:nObs
        path = obsVehicle_predPath{i};   % [N x 2]
        p0   = obsVehicle_position{i};   % [X_init, Y_init, yaw_init]

        if isempty(path) || isempty(p0)
            continue;
        end

        % --- waypoints 구성 (Z=0으로 가정) ---
        N = size(path,1);
        waypoints = [path, zeros(N,1)];  % [x y z]

        % --- 평균 속도로 trajectory 설정 (대충 T 안에 다 가도록) ---
        diffXY     = diff(path,1,1);                   % [N-1 x 2]
        segDist    = sqrt(sum(diffXY.^2,2));           % 각 segment 길이
        totalDist  = sum(segDist);                     % 전체 거리
        avgSpeed   = max(0.1, totalDist / max(T,0.1)); % [m/s], 0으로 나누기 방지

        % --- vehicle actor 생성 ---
        veh = vehicle(scenario, ...
            'ClassID', 1, ...
            'Length',  car_length, ...
            'Width',   car_width, ...
            'Height',  car_height, ...
            'Position', [p0(1), p0(2), 0], ...
            'Yaw',     rad2deg(p0(3)));  % drivingScenario는 deg 기준

        % --- trajectory 부여 ---
        trajectory(veh, waypoints, avgSpeed);
    end
end
