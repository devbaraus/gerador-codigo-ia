"""
Template gerado por Flauberth Duarte.
Gerado em: 23-07-2021 11:24:43
#-------Encontre me em: -------------#
Github: https://github.com/Samanosukeh
Site:   www.samanosuke.com.br
"""

import pandas as pd
#-----------Carregando base de dados-----------#
base1 = pd.read_csv('credit_data.csv')

inicio_previsores_base1 = 1
coluna_classe_base1 = 4

previsores_base1 = base1.iloc[:, inicio_previsores_base1:coluna_classe_base1].values
classe_base1 = base1.iloc[:, coluna_classe_base1].values


#-------- Tratando os valores faltantes -----------#
from sklearn.impute import SimpleImputer
import numpy as np
estrategia = "mean"
imputer = SimpleImputer(missing_values = np.nan, strategy = estrategia)
imputer = imputer.fit(previsores_base1[:, inicio_previsores_base1:coluna_classe_base1])
previsores_base1[:, inicio_previsores_base1:coluna_classe_base1] = imputer.transform(
    previsores_base1[:, inicio_previsores_base1:coluna_classe_base1]
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

#---------- SVM -----------#
from sklearn.svm import SVC
classificador_sv = SVC(kernel="rbf", random_state=0)

#---------- RandomForest -----------#
from sklearn.ensemble import RandomForestClassifier
classificador_rf = RandomForestClassifier(n_estimators=40, random_state=0)

#---------- Treinando o modelo -----------#
modelo.fit(previsores_treinamento, classe_treinamento)
