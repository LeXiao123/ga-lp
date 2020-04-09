function i=RouletteWheelSelection(P)
%%  ÂÖÅÌ¶Ä¹æÔò
r=rand;

c=cumsum(P);

i=find(r<=c,1,'first');
