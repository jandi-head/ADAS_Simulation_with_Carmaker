% base workspace에서 가져오기
obsPath = evalin('base','obsVehicle_predPath');
obsPos  = evalin('base','obsVehicle_position');
T       = evalin('base','T');   % 또는 T_planning 등 네가 쓰는 변수명에 맞게 수정

% 시나리오 생성
scenario = createScenarioFromPrediction(obsPath, obsPos, T);

% 시각화
figure('Name','Driving Scenario Viewer');
plot(scenario);
axis equal
grid on

% 애니메이션
while advance(scenario)
    pause(0.05);
end
