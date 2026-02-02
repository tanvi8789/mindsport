import 'package:flutter/material.dart';
import 'package:mindsport/main.dart';
import 'package:fl_chart/fl_chart.dart';

class DietPlanScreen extends StatefulWidget {
const DietPlanScreen({super.key});

@override
State<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
// State variables
String _selectedSport = 'football';
bool _isVegetarian = false;
String _mealTime = 'breakfast';
double _weight = 70.0; // kg
double _activityLevel = 1.6; // Moderate activity multiplier

// Sports data
final Map<String, Map<String, dynamic>> _sportsData = {
'football': {
'name': 'Football',
'icon': Icons.sports_soccer,
'color': Color(0xFF6B8E23), // Primary green
'protein_multiplier': 1.8,
'carbs_multiplier': 6.0,
'fat_multiplier': 1.0,
'calories_per_kg': 40,
'description': 'High intensity, endurance sport requiring explosive power and stamina',
},
'cricket': {
'name': 'Cricket',
'icon': Icons.sports_cricket,
'color': Color(0xFFD2691E), // Cricket brown
'protein_multiplier': 1.6,
'carbs_multiplier': 5.5,
'fat_multiplier': 1.0,
'calories_per_kg': 38,
'description': 'Mix of explosive movements and endurance, requiring quick reflexes',
},
'badminton': {
'name': 'Badminton',
'icon': Icons.sports_tennis,
'color': Color(0xFF4169E1), // Royal blue
'protein_multiplier': 1.7,
'carbs_multiplier': 5.8,
'fat_multiplier': 1.0,
'calories_per_kg': 42,
'description': 'Fast-paced sport requiring agility, speed, and explosive power',
},
'tennis': {
'name': 'Tennis',
'icon': Icons.sports_tennis,
'color': Color(0xFF32CD32), // Lime green
'protein_multiplier': 1.8,
'carbs_multiplier': 6.0,
'fat_multiplier': 1.0,
'calories_per_kg': 45,
'description': 'High intensity sport requiring endurance, strength, and agility',
},
'swimming': {
'name': 'Swimming',
'icon': Icons.pool,
'color': Color(0xFF00BFFF), // Deep sky blue
'protein_multiplier': 2.0,
'carbs_multiplier': 6.5,
'fat_multiplier': 1.2,
'calories_per_kg': 50,
'description': 'Full-body workout requiring endurance and strength',
},
};

// Food options
final Map<String, Map<String, List<String>>> _foodOptions = {
'breakfast': {
'veg': [
'Oats with nuts & fruits',
'Greek yogurt with berries',
'Vegetable poha/upma',
'Chickpea flour pancakes',
'Smoothie bowl with protein powder'
],
'non-veg': [
'Egg whites omelette with veggies',
'Chicken sausage with toast',
'Salmon avocado toast',
'Turkey bacon with scrambled eggs',
'Protein shake with banana'
],
},
'lunch': {
'veg': [
'Brown rice with dal & veggies',
'Quinoa salad with chickpeas',
'Paneer curry with roti',
'Lentil soup with whole grain bread',
'Vegetable stir-fry with tofu'
],
'non-veg': [
'Grilled chicken with sweet potato',
'Fish curry with brown rice',
'Lean beef stir-fry',
'Turkey breast wrap',
'Tuna salad with quinoa'
],
},
'dinner': {
'veg': [
'Vegetable soup with lentils',
'Cottage cheese salad',
'Roasted vegetables with hummus',
'Mushroom stir-fry',
'Light dal with vegetables'
],
'non-veg': [
'Baked fish with greens',
'Chicken breast with steamed veggies',
'Lean steak with asparagus',
'Shrimp salad',
'Egg white scramble'
],
},
'snacks': {
'veg': [
'Protein bars',
'Greek yogurt',
'Mixed nuts',
'Fruit with peanut butter',
'Roasted chickpeas'
],
'non-veg': [
'Hard boiled eggs',
'Chicken strips',
'Tuna crackers',
'Beef jerky',
'Protein shake'
],
},
};

// Calculate nutrition
Map<String, double> _calculateNutrition() {
final data = _sportsData[_selectedSport]!;
final baseCalories = _weight * data['calories_per_kg'] * _activityLevel;
final protein = _weight * data['protein_multiplier'];
final carbs = _weight * data['carbs_multiplier'];
final fat = _weight * data['fat_multiplier'];

// Adjust calories from macros (4 cals per g protein/carbs, 9 cals per g fat)
final calculatedCalories = (protein * 4) + (carbs * 4) + (fat * 9);
final scaleFactor = baseCalories / calculatedCalories;

return {
'protein': double.parse((protein * scaleFactor).toStringAsFixed(1)),
'carbs': double.parse((carbs * scaleFactor).toStringAsFixed(1)),
'fat': double.parse((fat * scaleFactor).toStringAsFixed(1)),
'calories': double.parse(baseCalories.toStringAsFixed(0)),
};
}

// Build pie chart
Widget _buildNutritionChart(Map<String, double> nutrition) {
final total = nutrition['protein']! + nutrition['carbs']! + nutrition['fat']!;
final proteinPercent = (nutrition['protein']! / total) * 100;
final carbsPercent = (nutrition['carbs']! / total) * 100;
final fatPercent = (nutrition['fat']! / total) * 100;

return Container(
height: 200,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.8),
borderRadius: BorderRadius.circular(16),
),
child: Column(
children: [
Expanded(
child: PieChart(
PieChartData(
sectionsSpace: 2,
centerSpaceRadius: 35,
sections: [
PieChartSectionData(
color: const Color(0xFF6B8E23), // Protein - Green
value: proteinPercent,
title: '${proteinPercent.toStringAsFixed(1)}%',
radius: 50,
titleStyle: const TextStyle(
fontSize: 11,
fontWeight: FontWeight.bold,
color: Colors.white,
),
),
PieChartSectionData(
color: const Color(0xFF4169E1), // Carbs - Blue
value: carbsPercent,
title: '${carbsPercent.toStringAsFixed(1)}%',
radius: 50,
titleStyle: const TextStyle(
fontSize: 11,
fontWeight: FontWeight.bold,
color: Colors.white,
),
),
PieChartSectionData(
color: const Color(0xFFFF8C00), // Fat - Orange
value: fatPercent,
title: '${fatPercent.toStringAsFixed(1)}%',
radius: 50,
titleStyle: const TextStyle(
fontSize: 11,
fontWeight: FontWeight.bold,
color: Colors.white,
),
),
],
),
),
),
const SizedBox(height: 8),
Row(
mainAxisAlignment: MainAxisAlignment.spaceEvenly,
children: [
_buildLegendItem(const Color(0xFF6B8E23), 'Protein', '${nutrition['protein']}g'),
_buildLegendItem(const Color(0xFF4169E1), 'Carbs', '${nutrition['carbs']}g'),
_buildLegendItem(const Color(0xFFFF8C00), 'Fat', '${nutrition['fat']}g'),
],
),
],
),
);
}

