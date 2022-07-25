import 'package:hasura_connect/hasura_connect.dart';
import 'package:test/test.dart';

void main() {
  test('map snapshot', () {
    final snapshot = Snapshot(query: const Query(document: 'null'));
    final snapshot2 = snapshot.map((event) => event.toString());
    snapshot.add(1);
    expect(
      snapshot2,
      emitsInOrder(['1', '2']),
    );
    snapshot.add(2);
  });

  test('map snapshot emit error', () {
    final snapshot = Snapshot(query: const Query(document: 'null'));
    expect(snapshot, emitsError(isA<Exception>()));
    snapshot.addError(Exception());
  });

  test('change variables', () {
    var isCalled = false;
    final snapshot = Snapshot(
      query: const Query(document: 'null'),
      changeVariablesF: (Snapshot snap) {
        isCalled = true;
      },
    );
    snapshot.changeVariables({'header': 'test'});
    expect(isCalled, true);
    expect(snapshot.query.variables, isNotNull);
  });
}
