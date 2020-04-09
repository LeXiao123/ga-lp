function q =Mutate( p )
%%  变异操作
index  = randi(3)  ;
a = randperm( numel( p ) , 3 );
switch index
    case 1
        % Swap  交换
        q=DoSwap(p,a(2),a(3));
        
    case 2
        % Reversion  翻转
        q=DoReversion(p,a(2),a(3));
        
    case 3
        % Insertion  插入
        q=DoInsertion(p,a(2),a(3));
        
end


function q=DoSwap(p,i1,i2)
%% 2-opt operation
q=p;
q([i1 i2])=p([i2 i1]);



function q=DoReversion(p,i1,i2)
%% Reverse operation
q=p;
if i1<i2
    q(i1:i2)=p(i2:-1:i1);
else
    q(i1:-1:i2)=p(i2:i1);
end



function q=DoInsertion(p,i1,i2)
%% insert operation
if i1<i2
    q=p([1:i1-1 i1+1:i2 i1 i2+1:end]);
else
    q=p([1:i2 i1 i2+1:i1-1 i1+1:end]);
end
