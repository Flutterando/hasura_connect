# Example

### Query

```dart
   var result = await hasuraConnect.query('''
    query getBooks {
        books {
          id
          name
        }
      }''');

    var listBooks = (result['data']['books'] as List).map((e) => Books.fromMap(e)).toList();


```

### Mutation

```dart
    var mutation = r'''
                  mutation addProduto($nome: String, $categoria: uuid, $tipo: uuid, $valor: float8) {
                    insert_produto(objects: {nome: $nome, categoria_produto_id: $categoria, tipo_produto_id: $tipo, valor: $valor}) {
                      affected_rows
                    }
                  }
              ''';

    var snapshot = await _hasuraConnect.mutation(mutation, variables: {
      "nome": descricao,
      "categoria": selectedCategoria,
      "tipo": selectedTipo,
      "valor": valor
    });
```

### Mutation

```dart
    var query = '''
              subscription getProdutos {
                produto {
                  id
                  nome
                  valor
                  tipo_produto {
                    descricao
                  }
                  categoria_produto {
                    descricao
                  }
                }
              }''';

    var snapshot = await _hasuraConnect.subscription(query);

    var stream = snapshot.map((data) {
      return ProdutoModel.fromJsonList(data["data"]["produto"]) ?? [];
    });
```

Welcome to Hasura Connect!
