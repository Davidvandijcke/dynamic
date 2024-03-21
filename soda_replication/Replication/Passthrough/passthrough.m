global NV NF NDRAWS 
global IDV IDF WGT S
global dsm dcs alt mar asymmetry 
global NCSMAX NP NROWS FProd
global PV PVI OFirm 

DataFile=fullfile(DataDir,'groupXmatrix.raw');
PriceFile=fullfile(DataDir,'prices.raw');
DrawFile=fullfile(DataDir,'drawnumber.raw');
CoefFile1=fullfile(DataDir,'groupXCoefdraws.raw');
CoefFile2=fullfile(DataDir,'groupFixedcoef.raw');
WGTFile=fullfile(DataDir,'weights.raw');
FirmDataFile=fullfile(DataDir,'ownership_data.raw');

dsm=1;
dcs=2;
alt=3;
mar=4;

IDV=[5 0;
     6 0;
     7 0];
IDF=(8:54)';

PV=5;
PVI=[];
SV=55;

asymmetry=1;
R=4;

%OProd=[];
OFirm=5;
tau=.25;

NDRAWS=250;

XMAT=load(DataFile);
NDV=load(DrawFile);

HetCoefRaw=load(CoefFile1);
FixCoef=load(CoefFile2);

WGT=load(WGTFile)';

NP=max(XMAT(:,dsm));
TALT=max(XMAT(:,alt));
NROWS=length(XMAT);

NV=size(IDV,1);
NF=length(IDF);

HetCoef=zeros(NV,NP,NDRAWS);
DS=zeros(NP,NDRAWS);
cp=HetCoefRaw(:,1);
dr=HetCoefRaw(:,2:end);
for n=1:NP  %loop over people
  xx=dr(cp == n,:); 
  xn=NDV(n);
  HetCoef(:,n,1:xn)=xx'; 
  DS(n,1:xn)=1;  
end

[NCSMAX,S,Market,Group]=IMatrix(TALT,NP,XMAT);
nMarket=max(XMAT(:,mar));  %Number of markets

%%%%MARGINAL COSTS

[X, XF]=simulationdata(NP,NCSMAX,XMAT,TALT);

[p, pp]=marketshare_soda(X,XF,NP,NCSMAX,TALT,S,R,Group,HetCoef,FixCoef,NDV,DS); 

[aggshare]=aggregatemarketshare_soda(p,TALT,Market,nMarket,WGT,NP);

[Gradv]=indexgrad_soda(XMAT,HetCoef,FixCoef,NP,NCSMAX,TALT,PV,[],R,Group);

%Load ownership martix
OM=load(FirmDataFile);
ProdCode=OM(:,1);
BrandCode=OM(:,2);
FirmCode=OM(:,3);
clear OM

nFirms=max(FirmCode);
AllFirmsProducts=cell(nFirms,1);
AllCompetitorProducts=cell(nFirms,1);
AllFirmsBrands=cell(nFirms,1);
for f=1:nFirms
    AllFirmsProducts{f}=ProdCode(FirmCode==f);
    AllCompetitorProducts{f}=ProdCode(FirmCode~=f);
    AllFirmsBrands{f}=BrandCode(FirmCode==f);
end

Mark=XMAT(:,mar);  %Market data column
Options=XMAT(:,alt);  %Column of options

PriceData=load(PriceFile);
Price=PriceData(:,1);
Fixedind=PriceData(:,2);
t=(1:TALT)';
FProd=t(Fixedind==1)';
clear PriceData t Fixedind

Simvar=load(SimvarFile);

NEWPRICE=zeros(size(XMAT,1),1);
for i=1:TALT
   for m=1:nMarket
       NEWPRICE(Options==i & Mark==m)=Price(i,m);
   end
end
clear ops mark
[XMAT]=updatedata(XMAT,NEWPRICE,PV,[]);
clear NEWPRICE

NEWV=zeros(size(XMAT,1),1);
for i=1:TALT
   for m=1:nMarket
       NEWV(Options==i & Mark==m)=Simvar(i,m);
   end
end
clear ops mark
[XMAT]=updatedata(XMAT,NEWV,SV,[]);
clear NEWV

