clear
DataDir='./DuboisGriffithOConnell2020';
OutDir='./DuboisGriffithOConnell2020';

%coefficients and variances
coeffile1=fullfile(DataDir,'coef1.raw');
vcovfile1=fullfile(DataDir,'vcov1.raw');
coeffile2=fullfile(DataDir,'coef2.raw');
vcovfile2=fullfile(DataDir,'vcov2.raw');
coeffile3=fullfile(DataDir,'coef3.raw');
vcovfile3=fullfile(DataDir,'vcov3.raw');
coeffile4=fullfile(DataDir,'coef4.raw');
vcovfile4=fullfile(DataDir,'vcov4.raw');

%cleaned coefficient index (all)
ipfile=fullfile(DataDir,'coef_price_index.raw');
ixfile=fullfile(DataDir,'coef_soda_index.raw');
iyfile=fullfile(DataDir,'coef_sugar_index.raw');
ixyfile=fullfile(DataDir,'coef_sodasugar_index.raw');

%cleaned coefficient index (group)
ipfile1=fullfile(DataDir,'coef_price_index1.raw');
ipfile2=fullfile(DataDir,'coef_price_index2.raw');
ipfile3=fullfile(DataDir,'coef_price_index3.raw');
ipfile4=fullfile(DataDir,'coef_price_index4.raw');
ixfile1=fullfile(DataDir,'coef_soda_index1.raw');
ixfile2=fullfile(DataDir,'coef_soda_index2.raw');
ixfile3=fullfile(DataDir,'coef_soda_index3.raw');
ixfile4=fullfile(DataDir,'coef_soda_index4.raw');
iyfile1=fullfile(DataDir,'coef_sugar_index1.raw');
iyfile2=fullfile(DataDir,'coef_sugar_index2.raw');
iyfile3=fullfile(DataDir,'coef_sugar_index3.raw');
iyfile4=fullfile(DataDir,'coef_sugar_index4.raw');
ixyfile1=fullfile(DataDir,'coef_sodasugar_index1.raw');
ixyfile2=fullfile(DataDir,'coef_sodasugar_index2.raw');
ixyfile3=fullfile(DataDir,'coef_sodasugar_index3.raw');
ixyfile4=fullfile(DataDir,'coef_sodasugar_index4.raw');

outfile=fullfile(OutDir,'estimates.raw');

%Load coefficients
coef1=load(coeffile1);
vcov1=load(vcovfile1);
coef2=load(coeffile2);
vcov2=load(vcovfile2);
coef3=load(coeffile3);
vcov3=load(vcovfile3);
coef4=load(coeffile4);
vcov4=load(vcovfile4);

pTind=load(ipfile);
xTind=load(ixfile);
yTind=load(iyfile);
xyTind=load(ixyfile);

%F:Female; M:Male
%Y:Young; O:Old

%%Coefficient dimensions

%Heterogeneous coefficients by group

%Name xy
%x=b/i - switch/inside only; y=s/z/o - switch/zero sugar/full sugar

%Females - young
bs1=477;
bz1=0;
bo1=4;
is1=117;
iz1=2;
io1=6;
%Females - old
bs2=508;
bz2=0;
bo2=3;
is2=69;
iz2=3;
io2=1;
%Males - young
bs3=520;
bz3=1;
bo3=6;
is3=129;
iz3=1;
io3=16;
%Males - old
bs4=476;
bz4=0;
bo4=5;
is4=94;
iz4=2;
io4=9;

%Fixed coefficients
FC=22;
MC=97;

%Total heterogenous coefficients
for i=1:4
    eval(['b',int2str(i),'=bs',int2str(i),'+bz',int2str(i),'+bo',int2str(i),';']);
    eval(['i',int2str(i),'=is',int2str(i),'+iz',int2str(i),'+io',int2str(i),';']);
    eval(['N',int2str(i),'=b',int2str(i),'+i',int2str(i),';']);
end

