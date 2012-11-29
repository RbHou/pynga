function [SA,sigma_SA]=BooreAtkinson_2007_nga(M,Rjb,siteprop,faultprop)
%Brendon Bradley   6 April 2008

%Provides the ground motion prediction equation for peak ground
%acceleration, PGA and spectral acceleration, SA,
%in units of g, and peak ground velocity, PGV, in cm/s

%modified from a version written by: Nirmal Jayaram and Jack Baker
%http://stanford.edu/~bakerjw/attenuation.html 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Input Variables:
% M             = Moment magnitude (Mw)
% Rjb           = Source-to-site distance (km) (Joyner Boore distance)
% siteprop      = properties of site (soil etc)
%                 siteprop.V30   -'(any real variable)' shear wave velocity(m/s)
%                 siteprop.period -'(-1),(0),(real variable)' period of
%                                   vibration =-1->PGV; =0->PGA; >0->SA
% faultprop     = properties of fault (strikeslip etc)
%                 faultprop.faultstyle 'normal'
%                                      'reverse'
%                                      'strikelip'
%                                      'other'

%Output Variables:
% SA           = median SA  (or PGA or PGV)
% sigma_SA     = lognormal standard deviation in SA
                 %sigma_SA(1) = total std
                 %sigma_SA(2) = interevent std
                 %sigma_SA(3) = intraevent std
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Coefficients
period = [  -10	      -1	    0     0.01	   0.02	    0.03	 0.05	 0.075	    0.1	    0.15	  0.2	  0.25	    0.3	     0.4	  0.5	  0.75	      1	     1.5	    2	     3	      4	       5      7.5	    10];
e01 = [-0.03279	  5.0012 -0.53804 -0.52883 -0.52192	-0.45285 -0.28476  0.00767	0.20109	 0.46128   0.5718  0.51884	0.43825	  0.3922  0.18957 -0.21338 -0.46896	-0.86271  -1.2265  -1.8298	-2.2466	 -1.2841  -1.4314  -2.1545];
e02 = [-0.03279	  5.0473  -0.5035 -0.49429 -0.48508	-0.41831 -0.25022  0.04912	0.23102	 0.48661  0.59253  0.53496	0.44516	 0.40602  0.19878 -0.19496 -0.43443	-0.79593  -1.1551  -1.7469	-2.1591	 -1.2127  -1.3163  -2.1614];
e03 = [-0.03279	  4.6319 -0.75472 -0.74551 -0.73906	-0.66722 -0.48462 -0.20578	0.03058	 0.30185   0.4086   0.3388	0.25356	 0.21398  0.00967 -0.49176 -0.78465	  -1.209   -1.577  -2.2258	-2.5823	  -1.509  -1.8102 -2.53323];
e04 = [-0.03279	  5.0821  -0.5097 -0.49966 -0.48895	-0.42229 -0.26092  0.02706	0.22193	 0.49328  0.61472  0.57747	 0.5199	  0.4608  0.26337 -0.10813	-0.3933	-0.88085  -1.2767  -1.9181	-2.3817	 -1.4109  -1.5922  -2.1464];
e05 = [ 0.29795	 0.18322  0.28805  0.28897	0.25144	 0.17976  0.06369	0.0117	0.04697	  0.1799  0.52729   0.6088	0.64472	  0.7861  0.76837  0.75179	 0.6788	 0.70689  0.77989  0.77966	 1.2496	 0.14271  0.52407  0.40387];
e06 = [-0.20341	-0.12736 -0.10164 -0.10019 -0.11006	-0.12858 -0.15752 -0.17051 -0.15948	-0.14539 -0.12964 -0.13843 -0.15694	-0.07843 -0.09054 -0.14053 -0.18257	 -0.2595 -0.29657 -0.45384 -0.35874	-0.39006 -0.37578 -0.48492];
e07 = [       0	       0	    0	     0	      0	       0	    0	     0	      0	       0  0.00102  0.08607	0.10601	 0.02262	    0  0.10302	0.05393	 0.19082  0.29888  0.67466	0.79508	       0	    0	     0];
mh = [        7	     8.5	 6.75	  6.75	   6.75	    6.75	 6.75	  6.75	   6.75	    6.75	 6.75     6.75	   6.75	    6.75	 6.75	  6.75	   6.75	    6.75	 6.75	  6.75	   6.75	     8.5	  8.5	   8.5];
c01 = [   -0.55	 -0.8737  -0.6605  -0.6622	 -0.666	 -0.6901   -0.717  -0.7205	-0.7081	 -0.6961   -0.583  -0.5726	-0.5543	 -0.6443  -0.6914  -0.7408	-0.8183	 -0.8303  -0.8285  -0.7844	-0.6854	 -0.5096  -0.3724 -0.09824];
c02 = [       0	  0.1006   0.1197	  0.12	 0.1228	  0.1283   0.1317	0.1237	 0.1117	 0.09884  0.04273  0.02977	0.01955	 0.04394   0.0608  0.07518	 0.1027	 0.09793  0.09432  0.07282	0.03758	-0.02391 -0.06568	-0.138];
c03 = [-0.01151	-0.00334 -0.01151 -0.01151 -0.01151	-0.01151 -0.01151 -0.01151 -0.01151	-0.01113 -0.00952 -0.00837	-0.0075	-0.00626  -0.0054 -0.00409 -0.00334	-0.00255 -0.00217 -0.00191 -0.00191	-0.00191 -0.00191 -0.00191];
mref = [    4.5	     4.5      4.5	   4.5	    4.5	     4.5	  4.5	   4.5	    4.5	     4.5	  4.5	   4.5	    4.5	     4.5	  4.5	   4.5	    4.5	     4.5	  4.5	   4.5	    4.5	     4.5	  4.5	   4.5];
rref = [      1	       1	    1	     1	      1	       1	    1	     1	      1	       1	    1	     1	      1	       1	    1	     1	      1	       1	    1	     1	      1	       1	    1	     1];
h = [         3	    2.54	 1.35	  1.35	   1.35	    1.35	 1.35	  1.55	   1.68	    1.86	 1.98	  2.07	   2.14	    2.24	 2.32	  2.46	   2.54	    2.66	 2.73	  2.83	   2.89	    2.93	    3	  3.04];
blin = [      0	    -0.6	-0.36	 -0.36	  -0.34	   -0.33	-0.29	 -0.23	  -0.25	   -0.28	-0.31	 -0.39	  -0.44	    -0.5	 -0.6	 -0.69	   -0.7	   -0.72	-0.73	 -0.74	  -0.75	   -0.75   -0.692	 -0.65];
vref = [      0	     760	  760	   760	    760	     760	  760	   760	    760	     760	  760	   760	    760	     760	  760	   760	    760	     760	  760	   760	    760	     760	  760	   760];
b1 = [        0	    -0.5	-0.64	 -0.64	  -0.63	   -0.62	-0.64	 -0.64	   -0.6	   -0.53	-0.52	 -0.52	  -0.52	   -0.51	 -0.5	 -0.47	  -0.44	    -0.4	-0.38	 -0.34	  -0.31	  -0.291   -0.247	-0.215];
b2 = [        0	   -0.06	-0.14	 -0.14	  -0.12	   -0.11	-0.11	 -0.11	  -0.13	   -0.18	-0.19	 -0.16	  -0.14	    -0.1	-0.06	     0	      0	       0	    0	     0	      0	       0	    0	     0];
v1 = [        0	     180	  180	   180	    180	     180	  180	   180	    180	     180	  180	   180	    180	     180	  180	   180	    180	     180	  180	   180	    180	     180	  180	   180];
v2 = [        0	     300	  300	   300	    300	     300	  300	   300	    300	     300	  300	   300	    300	     300	  300	   300	    300	     300	  300	   300	    300	     300	  300	   300];
a1 = [        0	    0.03	 0.03	  0.03	   0.03	    0.03	 0.03	  0.03	   0.03	    0.03	 0.03	  0.03	   0.03	    0.03	 0.03	  0.03	   0.03	    0.03	 0.03	  0.03	   0.03	    0.03	 0.03	  0.03];
pga_low = [   0	    0.06	 0.06	  0.06	   0.06	    0.06	 0.06	  0.06	   0.06	    0.06	 0.06	  0.06	   0.06	    0.06	 0.06	  0.06	   0.06	    0.06	 0.06	  0.06	   0.06	    0.06	 0.06	  0.06];
a2 = [        0	    0.09	 0.09	  0.09	   0.09	    0.09	 0.09	  0.09	   0.09	    0.09	 0.09	  0.09	   0.09	    0.09	 0.09	  0.09	   0.09	    0.09	 0.09	  0.09	   0.09	    0.09	 0.09	  0.09];
sig1 = [      0	     0.5    0.502	 0.502	  0.502	   0.507	0.516	 0.513	   0.52	   0.518	0.523	 0.527	  0.546	   0.541	0.555	 0.571	  0.573	   0.566	 0.58	 0.566	  0.583	   0.601	0.626	 0.645];
sig2u = [     0	   0.286	0.265	 0.267	  0.267	   0.276	0.286	 0.322	  0.313	   0.288	0.283	 0.267	  0.272	   0.267	0.265	 0.311	  0.318	   0.382	0.398	  0.41	  0.394	   0.414	0.465	 0.355];
sigtu = [     0	   0.576	0.566	 0.569	  0.569	   0.578	0.589	 0.606	  0.608	   0.592	0.596	 0.592	  0.608	   0.603	0.615	 0.649	  0.654	   0.684	0.702	   0.7	  0.702	    0.73	0.781	 0.735];
sig2m = [     0	   0.256	 0.26	 0.262	  0.262	   0.274	0.286	  0.32	  0.318	    0.29	0.288	 0.267	  0.269	   0.267	0.265	 0.299	  0.302	   0.373	0.389	 0.401	  0.385	   0.437	0.477	 0.477];
sigtm = [     0	    0.56	0.564	 0.566	  0.566	   0.576	0.589	 0.606	  0.608	   0.594	0.596	 0.592	  0.608	   0.603	0.615	 0.645	  0.647	   0.679	  0.7	 0.695	  0.698	   0.744	0.787	 0.801];