%elas=1;
[PGradS,GradM]=sharederiv(Gradv,pp,Market,TALT,NDV);

[costs]=marginalcosts(Gradv,p,pp,TALT,Price,Market,nMarket,nFirms,AllFirmsProducts,WGT,NDV);

iPrice=(1:TALT)';    %Index of prices to be optimised

if isempty(FProd)==0
 NO=length(FProd);
 for i=1:NO
    iPrice=iPrice(iPrice~=FProd(i));
 end
end
   

% Set up matrices for equilibrium output for each market

ProducerPrice=Price;   
HHConsumerPrice=XMAT(:,PV);     
HHExitFlag=zeros(NROWS,1);     
Residual=zeros(TALT,nMarket);  
ExitFlag=zeros(TALT,nMarket);   
Output=cell(nMarket,1);         

FsolveOptions=optimset('DerivativeCheck','off', ...
                       'Display','iter',        ...
                       'Jacobian','on',        ...
                       'MaxFunEvals', 10,      ...
                       'MaxIter',10,           ...
                       'TolFun', 1e-12,          ...
                       'TolX',   1e-12);                  
for m=1:nMarket
    Index=Mark==m;  

    XMATc=XMAT(Index,:);
      
    Pc=XMATc(:,dsm);      
    Pc2=zeros(size(Pc));   
    i=0;
    for k=1:NP
        i2=sum(Pc==k)>0;
        i=i+i2;
        Pc2(Pc==k)=i;
    end
    XMATc(:,dsm)=Pc2;
    NPc=max(XMATc(:,dsm));
    
    Pc=XMATc(:,dcs);      
    Pc2=zeros(size(Pc));   
    i=0;
    for k=1:NCSMAX
        i2=sum(Pc==k)>0;
        i=i+i2;
        Pc2(Pc==k)=i;
    end
    XMATc(:,dcs)=Pc2;
    clear Pc2
    
    [NCSMAXc,Sc,Marketc,Groupc]=IMatrix(TALT,NPc,XMATc);

    WGTc=ones(1,NPc);
    NDVc=ones(NPc,1);
    HetCoefc=zeros(NV,NPc,NDRAWS);
    DSc=zeros(NPc,NDRAWS);
    i=1;
    for j=1:NP
        if sum(Pc==j)>0
            WGTc(i)=WGT(j);
            NDVc(i)=NDV(j);
            HetCoefc(:,i,:)=HetCoef(:,j,:);
            DSc(i,:)=DS(j,:);
            i=i+1;
        end
    end
    WGTc=WGTc./sum(WGTc);
    clear Pc 
    
    PreSimPrice=Price(:,m); 
     
    x0=PreSimPrice(iPrice); 
       
    simfun = @(x)simulationfun_soda(x,XMATc,Sc,Groupc,NPc,NCSMAXc,iPrice,PreSimPrice,...
        HetCoefc,FixCoef,R,AllFirmsProducts,AllCompetitorProducts,costs(:,m),...
        TALT,WGTc,tau,SV,NDVc,DSc);

    [P,Res,Flag,Out]=fsolve(simfun,x0,FsolveOptions);
       
    ProducerPrice(iPrice,m) = P;       
    Residual(iPrice,m)      = Res;
    ExitFlag(1:TALT,m)      = Flag;
    Output{m}               = Out;
   
    indexop=XMAT(:,alt).*Index;
    indexmk=XMAT(:,mar).*Index;
    for k=1:TALT
        HHConsumerPrice(indexop==k)=ProducerPrice(k,m);
        HHExitFlag(indexmk==k)=Flag;
    end
end

ExitFile=fullfile(DataDir,'Exit.mat');   
save(ExitFile,'ExitFlag');

ConsumerPrice=tau.*Simvar+ProducerPrice;

Products=(1:TALT)';
Market=(1:nMarket)';

Outdata=[repmat(Products,[nMarket 1]) kron(Market,ones(TALT,1)) costs(:)...
    Price(:) ConsumerPrice(:)];
save(OutDataFile,'Outdata','-ascii','-double','-tabs'); 


