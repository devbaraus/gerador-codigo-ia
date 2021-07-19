import pandas as pd
base = pd.read_csv('credit_data.csv')

#Substituir a linha abaixo pela coluna de inicio dos atributos previsores
inicio_previsores = 0
#Substituir a linha abaixo pelo numero da coluna classe
coluna_classe = None

previsores = base.iloc[:, inicio_previsores:coluna_classe].values
classe = base.iloc[:, coluna_classe].values

#----------Escalonando os atributos -----------#
from sklearn.preprocessing import StandardScaler
scaler = StandardScaler()
previsores = scaler.fit_transform(previsores)

#------------Dividindo a base de dados para Treinamento------------#
from sklearn.model_selection import train_test_split
porcentagem_divisao = 0.250000
previsores_treinamento, previsores_teste, classe_treinamento, classe_teste = train_test_split(
    previsores, classe, test_size=porcentagem_divisao
)

#---------- Treinando o modelo -----------#
modelo.fit(previsores_treinamento, classe_treinamento)

#---------- Fazendo as predições -----------#
previsoes = modelo.predict(previsores_teste)

#---------- Checando a precisão ----------#
from sklearn.metrics import accuracy_score
precisao = accuracy_score(classe_teste, previsoes)
