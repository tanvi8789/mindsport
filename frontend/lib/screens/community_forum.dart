import 'package:flutter/material.dart';
import 'package:mindsport/main.dart'; // Import theme
import 'package:mindsport/screens/sidebar.dart';

class CommunityForum extends StatefulWidget {
const CommunityForum({super.key});

@override
State<CommunityForum> createState() => _CommunityForumState();
}

class _CommunityForumState extends State<CommunityForum> with SingleTickerProviderStateMixin {
late AnimationController _animationController;
late Animation<double> _fadeAnimation;
int _selectedCategory = 0;

// Sample forum categories
final List<ForumCategory> categories = [
ForumCategory(
id: 0,
title: "General Hangout",
description: "Daily check-ins and casual chat",
icon: Icons.coffee,
color: MindSportTheme.softGreen,
memberCount: "1.2k members",
postCount: 245,
recentPost: Post(
title: "How's everyone's training going this week?",
author: "RunnerMike",
time: "2 hours ago",
replies: 12,
),
),
ForumCategory(
id: 1,
title: "Injury & Rehab",
description: "Support for the road to recovery",
icon: Icons.healing,
color: Color(0xFFE57373).withOpacity(0.3),
memberCount: "856 members",
postCount: 189,
recentPost: Post(
title: "ACL recovery timeline experiences",
author: "BasketballSarah",
time: "1 day ago",
replies: 24,
),
),
ForumCategory(
id: 2,
title: "Pre-Game Nerves",
description: "Strategies to handle the pressure",
icon: Icons.psychology,
color: MindSportTheme.softLavender,
memberCount: "723 members",
postCount: 156,
recentPost: Post(
title: "Dealing with performance anxiety",
author: "SwimmerAlex",
time: "5 hours ago",
replies: 18,
),
),
ForumCategory(
id: 3,
title: "Wins & Highlights",
description: "Celebrate your victories here!",
icon: Icons.emoji_events,
color: Colors.orangeAccent.withOpacity(0.3),
memberCount: "945 members",
postCount: 312,
recentPost: Post(
title: "First marathon completed! 🏃‍♂️",
author: "MarathonJane",
time: "3 hours ago",
replies: 42,
),
),
];

// Sample posts for the selected category
List<Post> get categoryPosts {
return [
Post(
title: "How to stay motivated during off-season?",
author: "SwimmerAlex",
content: "Hey everyone! I'm struggling to maintain my training routine during the off-season. Any tips on staying motivated when there's no competition in sight?",
time: "Just now",
likes: 24,
replies: 8,
isPinned: true,
),
Post(
title: "Best recovery meals after intense workout",
author: "NutritionCoach",
content: "Sharing my go-to post-workout meals that help with muscle recovery. What are your favorites?",
time: "30 minutes ago",
likes: 56,
replies: 15,
isPinned: false,
),
Post(
title: "Dealing with performance anxiety before big games",
author: "BasketballSarah",
content: "I get so nervous before important games that it affects my performance. Any breathing exercises or mental tricks that work for you?",
time: "2 hours ago",
likes: 42,
replies: 23,
isPinned: false,
),
Post(
title: "Weekly accountability thread",
author: "RunnerMike",
content: "Post your training goals for this week and let's hold each other accountable!",
time: "5 hours ago",
likes: 31,
replies: 19,
isPinned: true,
),
Post(
title: "Injury update: 6 weeks post-ACL surgery",
author: "SoccerTom",
content: "Sharing my recovery progress. Finally started light jogging this week! The journey has been tough but seeing progress keeps me going.",
time: "1 day ago",
likes: 89,
replies: 34,
isPinned: false,
),
];
}

@override
void initState() {
super.initState();
_animationController = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 800),
);
_fadeAnimation = CurvedAnimation(
parent: _animationController,
curve: Curves.easeOutQuart,
);
_animationController.forward();
}

