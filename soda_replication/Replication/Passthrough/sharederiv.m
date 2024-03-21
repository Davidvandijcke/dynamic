function [GradS,GradM]=sharederiv(Gradv,pp,Market,TALT,NDV)

global NP NCSMAX

% Compute derivative
% Price varies down columns, the probabilities across rows
GradS=zeros(TALT,TALT,NCSMAX,NP); %Matrix for dprob/dp
GradM=zeros(TALT,TALT,NCSMAX,NP); %Matrix for dprob/dp index

NDVx=repmat(NDV,[1 NCSMAX]);
NDVx=permute(NDVx,[3 2 1]);
for j1=1:TALT
    
    temp=pp(j1,:,:,:).*(1-pp(j1,:,:,:)).*Gradv(j1,:,:,:);
    temp=sum(temp,4)./NDVx; %1 x NCSMAX x NP
    GradS(j1,j1,:,:)=reshape(temp,[1,1,NCSMAX,NP]);
    GradM(j1,j1,:,:)=Market(j1,:,:);
        
    for j2=1:TALT
        
        if j2~=j1
            temp=-pp(j1,:,:,:).*pp(j2,:,:,:).*Gradv(j2,:,:,:);
            temp=sum(temp,4)./NDVx; %1 x NCSMAX x NP
            GradS(j2,j1,:,:)=reshape(temp,[1,1,NCSMAX,NP]);
            GradM(j2,j1,:,:)=Market(j2,:,:).*(Market(j1,:,:)~=0);    
        end
    end
end