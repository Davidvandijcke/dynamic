function [X, XF]=simulationdata(NP,NCSMAX,XMAT,TALT)

global NV NF 
global IDV IDF
global dsm dcs alt asymmetry

X=zeros(TALT,NCSMAX,NV,NP); 
XF=zeros(TALT,NCSMAX,NF,NP);

cp=XMAT(:,dsm); % person

for n=1:NP
 if NV > 0
    xx=XMAT(cp == n, IDV(:,1));
 end
 if NF > 0
    xxf=XMAT(cp == n, IDF(:,1)); 
 end
 cs=XMAT(cp == n,dcs);    
  t1=cs(1,1);  
  t2=cs(end,1);  

  if asymmetry==0 

   for t=t1:t2
       k=sum(cs==t); 
     if NV>0
        X(1:k,1+t-t1,:,n)=xx(cs==t,:);
     end
     if NF>0
        XF(1:k,1+t-t1,:,n)=xxf(cs==t,:);
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
                  X(r,1+t-t1,:,n)=xx(cs==t & ops==r,:);
              end
              if NF>0
                  XF(r,1+t-t1,:,n)=xxf(cs==t & ops==r,:);
              end
          end
      end
   end
  end

end