
close all 
clear all
clc

% Refer�ncias: 
% [1] R.M. Cotta, C.P. Naveira-Cotta, and P. Magal, Parametric identification 
%     and public health measures influence on the COVID-19 epidemic evolution 
%     in Brazil, 2020. 

% Sum�rio de vari�veis utilizadas no modelo SIRU:
%
% S(t): n�mero de indiv�duos pass�veis de seren infectados no dia t
% I(t): n�mero de indiv�duos infecciosos e assintom�ticos no dia t
% R(t): n�mero de indiv�duos infecciosos e notificados no dia t
% U(t): n�mero de indiv�duos infecciosos e n�o-notificados no dia t
% CR(t): cumulativo de indiv�duos infectados notificados at� o dia t
% CU(t): cumulativo de indiv�duos infectados n�o-notificados at� o dia t
% f(t): fra��o de indiv�duos assintom�ticos se tornar�o casos notificados
% 1-f(t): fra��o de indiv�duos assintom�ticos se tornar�o casos n�o-notificados
% DR(t): n�mero di�rio de indiv�duos notificados

% Premissas:
%
% 1. Ind�viduos infecciosos notificados R(t) s�o removidos (ou isolados) da
% popula��o e n�o causam novas infec��es.
% 2. Individuos assintom�ticos (I) s�o infecciosos por um per�odo de Ti dias.
% 3. Indiv�duos sintom�ticos e notificados, ou n�o,(R ou U) s�o infecciosos por um per�odo
% de Tr dias;
% 4. Todas as infec��es acontecem via indiv�duos dos grupos I ou U.

% Par�metros do modelo:
t    = 0:150;   % Intervalo de tempo em dias
Ti   = 7.024;      % Tempo m�dio em que o indiv�duo em I permanece infeccioso
Tr   = 7.024;      % Tempo m�dio em que o indiv�duo em R permanece infeccioso
f0   = 0.1257;    % Taxa inicial de notifica��o de casos
X1   = 2.9445;  % Par�metro de ajuste da curva de casos acumulados
X2   = 0.1408;  % Par�metro de ajuste da curva de casos acumulados
X3   = 3.5587;  % Par�metro de ajuste da curva de casos acumulados
N    = 28.05;     % Dias sem medidas de interven��o na din�mica da epidemia
Nf   = length(t)+1; % Dias sem medidas de interven��o na contagem de casos
mu   = 0.0119; % Par�metro de ajuste da curva de taxa de transmiss�o
muf  = 0;     % Par�metro de ajuste da curva de taxa de notifica��o
fmax = 0;     % Par�metro de ajuste da curva de taxa de notifica��o

% Par�metros derivados utilizados no modelo:
nu  = 1/Ti; 
eta = 1/Tr; 
f   = f0*ones(1, length(t)); 
nu1 = nu*f;
nu2 = nu*(1-f);

S = 3.944e6;                  % N�mero inicial de indiv�duos pass�veis de infec��o
I = X2*X3/(nu*f(1));          % N�mero inicial de indiv�duos infectados assintom�ticos
U = (1-f(1))*(nu/(eta+X2))*I; % N�mero inicial de indiv�duos infectados, sintom�ticos e n�o notificados
R = 0;                        % N�mero inicial de indiv�duos infectados, sintom�ticos e notificados
tau0 = (X2+nu)/S*((eta+X2)/((1-f(1))*nu+eta+X2)); % Taxa de infec��o inicial
tau  = tau0*ones(1, length(t));

CR = 0;    % N�mero cumulativo de casos notificados
CU = 0;    % N�mero cumulativo de casos n�o-notificados
DR = 0;    % N�mero de notifica��es di�rias

R0 = (tau0*S(1)/nu)*(1+(1-f(1))*nu/eta); % Taxa b�sica de reprodu��o

% SIRU model
for indT = 1:length(t)-1 
    
    if indT > N
    % A partir do dia N, a taxa de transmiss�o tau � afetada por medidas de
    % conten��o da epidemia:
        tau(indT) = tau0*exp(-mu*(indT-N));
    end
    if indT > Nf
    % A partir do dia Nf, a taxa de notifica��o f � afetada por mudan�as na
    % metodologia ou quantidade de testes:
        f(indT)=(fmax-f0)*(1-exp(-muf*(indT-Nf)))+f(1);
    end
    
    % Integra��o num�rica:
    dS  = -tau(indT)*S(indT)*(I(indT)+U(indT));
    dI  = -dS - nu*I(indT);
    dR  = nu1(indT)*I(indT)-eta*R(indT);
    dU  = nu2(indT)*I(indT)-eta*U(indT);
    dDR = nu1(indT)*f(indT)*I(indT);    
  
    S(indT+1)  = S(indT) + dS;
    I(indT+1)  = I(indT) + dI; 
    R(indT+1)  = R(indT) + dR; 
    U(indT+1)  = U(indT) + dU; 
    CR(indT+1) = CR(indT) + nu1(indT)*I(indT);
    CU(indT+1) = CU(indT) + nu2(indT)*I(indT);
    DR(indT+1) = CR(indT+1) - CR(indT);
end

figure, 
plotScale = 1000;
hold on, plot(t, I/plotScale,'x','markerSize',4,'linewidth',1)
         plot(t, R/plotScale,'-.','markerSize',4,'linewidth',1)
         plot(t, U/plotScale,'--','markerSize',4,'linewidth',1)
         plot(t, CR/plotScale,'-d','markerSize',4,'linewidth',1)
         plot(t, CU/plotScale,'-o','markerSize',4,'linewidth',1)
         plot(t, DR/plotScale,'-sq','markerSize',4,'linewidth',1)
         xlabel('Tempo (dias)')
         ylabel(['Casos \times' num2str(plotScale)])
         title(['Taxa b�sica de reprodu��o inicial: R_0 = ' num2str(R0) ' Notifica��o inicial de casos: f_0 = ' num2str(100*f0) '%'])

load('cumCasesCG.mat','cumCasesCG')
CRdata = cumCasesCG';
plot(CRdata/plotScale,'k-o');

legend('Popula��o de infectados pre-sint./assint. I(t)', 'Casos sintom�ticos ativos notificados R(t)', 'Casos sintom�ticos ativos n�o-notificados U(t)',...
       'Cumulativo de casos notificados CR(t)', 'Cumulativo de casos n�o-notificados CU(t)', 'Notifica��es de casos no dia DR(t)','Cumulativo de casos PB','Location','NorthWest')