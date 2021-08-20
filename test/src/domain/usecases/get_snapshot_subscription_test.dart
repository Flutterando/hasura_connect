import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/domain/usecases/get_snapshot_subscription.dart';
import 'package:test/test.dart';

void main() {
  late GetSnapshotSubscription usecase;
  final url = 'https://hasura-fake.com';
  setUp(() {
    usecase = GetSnapshotSubscriptionImpl();
  });

  test('should return Snapshot', () async {
    final result =
        await usecase(request: Request(url: url, type: RequestType.subscription, query: Query(document: 'subscription', key: 'fdsfsffs')));
    final snapshot = result.right;
    expect(
        snapshot,
        emitsInOrder([
          'test 1',
          'test 2',
          'test 3',
        ]));
    snapshot.add('test 1');
    snapshot.add('test 2');
    snapshot.add('test 3');
  });

  test('should throw InvalidRequestError if Query.document is invalid', () async {
    final result = await usecase(request: Request(url: url, type: RequestType.subscription, query: Query(document: '', key: 'fdsfsffs')));
    expect(result.left, isA<InvalidRequestError>());
  });
  test('should throw InvalidRequestError if Document is not a subscription', () async {
    final result =
        await usecase(request: Request(url: url, type: RequestType.subscription, query: Query(document: 'mutation', key: 'fdsfsffs')));
    expect(result.left, isA<InvalidRequestError>());
  });

  test('should throw InvalidRequestError if invalid key', () async {
    final result = await usecase(
      request: Request(
        url: url,
        type: RequestType.subscription,
        query: Query(document: 'subscription', key: ''),
      ),
    );
    expect(result.left, isA<InvalidRequestError>());
  });

  test('should throw InvalidRequestError if type request is not subscription', () async {
    final result = await usecase(
      request: Request(
        url: url,
        type: RequestType.query,
        query: Query(document: 'subscription', key: 'dadas'),
      ),
    );
    expect(result.left, isA<InvalidRequestError>());
  });

  test('should throw InvalidRequestError if Url is invalid', () async {
    final result =
        await usecase(request: Request(url: '', type: RequestType.subscription, query: Query(document: 'subscription', key: 'fdsfsffs')));
    expect(
      result.left,
      isA<InvalidRequestError>(),
    );
  });
}