%Heterogeneous coefficient indices
for i=1:4
    eval(['pInd',int2str(i),'=(1:N',int2str(i),');']);
    eval(['xInd',int2str(i),'=(N',int2str(i),'+1:N',int2str(i),'+b',int2str(i),');']);
    eval(['yInd',int2str(i),'=(N',int2str(i),'+b',int2str(i),'+1:N',int2str(i),'+b',int2str(i),'+bs',int2str(i),'+is',int2str(i),');'])

    eval(['pxInd',int2str(i),'=(1:b',int2str(i),');']);
    eval(['pyInd',int2str(i),'=[(1:bs',int2str(i),') (b',int2str(i),'+1:b',int2str(i),'+is',int2str(i),')];']);
    eval(['xyInd',int2str(i),'=(N',int2str(i),'+1:N',int2str(i),'+bs',int2str(i),');']);
    eval(['yxInd',int2str(i),'=(N',int2str(i),'+b',int2str(i),'+1:N',int2str(i),'+b',int2str(i),'+bs',int2str(i),');']);
    
    eval(['fInd',int2str(i),'=(N',int2str(i),'+b',int2str(i),'+bs',int2str(i),'+is',int2str(i),'+1:N',int2str(i),'+b',int2str(i),'+bs',int2str(i),'+is',int2str(i),'+FC);']);
end

for i=1:4
    eval(['coefp',int2str(i),'=coef',int2str(i),'(pInd',int2str(i),');']);
    eval(['coefx',int2str(i),'=coef',int2str(i),'(xInd',int2str(i),');']);
    eval(['coefy',int2str(i),'=coef',int2str(i),'(yInd',int2str(i),');']);
    
    eval(['coefpx',int2str(i),'=coef',int2str(i),'(pxInd',int2str(i),');']);
    eval(['coefpy',int2str(i),'=coef',int2str(i),'(pyInd',int2str(i),');']);
    eval(['coefxy',int2str(i),'=coef',int2str(i),'(xyInd',int2str(i),');']);
    eval(['coefyx',int2str(i),'=coef',int2str(i),'(yxInd',int2str(i),');']);
    
    eval(['coeff',int2str(i),'=coef',int2str(i),'(fInd',int2str(i),');']);   
end

%Combine together coefficients
coefp=[coefp1 coefp2 coefp3 coefp4];
coefx=[coefx1 coefx2 coefx3 coefx4];
coefy=[coefy1 coefy2 coefy3 coefy4];

coefpx=[coefpx1 coefpx2 coefpx3 coefpx4];
coefpy=[coefpy1 coefpy2 coefpy3 coefpy4];
coefxy=[coefxy1 coefxy2 coefxy3 coefxy4];
coefyx=[coefyx1 coefyx2 coefyx3 coefyx4];

%Clean coefficient distributions
coeftp=coefp(pTind==0);
coeftx=coefx(xTind==0);
coefty=coefy(yTind==0);

coeftpx=coefpx(xTind==0);
coeftxp=coefx (xTind==0);
coeftpy=coefpy(yTind==0);
coeftyp=coefy (yTind==0);
coeftxy=coefxy(xyTind==0);
coeftyx=coefyx(xyTind==0);

for i=1:4
    eval(['pindTEMP=load(ipfile',int2str(i),');']);
    eval(['xindTEMP=load(ixfile',int2str(i),');']);
    eval(['yindTEMP=load(iyfile',int2str(i),');']);
    eval(['xyindTEMP=load(ixyfile',int2str(i),');']);
    
    eval(['pIndt',int2str(i),'=pInd',int2str(i),'(pindTEMP==0);']);
    eval(['xIndt',int2str(i),'=xInd',int2str(i),'(xindTEMP==0);']);
    eval(['yIndt',int2str(i),'=yInd',int2str(i),'(yindTEMP==0);']);

    eval(['pxIndt',int2str(i),'=pxInd',int2str(i),'(xindTEMP==0);']);
    eval(['xpIndt',int2str(i),'=xInd',int2str(i),'(xindTEMP==0);']);
    eval(['pyIndt',int2str(i),'=pyInd',int2str(i),'(yindTEMP==0);']);
    eval(['ypIndt',int2str(i),'=yInd',int2str(i),'(yindTEMP==0);']);
    eval(['xyIndt',int2str(i),'=xyInd',int2str(i),'(xyindTEMP==0);']);
    eval(['yxIndt',int2str(i),'=yxInd',int2str(i),'(xyindTEMP==0);']);
