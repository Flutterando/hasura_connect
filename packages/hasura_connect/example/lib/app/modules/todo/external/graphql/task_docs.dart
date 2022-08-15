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
}
