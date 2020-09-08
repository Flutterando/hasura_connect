import 'package:hasura_connect/hasura_connect.dart';

import '../models/produto_dto.dart';

class AddProdutoRepository {
  final HasuraConnect _hasuraConnect;

  AddProdutoRepository(this._hasuraConnect);

  Future<ProdutoDto> getProduto() async {
    var query = ''' 
            query getProduct {
                  product {
                    id
                    nome                  
                  }
              }
           ''';

    var snapshot = await _hasuraConnect.query(query);

    return ProdutoDto.fromMap(snapshot["data"]);
  }

  Future<bool> addproduto(String descricao) async {
    var mutation = r''' 
                  mutation addProduct($descricao: String) {
                    insert_product(objects: {descricao: $descricao}) {
                      affected_rows
                    }
                  }
              ''';

    var snapshot = await _hasuraConnect.mutation(mutation, variables: {
      "descricao": descricao,
    });

    return snapshot["data"]["insert_produto"]["affected_rows"] > 0;
  }

  Future<Snapshot<List<ProdutoDto>>> getProdutoStream() async {
    var query = '''
              subscription getProducts {
                product {
                  id
                  nome                  
                }
              }''';

    var snapshot = await _hasuraConnect.subscription(query);

    return snapshot.map((data) {
      if (data == null) {
        return null;
      }
      return ProdutoDto.fromJsonList(data["data"]["produto"]);
    });
  }
}
