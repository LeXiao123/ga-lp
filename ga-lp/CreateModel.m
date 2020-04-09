function model=CreateModel(  )
%%   设置模型参数

%   clc,clear, close all
%  载入 表1  参数
data = xlsread( 'data.xlsx' , 'sheet1') ;

model.FixedCost = data( : , 1); %  固定投资（元）
model.UnitHoldingCost =  data( : , 2) ;   % 单位管理费用（元/吨）
model.Capacity =  data( : , 3);  % 建设容量（吨）
model.Num_Center = numel(  model.FixedCost ) ; %配送中心的数目

% 载入 表2 参数
data = xlsread( 'data.xlsx' , 'sheet2') ;
model.D_Supply2Center =  data( : , 2)  ; %  工厂到 配送中心 的距离

%  载入 表3 参数
data = xlsread( 'data.xlsx' , 'sheet3') ;
model.Demand = data( : , 3 ) ; % 需求量
model.Num_Client = numel( model.Demand  ); % 需求点的数目

%  载入 表4 参数
data = xlsread( 'data.xlsx' , 'sheet4') ;
model.D_Center2Client =  data(3: end, : );

% 模型的其他参数
model.UnitDeliveryCost =  0.6 ; % 单位运输费用


%%   算法设计参数
%  编码的维度
model.nVar = model.Num_Client  + model.Num_Center - 1 ;
model.PenaltyCoefficient =   10^6 ;  %   惩罚系数





