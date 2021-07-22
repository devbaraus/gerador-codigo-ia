"""
Template gerado por Flauberth Duarte.
Gerado em: 22-07-2021 11:38:28
#-------Encontre me em: -------------#
Github: https://github.com/Samanosukeh
Site:   www.samanosuke.com.br
"""

import pandas as pd
base1 = pd.read_csv('credit_data.csv')

#Substituir a linha abaixo pela coluna de inicio dos atributos previsores
inicio_previsores_base1 = 1
#Substituir a linha abaixo pelo numero da coluna classe
coluna_classe_base1 = 6

previsores_base1 = base1.iloc[:, inicio_previsores_base1:coluna_classe_base1].values
classe_base1 = base1.iloc[:, coluna_classe_base1].values


base2 = pd.read_csv('risco_credito.csv')

#Substituir a linha abaixo pela coluna de inicio dos atributos previsores
inicio_previsores_base2 = 0
#Substituir a linha abaixo pelo numero da coluna classe
coluna_classe_base2 = 7

previsores_base2 = base2.iloc[:, inicio_previsores_base2:coluna_classe_base2].values
classe_base2 = base2.iloc[:, coluna_classe_base2].values


#-------- Tratando os valores faltantes -----------#
from sklearn.impute import SimpleImputer
import numpy as np
estrategia = "mean"
imputer = SimpleImputer(missing_values = np.nan, strategy = estrategia)
imputer = imputer.fit(previsores_base1[:, inicio_previsores_base1:coluna_classe_base1])
previsores_base1[:, inicio_previsores_base1:coluna_classe_base1] = imputer.transform(previsores_base1[:, inicio_previsores_base1:coluna_classe_base1])


#-------- Tratando os valores faltantes -----------#
imputer = SimpleImputer(missing_values = np.nan)
imputer = imputer.fit(previsores_base2[:, inicio_previsores_base2:coluna_classe_base2])
previsores_base2[:, inicio_previsores_base2:coluna_classe_base2] = imputer.transform(previsores_base2[:, inicio_previsores_base2:coluna_classe_base2])


#----------Escalonando os atributos -----------#
from sklearn.preprocessing import StandardScaler
scaler = StandardScaler()
previsores_base1 = scaler.fit_transform(previsores_base1)