end

%Update parameters
for i=1:4
    eval(['Np',int2str(i),'=size(pIndt',int2str(i),',2);'])
    eval(['Nx',int2str(i),'=size(xIndt',int2str(i),',2);'])
    eval(['Ny',int2str(i),'=size(yIndt',int2str(i),',2);'])
    eval(['Npx',int2str(i),'=size(pxIndt',int2str(i),',2);'])
    eval(['Npy',int2str(i),'=size(pyIndt',int2str(i),',2);'])
    eval(['Nxy',int2str(i),'=size(xyIndt',int2str(i),',2);'])
end

Np=Np1+Np2+Np3+Np4;
Nx=Nx1+Nx2+Nx3+Nx4;
Ny=Ny1+Ny2+Ny3+Ny4;
Npx=Npx1+Npx2+Npx3+Npx4;
Npy=Npy1+Npy2+Npy3+Npy4;
Nxy=Nxy1+Nxy2+Nxy3+Nxy4;

%Initialise outputs
stats=zeros(15,1);
errors=zeros(15,1);

%Covariances
VCpx=cov(coeftpx,coeftxp,1);
VCpy=cov(coeftpy,coeftyp,1);
VCxy=cov(coeftxy,coeftyx,1);

%Price statistics
stats(1)=mean(coeftp);
stats(2)=sqrt(cov(coeftp,1));
stats(3)=skewness(coeftp,1);
stats(4)=kurtosis(coeftp,1);
%Soft drink statistics
stats(5)=mean(coeftx);
stats(6)=sqrt(cov(coeftx));
stats(7)=skewness(coeftx,1);
stats(8)=kurtosis(coeftx,1);
%Sugar statistics
stats(9)=mean(coefty);
stats(10)=sqrt(cov(coefty));
stats(11)=skewness(coefty,1);
stats(12)=kurtosis(coefty,1);
%Covariances
stats(13)=VCpx(1,2);
stats(14)=VCpy(1,2);
stats(15)=VCxy(1,2);

%Variance-covariaces of heterogeneous parameters
pvcov=zeros(Np,Np);
xvcov=zeros(Nx,Nx);
yvcov=zeros(Ny,Ny);
pxvcov=zeros(Npx,Npx);
pyvcov=zeros(Npy,Npy);
xyvcov=zeros(Nxy,Nxy);

j=0;
k=0;
for i=1:4   
    eval(['k=k+Np',int2str(i),';']);
    eval(['pvcov(j+1:k,j+1:k)=vcov',int2str(i),'(pIndt',int2str(i),',pIndt',int2str(i),');'])
    eval(['j=j+Np',int2str(i),';']);
end
j=0;
k=0;
for i=1:4   
    eval(['k=k+Nx',int2str(i),';']);
    eval(['xvcov(j+1:k,j+1:k)=vcov',int2str(i),'(xIndt',int2str(i),',xIndt',int2str(i),');'])
    eval(['j=j+Nx',int2str(i),';']);
end
j=0;
k=0;
for i=1:4   
    eval(['k=k+Ny',int2str(i),';']);
    eval(['yvcov(j+1:k,j+1:k)=vcov',int2str(i),'(yIndt',int2str(i),',yIndt',int2str(i),');'])
    eval(['j=j+Ny',int2str(i),';']);
