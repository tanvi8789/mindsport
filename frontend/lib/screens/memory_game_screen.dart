import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:mindsport/main.dart';
import 'package:mindsport/screens/sidebar.dart';

class MemoryGameScreen extends StatefulWidget {
const MemoryGameScreen({super.key});

@override
State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
List<CardItem> cards = [];
CardItem? firstCard;
CardItem? secondCard;
bool isChecking = false;
int moves = 0;
int matchedPairs = 0;
int score = 0;
bool gameCompleted = false;
Timer? timer;
int secondsElapsed = 0;
bool isGameActive = false;

final List<String> emojis = [
'🧠', '⚽', '🏆', '💪', '🌟', '🎯',
'🔥', '🌈', '✨', '⚡', '🎮', '🏃'
];

@override
void initState() {
super.initState();
_resetGame();
}

@override
void dispose() {
timer?.cancel();
super.dispose();
}

void _resetGame() {
timer?.cancel();
setState(() {
List<String> pairs = List<String>.from(emojis);
pairs.shuffle();
pairs = pairs.sublist(0, 6); // 6 pairs = 12 cards

cards = [];
for (String emoji in pairs) {
cards.add(CardItem(emoji: emoji));
cards.add(CardItem(emoji: emoji));
}
cards.shuffle();

firstCard = null;
secondCard = null;
isChecking = false;
moves = 0;
matchedPairs = 0;
score = 0;
gameCompleted = false;
secondsElapsed = 0;
isGameActive = false;
});
}

void _startTimer() {
if (!isGameActive) {
isGameActive = true;
timer = Timer.periodic(const Duration(seconds: 1), (timer) {
setState(() {
secondsElapsed++;
});
});
}
}

void _onCardTap(CardItem card) {
if (isChecking || card.isMatched || card == firstCard) return;

_startTimer();

if (firstCard == null) {
setState(() {
firstCard = card;
card.isFlipped = true;
});
} else if (secondCard == null) {
setState(() {
secondCard = card;
card.isFlipped = true;
moves++;
isChecking = true;
});

// Check for match
Future.delayed(const Duration(milliseconds: 800), () {
if (firstCard!.emoji == secondCard!.emoji) {
setState(() {
firstCard!.isMatched = true;
secondCard!.isMatched = true;
matchedPairs++;
score += 100 - (secondsElapsed ~/ 2);
});

if (matchedPairs == 6) {
_endGame();
}
} else {
setState(() {
firstCard!.isFlipped = false;
secondCard!.isFlipped = false;
});
}

setState(() {
firstCard = null;
secondCard = null;
isChecking = false;
});
});
}
}

void _endGame() {
timer?.cancel();
setState(() {
gameCompleted = true;
score += (300 - secondsElapsed) * 2; // Time bonus
});
}

@override
Widget build(BuildContext context) {
return Scaffold(
drawer: const AppSidebar(),
appBar: AppBar(
title: const Text('Memory Match'),
backgroundColor: Colors.transparent,
elevation: 0,
iconTheme: const IconThemeData(color: MindSportTheme.darkText),
),
body: Stack(
children: [
CustomPaint(
painter: _BackgroundPainter(),
size: Size.infinite,
),

Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
children: [
// Game Stats
Card(
color: Colors.white.withOpacity(0.85),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(20),
),
child: Padding(
padding: const EdgeInsets.all(16.0),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceAround,
children: [
_buildStatItem(Icons.timer, '${secondsElapsed}s', 'Time'),
_buildStatItem(Icons.directions_run, '$moves', 'Moves'),
_buildStatItem(Icons.star, '$score', 'Score'),
],
),
),
),

const SizedBox(height: 20),

// Game Grid
Expanded(
child: GridView.builder(
gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 4,
crossAxisSpacing: 10,
mainAxisSpacing: 10,
childAspectRatio: 0.9,
),
itemCount: cards.length,
itemBuilder: (context, index) {
return _buildCard(cards[index]);
},
),
),

// Game Controls
Padding(
padding: const EdgeInsets.only(top: 20, bottom: 20),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceEvenly,
children: [
ElevatedButton.icon(
onPressed: _resetGame,
style: ElevatedButton.styleFrom(
backgroundColor: Colors.white,
foregroundColor: MindSportTheme.primaryGreen,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(25),
),
padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
),
icon: const Icon(Icons.refresh),
label: const Text('Restart Game'),
),

ElevatedButton.icon(
onPressed: () {
if (!gameCompleted && isGameActive) {
setState(() {
isGameActive = !isGameActive;
if (isGameActive) {
_startTimer();
} else {
timer?.cancel();
}
});
}
},
style: ElevatedButton.styleFrom(
backgroundColor: MindSportTheme.primaryGreen,
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(25),
),
padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
),
icon: Icon(isGameActive ? Icons.pause : Icons.play_arrow),
label: Text(isGameActive ? 'Pause' : 'Resume'),
),
],
),
),
],
),
),

