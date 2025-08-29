import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:fun_finder/helpers/helpers.dart';
import 'package:showcaseview/showcaseview.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<int> numbers = List.generate(9, (index) => index + 1);
  int? randomNumber;
  List<int> shuffledNumbers = [];
  int wrongCount = 0;
  bool gameStarted = false;
  List<Image> images;
  bool gameOver = false;
  bool showCorrectAnswer = false;
  bool animationStartedBtn = false;
  late ConfettiController _confettiController;
  final AudioPlayer player = AudioPlayer();

  final GlobalKey _startGameBtnKey = GlobalKey();
  final GlobalKey _searchForKey = GlobalKey();
  final GlobalKey _wrongAttemptsKey = GlobalKey();
  final GlobalKey _gridViewKey = GlobalKey();

  _HomeViewState()
    : images = List.generate(
        9,
        (index) =>
            Image.asset('assets/images/icon_gift.png', width: 100, height: 100),
      );

  @override
  void initState() {
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShowCaseWidget.of(context).startShowCase([
        _startGameBtnKey,
        _searchForKey,
        _wrongAttemptsKey,
        _gridViewKey,
      ]);
    });

    super.initState();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    player.dispose();
    super.dispose();
  }

  void startGame() {
    setState(() {
      shuffledNumbers = List.from(numbers)..shuffle();
      randomNumber = shuffledNumbers[Random().nextInt(shuffledNumbers.length)];
      wrongCount = 0;
      gameStarted = true;
      showCorrectAnswer = false;
      gameOver = false;
      // animationStartedBtn = false;
      images = List.generate(
        9,
        (index) => Image.asset('assets/images/icon_gift.png'),
      );
    });
  }

  void checkAnswer(int index) {
    if (!gameStarted || gameOver) return;

    if (shuffledNumbers[index] == randomNumber) {
      setState(() {
        gameOver = true;
      });

      _confettiController.play();
      player.play(AssetSource('sounds/success.mp3'));
      showCorrectAnswer = false;
    } else {
      wrongCount++;
      if (wrongCount == 3) {
        setState(() {
          showCorrectAnswer = true;
          gameOver = true;
        });

        player.play(AssetSource('sounds/fail.mp3'));
      }
    }
    setState(() {
      images[index] = Image.asset(
        'assets/images/test_colorful_number/${shuffledNumbers[index]}.png',
        width: 50,
        height: 50,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Search for',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Showcase(
                    key: _searchForKey,
                    description: 'You need to find this number',
                    child: Image.asset(
                      'assets/images/test_colorful_number/${randomNumber ?? 0}.png',
                      // 'assets/images/colorful_numbers/${1}.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                  SizedBox(height: 10),
                  Showcase(
                    key: _wrongAttemptsKey,
                    description: 'Shows your wrong attempts & You have only 3 attempts',
                    child: Text(
                      'Wrong Attempts: $wrongCount',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  SizedBox(height: 10),
                  Showcase(
                    key: _gridViewKey,
                    description: 'Tap on the boxes to find the correct number',
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1,
                      ),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        bool isCorrectTile =
                            showCorrectAnswer &&
                            shuffledNumbers[index] == randomNumber;
                        return GestureDetector(
                          onTap: () => checkAnswer(index),
                          child: Container(
                            margin: EdgeInsets.all(8.0),
                            child: isCorrectTile
                                ?  Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Helpers.primaryColor, width: 4),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Helpers.primaryColor.withOpacity(0.6),
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(8),
                              child: Image.asset(
                                'assets/images/test_colorful_number/$randomNumber.png',
                                width: 50,
                                height: 50,
                              ),
                            )
                                : images[index],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: startGame,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      backgroundColor: Helpers.primaryColor,
                    ),
                    child: Showcase(
                      key: _startGameBtnKey,
                      description: 'Click to start the game',
                      child: Text(
                        'Start Game',
                        style: TextStyle(color: Helpers.SecondaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                gravity: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
