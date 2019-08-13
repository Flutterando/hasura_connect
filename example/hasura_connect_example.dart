import 'package:hasura_connect/hasura_connect.dart';

import 'model_data.dart';

main() async {
  HasuraConnect conn =
      HasuraConnect('https://mvp-rtc-project.herokuapp.com/v1/graphql');

  // var r = await conn.query(docQuery);
  // print(r);

  var snap = conn.subscription(docSubscription).map((data) =>
      (data["data"]["users"] as List)
          .map((d) => ModelData.fromJson(d))
          .toList());

  snap.stream.listen((data) {
    print(data);
    print("==================");
  }).onError((err) {
    print(err);
  });

  await Future.delayed(Duration(seconds: 4));
  print("--- Add again --- ");

  await snap.mutation(docMutation,
      variables: {"email": "jjj@gmail.com", "pass": "123456"},
      onNotify: (data) {
    return data..insert(0, ModelData(userEmail: "jjj@gmail.com"));
  });
}

String docSubscription = """
  subscription {
  users(order_by: {user_id: desc}) {
    user_id
    user_email
    user_password
  }
}
""";

String docMutation = """
  mutation Add(\$email: String!, \$pass: String!){
    insert_users(objects: {user_email: \$email, user_password: \$pass}) {
      affected_rows
    }
  }
""";

String docQuery = """
  query {
    users {
        user_id
        user_email
        user_password
      }
  }
""";
