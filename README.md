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
