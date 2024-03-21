function [costs]=marginalcosts(Gradv,p,pp,TALT,Price,Market,nMarket,nFirms,AllFirmsProducts,WGT,NDV)

global S OFirm NP 

[GradS,GradM]=sharederiv(Gradv,pp,Market,TALT,NDV);

costs = zeros(TALT,nMarket);

findex=(1:nFirms)';

NO=length(OFirm);
for i=1:NO
    findex=findex(findex~=OFirm(i));
end

nInFirms=length(findex);

for ff=1:nInFirms
    
    f=findex(ff);
        
    CurrentProducts=AllFirmsProducts{f};
    NProd=size(CurrentProducts,1);      
        
    for m=1:nMarket
            
         Mindex=S;
         Mindex(Market~=m)=0;

         Mdsm=squeeze(max(max(Mindex,[],1),[],2));    
         MWGT=WGT.*Mdsm';                            
            
         if NProd>1
             TempS=sum(squeeze(sum(Mindex(CurrentProducts,:,:).* ...
                 p(CurrentProducts,:,:),2)).*repmat(MWGT,[NProd 1]),2);   
   
             GradMindex=GradM==m;
             TempD=sum(squeeze(sum(GradS(CurrentProducts,CurrentProducts,:,:).* ...
                 GradMindex(CurrentProducts,CurrentProducts,:,:),3)).* ...
                 permute(repmat(MWGT,[NProd,1,NProd]),[1 3 2]),3);  
         elseif NProd==1
             TempS=sum(squeeze(sum(Mindex(CurrentProducts,:,:).* ...
                p(CurrentProducts,:,:),2))'.*MWGT);   
            
             GradMindex=GradM==m;
             TempD=sum(squeeze(sum(GradS(CurrentProducts,CurrentProducts,:,:).* ...
                 GradMindex(CurrentProducts,CurrentProducts,:,:),3))'.*MWGT);  
         end
   
         TempCost=Price(CurrentProducts,m) + TempD\TempS;
            
         costs(CurrentProducts,m)=TempCost;  
    end
end

