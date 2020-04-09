% Real-Coded Genetic Algorithm in MATLAB  for location problem
clc; clear; close all;
feature jit off

%% Problem Definition  ���ⶨ��
model=CreateModel() ;

CostFunction=@(x)MyCost( x, model ) ;        % Cost Function  Ŀ�꺯��

nVar = model.nVar ;            % Number of Decision Variables   ��������

%% GA Parameters

MaxIt= 300;      % Maximum Number of Iterations  �㷨����������

nPop= 20;        % Population Size (Swarm Size)   ��Ⱥ��Ŀ

pc=0.7;                 % Crossover Percentage  �������
nc=2*round(pc*nPop/2);  % Number of Offsprings (also Parnets)   ��������  �¸������Ŀ

pm=0.3;                 % Mutation Percentage   �������
nm=round(pm*nPop);      % Number of Mutants  ��������  �¸������Ŀ

beta=8; % Selection Pressure  ���̶�ѡ�����

RunTime = 10 ; %  ѭ�������Ĵ���

% ���ѭ�����Ž�
empty_BestSolSet.BestCost = [ ];
empty_BestSolSet.BestSol = [ ];
empty_BestSolSet.BestSolValue= [  ];

BestSolSet = repmat( empty_BestSolSet  , RunTime , 1 );
%% Initialization  ��ʼ��
for  runtimeindex = 1 : RunTime
    disp( [ '��'   num2str( runtimeindex ) '��ѭ��'  ] )
    
    %% Initialization  ��ʼ��
    rand('seed' , sum( clock) ) ;
    
    % ������ʼ����Ⱥ
    empty_individual.Position= [ ];
    empty_individual.Cost= [ ];
    empty_individual.sol = [  ];
    pop=repmat(empty_individual,nPop,1);
    
    for i=1:nPop
        
        % Initialize Position  ��ʼ������
        pop(i).Position= randperm(  nVar );
        
        % Evaluation  ����Ŀ�꺯��ֵ
        [   pop(i).Cost   ,     pop(i).sol ] =  CostFunction(pop(i).Position);
        
    end
    
    % Sort Population   ����
    Costs=[pop.Cost];
    [Costs, SortOrder]=sort(Costs);
    pop=pop(SortOrder);
    
    % Store Best Solution  ��¼���Ž�
    BestSol=pop(1);
    
    % Array to Hold Best Cost Values   ��¼ÿ�������Ž�
    BestCost=zeros(MaxIt,1);
    
    % Store Cost  ���ѽ��Ŀ�꺯��ֵ
    WorstCost=pop(end).Cost;
    
    %% Main Loop  GA�㷨��ѭ��
    
    
    for it=1:MaxIt
        
        % Calculate Selection Probabilities  ���̶�ѡ�����
        P=exp(-beta*Costs/WorstCost);
        P=P/sum(P);
        
        
        % Crossover  �������
        popc=repmat(empty_individual,nc/2,2);
        for k=1:nc/2
            
            
            i1=RouletteWheelSelection(P);
            i2=RouletteWheelSelection(P);
            
            % Select Parents
            p1=pop(i1);
            p2=pop(i2);
            
            % Apply Crossover
            [popc(k,1).Position, popc(k,2).Position]=  Crossover(p1.Position,p2.Position, nVar );
            
            % Evaluate Offsprings
            [     popc(k,1).Cost ,    popc(k,1).sol ] =CostFunction(popc(k,1).Position);
            [  popc(k,2).Cost  ,  popc(k,2).sol ] =CostFunction(popc(k,2).Position);
            
        end
        popc=popc(:);
        
        
        % Mutation   �������
        popm=repmat(empty_individual,nm,1);
        for k=1:nm
            
            % Select Parent
            i=randi([1 nPop]);
            p=pop(i);
            
            % Apply Mutation
            popm(k).Position=Mutate(p.Position );
            
            % Evaluate Mutant
            [  popm(k).Cost  ,   popm(k).sol ]  =CostFunction(popm(k).Position);
            
        end
        
        % Create Merged Population
        pop=[pop
            popc
            popm]; %#ok
        
        % Sort Population
        Costs=[pop.Cost];
        [Costs, SortOrder]=sort(Costs);
        pop=pop(SortOrder);
        
        % Update Worst Cost
        WorstCost=max(WorstCost,pop(end).Cost);
        
        % Truncation
        pop=pop(1:nPop);
        Costs=Costs(1:nPop);
        
        % Store Best Solution Ever Found   ���µ�ǰ���Ž�
        BestSol=pop(1);
        
        
        % Store Best Cost Ever Found
        BestCost(it)=BestSol.Cost;
        if  BestSol.sol.IsFeasible
            % Show Iteration Information  ��ʾ������Ϣ
            disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))   '*** ' ]);
        else
            disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
        end
    end
    
    % ������еĽ�����ͳ��
    BestSolSet(  runtimeindex  ).BestCost = BestCost ;
    BestSolSet(  runtimeindex  ).BestSol = BestSol ;
    BestSolSet(  runtimeindex  ).BestSolValue = BestSol.Cost ;
    
end

%%  ѡȡ������е����Ž��
[  ~ ,   indxval ]   = min( [ BestSolSet.BestSolValue])   ;

BestSol =      BestSolSet( indxval ).BestSol  ;
BestCost  =      BestSolSet(  indxval).BestCost ;
%%  Results

% Ŀ�꺯��ֵ����ͼ
figure
set(gcf,'NumberTitle', 'off', 'Name', '�㷨��������');
set(gcf,'Color',[1 1 1]);
%plot(BestCost,'LineWidth',2);
plot(BestCost,'LineWidth',2);
xlabel('��������','fontsize',13 );
ylabel('���ۺ���ֵ','fontsize',13 );
box off ; grid off;