// Game Completed Overlay
if (gameCompleted)
Container(
color: Colors.black.withOpacity(0.85),
child: Center(
child: Card(
color: Colors.white.withOpacity(0.95),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(30),
),
child: Padding(
padding: const EdgeInsets.all(32.0),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
const Icon(
Icons.celebration,
size: 60,
color: Colors.amber,
),
const SizedBox(height: 20),
const Text(
'Congratulations!',
style: TextStyle(
fontSize: 28,
fontWeight: FontWeight.bold,
color: MindSportTheme.darkText,
),
),
const SizedBox(height: 10),
Text(
'You matched all pairs!',
style: TextStyle(
fontSize: 18,
color: Colors.grey.shade700,
),
),
const SizedBox(height: 30),
Row(
mainAxisAlignment: MainAxisAlignment.spaceEvenly,
children: [
Column(
children: [
const Icon(Icons.timer, color: Colors.blue),
const SizedBox(height: 5),
Text(
'$secondsElapsed s',
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
],
),
Column(
children: [
const Icon(Icons.directions_run, color: Colors.green),
const SizedBox(height: 5),
Text(
'$moves moves',
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
],
),
Column(
children: [
const Icon(Icons.star, color: Colors.amber),
const SizedBox(height: 5),
Text(
'$score pts',
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
],
),
],
),
const SizedBox(height: 30),
ElevatedButton(
onPressed: _resetGame,
style: ElevatedButton.styleFrom(
backgroundColor: MindSportTheme.primaryGreen,
foregroundColor: Colors.white,
padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(25),
),
),
child: const Text('Play Again'),
),
],
),
),
),
),
),
],
),
);
}

Widget _buildCard(CardItem card) {
return GestureDetector(
onTap: () => _onCardTap(card),
child: AnimatedContainer(
duration: const Duration(milliseconds: 400),
curve: Curves.easeInOut,
decoration: BoxDecoration(
color: card.isFlipped || card.isMatched
? (card.isMatched ? MindSportTheme.softGreen : Colors.white)
    : MindSportTheme.primaryGreen,
borderRadius: BorderRadius.circular(15),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.1),
blurRadius: 5,
offset: const Offset(0, 3),
),
],
),
child: Center(
child: AnimatedSwitcher(
duration: const Duration(milliseconds: 300),
child: card.isFlipped || card.isMatched
? Text(
card.emoji,
style: const TextStyle(fontSize: 32),
)
    : const Icon(
Icons.question_mark,
color: Colors.white,
size: 28,
),
),
),
),
);
}

Widget _buildStatItem(IconData icon, String value, String label) {
return Column(
children: [
Icon(icon, color: MindSportTheme.primaryGreen),
const SizedBox(height: 8),
Text(
value,
style: const TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
color: MindSportTheme.darkText,
),
),
Text(
label,
style: const TextStyle(
fontSize: 12,
color: Colors.grey,
),
),
],
);
}
}

class CardItem {
final String emoji;
bool isFlipped;
bool isMatched;

CardItem({
required this.emoji,
this.isFlipped = false,
this.isMatched = false,
});
}

class _BackgroundPainter extends CustomPainter {
@override
void paint(Canvas canvas, Size size) {
const double blurSigma = 45.0;
final paint1 = Paint()
..color = MindSportTheme.softPeach.withOpacity(0.5)
..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);
final paint2 = Paint()
..color = MindSportTheme.softLavender.withOpacity(0.6)
..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);
final paint3 = Paint()
..color = MindSportTheme.softGreen.withOpacity(0.5)
..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);

canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.1), 150, paint1);
canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.3), 200, paint2);
canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 180, paint3);
}

@override
bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}