T=siteprop.period;
% interpolate between periods if neccesary
if (length(find(abs((period-T))<0.0001))==0)
    T_low=max(period(find(period<T)));
    T_hi=min(period(find(period>T)));
    
    siteprop.period=T_low;
    [SA_low,sigma_SA_low]=BooreAtkinson_2007_nga(M,Rjb,siteprop,faultprop);
    siteprop.period=T_hi;
    [SA_high,sigma_SA_high]=BooreAtkinson_2007_nga(M,Rjb,siteprop,faultprop);
    siteprop.period=T;
    
    if T_low>eps %log interpolation
        x=[log(T_low) log(T_hi)];
        Y_sa=[log(SA_low) log(SA_high)];
        SA_sigma=[sigma_SA_low' sigma_SA_high'];
        SA=exp(interp1(x,Y_sa,log(T)));
        for i=1:3
            sigma_SA(i) = interp1(x,SA_sigma(i,:),log(T));
        end
    else    %inear interpolation
        x=[T_low T_hi];
        Y_sa=[SA_low SA_high];
        SA_sigma=[sigma_SA_low' sigma_SA_high'];
        SA=interp1(x,Y_sa,T);
        for i=1:3
            sigma_SA(i) = interp1(x,SA_sigma(i,:),T);
        end
    end
    