end
j=0;
k=0;
for i=1:4
    eval(['k=k+Npx',int2str(i),';']);
    eval(['pxvcov(j+1:k,j+1:k)=vcov',int2str(i),'(pxIndt',int2str(i),',pxIndt',int2str(i),');'])
    eval(['pxvcov(Npx+j+1:Npx+k,Npx+j+1:Npx+k)=vcov',int2str(i),'(xpIndt',int2str(i),',xpIndt',int2str(i),');'])
    eval(['pxvcov(j+1:k,Npx+j+1:Npx+k)=vcov',int2str(i),'(pxIndt',int2str(i),',xpIndt',int2str(i),');'])
    eval(['pxvcov(Npx+j+1:Npx+k,j+1:k)=vcov',int2str(i),'(xpIndt',int2str(i),',pxIndt',int2str(i),');'])
    eval(['j=j+Npx',int2str(i),';']);
end
j=0;
k=0;
for i=1:4
    eval(['k=k+Npy',int2str(i),';']);
    eval(['pyvcov(j+1:k,j+1:k)=vcov',int2str(i),'(pyIndt',int2str(i),',pyIndt',int2str(i),');'])
    eval(['pyvcov(Npy+j+1:Npy+k,Npy+j+1:Npy+k)=vcov',int2str(i),'(ypIndt',int2str(i),',ypIndt',int2str(i),');'])
    eval(['pyvcov(j+1:k,Npy+j+1:Npy+k)=vcov',int2str(i),'(pyIndt',int2str(i),',ypIndt',int2str(i),');'])
    eval(['pyvcov(Npy+j+1:Npy+k,j+1:k)=vcov',int2str(i),'(ypIndt',int2str(i),',pyIndt',int2str(i),');'])
    eval(['j=j+Npy',int2str(i),';']);
end
j=0;
k=0;
for i=1:4
    eval(['k=k+Nxy',int2str(i),';']);
    eval(['xyvcov(j+1:k,j+1:k)=vcov',int2str(i),'(xyIndt',int2str(i),',xyIndt',int2str(i),');'])
    eval(['xyvcov(Nxy+j+1:Nxy+k,Nxy+j+1:Nxy+k)=vcov',int2str(i),'(yxIndt',int2str(i),',yxIndt',int2str(i),');'])
    eval(['xyvcov(j+1:k,Nxy+j+1:Nxy+k)=vcov',int2str(i),'(xyIndt',int2str(i),',yxIndt',int2str(i),');'])
    eval(['xyvcov(Nxy+j+1:Nxy+k,j+1:k)=vcov',int2str(i),'(yxIndt',int2str(i),',xyIndt',int2str(i),');'])
    eval(['j=j+Nxy',int2str(i),';']);
end

%Gradients vectors for functions of price coefficients
dpm=ones(1,Np)/Np;
pdev=coeftp-mean(coeftp);
dpv=(1/Np)*(1/std(coeftp,1)).*(pdev-mean(pdev));
dps=(3/Np)*(1/std(coeftp,1)^3)*((pdev.^2-std(coeftp,1)^2)- ...
    std(coeftp,1)*skewness(coeftp,1)*(pdev-mean(pdev)));
dpk=(4/Np)*(1/std(coeftp,1)^4)*((pdev.^3-mean(pdev.^3))- ...
    std(coeftp,1)^2*kurtosis(coeftp,1)*(pdev-mean(pdev)));

%Gradients vectors for functions of soda coefficients
dxm=ones(1,Nx)/Nx;
xdev=coeftx-mean(coeftx);
dxv=(1/Nx)*(1/std(coeftx,1)).*(xdev-mean(xdev));
dxs=(3/Nx)*(1/std(coeftx,1)^3)*((xdev.^2-std(coeftx,1)^2)- ...
    std(coeftx,1)*skewness(coeftx,1)*(xdev-mean(xdev)));
dxk=(4/Nx)*(1/std(coeftx,1)^4)*((xdev.^3-mean(xdev.^3))- ...
    std(coeftx,1)^2*kurtosis(coeftx,1)*(xdev-mean(xdev)));

%Gradients vectors for functions of sugar coefficients
dym=ones(1,Ny)/Ny;
ydev=coefty-mean(coefty);
dyv=(1/Ny)*(1/std(coefty,1)).*(ydev-mean(ydev));
dys=(3/Ny)*(1/std(coefty,1)^3)*((ydev.^2-std(coefty,1)^2)- ...
    std(coefty,1)*skewness(coefty,1)*(ydev-mean(ydev)));
