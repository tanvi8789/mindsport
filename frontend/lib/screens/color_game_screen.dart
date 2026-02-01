import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:mindsport/main.dart';
import 'package:mindsport/screens/sidebar.dart';

class ColorGameScreen extends StatefulWidget {
const ColorGameScreen({super.key});

@override
State<ColorGameScreen> createState() => _ColorGameScreenState();
}

class _ColorGameScreenState extends State<ColorGameScreen> with SingleTickerProviderStateMixin {
Color targetColor = Colors.red;
String targetColorName = "RED";
List<ColorButton> buttons = [];
int score = 0;
int lives = 3;
int level = 1;
bool gameOver = false;
bool gameStarted = false;
Timer? gameTimer;
int timeLeft = 60;
int correctInRow = 0;
int highScore = 0;
late AnimationController _pulseController;
bool _showFeedbackOverlay = false; // Renamed from _showFeedback
Color? _feedbackColor;
String _feedbackText = "";

final List<Color> gameColors = [
Colors.red,
Colors.blue,
Colors.green,
Colors.yellow,
Colors.orange,
Colors.purple,
Colors.pink,
Colors.teal,
];

final Map<Color, String> colorNames = {
Colors.red: "RED",
Colors.blue: "BLUE",
Colors.green: "GREEN",
Colors.yellow: "YELLOW",
Colors.orange: "ORANGE",
Colors.purple: "PURPLE",
Colors.pink: "PINK",
Colors.teal: "TEAL",
};

@override
void initState() {
super.initState();
_pulseController = AnimationController(
duration: const Duration(milliseconds: 1000),
vsync: this,
)..repeat(reverse: true);
_resetGame();
}

@override
void dispose() {
gameTimer?.cancel();
_pulseController.dispose();
super.dispose();
}

void _resetGame() {
gameTimer?.cancel();
setState(() {
score = 0;
lives = 3;
level = 1;
gameOver = false;
gameStarted = false;
timeLeft = 60;
correctInRow = 0;
_showFeedbackOverlay = false; // Reset feedback overlay
_generateNewRound();
});
}

void _startGame() {
setState(() {
gameStarted = true;
});

gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
if (!mounted) return;

setState(() {
timeLeft--;
if (timeLeft <= 0) {
_endGame();
}
});
});

_generateNewRound();
}

void _generateNewRound() {
final random = Random();

// Generate new target color
targetColor = gameColors[random.nextInt(gameColors.length)];
targetColorName = colorNames[targetColor]!;

// Generate buttons (1 correct, rest random)
final availableColors = List<Color>.from(gameColors);
availableColors.remove(targetColor);

buttons.clear();

// Add correct button
buttons.add(ColorButton(color: targetColor, isCorrect: true));

// Add incorrect buttons (3-5 based on level)
int buttonCount = min(3 + level ~/ 3, 5);
for (int i = 0; i < buttonCount - 1; i++) {
final wrongColor = availableColors[random.nextInt(availableColors.length)];
buttons.add(ColorButton(color: wrongColor, isCorrect: false));
}

// Shuffle buttons
buttons.shuffle(random);

setState(() {});
}

// Renamed function to avoid conflict with variable
void _displayFeedback(String text, Color color) {
setState(() {
_showFeedbackOverlay = true;
_feedbackText = text;
_feedbackColor = color;
});

Future.delayed(const Duration(milliseconds: 800), () {
if (mounted) {
setState(() {
_showFeedbackOverlay = false;
});
}
});
}

void _onButtonTap(ColorButton button) {
if (gameOver || !gameStarted) return;

// Visual feedback for button press
if (button.isCorrect) {
_displayFeedback("CORRECT!", Colors.green);
correctInRow++;
score += 10 * level;

// Bonus for quick consecutive correct answers
if (correctInRow >= 3) {
score += 20;
_showBonusText("COMBO +20!");
}

if (correctInRow % 5 == 0) {
level++;
_showBonusText("LEVEL UP!");
}

_generateNewRound();
} else {
_displayFeedback("WRONG!", Colors.red);
correctInRow = 0;
lives--;

if (lives <= 0) {
_endGame();
} else {
_generateNewRound();
}
}
}

void _endGame() {
gameTimer?.cancel();
setState(() {
gameOver = true;
if (score > highScore) {
highScore = score;
}
});
}

void _showBonusText(String text) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(text),
backgroundColor: Colors.amber,
duration: const Duration(seconds: 1),
),
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
drawer: const AppSidebar(),
appBar: AppBar(
title: const Text('Color Reflex'),
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
_buildStatItem(Icons.score, '$score', 'Score'),
_buildStatItem(Icons.favorite, '$lives', 'Lives'),
_buildStatItem(Icons.stairs, '$level', 'Level'),
_buildStatItem(Icons.timer, '${timeLeft}s', 'Time'),
],
),
),
),

const SizedBox(height: 20),

