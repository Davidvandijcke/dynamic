function [NCSMAX,S,Market,Group]=IMatrix(TALT,NP,XMAT)

global dsm dcs alt mar asymmetry

nn=zeros(NP,1);
for n=1:NP
    k=(XMAT(:,dsm)==n);    
    k=XMAT(k,dcs);         
    nn(n,1)=1+k(end,1)-k(1,1);   
end
NCSMAX=max(nn);  

cp=XMAT(:,dsm);   
run=size(XMAT,2); 

S=zeros(TALT,NCSMAX,NP);    
Market=zeros(TALT,NCSMAX,NP); 
Group=zeros(TALT,NCSMAX,NP); 

for n=1:NP
 xm=XMAT(cp == n, mar);   
 xr=XMAT(cp == n, run);   
 cs=XMAT(cp == n,dcs);    
  t1=cs(1,1);    
  t2=cs(end,1);  
  
  if asymmetry==0
  
   for t=t1:t2
       k=sum(cs==t);
       S(1:k,1+t-t1,n)=ones(k,1); 
       Market(1:k,1+t-t1,n)=xm(cs==t,:); 
       Group(1:k,1+t-t1,n)=xr(cs==t,:); 
   end
  else
      
   ops=XMAT(cp == n,alt);    
   for t=t1:t2
      cops=ops(cs==t);
      r1=cops(1,1);
      r2=cops(end,1);
      for r=r1:r2 
          if sum(cops==r)==1 
              S(r,1+t-t1,n)=1; 
              Market(r,1+t-t1,n)=xm(cs==t & ops==r,:); 
              Group(r,1+t-t1,n)=xr(cs==t & ops==r,:); 
          end
      end
   end   
  end   
      
end
