function [R,J]=simulationfun_soda(FreePrice,XMAT,S,Group,NP,NCSMAX,iPrice,Price,...
    c,fhat,R,AllFirmsProducts,AllCompetitorProducts,costs,TALT,WGT,...
    tau,SV,NDV,DS)

global alt PV PVI FProd

NROWS=size(XMAT,1);

Price(iPrice)=FreePrice;  %Update price vector

ops=XMAT(:,alt);       
PSIM=zeros(NROWS,1);    
for k=1:TALT
    PSIM(ops==k)=Price(k);
end

inside=ones(length(XMAT),1);
if isempty(FProd)==0
 inside=ones(length(XMAT),1);
 NO=length(FProd);
 for i=1:NO
     inside(XMAT(:,alt)==FProd(i))=0;
 end
end

PSIM(inside==1)=PSIM(inside==1)+tau*XMAT(inside==1,SV);   

[uXMAT]=updatedata(XMAT,PSIM,PV,PVI);

[X, XF]=simulationdata(NP,NCSMAX,uXMAT,TALT);

[Share,GradS,FGradS,Hess]=SimulationMatrix_soda(uXMAT,NP,NCSMAX,X,XF,S,Group,...
    c,fhat,R,AllFirmsProducts,AllCompetitorProducts,TALT,NDV,DS);

margins=reshape(repmat((Price-costs)',[TALT*TALT 1])...
    ,[TALT TALT TALT]);

Weight=permute(repmat(WGT', [1 TALT TALT TALT NCSMAX]),[2 3 4 5 1]);

SHess=sum(sum(Hess.*Weight,4),5);

temp=sum(margins.*SHess,3);

Weight=permute(repmat(WGT', [1 TALT TALT NCSMAX]),[2 3 4 1]);

MShare=sum(sum(Share.*permute(repmat(WGT',[1 TALT NCSMAX]),[2 3 1]),2),3);

%TALTx1 vector of FOC residuals
R=MShare+sum(sum(GradS.*Weight,3),4)*(Price-costs);
R=R(iPrice);

%NALTMAXxNALTMAX Jacobian for FOCS
J=sum(sum(FGradS.*Weight,3),4)'+sum(sum(GradS.*Weight,3),4)+temp;
J=J(iPrice,iPrice);