dyk=(4/Ny)*(1/std(coefty,1)^4)*((ydev.^3-mean(ydev.^3))- ...
    std(coefty,1)^2*kurtosis(coefty,1)*(ydev-mean(ydev)));

coeftpx=coefpx(xTind==0);
coeftxp=coefx (xTind==0);
coeftpy=coefpy(yTind==0);
coeftyp=coefy (yTind==0);
coeftxy=coefxy(xyTind==0);
coeftyx=coefyx(xyTind==0);

%Gradients vectors for covariances
Ppxdev=coeftpx-mean(coeftpx);
Xpxdev=coeftxp-mean(coeftxp);
dpxcv=zeros(2*Npx,1);
dpxcv(1:Npx)=(1/Npx)*Xpxdev-mean(Xpxdev);
dpxcv(Npx+1:2*Npx)=(1/Npx)*Ppxdev-mean(Ppxdev);

Ppydev=coeftpy-mean(coeftpy);
Ypydev=coeftyp-mean(coeftyp);
dpycv=zeros(2*Npy,1);
dpycv(1:Npy)=(1/Npy)*Ypydev-mean(Ypydev);
dpycv(Npy+1:2*Npy)=(1/Npy)*Ppydev-mean(Ppydev);

Xxydev=coeftxy-mean(coeftxy);
Yxydev=coeftyx-mean(coeftyx);
dxycv=zeros(2*Nxy,1);
dxycv(1:Nxy)=(1/Nxy)*Yxydev-mean(Yxydev);
dxycv(Nxy+1:2*Nxy)=(1/Nxy)*Xxydev-mean(Xxydev);