else
    i = find(abs((period - T)) < 0.0001); % Identify the period (given by user)
    
    %fault style
    if length(regexp(faultprop.faultstyle,'normal','match'))~=0  %normal 
        U=0;
        S=0;
        N=1;
        Rev=0;
        sigma_SAt=sigtm(i);
        sigma_SAinter=sig2m(i);
    elseif length(regexp(faultprop.faultstyle,'strikeslip','match'))~=0  %strikeslip
        U=0;
        S=1;
        N=0;
        Rev=0; 
        sigma_SAt=sigtm(i);
        sigma_SAinter=sig2m(i);
    elseif length(regexp(faultprop.faultstyle,'reverse','match'))~=0  %reverse
        U=0;
        S=0;
        N=0;
        Rev=1; 
        sigma_SAt=sigtm(i);
        sigma_SAinter=sig2m(i);
    else
        U=1;
        S=0;
        N=0;
        Rev=0;
        sigma_SAt=sigtu(i);
        sigma_SAinter=sig2u(i);
    end
    %end of fault style
    
    %soil shear wave velocity
    V30=siteprop.V30;

    % Magnitude Scaling
    if M<=mh(i)
        Fm=e01(i)*U+e02(i)*S+e03(i)*N+e04(i)*Rev+e05(i)*(M-mh(i))+e06(i)*(M-mh(i))^2;
    else
        Fm=e01(i)*U+e02(i)*S+e03(i)*N+e04(i)*Rev+e07(i)*(M-mh(i));
    end  

    % Distance Scaling
    r=sqrt(Rjb^2+h(i)^2);
    Fd=(c01(i)+c02(i)*(M-mref(i)))*log(r/rref(i))+c03(i)*(r-rref(i));

    % Site Amplification
    % Linear term
    Flin=blin(i)*log(V30/vref(i));

    % Nonlinear term
    % Computation of pga4nl    
    Tpga = 0;
    i0 = find(abs((period - Tpga)) < 0.0001); % Identify the period
    % Magnitude Scaling
    if M<=mh(i0)
        Fm0=e01(i0)*U+e02(i0)*S+e03(i0)*N+e04(i0)*Rev+e05(i0)*(M-mh(i0))+e06(i0)*(M-mh(i0))^2;
    else
        Fm0=e01(i0)*U+e02(i0)*S+e03(i0)*N+e04(i0)*Rev+e07(i0)*(M-mh(i0));
    end  

    % Distance Scaling
    r0=sqrt(Rjb^2+h(i0)^2);
    Fd0=(c01(i0)+c02(i0)*(M-mref(i0)))*log(r0/rref(i0))+c03(i0)*(r0-rref(i0));        
    pga4nl=exp( Fm0 + Fd0 );      % T = 0; Fs= 0

     % Computation of nonlinear factor 
    if V30<=v1(i)
        bnl=b1(i);
    else
        if (V30>v1(i)&V30<=v2(i))
            bnl=b2(i)+(b1(i)-b2(i))*log(V30/v2(i))/log(v1(i)/v2(i));
        else
            if (V30>v2(i)&V30<=vref(i))
                bnl=b2(i)*log(V30/vref(i))/log(v2(i)/vref(i));
            else
                if V30>vref(i)
                    bnl=0;
                end
            end
        end
    end
    deltax=log(a2(i)/a1(i));
    deltay=bnl*log(a2(i)/pga_low(i));
    c=(3*deltay-bnl*deltax)/(deltax^2);
    d=-(2*deltay-bnl*deltax)/(deltax^3);

    if pga4nl<=a1(i)
        Fnl=bnl*log(pga_low(i)/0.1);
    else
        if (pga4nl>a1(i)&pga4nl<=a2(i))
            Fnl=bnl*log(pga_low(i)/0.1)+c*(log(pga4nl/a1(i)))^2+d*(log(pga4nl/a1(i)))^3;
        else
            if pga4nl>a2(i)
                Fnl=bnl*log(pga4nl/0.1);
            end
        end
    end

    Fs=Flin+Fnl;

    % Compute median and sigma
    lnSA=Fm+Fd+Fs;
    SA=exp(lnSA); 
    sigma_SA=[sigma_SAt sigma_SAinter sig1(i)];      %computed where fault type determined

end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%