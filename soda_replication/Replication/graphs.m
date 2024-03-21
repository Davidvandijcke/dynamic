clear

DDir='./DuboisGriffithOConnell2020\Data\RunResults';
input=fullfile(DDir,'ageexp.raw');

ODir='./DuboisGriffithOConnell2020\Results\RunResults';
output1=fullfile(ODir,'sugageexp');
output2=fullfile(ODir,'CVageexp');

load(input);

exp=ageexp(:,1);
exp=reshape(exp,[6 10]);

age=ageexp(:,2);
age=reshape(age,[6 10]);

z1=ageexp(:,3);
z1=reshape(z1,[6 10]);

z2=ageexp(:,4);
z2=reshape(z2,[6 10]);

bar3(z1)
view(30,30)
xlabel({'Decile of distribution of total'; 'equivalised grocery expenditure'})
ylabel('Age group')
zlabel('Reduction in sugar (g)')
saveas(gcf,output1,'eps') 

bar3(z2)
view(30,30)
xlabel({'Decile of distribution of total'; 'equivalised grocery expenditure'})
ylabel('Age group')
zlabel('Compensating variation (£)')
saveas(gcf,output2,'eps') 
%%%

clear
DDir='./DuboisGriffithOConnell2020\Data\RunResults';
input=fullfile(DDir,'agesug.raw');

ODir='./DuboisGriffithOConnell2020\Results\RunResults';
output1=fullfile(ODir,'sugagesug');
output2=fullfile(ODir,'CVagesug');

load(input);

sug=agesug(:,1);
sug=reshape(sug,[6 10]);

age=agesug(:,2);
age=reshape(age,[6 10]);

z1=agesug(:,3);
z1=reshape(z1,[6 10]);

z2=agesug(:,4);
z2=reshape(z2,[6 10]);

bar3(z1)
view(30,30)
xlabel({'Decile of distribution of share'; 'of calories from added sugar'})
ylabel('Age group')
zlabel('Reduction in sugar (g)')
saveas(gcf,output1,'eps') 

bar3(z2)
view(30,30)
xlabel({'Decile of distribution of share'; 'of calories from added sugar'})
ylabel('Age group')
zlabel('Compensating variation (£)')
saveas(gcf,output2,'eps') 

clear
DDir='./DuboisGriffithOConnell2020\Data\RunResults';
input=fullfile(DDir,'sugexp.raw');

ODir='./DuboisGriffithOConnell2020\Results\RunResults';
output1=fullfile(ODir,'sugsugexp');
output2=fullfile(ODir,'CVsugexp');

load(input);

sug=sugexp(:,1);
sug=reshape(sug,[10 10]);

exp=sugexp(:,2);
exp=reshape(exp,[10 10]);

z1=sugexp(:,3);
z1=reshape(z1,[10 10]);

z2=sugexp(:,4);
z2=reshape(z2,[10 10]);

z3=sugexp(:,5);
z3=reshape(z3,[10 10]);

bar3(z1)
view(30,30)
xlabel({'Decile of distribution'; 'of share of calories'; 'from added sugar'})
ylabel({'Decile of distribution'; 'of total equivalised'; 'grocery expenditure'})
zlabel('Reduction in sugar (g)')
saveas(gcf,output1,'eps') 

bar3(z2)
view(30,30)
xlabel({'Decile of distribution'; 'of share of calories'; 'from added sugar'})
ylabel({'Decile of distribution'; 'of total equivalised'; 'grocery expenditure'})
zlabel('Compensating variation (£)')
saveas(gcf,output2,'eps') 

