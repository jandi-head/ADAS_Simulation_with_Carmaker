figure('Name', 'Trajectory Viewer');
grid on; hold on;
xlabel('X'); ylabel('Y');
title('Real-time trajSet visualization + Collision Info');
axis equal;

while true

    cla;  % 그림 초기화

    % === Candidate trajectories ===
    if evalin('base','exist(''trajSet'',''var'')')
        trajSet = evalin('base','trajSet');
        for i = 1:numel(trajSet)
            plot(trajSet{i}(:,1), trajSet{i}(:,2), '-', ...
                 'Color',[0.6 0.6 0.6]);
            hold on;
        end
    end

    % === Obstacles predicted path ===

        obsPath = evalin('base','obsVehicle_predPath');
        for i = 1:numel(obsPath)
            plot(obsPath{i}(:,1), obsPath{i}(:,2), 'b--'); % dotted blue
            hold on;
        end


    % === Colliding path of Ego ===

        collPath = evalin('base','egoVehicle_collidingPath');
        for i = 1:numel(collPath)
            plot(collPath{i}(:,1), collPath{i}(:,2), 'r-');
            hold on;
        end

    
    drawnow;
    pause(0.01);

end
