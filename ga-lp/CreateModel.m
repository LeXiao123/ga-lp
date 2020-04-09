function model=CreateModel(  )
%%   ����ģ�Ͳ���

%   clc,clear, close all
%  ���� ��1  ����
data = xlsread( 'data.xlsx' , 'sheet1') ;

model.FixedCost = data( : , 1); %  �̶�Ͷ�ʣ�Ԫ��
model.UnitHoldingCost =  data( : , 2) ;   % ��λ������ã�Ԫ/�֣�
model.Capacity =  data( : , 3);  % �����������֣�
model.Num_Center = numel(  model.FixedCost ) ; %�������ĵ���Ŀ

% ���� ��2 ����
data = xlsread( 'data.xlsx' , 'sheet2') ;
model.D_Supply2Center =  data( : , 2)  ; %  ������ �������� �ľ���

%  ���� ��3 ����
data = xlsread( 'data.xlsx' , 'sheet3') ;
model.Demand = data( : , 3 ) ; % ������
model.Num_Client = numel( model.Demand  ); % ��������Ŀ

%  ���� ��4 ����
data = xlsread( 'data.xlsx' , 'sheet4') ;
model.D_Center2Client =  data(3: end, : );

% ģ�͵���������
model.UnitDeliveryCost =  0.6 ; % ��λ�������


%%   �㷨��Ʋ���
%  �����ά��
model.nVar = model.Num_Client  + model.Num_Center - 1 ;
model.PenaltyCoefficient =   10^6 ;  %   �ͷ�ϵ��





