---
sidebar_position: 9
---

# Dispose

HasuraConnect provides a dispose() method for use in Provider or BlocProvider.
Subscription will start only when someone is listening, and when all listeners are closed HasuraConnect automatically disconnects.

Therefore, we only connect to Hasura when we are actually using it;
