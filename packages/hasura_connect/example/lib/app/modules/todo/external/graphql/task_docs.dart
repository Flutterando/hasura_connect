abstract class TaskDocs {
  static String watch() {
    return r'''
    subscription TaskSnapshot {
      todo(order_by: {id: desc}) {
        id
        todo
        value
      }
    }
    ''';
  }

  static String create() {
    return r'''
    mutation CreateTask($description: String) {
      insert_todo(objects: {todo: $description}) {
        returning {
          id
          todo
        }
      }
    }
    ''';
  }

  static String delete() {
    return r'''
    mutation DeleteTask($id: Int) {
      delete_todo(where: {id: {_eq: $id}}) {
        returning {
          id
          todo
        }
      }
    }
    ''';
  }
}
