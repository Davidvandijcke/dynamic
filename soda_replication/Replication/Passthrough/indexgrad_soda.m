function [Gradv]=indexgrad_soda(XMAT,c,fhat,NP,NCSMAX,TALT,PV,PVI,R,Group) 

global NV NF NDRAWS 
global IDV IDF
global dsm dcs alt asymmetry OProd

%Matrices to hold dXMAT/dp
GXms=zeros(TALT,NCSMAX,NV,NP); 
GXFms=zeros(TALT,NCSMAX,NF,NP); 

inside=ones(length(XMAT),1);
NO=length(OProd);
for i=1:NO
    inside(XMAT(:,alt)==OProd(i))=0;
end

GradX=zeros(size(XMAT));       
GradX(inside==1,PV)=1;
if isempty(PVI)==0
    for i=1:size(PVI,1)
        PVIc=PVI(i,1);
        MPc=PVI(i,2);

        GradX(inside==1,PVIc)=MPc*XMAT(inside==1,PVIc)...
            ./(XMAT(inside==1,PV));
    end
end

GradX(isnan(GradX))=0;
clear index PVc MPc

cp=XMAT(:,dsm); % person

 for n=1:NP
 if NV > 0
    xx=GradX(cp == n, IDV(:,1)); 
 end
 if NF > 0
    xxf=GradX(cp == n, IDF); 
 end
 cs=XMAT(cp == n,dcs);    
  t1=cs(1,1);    
  t2=cs(end,1);  
  
  if asymmetry==0 
  
  for t=t1:t2
      k=sum(cs==t); 
    if NV>0
       GXms(1:k,1+t-t1,:,n)=xx(cs==t,:);
    end
    if NF>0
       GXFms(1:k,1+t-t1,:,n)=xxf(cs==t,:);
    end
  end
  
  else
  ops=XMAT(cp == n,alt);   
  for t=t1:t2
     cops=ops(cs==t);
     r1=cops(1,1);
     r2=cops(end,1);
     for r=r1:r2 
         if sum(cops==r)==1 
             if NV>0
                 GXms(r,1+t-t1,:,n)=xx(cs==t & ops==r,:);
             end
             if NF>0
                 GXFms(r,1+t-t1,:,n)=xxf(cs==t & ops==r,:);
             end
         end
     end
  end         
  end
 end

if NF > 0
 vf=zeros(TALT,NCSMAX,NP);
 for i=1:R
   ff=reshape(fhat(i,:),1,1,NF,1);  
   ff=repmat(ff,[TALT,NCSMAX,1,NP]); 
   vff=reshape(sum(GXFms.*ff,3),TALT,NCSMAX,NP); 
   vf(Group==i)=vff(Group==i);
 end
else
   vf=zeros(TALT,NCSMAX,NP);
end
vf=repmat(vf,[1,1,1,NDRAWS]);

if NV >0
   
   cc=reshape(c,1,1,NV,NP,NDRAWS); 
   cc=repmat(cc,[TALT,NCSMAX,1,1,1]); 
   Gradr=(repmat(GXms,[1,1,1,1,NDRAWS]).*cc); 
   Gradr=reshape(sum(Gradr,3),TALT,NCSMAX,NP,NDRAWS); 
   Gradv=Gradr+vf; 
else
   Gradv=vf;
end