Widget _buildLegendItem(Color color, String label, String value) {
return Column(
mainAxisSize: MainAxisSize.min,
children: [
Row(
mainAxisSize: MainAxisSize.min,
children: [
Container(
width: 8,
height: 8,
decoration: BoxDecoration(
color: color,
shape: BoxShape.circle,
),
),
const SizedBox(width: 4),
Text(
label,
style: const TextStyle(
fontSize: 10,
color: Colors.black54,
),
),
],
),
const SizedBox(height: 2),
Text(
value,
style: const TextStyle(
fontSize: 12,
fontWeight: FontWeight.bold,
color: Colors.black87,
),
),
],
);
}

// SIMPLIFIED MACRO CARDS - Fixed overflow
Widget _buildMacroCardsRow(Map<String, double> nutrition) {
return Column(
children: [
// First row: Calories and Protein
Row(
children: [
Expanded(
child: _buildCompactMacroCard(
'Calories',
nutrition['calories']!,
'kcal',
const Color(0xFF6B8E23),
Icons.local_fire_department,
),
),
const SizedBox(width: 8),
Expanded(
child: _buildCompactMacroCard(
'Protein',
nutrition['protein']!,
'g',
const Color(0xFF6B8E23),
Icons.fitness_center,
),
),
],
),
const SizedBox(height: 8),
// Second row: Carbs and Fat
Row(
children: [
Expanded(
child: _buildCompactMacroCard(
'Carbs',
nutrition['carbs']!,
'g',
const Color(0xFF4169E1),
Icons.energy_savings_leaf,
),
),
const SizedBox(width: 8),
Expanded(
child: _buildCompactMacroCard(
'Fat',
nutrition['fat']!,
'g',
const Color(0xFFFF8C00),
Icons.opacity,
),
),
],
),
],
);
}

Widget _buildCompactMacroCard(String title, double value, String unit, Color color, IconData icon) {
return Container(
padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
decoration: BoxDecoration(
color: color.withOpacity(0.1),
borderRadius: BorderRadius.circular(12),
border: Border.all(color: color.withOpacity(0.2)),
),
child: Row(
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Container(
padding: const EdgeInsets.all(6),
decoration: BoxDecoration(
color: color.withOpacity(0.2),
shape: BoxShape.circle,
),
child: Icon(icon, size: 16, color: color),
),
const SizedBox(width: 10),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
mainAxisSize: MainAxisSize.min,
children: [
Text(
title,
style: TextStyle(
fontSize: 11,
color: color,
fontWeight: FontWeight.w600,
),
maxLines: 1,
overflow: TextOverflow.ellipsis,
),
const SizedBox(height: 4),
Text(
'${value.toStringAsFixed(0)}$unit',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
color: color,
),
),
],
),
),
],
),
);
}

