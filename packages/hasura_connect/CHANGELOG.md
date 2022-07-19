## 4.0.0+2
- BREAK CHANGE: Added HasuraConnect instance in Request, Response and Error in Interceptors;
- Added headers property in `HasuraConnect.query` and `HasuraConnect.mutation`;

## 3.0.4-dev.2
- Fix Bug: an operation already exists with this id
- Migrate Mockito to Mocktail

## 3.0.4-dev.1
- Export Query Model
- Add function to Execute Mutation, Query and Subscription execQuery(Query query), execMutation(Query query) and execSubscription(Query query)


## 3.0.4
- Remove  invalid url launch

## 3.0.0-nullsafety.0
- Migration to nullsafety

## 2.0.0
- New Release

## 1.2.2+
- Fix bugs
- Added cleanCache in Hasura instance
- Added LocalStorageInMemory


## 1.2.1
- Added LocalStorage Delegates (LocalStorageSharedPreferences, LocalStorageHive)
- Remove RXDART dependecy

## 1.1.1

- fix errors.

## 1.0.5

- Change cache engine (hive to Sharepreferences)
- Fix id snapshot errors (uuid)

## 1.0.4

- Update RXDART to v0.23.x

## 1.0.3

- Fix not close snapshot error
- improve cache.

## 1.0.2

- Added Flutter Web Cache offline for PWA.
- added request with variable cache.

## 1.0.0+2

- Cache offline for Subscription and Query (CachedQuery).
- When mutation fails due to no connection, HasuraConnect will retry when you have internet.
- Refactored Snapshot.
- Error Handling.

## 0.2.0

- Added Subscription Cache.
- fix error #9
- fix Duplicate error
- close streams subscriptions
- Added isError in token Function

## 0.1.2

- fix start stream with value

## 0.1.0

- Mapped Subscriptions
- Mutation in Snapshot

## 0.0.8

- Flutter web Support.

## 0.0.7+1

- Apply Health suggestions.

## 0.0.7

- Add and Remove Headers

## 0.0.6

- Added variables.
- Change Variables in subscriptions (for Reactive Pagination)
- Mutations links

## 0.0.3

- Add variable;
- Add mutation;

## 0.0.2

- Query return param data;

## 0.0.1

- Initial version, created by Stagehand