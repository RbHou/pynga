function illustrationofMCprodedure

%purpose:to illustrate graphically the procedure used to compute the SI
%distribution using MC simulation

%1) Show correlation structure of Jayaram and Baker, 2008
%2) Show one realisation of lnSa values with period
%3) Conversion to Sa (non-log)
%4) conversion to PSV and computation of SI

M=6.5;  R=30;  %magnitude and distance in km

%get attenuation relation data
g=981;  %acc of gravity in cm/s
dT=0.1;
T=0.1:dT:2.5;
siteprop.V30=300;  %shear wave velocity in m/s
faultprop.faultstyle='strikeslip';

for i=1:length(T)
    siteprop.period=T(i);
    [median_lnSA(i),sigma_lnSA(i)]=BooreAtkinson_2007_nga(M,R,siteprop,faultprop);
end

%get correlation values using Baker emperical expression
for i=1:length(T)
    for j=1:length(T)
        [rho(i,j)]=SA_correlation(T(i),T(j)); 
        cov_lnSA(i,j)=rho(i,j)*sigma_lnSA(i)*sigma_lnSA(j);
    end
end


    %compute one realisation of spectral acceleration terms
    R_SA = mvnrnd(log(median_lnSA),cov_lnSA);
    
    %now convert the log-form to non-log form
    SA=exp(R_SA);

    %now convert to PSV
    omega=2*pi./T;
    SV=g*SA./omega;


    %compute VSI
    VSI=dT*(0.5*(SV(1)+SV(length(T)))+sum(SV(2:length(T)-1)));

figout=2;
if figout==1
    %fig1 J+B correlation
    periodplot=[5 20];
    figure(1)
    for i=1:length(periodplot)
        plot(T,rho(periodplot(i),:));
        hold on
    end
    xlabel('Period, T (s)'); ylabel('Correlation coefficient,  {\it\rho}_{ln{\itSa_i},ln{\itSa_j}}');
else
    %fig 2 Generation of lnSa ordinates
%     figure(2)
%     plot(T,log(median_lnSA),'-',T,R_SA,'o')
    
%     figure(3)
%     plot(T,median_lnSA,'-',T,SA,'o')
    
%     figure(4)
hold on
%     plot(T,SV,'-',T,SV,'o')
plot(T,g.*median_lnSA./omega,'--')
end
    %     plot(T,SA,'o',T,median_lnSA,'-r')
%     plot(T,SV,'o',T,g*median_lnSA./omega,'-r');














