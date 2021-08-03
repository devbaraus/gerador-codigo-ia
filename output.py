"""
Template gerado por Flauberth Duarte.
Gerado em: 03-08-2021 17:25:15
#-------Encontre me em: -------------#
Github: https://github.com/Samanosukeh
Site:   www.samanosuke.com.br
"""

import pandas as pd
#-----------Carregando base de dados-----------#
base1 = pd.read_csv('datasets/credit_data.csv')
inicio_previsores_base1 = 1
coluna_classe_base1 = 4
previsores_base1 = base1.iloc[:, inicio_previsores_base1:coluna_classe_base1].values
classe_base1 = base1.iloc[:, coluna_classe_base1].values


#-----------Carregando base de dados-----------#
base2 = pd.read_csv('datasets/census.csv')
inicio_previsores_base2 = 0
coluna_classe_base2 = 10
previsores_base2 = base2.iloc[:, inicio_previsores_base2:coluna_classe_base2].values
classe_base2 = base2.iloc[:, coluna_classe_base2].values


#-------- Tratando os valores faltantes -----------#
from sklearn.impute import SimpleImputer
import numpy as np
estrategia = "mean"
imputer = SimpleImputer(missing_values = np.nan, strategy = estrategia)
imputer = imputer.fit(previsores_base1[:, inicio_previsores_base1:coluna_classe_base1])
previsores_base1[:, inicio_previsores_base1:coluna_classe_base1] = imputer.transform(
    previsores_base1[:, inicio_previsores_base1:coluna_classe_base1]
)


#----------Transformação categórica pra numérica -----------#
from sklearn.preprocessing import LabelEncoder
labelencorder = LabelEncoder()
classe_base2 = labelencorder.fit_transform(classe_base2)

#----------Transformação categórica pra numérica -----------#
labelencorder = LabelEncoder()
# copie a linha abaixo e cole quantas vezes for necessário, essa de baixo
# está aplicando apenas a coluna 0, substitua ou aplique nas outras se
# necessário.
previsores_base2[:,2] = labelencorder.fit_transform(previsores_base2[:,2])
previsores_base2[:,4] = labelencorder.fit_transform(previsores_base2[:,4])
previsores_base2[:,5] = labelencorder.fit_transform(previsores_base2[:,5])
previsores_base2[:,6] = labelencorder.fit_transform(previsores_base2[:,6])

#----------Escalonando os atributos -----------#
from sklearn.preprocessing import StandardScaler
scaler = StandardScaler()
previsores_base2 = scaler.fit_transform(previsores_base2)



#------------Dividindo a base de dados para Treinamento------------#
from sklearn.model_selection import train_test_split
porcentagem_divisao = 0.25
previsores_treinamento_base1, previsores_teste_base1, classe_treinamento_base1, classe_teste_base1 = train_test_split(
    previsores_base1, classe_base1, test_size=porcentagem_divisao
)


#------------Dividindo a base de dados para Treinamento------------#
porcentagem_divisao = 0.25
previsores_treinamento_base2, previsores_teste_base2, classe_treinamento_base2, classe_teste_base2 = train_test_split(
    previsores_base2, classe_base2, test_size=porcentagem_divisao
)

#---------- RandomForest -----------#
from sklearn.ensemble import RandomForestClassifier
modelo_rf = RandomForestClassifier(n_estimators=40, random_state=0)

#---------- SVM -----------#
from sklearn.svm import SVC
modelo_svm = SVC(random_state=0)


#---------- Treinando o modelo -----------#
modelo_rf.fit(previsores_treinamento_base1, classe_treinamento_base1)

#---------- Treinando o modelo -----------#
modelo_svm.fit(previsores_treinamento_base2, classe_treinamento_base2)

#---------- Fazendo a predição -----------#
previsoes_base1 = modelo_rf.predict(previsores_teste_base1)

#---------- Fazendo a predição -----------#
previsoes_base2 = modelo_svm.predict(previsores_teste_base2)

#---------- Checando a F1-Score ----------#
from sklearn.metrics import f1_score
precisao_f1_base1 = f1_score(classe_teste_base1, previsoes_base1, average='macro')


#---------- Checando a precisão ----------#
from sklearn.metrics import accuracy_score
precisao_base2 = accuracy_score(classe_teste_base2, previsoes_base2)
#-----------Carregando base de dados-----------#
base3 = pd.read_csv('datasets/plano_saude.csv')
inicio_previsores_base3 = 0
coluna_classe_base3 = 1
previsores_base3 = base3.iloc[:, inicio_previsores_base3:coluna_classe_base3].values
classe_base3 = base3.iloc[:, coluna_classe_base3].values



#------------Dividindo a base de dados para Treinamento------------#
porcentagem_divisao = 0.25
previsores_treinamento_base3, previsores_teste_base3, classe_treinamento_base3, classe_teste_base3 = train_test_split(
    previsores_base3, classe_base3, test_size=porcentagem_divisao
)

#---------- Regressor RandomForest -----------#
from sklearn.ensemble import RandomForestRegressor
modelo_rfr = RandomForestRegressor(random_state=0)


#---------- Treinando o modelo -----------#
modelo_rfr.fit(previsores_treinamento_base3, classe_treinamento_base3)

#---------- Fazendo a predição -----------#
previsoes_base3 = modelo_rfr.predict(previsores_teste_base3)

#---------- Checando o MSE ----------#
from sklearn.metrics import mean_squared_error
mse_base3 = mean_squared_error(classe_teste_base3, previsoes_base3)

