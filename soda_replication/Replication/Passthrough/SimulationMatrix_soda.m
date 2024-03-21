function [Share,GradS,FGradS,Hess]=SimulationMatrix_soda(XMAT,NP,NCSMAX,X,XF,S,Group,...
    c,fhat,R,AllFirmsProducts,AllCompetitorProducts,TALT,NDV,DS)

global NDRAWS PV PVI OFirm

[Share, cprob]=marketshare_soda(X,XF,NP,NCSMAX,TALT,S,R,Group,c,fhat,NDV,DS); 

% Share is %NAMxNCSMAXxNP
% cprob is %NAMxNCSMAXxNPxNDRAWS

%Compute derivative of utility index with respect to price
[Gradv]=indexgrad_soda(XMAT,c,fhat,NP,NCSMAX,TALT,PV,[],R,Group);
% Gradv is NAMxNCSMxNPxNDRAWS

GradS=zeros(TALT,TALT,NCSMAX,NP);  %Matrix for holding firm specific
                                         %gradients
                                         %(Price,Share)
FGradS=zeros(TALT,TALT,NCSMAX,NP); %Matrix for holding all gradients
                                         %(Price,Share)

Hess=zeros(TALT,TALT,TALT,NCSMAX,NP);  %Matrix for holding second
                                                %derivatives
                                                %(Price(all),Price(firm),Share)

nFirms=size(AllFirmsProducts,1);         %Number of firms

findex=(1:nFirms)';

NO=length(OFirm);
for i=1:NO
    findex=findex(findex~=OFirm(i));
end

nInFirms=length(findex);

NDVx=repmat(NDV,[1 NCSMAX]);
NDVx=permute(NDVx,[3 2 1]);%1 x NCSMAX x NP

for ff=1:nInFirms
    
 f=findex(ff);
    
 % Index of Products owned by firm f
 FProd=AllFirmsProducts{f};
 % Number of products owned by firm f
 nProd=length(FProd);
 % Index of Products not owned by firm f
 CProd=AllCompetitorProducts{f};
 % Number of products not owned by firm f
 nComp=length(CProd);
    
 for j1=1:nProd
    
  % dprob/dp = dV/dp*prob*(1-prob)          
  % dprob[i]/dp[j] = -dV[j]/dp[j]*prob[i]*prob[j] 
   
  % d2prob/dp2 = -(dV/dp)^2*prob*(1-prob)*(1-2prob)
  % d2prob[i]/dp[i]dp[j] = 
  %        -(dV[i]/dp[i])*(dV[j]/dp[j])*prob[i]*prob[j]*(1-2prob[i])
  % d2prob[i]/dp[j]dp[k] =
  %        -2*(dV[j]/dp[j])*(dV[k]/dp[k])*prob[j]*prob[k]*prob[i]
  % d2prob[i]/dp[j]2 = -(dV[j]/dz[j])^2*prob[i]*prob[j]*(1-2prob[j])
        
  temp0=Gradv(FProd(j1),:,:,:).* cprob(FProd(j1),:,:,:) ...
       .*(1-cprob(FProd(j1),:,:,:));
  %1 x NCSMAX x NP X NDRAWS 
        
  GradS(FProd(j1),FProd(j1),:,:)=sum(temp0,4)./NDVx;
  % dprob/dp
        
  for j2=1:TALT
   if j2==FProd(j1)
   
    temp=temp0.*Gradv(FProd(j1),:,:,:).*(1-2*cprob(FProd(j1),:,:,:));
    %1 x NCSMAX x NP X NDRAWS  
    Hess(FProd(j1),FProd(j1),FProd(j1),:,:)=sum(temp,4)./NDVx; 
    % d2prob/dp2
   else
       
    temp=-Gradv(FProd(j1),:,:,:).*Gradv(j2,:,:,:).*cprob(FProd(j1),:,:,:)...
        .*cprob(j2,:,:,:).*(1-2*cprob(FProd(j1),:,:,:));
    %1 x NCSMAX x NP X NDRAWS
    
    Hess(FProd(j1),j2,FProd(j1),:,:)=sum(temp,4)./NDVx; 
    % d2prob[i]/dp[i]dp[j]
   end
  end
  
  for j2=1:nProd
  if FProd(j2)~=FProd(j1)
      
   temp0=-Gradv(FProd(j2),:,:,:).*cprob(FProd(j1),:,:,:).*...
       cprob(FProd(j2),:,:,:);
   %1 x NCSMAX x NP X NDRAWS
   
   GradS(FProd(j2),FProd(j1),:,:)=sum(temp0,4)./NDVx; 
   % dprob[i]/dp[j]
   for j3=1:TALT
    
    if j3==FProd(j1)
     
     Hess(FProd(j2),j3,FProd(j1),:,:)=Hess(j3,FProd(j2),FProd(j1),:,:);
     % d2prob[i]/dp[j]dp[i]
    elseif j3==FProd(j2)
     
     temp=temp0.*(1-2*cprob(j3,:,:,:)).*Gradv(j3,:,:,:);        
     %1 x NCSMAX x NP X NDRAWS
     
     Hess(j3,j3,FProd(j1),:,:)=sum(temp,4)./NDVx; 
     % d2prob[i]/dp[j]2
    else
     
     temp=-2.*temp0.*cprob(j3,:,:,:).*Gradv(j3,:,:,:);
     %1 x NCSMAX x NP X NDRAWS
     
     Hess(FProd(j2),j3,FProd(j1),:,:)=sum(temp,4)./NDVx; 
     % d2prob[i]/dp[j]dp[k]
    end
       
   end
  end
  end
  
  for j2=1:nComp
%    temp=-Gradv(CProd(j2),:,:,:).*cprob(FProd(j1),:,:,:).*...
%        cprob(CProd(j2),:,:,:);
   temp=-Gradv(FProd(j1),:,:,:).*cprob(FProd(j1),:,:,:).*...
       cprob(CProd(j2),:,:,:);
   %1 x NCSMAX x NP X NDRAWS
   
   FGradS(FProd(j1),CProd(j2),:,:)=sum(temp,4)./NDVx;
  end
 end
end
FGradS=FGradS+GradS;