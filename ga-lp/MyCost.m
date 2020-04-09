function [ Fitnessval , sol]=MyCost(q,model)
% %% 计算目标函数值

% clc,clear
% model=CreateModel() ;
% q=randperm( model.nVar ) ;

%%  确定分割符号
DelPos=find(  q> model.Num_Client );

% Determine Start and End of Machines Job Sequence
From=[0 DelPos]+1;
To=[DelPos   model.nVar+1  ]-1;

% Create Jobs List
L = cell( model.Num_Center , 1  );
for j=1 :  model.Num_Center
    
    L{j }= sort( q(From(j):To(j)) );
    
end

%%
empty_rourte.CenterID = [ ]; % 各个配送中心   的编号
empty_rourte.CenterCapacity = [ ]; %  各个配送中心  的能力
empty_rourte.ClientSet = [ ]; % 各个配送中心  的 客户服务序列
empty_rourte.Num_Client = [ ]; % 各个配送中心  的 客户总数
empty_rourte.DemandSum  = [ ]; % 各个配送中心  的 处理量
empty_rourte.QuantityViolation = [ ]; % 各个配送中心  的 处理量  超过能力的部分
empty_rourte.Cost1= [ ]; % 各个配送中心  的  一级运输成本
empty_rourte.Cost2= [ ]; % 各个配送中心  的  二级运输成本
empty_rourte.Cost3= [ ]; % 各个配送中心  的  管理费用；
empty_rourte.Cost4= [ ]; %  各个配送中心  的  建设费用

Detailed_Schedule =  repmat( empty_rourte , model.Num_Center   , 1 ) ;  %每条线路的具体情形

for     t =  1: model.Num_Center
    
    % 各个配送中心   的编号
    Detailed_Schedule( t ).CenterID =  t ;
    %  各个配送中心  的能力
    Detailed_Schedule( t ).CenterCapacity =model.Capacity( t );
    
    % 各个配送中心  的 客户服务序列
    temp =     L{ t } ;
    Detailed_Schedule( t ).ClientSet =   temp ;
    
    % 各个配送中心  的 客户总数
    Detailed_Schedule( t ).Num_Client =numel(   temp);
    
    if numel(   temp) ==0
        continue;
    end
    
    % 各个配送中心  的 处理量
    Detailed_Schedule( t ).DemandSum  = sum( model.Demand( temp ) );
    
    % 各个配送中心  的 处理量  超过能力的部分
    Detailed_Schedule( t ).QuantityViolation = max( 0 , ...
        (  Detailed_Schedule( t ).DemandSum -   Detailed_Schedule( t ).CenterCapacity   )  );
    
    % 各个配送中心  的  一级运输成本
    Detailed_Schedule( t ).Cost1=   model.UnitDeliveryCost  * ...
        Detailed_Schedule( t ).DemandSum * model.D_Supply2Center( t );
    
    
    Detailed_Schedule( t ).Cost2=  model.UnitDeliveryCost  * ...
        sum(   [  model.Demand( temp ) ]    .*  model.D_Center2Client(  t , temp )   ); % 各个配送中心  的  二级运输成本
    
    % 各个配送中心  的  管理费用；
    Detailed_Schedule( t ).Cost3=   model.UnitHoldingCost(t)/2 *...
        sum(  sqrt(  model.Demand( temp )   )   ) ;
    Detailed_Schedule( t ).Cost4=model.FixedCost( t ); %  各个配送中心  的  建设费用
    
    
end

Detailed_Schedule( find( [ Detailed_Schedule.Num_Client ] ==0 ) ) = [ ] ;
CenterSelected =  [  Detailed_Schedule.CenterID ]; % 所选的配送中心

%%  目标函数计算
F = sum(   [    Detailed_Schedule.Cost1 ]  ) + ...
    sum(   [    Detailed_Schedule.Cost2 ]  ) + ...
    sum(   [    Detailed_Schedule.Cost3 ]  ) + ...
    sum(   [    Detailed_Schedule.Cost4 ]  ) ;

%    适应度值计算
Violation =  sum(   [  Detailed_Schedule.QuantityViolation   ]) ;  %能力超载量

Fitnessval =  F  + model.PenaltyCoefficient * Violation ; %适应度值
IsFeasible = ( Violation==0 );

%% 解的结构体

sol.Fitnessval = Fitnessval ; %适应度值
sol.IsFeasible  = IsFeasible  ; % 0-1  逻辑变量   表示 解 是否可行
sol.F=F;  %  目标函
sol.CenterSelected =CenterSelected ; % 所选的配送中心
sol.Detailed_Schedule =Detailed_Schedule; % m每个配中心的相关情况
sol.Violation  = Violation ; % 违反约束的情况

