function i=RouletteWheelSelection(P)
%%  ���̶Ĺ���
r=rand;

c=cumsum(P);

i=find(r<=c,1,'first');
