function[aggshare]=aggregatemarketshare_soda(p,TALT,Market,nMarket,WGT,NP)

global S 

aggshare=zeros(TALT,nMarket);

for m=1:nMarket
    
    Mindex=S;
    Mindex(Market~=m)=0;
    
    Mdsm=zeros(1,NP);
    T=max(Mindex,[],1); %1xNCSMxNP
    T=max(T,[],2); %1x1xNP
    Mdsm(1,:)=T(1,1,:);
    
    MWGT=(WGT.*Mdsm)./sum(WGT.*Mdsm);           %1xNP market weights
    
    Mnc=zeros(1,NP);
    T=max(Mindex,[],1); %1xNCSMxNP
    T=sum(T,2); %1x1xNP
    Mnc(1,:)=T(1,1,:);                    
    
    T=squeeze(sum(Mindex.*p,2));  %TALTxNP
    
    T2=T./repmat(Mnc,[TALT 1]); %TALTxNP
    T2(isnan(T2)==1)=0;

    aggshare(:,m)=sum(T2.*repmat(MWGT,[TALT 1]),2);   
    %TALT x 1 matrix of summed probs   
end