// Target Color Display with pulsing animation
Card(
color: Colors.white.withOpacity(0.9),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(25),
),
child: Padding(
padding: const EdgeInsets.all(30.0),
child: Column(
children: [
const Text(
'FIND THIS COLOR:',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
color: Colors.grey,
),
),
const SizedBox(height: 20),
AnimatedBuilder(
animation: _pulseController,
builder: (context, child) {
return Container(
width: 120 + (_pulseController.value * 10),
height: 120 + (_pulseController.value * 10),
decoration: BoxDecoration(
color: targetColor,
shape: BoxShape.circle,
boxShadow: [
BoxShadow(
color: targetColor.withOpacity(0.5 + _pulseController.value * 0.3),
blurRadius: 20,
spreadRadius: 5,
),
],
),
);
},
),
const SizedBox(height: 20),
Text(
targetColorName,
style: TextStyle(
fontSize: 32,
fontWeight: FontWeight.bold,
color: targetColor,
fontFamily: 'Nunito',
),
),
],
),
),
),

// Feedback overlay
if (_showFeedbackOverlay)
Padding(
padding: const EdgeInsets.symmetric(vertical: 10),
child: AnimatedContainer(
duration: const Duration(milliseconds: 300),
padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
decoration: BoxDecoration(
color: _feedbackColor?.withOpacity(0.9),
borderRadius: BorderRadius.circular(25),
boxShadow: [
BoxShadow(
color: _feedbackColor?.withOpacity(0.5) ?? Colors.transparent,
blurRadius: 15,
spreadRadius: 3,
),
],
),
child: Text(
_feedbackText,
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
color: Colors.white,
),
),
),
),

const SizedBox(height: 20),

// Color Buttons Grid
Expanded(
child: GridView.builder(
gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 2,
crossAxisSpacing: 15,
mainAxisSpacing: 15,
childAspectRatio: 1.5,
),
itemCount: buttons.length,
itemBuilder: (context, index) {
return _buildColorButton(buttons[index]);
},
),
),

const SizedBox(height: 20),

// Game Controls
if (!gameStarted && !gameOver)
ElevatedButton.icon(
onPressed: _startGame,
style: ElevatedButton.styleFrom(
backgroundColor: MindSportTheme.primaryGreen,
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(25),
),
padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
),
icon: const Icon(Icons.play_arrow),
label: const Text(
'START GAME',
style: TextStyle(fontSize: 18),
),
),

if (gameStarted && !gameOver)
ElevatedButton.icon(
onPressed: _resetGame,
style: ElevatedButton.styleFrom(
backgroundColor: Colors.white,
foregroundColor: Colors.red,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(25),
),
padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
),
icon: const Icon(Icons.refresh),
label: const Text('RESTART'),
),
],
),
),

// Game Over Overlay
if (gameOver)
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
Icons.games,
size: 60,
color: Colors.blue,
),
const SizedBox(height: 20),
const Text(
'Game Over!',
style: TextStyle(
fontSize: 28,
fontWeight: FontWeight.bold,
color: MindSportTheme.darkText,
),
),
const SizedBox(height: 10),
Text(
'Your score: $score',
style: const TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
color: Colors.green,
),
),
const SizedBox(height: 5),
Text(
'High score: $highScore',
style: TextStyle(
fontSize: 18,
color: Colors.grey.shade700,
),
),
const SizedBox(height: 20),
Row(
mainAxisAlignment: MainAxisAlignment.spaceEvenly,
children: [
_buildResultItem(Icons.stairs, 'Level $level'),
_buildResultItem(Icons.timer, '${60 - timeLeft}s'),
],
),
const SizedBox(height: 30),
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
ElevatedButton(
onPressed: _resetGame,
style: ElevatedButton.styleFrom(
backgroundColor: MindSportTheme.primaryGreen,
foregroundColor: Colors.white,
padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(25),
),
),
child: const Text('Play Again'),
),
const SizedBox(width: 20),
OutlinedButton(
onPressed: () => Navigator.pop(context),
style: OutlinedButton.styleFrom(
foregroundColor: MindSportTheme.darkText,
padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(25),
),
side: const BorderSide(color: MindSportTheme.darkText),
),
child: const Text('Menu'),
),
],
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

Widget _buildColorButton(ColorButton button) {
return GestureDetector(
onTap: () => _onButtonTap(button),
child: AnimatedContainer(
duration: const Duration(milliseconds: 300),
curve: Curves.easeInOut,
decoration: BoxDecoration(
color: button.color,
borderRadius: BorderRadius.circular(20),
boxShadow: [
BoxShadow(
color: button.color.withOpacity(0.5),
blurRadius: 15,
offset: const Offset(0, 5),
),
if (gameStarted && !gameOver)
BoxShadow(
color: button.color.withOpacity(0.7),
blurRadius: 20,
spreadRadius: 1,
),
],
border: Border.all(
color: Colors.white.withOpacity(0.3),
width: 3,
),
),
child: Center(
child: AnimatedScale(
duration: const Duration(milliseconds: 200),
scale: gameStarted && !gameOver ? 1.0 : 0.8,
child: Container(
width: 40,
height: 40,
decoration: BoxDecoration(
shape: BoxShape.circle,
color: Colors.white.withOpacity(0.2),
border: Border.all(
color: Colors.white.withOpacity(0.5),
width: 2,
),
),
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

Widget _buildResultItem(IconData icon, String value) {
return Column(
children: [
Icon(icon, color: Colors.grey, size: 24),
const SizedBox(height: 5),
Text(
value,
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.w500,
),
),
],
);
}
}

class ColorButton {
final Color color;
final bool isCorrect;

ColorButton({required this.color, required this.isCorrect});
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