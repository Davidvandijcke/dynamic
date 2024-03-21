clear all

BR=100;

DataDirO='./DuboisGriffithOConnell2020/Data/RunResults/Passthrough';

for rmy=1:66
   
    fd=int2str(rmy);
    DataDir=fullfile(DataDirO,fd);

    infile='simv1.raw';
    outfile='passthrough.raw';
    
    %Sugary soda tax
    SimvarFile=fullfile(DataDir,infile);
    OutDataFile=fullfile(DataDir,outfile);
 
    passthrough;

end
Exit=zeros(66,1);
for rmy=1:66
    fd=int2str(rmy);
    DataDir=fullfile(DataDirO,fd);
    ExitFile=fullfile(DataDir,'Exit.mat');   
    load(ExitFile);
    exit=ExitFlag(1);
    Exit(rmy)=exit;
end
t=(1:66)';
disp(t(Exit==0));
