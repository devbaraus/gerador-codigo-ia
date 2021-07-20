import pandas as pd
base1 = pd.read_csv('credit_data.csv')

#Substituir a linha abaixo pela coluna de inicio dos atributos previsores
inicio_previsores_base1 = 0
#Substituir a linha abaixo pelo numero da coluna classe
coluna_classe_base1 = None

previsores_base1 = base1.iloc[:, inicio_previsores_base1:coluna_classe_base1].values
classe_base1 = base1.iloc[:, coluna_classe_base1].values

base2 = pd.read_csv('risco_credito.csv')

#Substituir a linha abaixo pela coluna de inicio dos atributos previsores
inicio_previsores_base2 = 0
#Substituir a linha abaixo pelo numero da coluna classe
coluna_classe_base2 = None

previsores_base2 = base2.iloc[:, inicio_previsores_base2:coluna_classe_base2].values
classe_base2 = base2.iloc[:, coluna_classe_base2].values


#----------Escalonando os atributos -----------#
from sklearn.preprocessing import StandardScaler
scaler = StandardScaler()
previsores = scaler.fit_transform(previsores)