@override
void dispose() {
_animationController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
drawer: const AppSidebar(),
appBar: AppBar(
title: const Text('Community Forum'),
backgroundColor: Colors.transparent,
elevation: 0,
iconTheme: const IconThemeData(color: MindSportTheme.darkText),
actions: [
IconButton(
icon: const Icon(Icons.notifications_none),
onPressed: () {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('No new notifications')),
);
},
),
IconButton(
icon: const Icon(Icons.person_add),
onPressed: () {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Find friends feature coming soon!')),
);
},
),
],
),
body: Stack(
children: [
// --- BACKGROUND ---
CustomPaint(
painter: _BackgroundPainter(),
size: Size.infinite,
),

// --- CONTENT ---
FadeTransition(
opacity: _fadeAnimation,
child: Column(
children: [
// Header Section
Container(
padding: const EdgeInsets.all(20),
color: Colors.transparent,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'The Locker Room',
style: TextStyle(
fontSize: 28,
fontWeight: FontWeight.w700,
color: MindSportTheme.darkText,
),
),
const SizedBox(height: 4),
const Text(
'Connect, share, and recover with fellow athletes.',
style: TextStyle(fontSize: 16, color: Colors.black54),
),
const SizedBox(height: 20),

// Search Bar
Container(
padding: const EdgeInsets.symmetric(horizontal: 16),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.9),
borderRadius: BorderRadius.circular(25),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 10,
offset: const Offset(0, 3),
),
],
),
child: Row(
children: [
const Icon(Icons.search, color: Colors.grey),
const SizedBox(width: 10),
Expanded(
child: TextField(
decoration: const InputDecoration(
hintText: "Search discussions...",
border: InputBorder.none,
hintStyle: TextStyle(color: Colors.grey),
),
style: const TextStyle(color: MindSportTheme.darkText),
),
),
IconButton(
icon: const Icon(Icons.filter_list, color: Colors.grey),
onPressed: () {},
),
],
),
),
],
),
),

// Category Tabs
Container(
height: 60,
padding: const EdgeInsets.symmetric(horizontal: 20),
child: ListView.builder(
scrollDirection: Axis.horizontal,
itemCount: categories.length,
itemBuilder: (context, index) {
final category = categories[index];
return Padding(
padding: const EdgeInsets.only(right: 10),
child: ChoiceChip(
label: Text(category.title),
selected: _selectedCategory == index,
onSelected: (selected) {
setState(() {
_selectedCategory = index;
});
},
selectedColor: category.color,
backgroundColor: Colors.white.withOpacity(0.7),
labelStyle: TextStyle(
color: _selectedCategory == index
? MindSportTheme.darkText
    : Colors.grey.shade700,
fontWeight: _selectedCategory == index
? FontWeight.bold
    : FontWeight.normal,
),
),
);
},
),
),

// Forum Content
Expanded(
child: DefaultTabController(
length: 2,
child: Column(
children: [
Container(
color: Colors.white.withOpacity(0.1),
child: TabBar(
labelColor: MindSportTheme.primaryGreen,
unselectedLabelColor: Colors.grey.shade600,
indicatorColor: MindSportTheme.primaryGreen,
tabs: const [
Tab(text: 'Posts'),
Tab(text: 'Members'),
],
),
),
Expanded(
child: TabBarView(
children: [
// Posts Tab
_buildPostsTab(),

// Members Tab
_buildMembersTab(),
],
),
),
],
),
),
),
],
),
),
],
),
floatingActionButton: FloatingActionButton.extended(
onPressed: () {
_showCreatePostDialog(context);
},
backgroundColor: MindSportTheme.primaryGreen,
icon: const Icon(Icons.add, color: Colors.white),
label: const Text("New Post", style: TextStyle(color: Colors.white)),
),
);
}

Widget _buildPostsTab() {
return ListView.builder(
padding: const EdgeInsets.all(20),
itemCount: categoryPosts.length + 1,
itemBuilder: (context, index) {
if (index == 0) {
return _buildCategoryHeader();
}

final post = categoryPosts[index - 1];
return _buildPostCard(post);
},
);
}

