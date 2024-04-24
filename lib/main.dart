// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

// Actions
abstract class AppAction {}

class RootIncrease extends AppAction {}

// Root State
class AppState {
  int rootCount;
  ChildOneState? childOneState;
  ChildTwoState? childTwoState;

  AppState({
    required this.rootCount,
    this.childOneState,
    this.childTwoState,
  });

  AppState copyWith({
    int? rootCount,
    ChildOneState? childOneState,
    ChildTwoState? childTwoState,
  }) {
    return AppState(
      rootCount: rootCount ?? this.rootCount,
      childOneState: childOneState ?? this.childOneState,
      childTwoState: childTwoState ?? this.childTwoState,
    );
  }
}

// Reducers
int rootCounterIncreaseReducer(AppState state, dynamic action) {
  if (action is RootIncrease) {
    return state.rootCount + 1;
  }

  return state.rootCount;
}

// App
void main() {
  final store = Store<AppState>(
    (AppState state, action) => AppState(
      rootCount: rootCounterIncreaseReducer(state, action),
      childOneState: childOneReducer(state.childOneState, action),
      childTwoState: childTwoReducer(state.childTwoState, action),
    ),
    initialState: AppState(rootCount: 0),
  );

  runApp(FlutterStoreApp(
    title: 'Flutter Store POC',
    store: store,
  ));
}

class FlutterStoreApp extends StatelessWidget {
  final Store<AppState> store;
  final String title;

  const FlutterStoreApp({
    Key? key,
    required this.store,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        theme: ThemeData.dark(),
        title: title,
        home: Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 50),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: ChildOne()),
                  Expanded(child: ChildTwo()),
                  Container(
                    margin: const EdgeInsets.all(10),
                    height: 150,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: StoreConnector<AppState, int>(
                            distinct: true,
                            converter: (store) => store.state.rootCount,
                            builder: (context, count) {
                              print('Root (distinct): root count rebuilt');
                              return Text(
                                'White Count: $count',
                                style: Theme.of(context).textTheme.bodyMedium,
                              );
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: StoreConnector<AppState, int>(
                            distinct: false,
                            converter: (store) => store.state.childOneState?.count ?? 0,
                            builder: (context, count) {
                              print('Root: Child one count rebuilt');
                              return Text(
                                'Red Count: $count',
                                style: Theme.of(context).textTheme.bodyMedium,
                              );
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: StoreConnector<AppState, int>(
                            distinct: true,
                            converter: (store) => store.state.childTwoState?.count ?? 0,
                            builder: (context, count) {
                              print('Root (distinct): Child two count rebuilt');
                              return Text(
                                'Yellow Count: $count',
                                style: Theme.of(context).textTheme.bodyMedium,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        StoreConnector<AppState, VoidCallback>(
                          converter: (store) {
                            return () => store.dispatch(RootIncrease());
                          },
                          builder: (context, callback) {
                            return Container(
                              width: 30,
                              height: 30,
                              margin: const EdgeInsets.all(10),
                              child: FloatingActionButton(
                                backgroundColor: Colors.white,
                                onPressed: callback,
                                tooltip: 'Increment',
                                child: Icon(Icons.add),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Red
class ChildOneIncrease extends AppAction {}

class ChildOneState {
  final int count;

  ChildOneState({required this.count});

  ChildOneState copyWith({int? count}) {
    return ChildOneState(count: count ?? this.count);
  }
}

ChildOneState childOneReducer(ChildOneState? state, dynamic action) {
  state ??= ChildOneState(count: 0);

  if (action is ChildOneIncrease) {
    return state.copyWith(count: state.count + 1);
  }

  return state;
}

class ChildOne extends StatelessWidget {
  const ChildOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 246, 50, 50), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: StoreConnector<AppState, int>(
              distinct: false,
              converter: (store) => store.state.rootCount,
              builder: (context, count) {
                print('Red: root count rebuilt');
                return Text(
                  'White Count: $count',
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: StoreConnector<AppState, int>(
              distinct: true,
              converter: (store) => store.state.childOneState?.count ?? 0,
              builder: (context, count) {
                print('Red (distinct): Child one count rebuilt');
                return Text(
                  'Red Count: $count',
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: StoreConnector<AppState, int>(
              distinct: false,
              converter: (store) => store.state.childTwoState?.count ?? 0,
              builder: (context, count) {
                print('Red: Child two count rebuilt');
                return Text(
                  'Yellow Count: $count',
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          StoreConnector<AppState, VoidCallback>(
            converter: (store) {
              return () => store.dispatch(ChildOneIncrease());
            },
            builder: (context, callback) {
              return Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.all(10),
                child: FloatingActionButton(
                  backgroundColor: Color.fromARGB(255, 246, 50, 50),
                  onPressed: callback,
                  tooltip: 'Increment',
                  child: Icon(Icons.add),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

// ChildTwo
class ChildTwoIncrease extends AppAction {}

class ChildTwoState {
  final int count;

  ChildTwoState({required this.count});

  ChildTwoState copyWith({int? count}) {
    return ChildTwoState(count: count ?? this.count);
  }
}

ChildTwoState childTwoReducer(ChildTwoState? state, dynamic action) {
  state ??= ChildTwoState(count: 0);

  if (action is ChildTwoIncrease) {
    return state.copyWith(count: state.count + 1);
  }

  return state;
}

class ChildTwo extends StatelessWidget {
  const ChildTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 207, 243, 24), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: StoreConnector<AppState, int>(
              distinct: true,
              converter: (store) => store.state.rootCount,
              builder: (context, count) {
                print('Yellow (distinct): root count rebuilt');
                return Text(
                  'White Count: $count',
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: StoreConnector<AppState, int>(
              distinct: false,
              converter: (store) => store.state.childOneState?.count ?? 0,
              builder: (context, count) {
                print('Yellow: Child one count rebuilt');
                return Text(
                  'Red Count: $count',
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: StoreConnector<AppState, int>(
              distinct: true,
              converter: (store) => store.state.childTwoState?.count ?? 0,
              builder: (context, count) {
                print('Yellow (distinct): Child two count rebuilt');
                return Text(
                  'Yellow Count: $count',
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          StoreConnector<AppState, VoidCallback>(
            converter: (store) {
              return () => store.dispatch(ChildTwoIncrease());
            },
            builder: (context, callback) {
              return Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.all(10),
                child: FloatingActionButton(
                  backgroundColor: Color.fromARGB(255, 207, 243, 24),
                  onPressed: callback,
                  tooltip: 'Increment',
                  child: Icon(Icons.add),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
