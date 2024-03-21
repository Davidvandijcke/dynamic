function [p, pp]=marketshare_soda(X,XF,NP,NCSMAX,TALT,S,R,Group,c,fhat,NDV,DS)

global NV NF NDRAWS 

p=zeros(TALT,NCSMAX,NP); %NAMxNCSMAXxNP

% Xms  is a TALTxNCSMAXxNVxNP 
% XFms is a TALTxNCSMAXxNFxNP 

v=zeros(TALT,NCSMAX,NP,NDRAWS);

if NF > 0
 vf=zeros(TALT,NCSMAX,NP);
 for i=1:R
    ff=reshape(fhat(i,:),1,1,NF,1);  %1x1xNFx1 matrix 
    ff=repmat(ff,[TALT,NCSMAX,1,NP]); %NAMxNCSMxNFxNP matrix 
    vff=reshape(sum(XF.*ff,3),TALT,NCSMAX,NP);  %NAMxNCSMxNP 
    vf(Group==i)=vff(Group==i);
 end
else
    vf=zeros(TALT,NCSMAX,NP);
end
 vf=repmat(vf,[1,1,1,NDRAWS]); %NAMxNCSMxNPxNMEM matrix 

if NV >0 
    cc=reshape(c,1,1,NV,NP,NDRAWS); %1x1xNVxNPxNMEM 
    cc=repmat(cc,[TALT,NCSMAX,1,1,1]); %NAMxNCSMxNVxNPxNMEM 
    vr=(repmat(X,[1,1,1,1,NDRAWS]).*cc); %NAMxNCSMxNVxNPxNMEM 
    vr=reshape(sum(vr,3),TALT,NCSMAX,NP,NDRAWS); %NAMxNCSMxNPxNMEM 
    v=vr+vf; %NAMxNCSMxNPxNMEM 
else
    v=vf;
end

DS=repmat(DS,[1 1 NCSMAX TALT]);
DS=permute(DS,[4 3 1 2]);
v=exp(v);  %NAMxNCSMxNPxNMEM
v(DS==0)=0;
v(isinf(v))=10.^20;  
v=v.*repmat(S,[1,1,1,NDRAWS]);  
sv=sum(v,1);
pp=v./repmat(sv,[TALT,1,1,1]); %NAMxNCSMAXxNPxNMEM 
pp(isnan(pp))=0; 
spp=sum(pp,4);   

p=p+spp; %Sum over NTAKES

NDVx=repmat(NDV,[1 TALT NCSMAX]);
NDVx=permute(NDVx,[2 3 1]);

p=p./NDVx; %NAMxNCSMAXxNP
