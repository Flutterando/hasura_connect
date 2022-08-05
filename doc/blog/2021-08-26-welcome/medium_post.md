---
slug: Flutter + Hasura
title: Flutter + Hasura
authors: [ian]
tags: [facebook, hello, docusaurus]
---

# Flutter + Hasura

![](https://cdn-images-1.medium.com/max/2000/1*vYiJ3zUondrwE8JahNDqvw.png)

Fala galera, tudo blz? Hoje vamos aprender como integrar o seu app flutter ao hasura, os dois são uma combinação muito boa para a construção de aplicativos [3factor](https://hasura.io/blog/tagged/3factor/). Onde a mesma se refere a uma arquitetura moderna para aplicativos full stack, descritos pelo pessoal da [Hasura](https://hasura.io/), mais detalhes sobre o assunto você pode encontrar nesse post do [CodingBlocks](https://dev.to/codingblocks/3factor-app-realtime-graphql).

## Conhecendo o GraphQL

GraphQl é uma linguagem de consulta de APIS criado pelo facebook, com ele podemos desenvolver APIS mais rápidas, flexíveis e intuitivas para os desenvolvedores. Como uma alternativa ao REST, o GraphQL se torna interessante pois proporciona construir requisições que extraem os dados de várias fontes em uma única requisição, ou seja, trazemos exatamente o que precisamos através da construção de queries.

Para fazermos uma consulta no GraphQL, teríamos algo parecido com isso:

    query {
       posts {
          likes
          comments
          shares
       }
    }

Declaramos uma consulta com query e indicamos que queremos um campo com o nome posts.

## **Conhecendo o Hasura**

O hasura é uma engine de código aberto que oferece uma API GraphQL em tempo real baseada em um banco de dados Postgres de comunicação instantânea. O mecanismo vem com painel de administrador para ajudá-lo a explorar suas APIs GraphQL e gerenciar seu esquema de banco de dados. Utilizando o hasura podemos construir automaticamente um back-end para os nossos aplicativos baseados em dados além de ajudar a acelerar o desenvolvimento do nosso front-end também.

![Hasura](https://cdn-images-1.medium.com/max/2000/0*cDLVGN-pUF82E10o.gif)_Hasura_

## Por que você deve usar Hasura?

Temos aqui 4 respostas para isso. Simplicidade, baixo custo em tempo real, velocidade de desenvolvimento e código aberto / comunidade.

- Simplicidade, fácil de aprender e a progressão da aprendizagem é inicialmente rápida.

- Baixo custo em relação ao firebase que é difícil de manter.

- Velocidade de desenvolvimento, aponte Hasura para seus bancos de dados e obtenha instantaneamente uma API rica em tempo real, sem interromper seus aplicativos existentes.

- Código aberto / comunidade, você pode ver todas as tarefas no GitHub e criar solicitações pull para contribuir com seu código [aqui](https://github.com/hasura/graphql-engine) .

## Iniciando com o Hasura

Bom, acesse a página do guia de [deploy ](https://hasura.io/docs/1.0/graphql/core/deployment/deployment-guides/heroku.html)do hasura, nesse tutorial vamos implantar o Hasura no [Heroku](https://www.heroku.com/), devido ser bem simples e fácil configurar, mas existe outras opções no site do hasura, para consultar acesse o [link ](https://hasura.io/docs/1.0/graphql/core/deployment/deployment-guides/index.html).

- Na [página de deploy no Heroku](https://docs.hasura.io/1.0/graphql/manual/getting-started/heroku-simple.html) basta clicar no botão roxo onde tem escrito **Deploy to Heroku.**

- Na pagina do Heroku que se abre, escolha um nome. Eu escolhi **hasura-flutter-example**, confira a foto abaixo.

![](https://cdn-images-1.medium.com/max/2000/1*1abz4ky4wSQCd6KlypAc6g.png)

- Clique em **Deploy App** e se tudo ocorreu bem, aparecerá a seguinte mensagem “Your app was successfully deployed” e seu Hasura estará publicado no Heroku em poucos segundos.

Agora clique na opção **View **para acessar o client do Hasura sendo executado. Confira a foto abaixo:

![](https://cdn-images-1.medium.com/max/2000/1*JG4NBjCsnO7UDhuO7PqWSg.png)

![Hasura implantado no heroku](https://cdn-images-1.medium.com/max/2690/1*bAnMAp303TPUoaubmy7MYA.png)_Hasura implantado no heroku_

## Criação de tabelas

Agora vamos começar criar nossas tabelas para mais tarde consumirmos esses dados em nosso aplicativo flutter, eu irei criar um cadastro simples de carros nesse exemplo.

1. Acesse a aba **Data, **na parte superior da tela e em seguida clique no botão amarelo **Create Table**.

1. Preencha os campos necessários para criação da tabela e no final da página clique em **Add Table**.

Eu criei uma tabela _cars_, com os campos _id_(Integer auto-increment), name(Text) e description(Text), sendo o *id *a _primary key_ (PK) da tabela.

![Criação da tabela **cars**](https://cdn-images-1.medium.com/max/2000/1*H2WOWDHEPXozDSjC7CZZ8Q.png)\*Criação da tabela **cars\***

## Inserção de dados na tabela

1. Ainda na aba **Data**, do lado esquerdo clique na tabela _cars._

1. Dentro de _cars_, acesse **Insert Row**.

1. Insira alguns dados e clique em **Save**.

![Inserindo dados](https://cdn-images-1.medium.com/max/2000/1*h_8bhFpWNGKNZxgjDm7fjA.png)_Inserindo dados_

Ótimo! Nosso back-end está pronto. Agora depois de cadastrado mais alguns registros, clique em **Browse Rows** para ver todos os dados na tabela.

![Listando os dados cadastrados](https://cdn-images-1.medium.com/max/2584/1*P6JdJ9SmHy5kYfr4oja0CA.png)_Listando os dados cadastrados_

## Realizando consultas na tabela

Agora vamos realizar uma consulta no painel usando o que o hasura tem de mais legal.

1. Clique na aba **GRAPHQL, **é nessa tela onde vamos pode realizar as consultas execultando nosssas querys graphql.

1. No lado esquerdo na seção **Explorer, **é onde poderemos criar nossas querys, apenas selecione quais campos você deseja trazer nessa consulta.

1. Na seção do meio chamada *GraphQl *vai mostrar nossa query com os campos que selecionamos no passo anterior.

1. E por último, clique na opção de play, do lado de _GraphQl para execultar nossa consulta e trazer nossos dados cadastrados._

Veja todo o processo na imagem abaixo:

![Execultando querys no hasura](https://cdn-images-1.medium.com/max/2530/1*5MoKzMvz_WvPH0gufE1I8g.png)_Execultando querys no hasura_

**_Perfeito!!! Não é?_**

> Agora que nossa API está feita, vamos iniciar a implementação do front-end usando flutter e o nosso maravilhoso package [hasura_connect ](https://pub.dev/packages/hasura_connect)criado pela comunidade [flutterando](https://flutterando.com.br/) para facilitar a integração.

## Implementação do aplicativo usando Flutter + Hasura.

Nesse exemplo, vamos criar um app bem simples para consumir nossos dados que estão no hasura. A ideia aqui é mostrar como é facil fazer essa integração para ter um aplicativo consumindo dados da nossa API graphQl sem muito trabalho.

![Aplicativo que vamos construir](https://cdn-images-1.medium.com/max/2000/1*WqngPBHLviZ_pNOxJpkSTg.png)_Aplicativo que vamos construir_

1.  Vamos começar adicionando a dependência ao nosso arquivo**\* pubspec.yaml. **No momento desse artigo o mesmo se encontra em sua versão mais nova 3.0.4\*

    dependencies:
    hasura_connect: ^3.0.4

2.  Instale o pacote a partir da linha de comando com o Flutter:

    $ flutter pub get

3.  Agora, no seu código Dart, você pode importar o package:

        **import** 'package:hasura_connect/hasura_connect.dart';

    > **Atenção!!!** Para criar esse exemplo, estou utilizando também os packages [flutter_modular ](https://pub.dev/packages/flutter_modular)para nos ajudar com injeção de dependências, rotas e o [mobx](https://pub.dev/packages/mobx) como gerenciador de estados. Se desejar saber um pouco mais sobre eles vou deixar esses dois posts abaixo:
    > [**Quais os problemas que o Flutter Modular veio resolver?** > *Olá devs,
    > Sempre gostei dessa pegada "Open Source" ao ponto de publicar tudo o que crio para usar, e isso já me gerou…*medium.com](https://medium.com/flutterando/quais-os-problemas-que-o-flutter-modular-veio-resolver-deaed96b71b3) > [**Guia completo do MobX** > *Você aprenderá como usar, organizar e testar a sua lógica de negócio com MobX.*medium.com](https://medium.com/flutterando/guia-completo-do-mobx-11d20391428e)

## **Criando o modelo para o parse dos dados.**

Iremos criar um modelo chamado CarModel que vai converter o retorno de *json *vindo do *graphql *para um objeto _dart_.

Dentro de **lib/app/modules/home **vamos criar uma pasta chamada **models **e adicionar um arquivo chamado: car_model.dart.

```dart
class CarModel {
  CarModel({
    required this.id,
    required this.name,
    required this.description,
  });

  final int id;
  final String name;
  final String description;

  factory CarModel.fromJson(Map<String, dynamic> json) => CarModel(
    id: json['id'] == null ? null : json['id'],
    name: json['name'] == null ? null : json['name'],
    description: json['description'] == null ? null : json['description'],
  );
}
```

- Na linha 12 criamos o método fromJson(), que vai deserializar nossos dados para um objeto dart CarModel.

## Criando o nosso repository para pegar os dados.

Agora vamos criar um _repository_, para isso, crie uma pasta chamada **repositories **e adicione um arquivo chamado: car_repository.dart. Nesse arquivo lib/app/modules/home/car_repository.dartque foi criado, crie um objeto da classeHasuraConnect e receba como parâmetro no construtor:

Confira como ficou abaixo:

```dart
import 'package:hasura_connect/hasura_connect.dart';
import 'package:flutter_hasura_app_example/app/modules/home/models/car_model.dart';

class CarRepository {
  final HasuraConnect _hasuraConnect;

  CarRepository(this._hasuraConnect);

  Future<List<CarModel>> getCars() async {
    List<CarModel> listCars = [];
    CarModel carModel;
    var query = '''
      query getCars {
        cars {
          id
          name
          description
        }
      }
    ''';

    var snapshot = await _hasuraConnect.query(query);
    for (var json in (snapshot['data']['cars']) as List) {
      carModel = CarModel.fromJson(json);
      listCars.add(carModel);
    }
    return listCars;
  }

  // novo método adicionado
  Future<String> addCard(String name, String description) async {
    var query = """
      mutation addCars(\$name:String!, \$description:String!) {
      insert_cars(objects: {name: \$name, description: \$description}) {
        affected_rows
        returning {
          name
        }
      }
    }
    """;
    var data = await _hasuraConnect.mutation(query, variables: {
      "name": name,
      "description": description,
    });
    return data["data"]['insert_cars']['returning'][0]['name'];
  }
}

```

- Na linha 9 criamos o método getCars() que fará a busca dos dados no Hasura.

- Na linha 22 passamos nossa query para o hasura.

- Da linha 23 até a 25 manipulamos o resultado e transformamos numa lista de objetos CarModel .

Para que funcione como o esperado, será necessário fazer a injeção de dependência em app_module.dart :

![app_module.d](https://cdn-images-1.medium.com/max/2000/1*h91AGO7ev4EGbfb___nC0g.png)_app_module.d_

- Na linha 9 injetamos nosso bind com uma instância de *HasuraConnect *passando a url do Hasura. Ela pode ser encontrada na aba **Data**, no campo **GraphQL Endpoint**.

![](https://cdn-images-1.medium.com/max/2000/1*Axdlg5hkhP2sc0RhpL2NvA.png)

## **Criando nossa Ui (User interface) para listar os dados**

Primeiramente, precisamos de um controller com o *mobx *para gerenciar nossos dados na tela, então vamos criar um em lib/app/modules/home/ crie o home_controller.dart:

```dart
import 'package:mobx/mobx.dart';

import 'package:flutter_hasura_app_example/app/modules/home/models/car_model.dart';
import 'package:flutter_hasura_app_example/app/modules/home/repositories/car_repository.dart';

part 'home_controller.g.dart';

class HomeController = _HomeControllerBase with _$HomeController;

abstract class _HomeControllerBase with Store {
  late CarRepository repository;
  _HomeControllerBase(this.repository);

  @observable
  List<CarModel> listCars = <CarModel>[].asObservable();

  @action
  getCars() async {
    listCars = await repository.getCars();
  }

  //novo método adicionado
  @action
  addCar() {
    repository.addCard(name, description);
    getCars();
  }
}
```

- Na linha 11 recuperamos por parâmetro uma intância do nosso repository injetado no HomeModule .

- Na linha 15 criamos uma variável de lista para receber nossos dados.

- Na linha 18 criamos um método chamado getCars() para atribuir o que vem do repository a nossa variavél criada acima.

### Injetando o controller

Para que funcione como o esperado, será necessário fazer a injeção de dependência em home\*module.dart do nosso \*\*\_controller **\*e do **_repository _\*\*que criamos no passo anterior:

![home_module.dart](https://cdn-images-1.medium.com/max/2000/1*L5Kqt9z4s2igzOqJXkaTuA.png)_home_module.dart_

**Criando a listagem dos carros**

vamos criar um em lib/app/modules/home/ crie o home_page.dart:

Confira o exemplo abaixo:

```dart

import 'package:flutter/material.dart';

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'home_controller.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeController controller = Modular.get();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    controller.getCars();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (controller.listCars.isEmpty) {
          return Container(
            child: Center(child: CircularProgressIndicator()),
            color: Colors.white,
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('Hasura Connect Example'),
            centerTitle: true,
          ),
          body: ListView.builder(
            itemCount: controller.listCars.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  child: Text(controller.listCars[index].id.toString()),
                ),
                title: Text(controller.listCars[index].name),
                subtitle: Text(controller.listCars[index].description),
              );
            },
          ),
          //novo widget adicionado
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context1) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      title: Text("Adicionar Novo"),
                      content: Form(
                        key: _formKey,
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TextFormField(
                                validator: (value) =>
                                    value!.isEmpty ? 'Preencha o campo' : null,
                                decoration: InputDecoration(
                                    labelText: "Nome do veículo"),
                                onChanged: controller.setName,
                              ),
                              TextFormField(
                                validator: (value) =>
                                    value!.isEmpty ? 'Preencha o campo' : null,
                                decoration:
                                    InputDecoration(labelText: "Descrição"),
                                onChanged: controller.setDescription,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      elevation: MaterialStateProperty.all(3.0),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ))),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      controller.addCar();
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text(
                                    "Salvar",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                            ]),
                      ),
                    );
                  });
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}
```

- Na linha 19 estamos chamando o método getCars() **_initState_**, assim que a tela for iniciada ele vai buscar nossos dados que estão salvos no **Hasura**.

- Na linha 28 adicionamos um [\*CircularProgressIndicator ](https://api.flutter.dev/flutter/material/CircularProgressIndicator-class.html)\*para esperar enquanto nossos dados carregam do banco de dados.

- Na linha 39 usamos um _ListView.builder_ para listar os carros que estão no **HomeController**.

![Resultado](https://cdn-images-1.medium.com/max/2000/1*tBiFv5P2X0Jbj5qbd5fQLA.png)_Resultado_

**_Lindo!!! Não é?_**

## **Adicionando a função de cadastro de novos carros**

Para adicionar um novo dado no hasura ou até mesmo atualizar um dado já existente precisamos utilizar uma **_mutation _**e não mais uma *query *como no exemplo anterior.

### Execultando mutations no Hasura

As [**\*mutations** ](https://hasura.io/docs/latest/graphql/core/databases/postgres/mutations/index.html)\*GraphQL são usadas para modificar dados no servidor (ou seja, gravar, atualizar ou excluir dados).

![execultando uma mutation no console](https://cdn-images-1.medium.com/max/2342/1*muhRzjEigYmV_s3BVKEeLg.png)_execultando uma mutation no console_

1. Clique no botão de + na parte inferior do explorer e selecione **Mutation.**

1. No **Explorer, **o hasura já mostra as possíveis mutations que você pode realizar, selecione a _insert_cars para conseguir cadastrar um novo registro e também selecione quais campos você deseja enviar. Observe que, como retorno estamos usando o campo **name **do carro para sinalizar que deu certo._

1. \*Em **QUERY VARIABLES \***crie uma espécie de json/map com os dados que irão ser submetidos ao servidor. No nosso app esses dados serão passados através do nosso formulário quando o usuario submeter os mesmos.

1. E, por fim clique na opção de play do lado de Graphql e veja sua *mutation *rodando e já mostrando resultados.

### Agora de volta ao flutter

Voltando ao nosso car_repository.dart na pasta chamada **repositories **adicione um novo método chamado addCars() e dentro dele vamos passar nossa *mutation *criada no console.

Confira como ficou baixo o código com o novo método:

```dart

import 'package:hasura_connect/hasura_connect.dart';
import 'package:flutter_hasura_app_example/app/modules/home/models/car_model.dart';

class CarRepository {
  final HasuraConnect _hasuraConnect;

  CarRepository(this._hasuraConnect);

  Future<List<CarModel>> getCars() async {
    List<CarModel> listCars = [];
    CarModel carModel;
    var query = '''
      query getCars {
        cars {
          id
          name
          description
        }
      }
    ''';

    var snapshot = await _hasuraConnect.query(query);
    for (var json in (snapshot['data']['cars']) as List) {
      carModel = CarModel.fromJson(json);
      listCars.add(carModel);
    }
    return listCars;
  }

  // novo método adicionado
  Future<String> addCard(String name, String description) async {
    var query = """
      mutation addCars(\$name:String!, \$description:String!) {
      insert_cars(objects: {name: \$name, description: \$description}) {
        affected_rows
        returning {
          name
        }
      }
    }
    """;
    var data = await _hasuraConnect.mutation(query, variables: {
      "name": name,
      "description": description,
    });
    return data["data"]['insert_cars']['returning'][0]['name'];
  }
}
```

- Na linha 31 criamos o método addCars() que fará o cadastro de novos dados no Hasura.

- Na linha 34 usamos nossa *mutation *criada no console.

- Na linha 44 dizemos ao hasura que queremos usar uma *mutation *e passamos a ela no parametro *variables *um _map nossos dados._

- Por último na linha 48 pegamos o retorno do nome do registro adicionado que nesse caso é um carro.

Para que funcione como o esperado, será necessário chamar o método de adicionar em nosso controller, o mesmo ainda não existe, então vamos criá-lo.

Confira o código abaixo:

```dart

import 'package:mobx/mobx.dart';

import 'package:flutter_hasura_app_example/app/modules/home/models/car_model.dart';
import 'package:flutter_hasura_app_example/app/modules/home/repositories/car_repository.dart';

part 'home_controller.g.dart';

class HomeController = _HomeControllerBase with _$HomeController;

abstract class _HomeControllerBase with Store {
  late CarRepository repository;
  _HomeControllerBase(this.repository);

  @observable
  List<CarModel> listCars = <CarModel>[].asObservable();

  @action
  getCars() async {
    listCars = await repository.getCars();
  }

  //novo método adicionado
  @action
  addCar() {
    repository.addCard(name, description);
    getCars();
  }
}

```

- Na linha 24 criamos o método addCar() em nosso controller, o mesmo chamará o *repository *passando os dados vindo do formulário preenchido pelo usuário.

- Na linha 26 fazemos uma chamada para o método getCars() para ser possível atualizar a nossa tela com os novos dados inseridos no banco.

### E por último… vamos criar nosso formulário no flutter para receber os dados para o cadastro de um novo registro.

Confira o código abaixo com essa adição apartir da linha 51:

```dart

import 'package:flutter/material.dart';

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'home_controller.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeController controller = Modular.get();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    controller.getCars();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (controller.listCars.isEmpty) {
          return Container(
            child: Center(child: CircularProgressIndicator()),
            color: Colors.white,
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('Hasura Connect Example'),
            centerTitle: true,
          ),
          body: ListView.builder(
            itemCount: controller.listCars.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  child: Text(controller.listCars[index].id.toString()),
                ),
                title: Text(controller.listCars[index].name),
                subtitle: Text(controller.listCars[index].description),
              );
            },
          ),
          //novo widget adicionado
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context1) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      title: Text("Adicionar Novo"),
                      content: Form(
                        key: _formKey,
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TextFormField(
                                validator: (value) =>
                                    value!.isEmpty ? 'Preencha o campo' : null,
                                decoration: InputDecoration(
                                    labelText: "Nome do veículo"),
                                onChanged: controller.setName,
                              ),
                              TextFormField(
                                validator: (value) =>
                                    value!.isEmpty ? 'Preencha o campo' : null,
                                decoration:
                                    InputDecoration(labelText: "Descrição"),
                                onChanged: controller.setDescription,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      elevation: MaterialStateProperty.all(3.0),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ))),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      controller.addCar();
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text(
                                    "Salvar",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                            ]),
                      ),
                    );
                  });
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}
```

- Na linha 57 criamos uma [\*AlertDialog ](https://api.flutter.dev/flutter/material/AlertDialog-class.html)*, *e*la aparece como um* pop-up\* no meio da tela que coloca uma sobreposição sobre o fundo. Como filho dessa dialog eu acrescentei o nosso form e um botão de salvar.

- Dar linha 89 a 93 no *onPressed d*o botão eu fiz uma validação para saber se os campos estão preenchidos, caso verdadeiro, podemos chamar o método de cadastrar o nosso novo carro no Hasura.
  > Sobre essa validação dos TextFields utilizando GlobalKey não irei entrar em detalhes nesse post, contudo você pode saber um pouco mais em: [http://www.macoratti.net/19/07/flut_fomval1.htm](http://www.macoratti.net/19/07/flut_fomval1.htm)

![Formulário pronto](https://cdn-images-1.medium.com/max/2000/1*s-T3f-Sduzou9Tyw22uwKg.png)_Formulário pronto_

### Aplicativo funcionando!!! 0/

![Resultado final](https://cdn-images-1.medium.com/max/2000/1*Vaanr1bwxaiMTfGeBAr9MQ.gif)_Resultado final_

## Link do GitHub para o código mostrado neste artigo

Todo o código deste artigo está disponível neste [link do GitHub](https://github.com/iang12/flutter_hasura_app_example).

## **Link da comunidade de Hasura no telegram:**

Não posso deixar de mencionar nesse post , a comunidade** [\*Hasura Brasi](https://t.me/hasurabr)l \***no [Telegram](https://t.me/hasurabr).

## [Referências](https://www.todamateria.com.br/referencias-abnt/)

- [https://hasura.io/blog/build-flutter-app-graphql-hasura-serverless-part1/](https://hasura.io/blog/build-flutter-app-graphql-hasura-serverless-part1/)

- [https://techcrunch.com/2020/06/22/hasura-launches-managed-cloud-service-for-its-open-source-graphql-api/](https://techcrunch.com/2020/06/22/hasura-launches-managed-cloud-service-for-its-open-source-graphql-api/)

- [https://blog.geekyants.com/flutter-graphql-with-hasura-d4d0b34621da](https://blog.geekyants.com/flutter-graphql-with-hasura-d4d0b34621da)

- [https://medium.com/flutterando/criando-um-master-detail-usando-flutter-e-graphql-f8c4bfb3c2e6](https://medium.com/flutterando/criando-um-master-detail-usando-flutter-e-graphql-f8c4bfb3c2e6)

- [https://medium.com/trainingcenter/graphql-para-iniciantes-a4cbe6c3da5d](https://medium.com/trainingcenter/graphql-para-iniciantes-a4cbe6c3da5d)

## Conclusão

Bom flutter devs, isso foi tudo rsrsr.. Obrigado se você leu até aqui. Acho que deu pra ver um pouco do grande potencial do hasura junto ao flutter utilizando o package _hasura_connect_. Vale ressaltar que o tema[ hasura.io ](https://hasura.io/)é muito vasto, sendo assim, abaixo vou deixar o link de mais contéudos feitos pela nossa comunidade sobre o assunto.

Acredito que, para quem não tem muita experiência para criar um backend do zero e quer usar um Baas **(back-end as a service)** como o Hasura, é uma das melhores alternativas, até mesmo se você quiser criar algo rápido como um [MPV ](https://endeavor.org.br/estrategia-e-gestao/mvp/)para mostrar para o seu cliente ou montar sua startup etc. Vale muito apena.

Espero que você tenha gostado! Caso haja alguma dúvida ou contribuição, deixe nos comentários!

Para mais assuntos de Flutter, procure os canais de comunicação da Flutterando: [https://linktr.ee/flutterando](https://linktr.ee/flutterando)

Para mais assuntos de Hasura, confira esse meetup onde convidei meu amigo arthur para falar de hasura no canal da flutterando. [https://www.youtube.com/watch?v=XtrEq55EFC4](https://www.youtube.com/watch?v=XtrEq55EFC4)

Confira essa live feita pelo canal do Flutter Angola onde eles também falam de Hasura. [https://www.youtube.com/watch?v=3ObcMCIZkos](https://www.youtube.com/watch?v=3ObcMCIZkos)

Ainda não faz parte da nossa comunidade do Telegram? Entre agora mesmo! [https://t.me/flutterando](https://t.me/flutterando)

Nos siga no Twitter: [https://twitter.com/flutterando\_](https://twitter.com/flutterando_)

Caso você queira me seguir: [https://twitter.com/ianoliveirag12](https://twitter.com/ianoliveirag12)

Meu LinkedIn: [https://www.linkedin.com/in/ian-oliveira-0701a2130/](https://www.linkedin.com/in/ian-oliveira-0701a2130/)
