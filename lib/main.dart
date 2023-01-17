import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordle_clone_flutter/bloc/wordle_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WordleBloc()
        ..add(
          LoadGame(),
        ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(),
        home: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Wordle',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: SizedBox.expand(
            child: BlocBuilder<WordleBloc, WordleState>(
              builder: (context, state) {
                double width = MediaQuery.of(context).size.width * 0.6 / 5;
                Size size = Size(width * 5 + 115, width * 6.5 + 115);
                if (state.status.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
                return Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox.fromSize(
                      size: size,
                      child: GridView.count(
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        crossAxisCount: 5,
                        children: buildGrid(state),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    if (state.status.isPlaying) ...[
                      const Keyboard()
                    ] else if (state.status.isFinished) ...[
                      const Text("Game Over"),
                      ElevatedButton(
                        onPressed: () {
                          context.read<WordleBloc>().add(RestartGame());
                        },
                        child: const Text("Restart"),
                      )
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildGrid(WordleState state) {
    List<Widget> grid = [];
    for (var box in state.grid) {
      grid.add(
        Container(
          child: Text(
            box.letter,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _getColor(box.status),
            border: Border.all(
              color: Colors.black,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
    return grid;
  }

  Color _getColor(BoxStatus status) {
    if (status.isIncorrect) {
      return Colors.grey;
    } else if (status.isCorrect) {
      return Colors.green;
    } else if (status.isInCorrectPlace) {
      return Colors.orange;
    }
    return Colors.transparent;
  }
}

class Keyboard extends StatelessWidget {
  const Keyboard({Key? key}) : super(key: key);
  static const List<List<String>> keyboard = [row1, row2, row3];
  static const List<String> row1 = [
    'q',
    'w',
    'e',
    'r',
    't',
    'y',
    'u',
    'i',
    'o',
    'p'
  ];
  static const List<String> row2 = [
    'a',
    's',
    'd',
    'f',
    'g',
    'h',
    'j',
    'k',
    'l'
  ];
  static const List<String> row3 = [
    'back',
    'z',
    'x',
    'c',
    'v',
    'b',
    'n',
    'm',
    'enter',
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (List e in keyboard)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < e.length; i++)
                KeyboardKey(letter: e[i].toUpperCase()),
            ],
          ),
      ],
    );
  }
}

class KeyboardKey extends StatelessWidget {
  final String letter;
  const KeyboardKey({Key? key, required this.letter}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (letter == 'enter'.toUpperCase()) {
          context.read<WordleBloc>().add(SubmitGuess());
        } else if (letter == 'Back'.toUpperCase()) {
          context.read<WordleBloc>().add(DeleteLetter());
        } else {
          context.read<WordleBloc>().add(EnterLetter(letter: letter));
        }
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        width: letter.length == 1 ? 30 : 60,
        alignment: Alignment.center,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.grey[350],
          borderRadius: BorderRadius.circular(5),
        ),
        child: letter.length == 1
            ? Text(
                letter,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              )
            : letter == 'enter'.toUpperCase()
                ? const Icon(
                    Icons.subdirectory_arrow_left,
                    size: 30,
                  )
                : const Icon(
                    Icons.arrow_right_alt,
                    size: 45,
                  ),
      ),
    );
  }
}
