function [uXMAT]=updatedata(XMAT,DATAC,V,VI)

global alt OProd

uXMAT=XMAT;                      
inside=ones(length(XMAT),1);
NO=length(OProd);
for i=1:NO
    inside(XMAT(:,alt)==OProd(i))=0;
end

uXMAT(inside==1,V)=DATAC(inside==1);

if isempty(VI)==0
    for i=1:size(VI,1)
        VIc=VI(i,1);
        MPc=VI(i,2);

        uXMAT(inside==1,VIc)=XMAT(inside==1,VIc)...
            .*(((DATAC(inside==1).^MPc))./(XMAT(inside==1,V).^MPc));
        uXMAT(DATAC==0,VIc)=0;
    end
end