@override
Widget build(BuildContext context) {
final nutrition = _calculateNutrition();
final sportData = _sportsData[_selectedSport]!;
final currentFoods = _foodOptions[_mealTime]![_isVegetarian ? 'veg' : 'non-veg']!;
final sportName = sportData['name'] as String;

return Scaffold(
appBar: AppBar(
backgroundColor: Colors.transparent,
elevation: 0,
title: const Text(
'Sports Nutrition',
style: TextStyle(
color: MindSportTheme.darkText,
fontSize: 20,
fontWeight: FontWeight.bold,
fontFamily: 'Nunito',
),
),
iconTheme: const IconThemeData(color: MindSportTheme.darkText),
),
backgroundColor: MindSportTheme.primaryBackground,
body: SingleChildScrollView(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Sport Selection
_buildGlassCard(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Select Your Sport',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
color: MindSportTheme.darkText,
),
),
const SizedBox(height: 10),
SizedBox(
height: 45,
child: ListView(
scrollDirection: Axis.horizontal,
children: _sportsData.entries.map((entry) {
final isSelected = _selectedSport == entry.key;
return Container(
margin: const EdgeInsets.only(right: 6),
child: ChoiceChip(
label: Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(entry.value['icon'], size: 14),
const SizedBox(width: 3),
Text(
entry.value['name'],
style: const TextStyle(fontSize: 12),
),
],
),
selected: isSelected,
onSelected: (_) => setState(() => _selectedSport = entry.key),
backgroundColor: Colors.white.withOpacity(0.5),
selectedColor: (entry.value['color'] as Color).withOpacity(0.2),
labelStyle: TextStyle(
color: isSelected ? entry.value['color'] : Colors.black87,
fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
fontSize: 12,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(20),
side: BorderSide(
color: isSelected ? entry.value['color'] as Color : Colors.grey.shade300,
width: isSelected ? 1.5 : 1,
),
),
),
);
}).toList(),
),
),
const SizedBox(height: 10),
Text(
sportData['description'] as String,
style: const TextStyle(
fontSize: 12,
color: Colors.black54,
fontStyle: FontStyle.italic,
),
),
],
),
),
const SizedBox(height: 12),

// Nutrition Overview
_buildGlassCard(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Daily Nutrition Targets',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
color: MindSportTheme.darkText,
),
),
const SizedBox(height: 10),
_buildNutritionChart(nutrition),
const SizedBox(height: 12),
// FIXED: Using the new compact macro cards layout
_buildMacroCardsRow(nutrition),
],
),
),
const SizedBox(height: 12),

// Personalization
_buildGlassCard(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Personalize',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
color: MindSportTheme.darkText,
),
),
const SizedBox(height: 10),
// Weight Slider
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'Weight: ${_weight.toStringAsFixed(0)} kg',
style: const TextStyle(
fontSize: 13,
fontWeight: FontWeight.w600,
),
),
Slider(
value: _weight,
min: 40,
max: 120,
divisions: 80,
onChanged: (value) => setState(() => _weight = value),
activeColor: MindSportTheme.primaryGreen,
inactiveColor: MindSportTheme.softGreen,
),
],
),
const SizedBox(height: 10),
// Activity Level Slider
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'Activity Level: ${_activityLevel.toStringAsFixed(1)}x',
style: const TextStyle(
fontSize: 13,
fontWeight: FontWeight.w600,
),
),
Slider(
value: _activityLevel,
min: 1.2,
max: 2.0,
divisions: 8,
onChanged: (value) => setState(() => _activityLevel = value),
activeColor: Colors.blue,
inactiveColor: Colors.blue.shade100,
),
],
),
const SizedBox(height: 10),
// Diet Type Selection
Row(
mainAxisAlignment: MainAxisAlignment.spaceEvenly,
children: [
Flexible(
child: ChoiceChip(
label: const Text('Vegetarian', style: TextStyle(fontSize: 12)),
selected: _isVegetarian,
onSelected: (_) => setState(() => _isVegetarian = true),
selectedColor: Colors.green.withOpacity(0.2),
labelStyle: TextStyle(
color: _isVegetarian ? Colors.green : Colors.black87,
fontWeight: _isVegetarian ? FontWeight.bold : FontWeight.normal,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
),
),
Flexible(
child: ChoiceChip(
label: const Text('Non-Veg', style: TextStyle(fontSize: 12)),
selected: !_isVegetarian,
onSelected: (_) => setState(() => _isVegetarian = false),
selectedColor: Colors.red.withOpacity(0.2),
labelStyle: TextStyle(
color: !_isVegetarian ? Colors.red : Colors.black87,
fontWeight: !_isVegetarian ? FontWeight.bold : FontWeight.normal,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
),
),
],
),
],
),
),
const SizedBox(height: 12),

