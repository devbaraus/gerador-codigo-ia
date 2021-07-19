# -*- coding: utf-8 -*-
"""
Created on Mon Jul 19 09:16:30 2021

@author: Flauberth
"""

import pandas as pd
base = pd.read_csv('credit_data.csv') #Lendo a base

#Descomentar a linha abaixo e substituir pela coluna de inicio dos atributos previsores
inicio_previsores = 1

#Descomentar a linha abaixo e subistituir o valor pela numero da coluna classe
coluna_classe = 4

previsores = base.iloc[:, inicio_previsores:coluna_classe].values
classe = base.iloc[:, coluna_classe].values


#-------- Tratando os valores faltantes -----------#
from sklearn.impute import SimpleImputer
import numpy as np
estrategia = "mean"
imputer = SimpleImputer(missing_values = np.nan, strategy = estrategia)
imputer = imputer.fit(previsores[:, inicio_previsores:coluna_classe])
previsores[:, inicio_previsores:coluna_classe] = imputer.transform(previsores[:, inicio_previsores:coluna_classe])


#----------Escalonando os atributos -----------#
from sklearn.preprocessing import StandardScaler
scaler = StandardScaler() 
previsores = scaler.fit_transform(previsores)


#----------classe categórica pra numérica -----------#
from sklearn.preprocessing import LabelEncoder
labelencorder_classe = LabelEncoder()
classe = labelencorder_classe.fit_transform(classe)


#------------Dividindo a base de dados para Treinamento------------#
from sklearn.model_selection import train_test_split
porcentagem_divisao = 0.25
previsores_treinamento, previsores_teste, classe_treinamento, classe_teste = train_test_split(
    previsores, classe, test_size=porcentagem_divisao,random_state=0
)


#---------- SVM -----------#
from sklearn.svm import SVC
classificador = SVC(kernel="rbf") #kernel linear passa uma reta em 2D, C=2 resultado bom

#---------- Treinando o modelo -----------#
classificador.fit(previsores_treinamento, classe_treinamento)


#---------- Treinando as predições -----------#
previsoes = classificador.predict(previsores_teste)


#----------Fazendo o comparativo de acerto----------#
from sklearn.metrics import accuracy_score
precisao = accuracy_score(classe_teste, previsoes) #porcentagem de acerto do algoritmo
