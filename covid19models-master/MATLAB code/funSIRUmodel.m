function [mse, CR] = funSIRUmodel(CRdata, t, param)

% Par�metros do modelo:
%t    = 0:120;   % Intervalo de tempo em dias
Ti   = param(1); % Tempo m�dio em que o indiv�duo em I permanece infeccioso
Tr   = param(1); % Tempo m�dio em que o indiv�duo em R permanece infeccioso
f0   = param(2); % Taxa inicial de notifica��o de casos
X1   = 2.9445;   % Par�metro de ajuste da curva de casos acumulados
X2   = 0.1408;   % Par�metro de ajuste da curva de casos acumulados
X3   = 3.5587;   % Par�metro de ajuste da curva de casos acumulados
N    = param(3);     % Dias sem medidas de interven��o na din�mica da epidemia
Nf   = length(t)+1;  % Dias sem medidas de interven��o na contagem de casos
mu   = param(4);     % Par�metro de ajuste da curva de taxa de transmiss�o
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

% Calcula MSE entre o curva do modelo e os dados de refer�ncia:
mse  = mean(abs(CRdata-CR).^2);

end