Widget _buildCategoryHeader() {
final category = categories[_selectedCategory];
return Card(
color: category.color.withOpacity(0.9),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
child: Padding(
padding: const EdgeInsets.all(16),
child: Row(
children: [
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.7),
shape: BoxShape.circle,
),
child: Icon(category.icon, color: MindSportTheme.darkText, size: 24),
),
const SizedBox(width: 16),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
category.title,
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
color: MindSportTheme.darkText,
),
),
const SizedBox(height: 4),
Text(
category.description,
style: const TextStyle(
fontSize: 14,
color: Colors.black87,
),
),
const SizedBox(height: 8),
Row(
children: [
_buildStatItem(Icons.people, category.memberCount),
const SizedBox(width: 16),
_buildStatItem(Icons.chat_bubble, "${category.postCount} posts"),
],
),
],
),
),
],
),
),
);
}

Widget _buildPostCard(Post post) {
return Card(
margin: const EdgeInsets.only(top: 12),
color: Colors.white.withOpacity(0.85),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Post Header
Row(
children: [
CircleAvatar(
backgroundColor: MindSportTheme.primaryGreen.withOpacity(0.2),
child: Text(
post.author.substring(0, 1),
style: const TextStyle(
color: MindSportTheme.primaryGreen,
fontWeight: FontWeight.bold,
),
),
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
post.author,
style: const TextStyle(
fontWeight: FontWeight.bold,
color: MindSportTheme.darkText,
),
),
Text(
post.time,
style: TextStyle(
fontSize: 12,
color: Colors.grey.shade600,
),
),
],
),
),
if (post.isPinned)
Container(
padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
decoration: BoxDecoration(
color: Colors.amber.withOpacity(0.2),
borderRadius: BorderRadius.circular(10),
),
child: Row(
children: [
const Icon(Icons.push_pin, size: 12, color: Colors.amber),
const SizedBox(width: 4),
Text(
'Pinned',
style: TextStyle(
fontSize: 10,
color: Colors.amber.shade800,
fontWeight: FontWeight.bold,
),
),
],
),
),
],
),

const SizedBox(height: 12),

// Post Title & Content
Text(
post.title,
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
color: MindSportTheme.darkText,
),
),

if (post.content != null) ...[
const SizedBox(height: 8),
Text(
post.content!,
maxLines: 3,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
fontSize: 14,
color: Colors.black87,
height: 1.4,
),
),
],

const SizedBox(height: 16),

// Post Actions
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Row(
children: [
IconButton(
onPressed: () {},
icon: Icon(
Icons.thumb_up_outlined,
color: Colors.grey.shade600,
size: 20,
),
),
Text(
'${post.likes}',
style: TextStyle(
color: Colors.grey.shade600,
fontSize: 12,
),
),
const SizedBox(width: 20),
IconButton(
onPressed: () {
_showCommentsDialog(context, post);
},
icon: Icon(
Icons.chat_bubble_outline,
color: Colors.grey.shade600,
size: 20,
),
),
Text(
'${post.replies}',
style: TextStyle(
color: Colors.grey.shade600,
fontSize: 12,
),
),
],
),
IconButton(
onPressed: () {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Saved "${post.title}"')),
);
},
icon: Icon(
Icons.bookmark_border,
color: Colors.grey.shade600,
size: 20,
),
),
],
),
],
),
),
);
}

Widget _buildMembersTab() {
final members = [
ForumMember(name: "RunnerMike", role: "Marathon Runner", posts: 156),
ForumMember(name: "SwimmerAlex", role: "Competitive Swimmer", posts: 89),
ForumMember(name: "BasketballSarah", role: "College Player", posts: 203),
ForumMember(name: "YogaEmma", role: "Instructor", posts: 67),
ForumMember(name: "NutritionCoach", role: "Sports Dietitian", posts: 124),
ForumMember(name: "SoccerTom", role: "Semi-Pro", posts: 91),
ForumMember(name: "MarathonJane", role: "Ultra Runner", posts: 178),
ForumMember(name: "WeightlifterSam", role: "Powerlifter", posts: 45),
];

return ListView.builder(
padding: const EdgeInsets.all(20),
itemCount: members.length,
itemBuilder: (context, index) {
final member = members[index];
return Card(
margin: const EdgeInsets.only(bottom: 12),
color: Colors.white.withOpacity(0.85),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
child: ListTile(
leading: CircleAvatar(
backgroundColor: MindSportTheme.primaryGreen.withOpacity(0.2),
child: Text(
member.name.substring(0, 1),
style: const TextStyle(
color: MindSportTheme.primaryGreen,
fontWeight: FontWeight.bold,
),
),
),
title: Text(
member.name,
style: const TextStyle(
fontWeight: FontWeight.bold,
color: MindSportTheme.darkText,
),
),
subtitle: Text(
member.role,
style: TextStyle(
fontSize: 12,
color: Colors.grey.shade600,
),
),
trailing: Container(
padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
decoration: BoxDecoration(
color: MindSportTheme.softLavender.withOpacity(0.5),
borderRadius: BorderRadius.circular(15),
),
child: Text(
'${member.posts} posts',
style: TextStyle(
fontSize: 12,
color: MindSportTheme.darkText,
fontWeight: FontWeight.w500,
),
),
),
onTap: () {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Viewing ${member.name}\'s profile')),
);
},
),
);
},
);
}

