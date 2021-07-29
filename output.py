"""
Template gerado por Flauberth Duarte.
Gerado em: 29-07-2021 11:40:07
#-------Encontre me em: -------------#
Github: https://github.com/Samanosukeh
Site:   www.samanosuke.com.br
"""

import pandas as pd
#-----------Carregando base de dados-----------#
base1 = pd.read_csv('credit_data.csv')

inicio_previsores_base1 = 0
coluna_classe_base1 = 4

previsores_base1 = base1.iloc[:, inicio_previsores_base1:coluna_classe_base1].values
classe_base1 = base1.iloc[:, coluna_classe_base1].values


#-----------Carregando base de dados-----------#
base2 = pd.read_csv('risc_credit.csv')

inicio_previsores_base2 = 1
coluna_classe_base2 = 9

previsores_base2 = base2.iloc[:, inicio_previsores_base2:coluna_classe_base2].values
classe_base2 = base2.iloc[:, coluna_classe_base2].values


#-------- Tratando os valores faltantes -----------#
from sklearn.impute import SimpleImputer
import numpy as np
estrategia = "mean"
imputer = SimpleImputer(missing_values = np.nan, strategy = estrategia)
imputer = imputer.fit(previsores_base2[:, inicio_previsores_base2:coluna_classe_base2])
previsores_base2[:, inicio_previsores_base2:coluna_classe_base2] = imputer.transform(
    previsores_base2[:, inicio_previsores_base2:coluna_classe_base2]
)


#----------Escalonando os atributos -----------#
from sklearn.preprocessing import StandardScaler
scaler = StandardScaler()
previsores_base1 = scaler.fit_transform(previsores_base1)


#----------Transformação categórica pra numérica -----------#
from sklearn.preprocessing import LabelEncoder
labelencorder = LabelEncoder()
classe_base1 = labelencorder.fit_transform(classe_base1)


#------------Dividindo a base de dados para Treinamento------------#
from sklearn.model_selection import train_test_split
porcentagem_divisao = 0.25
previsores_treinamento_base1, previsores_teste_base1, classe_treinamento_base1, classe_teste_base1 = train_test_split(
    previsores_base1, classe_base1, test_size=porcentagem_divisao
)

#---------- RandomForest -----------#
from sklearn.ensemble import RandomForestClassifier
modelo_rf = RandomForestClassifier(n_estimators=40, random_state=0)

#---------- KNN -----------#
from sklearn.neighbors import KNeighborsClassifier
modelo_knn = KNeighborsClassifier(n_neighbors=5, metric='minkowski', p=2)

#---------- Treinando o modelo -----------#
modelo_rf.fit(previsores_treinamento_base1, classe_treinamento_base1)

#---------- Fazendo a predição -----------#
previsoes_base1 = modelo_rf.predict(previsores_teste_base1)

#---------- Checando a precisão ----------#
from sklearn.metrics import accuracy_score
precisao_base1 = accuracy_score(classe_teste_base1, previsoes_base1)

#---------- Checando a F1-Score ----------#
from sklearn.metrics import f1_score
precisao_f1_base1 = f1_score(classe_teste_base1, previsoes_base1, average='macro')

#-----------Carregando base de dados-----------#
base3 = pd.read_csv('plano_saude.csv')

inicio_previsores_base3 = 0
coluna_classe_base3 = 1

previsores_base3 = base3.iloc[:, inicio_previsores_base3:coluna_classe_base3].values
classe_base3 = base3.iloc[:, coluna_classe_base3].values


#---------- Regressão Polinomial -----------#
from sklearn.preprocessing import PolynomialFeatures
poly = PolynomialFeatures(degree = 2)
previsores_base3 = poly.fit_transform(previsores_base3)
from sklearn.linear_model import LinearRegression
modelo_rp = LinearRegression()

#---------- Regressor RandomForest -----------#
from sklearn.ensemble import RandomForestRegressor
modelo_rfr = RandomForestRegressor(random_state=0)