// Meal Planner
_buildGlassCard(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
const Text(
'Meal Suggestions',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
color: MindSportTheme.darkText,
),
),
Container(
padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
decoration: BoxDecoration(
color: MindSportTheme.softLavender,
borderRadius: BorderRadius.circular(16),
),
child: DropdownButton<String>(
value: _mealTime,
onChanged: (value) => setState(() => _mealTime = value!),
items: ['breakfast', 'lunch', 'dinner', 'snacks']
    .map((time) => DropdownMenuItem(
value: time,
child: Text(
time.capitalize(),
style: const TextStyle(fontSize: 12),
),
))
    .toList(),
underline: const SizedBox(),
icon: const Icon(Icons.arrow_drop_down, size: 16),
borderRadius: BorderRadius.circular(10),
dropdownColor: Colors.white,
iconSize: 16,
),
),
],
),
const SizedBox(height: 10),
...currentFoods.map((food) => Padding(
padding: const EdgeInsets.only(bottom: 6),
child: Container(
padding: const EdgeInsets.all(10),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.6),
borderRadius: BorderRadius.circular(10),
border: Border.all(color: Colors.grey.shade200),
),
child: Row(
children: [
Container(
padding: const EdgeInsets.all(5),
decoration: BoxDecoration(
color: MindSportTheme.softGreen,
shape: BoxShape.circle,
),
child: const Icon(Icons.restaurant, size: 14, color: MindSportTheme.darkText),
),
const SizedBox(width: 8),
Expanded(
child: Text(
food,
style: const TextStyle(
fontSize: 13,
fontWeight: FontWeight.w500,
color: Colors.black87,
),
maxLines: 2,
),
),
Icon(
Icons.arrow_forward_ios,
size: 12,
color: Colors.grey.shade400,
),
],
),
),
)),
],
),
),

// Tips Section
const SizedBox(height: 12),
_buildGlassCard(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'Tips for $sportName',
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
color: MindSportTheme.darkText,
),
),
const SizedBox(height: 8),
..._getSportSpecificTips().map((tip) => Padding(
padding: const EdgeInsets.only(bottom: 5),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
margin: const EdgeInsets.only(top: 5),
width: 4,
height: 4,
decoration: const BoxDecoration(
color: MindSportTheme.primaryGreen,
shape: BoxShape.circle,
),
),
const SizedBox(width: 8),
Expanded(
child: Text(
tip,
style: const TextStyle(
fontSize: 12,
color: Colors.black54,
height: 1.4,
),
),
),
],
),
)),
],
),
),
const SizedBox(height: 20),
],
),
),
);
}

List<String> _getSportSpecificTips() {
switch (_selectedSport) {
case 'football':
return [
'Complex carbs 3-4 hours before match',
'Stay hydrated with electrolytes',
'Protein + carbs within 30 min post-game',
'Healthy fats for joint health',
];
case 'cricket':
return [
'Quick energy carbs for batsmen',
'More protein for bowlers',
'Hydrate during long sessions',
'Small frequent meals',
];
case 'badminton':
return [
'Light meal 2 hours before',
'Quick energy sources',
'Adequate protein for recovery',
'Avoid heavy foods',
];
case 'tennis':
return [
'High carb meal 3-4 hours pre-match',
'Banana/energy gels during match',
'Protein shake + carbs post-match',
'Anti-inflammatory foods',
];
case 'swimming':
return [
'Eat 2-3 hours before swimming',
'High protein for muscle repair',
'Complex carbs for energy',
'Replenish electrolytes',
];
default:
return [
'Balanced meals throughout day',
'Stay hydrated',
'Time nutrition around training',
'Listen to body cues',
];
}
}

Widget _buildGlassCard({required Widget child}) {
return ClipRRect(
borderRadius: BorderRadius.circular(14),
child: Container(
width: double.infinity,
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.7),
borderRadius: BorderRadius.circular(14),
border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.2),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 12,
offset: const Offset(0, 6),
),
],
),
child: child,
),
);
}
}

extension StringExtension on String {
String capitalize() {
return "${this[0].toUpperCase()}${substring(1)}";
}
}