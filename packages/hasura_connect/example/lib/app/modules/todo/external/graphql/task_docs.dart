abstract class TaskDocs {
  static String watch() {
    return r'''
    subscription TaskSnapshot {
      todo {
        todo
        id
      }
    }
    ''';
  }
}