%Price errors
errors(1)=sqrt(dpm*pvcov*dpm');
errors(2)=sqrt(dpv*pvcov*dpv');
errors(3)=sqrt(dps*pvcov*dps');
errors(4)=sqrt(dpk*pvcov*dpk');
%Soft drinks errors
errors(5)=sqrt(dxm*xvcov*dxm');
errors(6)=sqrt(dxv*xvcov*dxv');
errors(7)=sqrt(dxs*xvcov*dxs');
errors(8)=sqrt(dxk*xvcov*dxk');
%Sugar errors
errors(9)=sqrt(dym*yvcov*dym');
errors(10)=sqrt(dyv*yvcov*dyv');
errors(11)=sqrt(dys*yvcov*dys');
errors(12)=sqrt(dyk*yvcov*dyk');
%Covariance errors
errors(13)=sqrt(dpxcv'*pxvcov*dpxcv);
errors(14)=sqrt(dpycv'*pyvcov*dpycv);
errors(15)=sqrt(dxycv'*xyvcov*dxycv);

%Parameter vector
param=zeros(15+4*FC,1);
param(1:15)=stats;
param(16:15+FC)=coef1(fInd1)';
param(16+FC:15+2*FC)=coef2(fInd2)';
param(16+2*FC:15+3*FC)=coef3(fInd3)';
param(16+3*FC:15+4*FC)=coef4(fInd4)';

%Variance-covariaces of homogeneous parameters
fvcov=zeros(4*FC,4*FC);
fvcov(1:FC,1:FC)=vcov1(fInd1,fInd1);
fvcov(1+FC:2*FC,1+FC:2*FC)=vcov2(fInd2,fInd2);
fvcov(1+2*FC:3*FC,1+2*FC:3*FC)=vcov3(fInd3,fInd3);
fvcov(1+3*FC:4*FC,1+3*FC:4*FC)=vcov4(fInd4,fInd4);

%Standard errors for homogeneous parameters
ses=zeros(15+4*FC,1);
ses(1:15)=errors;
ses(16:15+FC)=sqrt(diag(fvcov(1:FC,1:FC)));
ses(16+FC:15+2*FC)=sqrt(diag(fvcov(1+FC:2*FC,1+FC:2*FC)));
ses(16+2*FC:15+3*FC)=sqrt(diag(fvcov(1+2*FC:3*FC,1+2*FC:3*FC)));
ses(16+3*FC:15+4*FC)=sqrt(diag(fvcov(1+3*FC:4*FC,1+3*FC:4*FC)));

data=[param ses];
save(outfile,'data','-ascii','-double','-tabs');

%price
%soda
%sugar
%fixed
%year
%quater
%region

%within MC
%region
rindex=(1:25);
%time-years
aindex=(26:70);
%time-quarters
qindex=(71:97);

%Draw coefficients for monte carlo confidence intervals
pdrawfile=fullfile(OutDir,'pdraw.raw');
xdrawfile=fullfile(OutDir,'xdraw.raw');
ydrawfile=fullfile(OutDir,'ydraw.raw');
fdrawfile=fullfile(OutDir,'fdraw.raw');
rdrawfile=fullfile(OutDir,'rdraw.raw');
adrawfile=fullfile(OutDir,'adraw.raw');
qdrawfile=fullfile(OutDir,'qdraw.raw');

REPS=100;
rng(346); %Set seed of random number generator

for i=1:4
    eval(['paramhat=load(coeffile',int2str(i),');']);
    eval(['vcov=load(vcovfile',int2str(i),');']);
    
    indiss=diag(vcov==0);
    p=size(paramhat,2); %Number of estimated parameters
    phatd=zeros(REPS,p);
    phatd(:,indiss==0)=repmat(paramhat(indiss==0),[REPS 1])+randn(REPS,p-sum(indiss==1))*chol(vcov(indiss==0,indiss==0)); %Draws 
    phatd=phatd'; %pxREPS

    eval(['phatd',int2str(i),'=phatd;']);

end

pd=[phatd1(pInd1,:);phatd2(pInd2,:);phatd3(pInd3,:);phatd4(pInd4,:)];
xd=[phatd1(xInd1,:);phatd2(xInd2,:);phatd3(xInd3,:);phatd4(xInd4,:)];
yd=[phatd1(yInd1,:);phatd2(yInd2,:);phatd3(yInd3,:);phatd4(yInd4,:)];
fd=[phatd1(fInd1,:);phatd2(fInd2,:);phatd3(fInd3,:);phatd4(fInd4,:)];
ad=[phatd1(aindex+fInd1(end),:);phatd2(aindex+fInd2(end),:);phatd3(aindex+fInd3(end),:);phatd4(aindex+fInd4(end),:)];
qd=[phatd1(qindex+fInd1(end),:);phatd2(qindex+fInd2(end),:);phatd3(qindex+fInd3(end),:);phatd4(qindex+fInd4(end),:)];
rd=[phatd1(rindex+fInd1(end),:);phatd2(rindex+fInd2(end),:);phatd3(rindex+fInd3(end),:);phatd4(rindex+fInd4(end),:)];

group=kron((1:4)',ones(length(aindex),1));
brd=repmat(kron((1:9)',ones(5,1)),[4 1]);
a=repmat((2010:2014)',[4*9 1]);

ad=[group brd a ad];

group=kron((1:4)',ones(length(qindex),1));
brd=repmat(kron((1:9)',ones(3,1)),[4 1]);
q=repmat((2:4)',[4*9 1]);

qd=[group brd q qd];

group=kron((1:4)',ones(length(rindex),1));
out=repmat(kron((1:5)',ones(5,1)),[4 1]);
r=repmat((2:6)',[4*5 1]);
rd=[group out r rd];

save(pdrawfile,'pd','-ascii','-double','-tabs');
save(xdrawfile,'xd','-ascii','-double','-tabs');
save(ydrawfile,'yd','-ascii','-double','-tabs');
save(fdrawfile,'fd','-ascii','-double','-tabs');
save(rdrawfile,'rd','-ascii','-double','-tabs');
save(adrawfile,'ad','-ascii','-double','-tabs');
save(qdrawfile,'qd','-ascii','-double','-tabs');