Widget _buildStatItem(IconData icon, String text) {
return Row(
children: [
Icon(icon, size: 14, color: Colors.grey.shade600),
const SizedBox(width: 4),
Text(
text,
style: TextStyle(
fontSize: 12,
color: Colors.grey.shade600,
),
),
],
);
}

void _showCreatePostDialog(BuildContext context) {
final TextEditingController titleController = TextEditingController();
final TextEditingController contentController = TextEditingController();

showDialog(
context: context,
builder: (context) => AlertDialog(
title: const Text('Create New Post'),
content: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextField(
controller: titleController,
decoration: const InputDecoration(
labelText: 'Post Title',
border: OutlineInputBorder(),
),
),
const SizedBox(height: 16),
TextField(
controller: contentController,
maxLines: 5,
decoration: const InputDecoration(
labelText: 'Content',
border: OutlineInputBorder(),
alignLabelWithHint: true,
),
),
const SizedBox(height: 16),
DropdownButtonFormField<String>(
decoration: const InputDecoration(
labelText: 'Category',
border: OutlineInputBorder(),
),
value: categories[_selectedCategory].title,
items: categories.map((category) {
return DropdownMenuItem(
value: category.title,
child: Text(category.title),
);
}).toList(),
onChanged: (value) {},
),
],
),
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text('Cancel'),
),
ElevatedButton(
onPressed: () {
if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Post created successfully!'),
backgroundColor: Colors.green,
),
);
Navigator.pop(context);
}
},
style: ElevatedButton.styleFrom(
backgroundColor: MindSportTheme.primaryGreen,
),
child: const Text('Post', style: TextStyle(color: Colors.white)),
),
],
),
);
}

void _showCommentsDialog(BuildContext context, Post post) {
final comments = [
Comment(
author: "YogaEmma",
content: "Great post! Have you tried box breathing? It works wonders for me.",
time: "1 hour ago",
likes: 8,
),
Comment(
author: "NutritionCoach",
content: "Agreed with RunnerMike. Protein intake within 30 mins post-workout is crucial.",
time: "45 minutes ago",
likes: 12,
),
Comment(
author: "SwimmerAlex",
content: "Visualization techniques really helped me overcome my competition anxiety.",
time: "30 minutes ago",
likes: 5,
),
];

showModalBottomSheet(
context: context,
isScrollControlled: true,
backgroundColor: Colors.transparent,
builder: (context) => DraggableScrollableSheet(
initialChildSize: 0.8,
minChildSize: 0.5,
maxChildSize: 0.9,
builder: (context, scrollController) {
return Container(
decoration: BoxDecoration(
color: Colors.white,
borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.1),
blurRadius: 20,
spreadRadius: 5,
),
],
),
child: Column(
children: [
// Header
Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: MindSportTheme.primaryGreen.withOpacity(0.1),
borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
),
child: Row(
children: [
IconButton(
onPressed: () => Navigator.pop(context),
icon: const Icon(Icons.close),
),
const SizedBox(width: 8),
const Text(
'Comments',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
const Spacer(),
Text(
'${post.replies} replies',
style: const TextStyle(color: Colors.grey),
),
],
),
),

// Post Preview
Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.grey.shade50,
border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
post.title,
style: const TextStyle(
fontWeight: FontWeight.bold,
fontSize: 16,
),
),
const SizedBox(height: 8),
Text(
'by ${post.author} • ${post.time}',
style: const TextStyle(
fontSize: 12,
color: Colors.grey,
),
),
],
),
),

