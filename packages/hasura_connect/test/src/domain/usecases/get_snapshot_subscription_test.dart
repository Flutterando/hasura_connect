import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:hasura_connect/src/domain/models/request.dart';
import 'package:hasura_connect/src/domain/usecases/get_snapshot_subscription.dart';
import 'package:test/test.dart';

void main() {
  late GetSnapshotSubscription usecase;
  const url = 'https://hasura-fake.com';
  setUp(() {
    usecase = GetSnapshotSubscriptionImpl();
  });

  test('should return Snapshot', () async {
    final result = usecase(
      request: Request(
        url: url,
        type: RequestType.subscription,
        query: const Query(document: 'subscription', key: 'fdsfsffs'),
      ),
    );
    final snapshot = result.right;
    expect(
      snapshot,
      emitsInOrder([
        'test 1',
        'test 2',
        'test 3',
      ]),
    );
    snapshot
      ..add('test 1')
      ..add('test 2')
      ..add('test 3');
  });

  test('should throw InvalidRequestError if Query.document is invalid', () {
    final result = usecase(
      request: Request(
        url: url,
        type: RequestType.subscription,
        query: const Query(document: '', key: 'fdsfsffs'),
      ),
    );
    expect(result.left, isA<InvalidRequestError>());
  });
  test('should throw InvalidRequestError if Document is not a subscription',
      () {
    final result = usecase(
      request: Request(
        url: url,
        type: RequestType.subscription,
        query: const Query(document: 'mutation', key: 'fdsfsffs'),
      ),
    );
    expect(result.left, isA<InvalidRequestError>());
  });

  test('should throw InvalidRequestError if invalid key', () {
    final result = usecase(
      request: Request(
        url: url,
        type: RequestType.subscription,
        query: const Query(document: 'subscription', key: ''),
      ),
    );
    expect(result.left, isA<InvalidRequestError>());
  });

  test('should throw InvalidRequestError if type request is not subscription',
      () {
    final result = usecase(
      request: Request(
        url: url,
        type: RequestType.query,
        query: const Query(document: 'subscription', key: 'dadas'),
      ),
    );
    expect(result.left, isA<InvalidRequestError>());
  });

  test('should throw InvalidRequestError if Url is invalid', () {
    final result = usecase(
      request: Request(
        url: '',
        type: RequestType.subscription,
        query: const Query(document: 'subscription', key: 'fdsfsffs'),
      ),
    );
    expect(result.isLeft, true);

    expect(
      result.left,
      isA<InvalidRequestError>(),
    );
  });
}
