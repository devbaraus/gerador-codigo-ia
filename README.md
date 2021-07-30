# gerador-codigo-ia

# Comandos

- ## Carregar base de dados:  ```carrega base1 credit_data 7 1;```
     -  **carrega**: o comando para carregar a base
     -  **base1**: o nome da variável que receberá a base
     -  **credit_data**: nome do arquivo .csv que está salvo os dados, exemplo: credit_data.csv
     -  **7**: colula do dataframe onde está o atributo classe
     -  **1**: colula do dataframe onde inicia os atributos previsores, 
         - se não passo o valor padrão será 0

---
- ## Tratar valores faltantes nos dados: ```faltantes base1 media;```
     -  **faltantes**: o comando para importar a biblioteca que trata valores faltantes
     -  **base1**: o conjunto de dados escolhido para aplicar o tratamento
     -  **media**: a estratégia escolhida para tratar os valores faltantes, todas as estratégias:
         - **media**: pega a média dos valores 
         - **mediana**: pega o valor mediano dos valores
         - **mais_frequente**: pega o que mais aparece frequentemente nos dados

----
- ## Escalonar os valores: ```escalonar base1;```
     -  **escalonar**: o comando para importar a biblioteca que escalona os valores
     -  **base1**: o conjunto de dados escolhido para aplicar o escalonamento

----
- ## Aplicar LabelEncoder: ```transformar base1 classe;```
     -  **transformar**: o comando para importar a biblioteca que aplica o LabelEncoder
     -  **base1**: o conjunto de dados escolhido para aplicar o escalonamento
     -  **classe**: conjunto onde vai ser aplicado o label encoder:
         - **classe**: aplicar no atributo classe
         - **previsores**: aplicar nos atributos previsores

----
- ## Dividindo o conjunto em treinamento e teste: ```divisao base1 25;```
     -  **divisao**: o comando para importar a biblioteca de divisão dos valores para dividir a base
     -  **base1**: o conjunto de dados escolhido para aplicar o escalonamento
     -  **25**: porcentagem de quanto será destinado para o teste, exemplo: 25% teste, 75% treinamento

----

- ## Instanciando o modelo de predição: ```classificador rf randomforest 40;```
     -  **classificador**: importando um classificador para instanciar:
         - **classificador**: para importar a versão de classificação do modelo
         - **regressor**: para importar a versão de regressor do modelo
     -  **rf**: o nome da variável que guardará a instância do modelo
     -  **randomforest**: modelo de classificação/regressão utilizado
     -  **40**: nesse exemplo, quantidade de árvores utilizada no RandomForest, parâmetro opcional, outroas opções:
        - **‘linear’, ‘poly’ ou ‘rbf’**: parâmetro para o kernel do SVM, exemplo: ```classificador svc svm rbf;```
         - Um número como parâmetro pode ser também a quantidade de vizinhos no KNN, exemplo: ```classificador kn knn 5;```. o grau do polinômio na regressão: ```regressor rp polinomial 2 base3;``` PS: o regressor polinomial é o único que recebe um segundo parâmetro que é além do grau do polinômio que é o nome da base que é onde será aplicado a transformação dos dados para o grau do polinômio.

----

- ## Treinando o modelo : ```treinamento rf base1;```
     -  **treinamento**: chamada para treinar o modelo escolhido
     -  **rf**: o modelo escolhido para ser treinado
     -  **base1**: base de dados escolhida para ter os dados treinado

----

- ## Realizando as predições no modelo : ```predicao rf base1;```
     -  **predicao**: chamada para realizar as predições no modelo escolhido
     -  **rf**: o modelo escolhido para realizar as predições
     -  **base1**: base de dados escolhida para realizar as predições no conjunto de teste

----

- ## Verificar os resultados do modelo : ```resultado base1 acuracia;```
     -  **resultado**: chamada para realizar a checagem dos resultados
     -  **base1**: base de dados escolhida para verificar os resultados
     -  **acuracia**: tipo de resultado para checar a acurácia do modelo, outras opções de resultado:
         - **classe**: aplicar no atributo classe

----

resultado base1 acuracia;