// Comments List
Expanded(
child: ListView.builder(
controller: scrollController,
padding: const EdgeInsets.all(16),
itemCount: comments.length + 1,
itemBuilder: (context, index) {
if (index == 0) {
return const Padding(
padding: EdgeInsets.only(bottom: 16),
child: Text(
'Top Comments',
style: TextStyle(
fontSize: 14,
fontWeight: FontWeight.bold,
color: Colors.grey,
),
),
);
}

final comment = comments[index - 1];
return Container(
margin: const EdgeInsets.only(bottom: 12),
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: Colors.grey.shade50,
borderRadius: BorderRadius.circular(10),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
CircleAvatar(
backgroundColor: MindSportTheme.primaryGreen.withOpacity(0.2),
radius: 14,
child: Text(
comment.author.substring(0, 1),
style: const TextStyle(
fontSize: 12,
color: MindSportTheme.primaryGreen,
fontWeight: FontWeight.bold,
),
),
),
const SizedBox(width: 8),
Text(
comment.author,
style: const TextStyle(
fontWeight: FontWeight.bold,
fontSize: 14,
),
),
const SizedBox(width: 8),
Text(
'• ${comment.time}',
style: const TextStyle(
fontSize: 12,
color: Colors.grey,
),
),
const Spacer(),
Row(
children: [
IconButton(
onPressed: () {},
icon: const Icon(Icons.thumb_up_outlined, size: 16),
),
Text(
'${comment.likes}',
style: const TextStyle(fontSize: 12),
),
],
),
],
),
const SizedBox(height: 8),
Text(
comment.content,
style: const TextStyle(fontSize: 14),
),
],
),
);
},
),
),

// Add Comment Input
Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,
border: Border(top: BorderSide(color: Colors.grey.shade200)),
),
child: Row(
children: [
Expanded(
child: TextField(
decoration: InputDecoration(
hintText: 'Add a comment...',
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(25),
borderSide: BorderSide.none,
),
filled: true,
fillColor: Colors.grey.shade100,
contentPadding: const EdgeInsets.symmetric(
horizontal: 20,
vertical: 12,
),
),
),
),
const SizedBox(width: 10),
CircleAvatar(
backgroundColor: MindSportTheme.primaryGreen,
child: IconButton(
onPressed: () {},
icon: const Icon(Icons.send, color: Colors.white, size: 20),
),
),
],
),
),
],
),
);
},
),
);
}
}

// Data Models
class ForumCategory {
final int id;
final String title;
final String description;
final IconData icon;
final Color color;
final String memberCount;
final int postCount;
final Post recentPost;

ForumCategory({
required this.id,
required this.title,
required this.description,
required this.icon,
required this.color,
required this.memberCount,
required this.postCount,
required this.recentPost,
});
}

class Post {
final String title;
final String author;
final String time;
final int replies;
final int likes;
final bool isPinned;
final String? content;

Post({
required this.title,
required this.author,
required this.time,
required this.replies,
this.likes = 0,
this.isPinned = false,
this.content,
});
}

class ForumMember {
final String name;
final String role;
final int posts;

ForumMember({
required this.name,
required this.role,
required this.posts,
});
}

class Comment {
final String author;
final String content;
final String time;
final int likes;

Comment({
required this.author,
required this.content,
required this.time,
this.likes = 0,
});
}

// --- Background Painter ---
class _BackgroundPainter extends CustomPainter {
@override
void paint(Canvas canvas, Size size) {
const double blurSigma = 45.0;
final paint1 = Paint()..color = MindSportTheme.softPeach.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);
final paint2 = Paint()..color = MindSportTheme.softLavender.withOpacity(0.6)..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);
final paint3 = Paint()..color = MindSportTheme.softGreen.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);
canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.1), 150, paint1);
canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.3), 200, paint2);
canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 180, paint3);
}
@override
bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}