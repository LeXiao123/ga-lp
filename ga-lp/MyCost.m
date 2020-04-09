function [ Fitnessval , sol]=MyCost(q,model)
% %% ����Ŀ�꺯��ֵ

% clc,clear
% model=CreateModel() ;
% q=randperm( model.nVar ) ;

%%  ȷ���ָ����
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
empty_rourte.CenterID = [ ]; % ������������   �ı��
empty_rourte.CenterCapacity = [ ]; %  ������������  ������
empty_rourte.ClientSet = [ ]; % ������������  �� �ͻ���������
empty_rourte.Num_Client = [ ]; % ������������  �� �ͻ�����
empty_rourte.DemandSum  = [ ]; % ������������  �� ������
empty_rourte.QuantityViolation = [ ]; % ������������  �� ������  ���������Ĳ���
empty_rourte.Cost1= [ ]; % ������������  ��  һ������ɱ�
empty_rourte.Cost2= [ ]; % ������������  ��  ��������ɱ�
empty_rourte.Cost3= [ ]; % ������������  ��  ������ã�
empty_rourte.Cost4= [ ]; %  ������������  ��  �������

Detailed_Schedule =  repmat( empty_rourte , model.Num_Center   , 1 ) ;  %ÿ����·�ľ�������

for     t =  1: model.Num_Center
    
    % ������������   �ı��
    Detailed_Schedule( t ).CenterID =  t ;
    %  ������������  ������
    Detailed_Schedule( t ).CenterCapacity =model.Capacity( t );
    
    % ������������  �� �ͻ���������
    temp =     L{ t } ;
    Detailed_Schedule( t ).ClientSet =   temp ;
    
    % ������������  �� �ͻ�����
    Detailed_Schedule( t ).Num_Client =numel(   temp);
    
    if numel(   temp) ==0
        continue;
    end
    
    % ������������  �� ������
    Detailed_Schedule( t ).DemandSum  = sum( model.Demand( temp ) );
    
    % ������������  �� ������  ���������Ĳ���
    Detailed_Schedule( t ).QuantityViolation = max( 0 , ...
        (  Detailed_Schedule( t ).DemandSum -   Detailed_Schedule( t ).CenterCapacity   )  );
    
    % ������������  ��  һ������ɱ�
    Detailed_Schedule( t ).Cost1=   model.UnitDeliveryCost  * ...
        Detailed_Schedule( t ).DemandSum * model.D_Supply2Center( t );
    
    
    Detailed_Schedule( t ).Cost2=  model.UnitDeliveryCost  * ...
        sum(   [  model.Demand( temp ) ]    .*  model.D_Center2Client(  t , temp )   ); % ������������  ��  ��������ɱ�
    
    % ������������  ��  ������ã�
    Detailed_Schedule( t ).Cost3=   model.UnitHoldingCost(t)/2 *...
        sum(  sqrt(  model.Demand( temp )   )   ) ;
    Detailed_Schedule( t ).Cost4=model.FixedCost( t ); %  ������������  ��  �������
    
    
end

Detailed_Schedule( find( [ Detailed_Schedule.Num_Client ] ==0 ) ) = [ ] ;
CenterSelected =  [  Detailed_Schedule.CenterID ]; % ��ѡ����������

%%  Ŀ�꺯������
F = sum(   [    Detailed_Schedule.Cost1 ]  ) + ...
    sum(   [    Detailed_Schedule.Cost2 ]  ) + ...
    sum(   [    Detailed_Schedule.Cost3 ]  ) + ...
    sum(   [    Detailed_Schedule.Cost4 ]  ) ;

%    ��Ӧ��ֵ����
Violation =  sum(   [  Detailed_Schedule.QuantityViolation   ]) ;  %����������

Fitnessval =  F  + model.PenaltyCoefficient * Violation ; %��Ӧ��ֵ
IsFeasible = ( Violation==0 );

%% ��Ľṹ��

sol.Fitnessval = Fitnessval ; %��Ӧ��ֵ
sol.IsFeasible  = IsFeasible  ; % 0-1  �߼�����   ��ʾ �� �Ƿ����
sol.F=F;  %  Ŀ�꺯
sol.CenterSelected =CenterSelected ; % ��ѡ����������
sol.Detailed_Schedule =Detailed_Schedule; % mÿ�������ĵ�������
sol.Violation  = Violation ; % Υ��Լ�������

