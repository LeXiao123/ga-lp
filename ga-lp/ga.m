% Real-Coded Genetic Algorithm in MATLAB  for location problem
clc; clear; close all;
feature jit off

%% Problem Definition  问题定义
model=CreateModel() ;

CostFunction=@(x)MyCost( x, model ) ;        % Cost Function  目标函数

nVar = model.nVar ;            % Number of Decision Variables   变量个数

%% GA Parameters

MaxIt= 300;      % Maximum Number of Iterations  算法最大迭代次数

nPop= 20;        % Population Size (Swarm Size)   种群数目

pc=0.7;                 % Crossover Percentage  交叉概率
nc=2*round(pc*nPop/2);  % Number of Offsprings (also Parnets)   交叉所得  新个体的数目

pm=0.3;                 % Mutation Percentage   变异概率
nm=round(pm*nPop);      % Number of Mutants  变异所得  新个体的数目

beta=8; % Selection Pressure  轮盘赌选择参数

RunTime = 10 ; %  循环迭代的次数

% 多次循环最优解
empty_BestSolSet.BestCost = [ ];
empty_BestSolSet.BestSol = [ ];
empty_BestSolSet.BestSolValue= [  ];

BestSolSet = repmat( empty_BestSolSet  , RunTime , 1 );
%% Initialization  初始化
for  runtimeindex = 1 : RunTime
    disp( [ '第'   num2str( runtimeindex ) '次循环'  ] )
    
    %% Initialization  初始化
    rand('seed' , sum( clock) ) ;
    
    % 构建初始化种群
    empty_individual.Position= [ ];
    empty_individual.Cost= [ ];
    empty_individual.sol = [  ];
    pop=repmat(empty_individual,nPop,1);
    
    for i=1:nPop
        
        % Initialize Position  初始化编码
        pop(i).Position= randperm(  nVar );
        
        % Evaluation  计算目标函数值
        [   pop(i).Cost   ,     pop(i).sol ] =  CostFunction(pop(i).Position);
        
    end
    
    % Sort Population   排序
    Costs=[pop.Cost];
    [Costs, SortOrder]=sort(Costs);
    pop=pop(SortOrder);
    
    % Store Best Solution  记录最优解
    BestSol=pop(1);
    
    % Array to Hold Best Cost Values   记录每代的最优解
    BestCost=zeros(MaxIt,1);
    
    % Store Cost  最裂解的目标函数值
    WorstCost=pop(end).Cost;
    
    %% Main Loop  GA算法主循环
    
    
    for it=1:MaxIt
        
        % Calculate Selection Probabilities  轮盘赌选择概率
        P=exp(-beta*Costs/WorstCost);
        P=P/sum(P);
        
        
        % Crossover  交叉操作
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
        
        
        % Mutation   变异操作
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
        
        % Store Best Solution Ever Found   更新当前最优解
        BestSol=pop(1);
        
        
        % Store Best Cost Ever Found
        BestCost(it)=BestSol.Cost;
        if  BestSol.sol.IsFeasible
            % Show Iteration Information  显示迭代信息
            disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))   '*** ' ]);
        else
            disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
        end
    end
    
    % 多次运行的解的情况统计
    BestSolSet(  runtimeindex  ).BestCost = BestCost ;
    BestSolSet(  runtimeindex  ).BestSol = BestSol ;
    BestSolSet(  runtimeindex  ).BestSolValue = BestSol.Cost ;
    
end

%%  选取多次运行的最优结果
[  ~ ,   indxval ]   = min( [ BestSolSet.BestSolValue])   ;

BestSol =      BestSolSet( indxval ).BestSol  ;
BestCost  =      BestSolSet(  indxval).BestCost ;
%%  Results

% 目标函数值收敛图
figure
set(gcf,'NumberTitle', 'off', 'Name', '算法收敛曲线');
set(gcf,'Color',[1 1 1]);
%plot(BestCost,'LineWidth',2);
plot(BestCost,'LineWidth',2);
xlabel('迭代次数','fontsize',13 );
ylabel('评价函数值','fontsize',13 );
box off ; grid off;


