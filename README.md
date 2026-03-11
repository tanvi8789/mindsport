# Mindsport 

**The Athlete’s Mental Performance Companion**

In the high-pressure world of sports, athletes often track their physical stats religiously but neglect their mental state. **Mindsport** is a cross-platform mobile application designed to bridge the gap between mental well-being and athletic performance. It empowers athletes to track the "Athlete's Trifecta" (Mood, Sleep, and Physical Strain) to prevent burnout and optimize performance.


## Key Features

* **Daily Performance Check-In:** Context-aware logging that correlates mood with sleep quality and physical strain.
* **Burnout Prevention Analytics:** Interactive charts (`fl_chart`) visualizing the relationship between physical load and recovery over time.
* **Mood History Calendar:** Long-term tracking to identify patterns (e.g., pre-game anxiety spikes).
* **AI Wellness Companion (Chatbot):** 24/7 empathetic conversational AI with **Speech-to-Text** capabilities for immediate mental health triage.
* **The Mental Gym:** Actionable, client-side tools like Box Breathing timers and Guided Visualization to reset the nervous system.
* **Smart Reminders:** Local notifications to build consistent mental routines (e.g., "Pre-game Visualization").
* **Community Forum "Locker Room":** A safe, themed space for athletes to discuss injury rehab, game-day nerves, and wins.
* **Curated Resources:** Quick access to sports psychology articles, Spotify recovery playlists, and YouTube physical conditioning routines.
  

## Tech Stack

Mindsport uses a modern client-server architecture:

**Frontend (Mobile App)**
* **Framework:** Flutter (Dart)
* **State Management:** Provider
* **Key Packages:** `http`, `fl_chart`, `table_calendar`, `flutter_local_notifications`, `flutter_secure_storage`, `speech_to_text`
* **Design:** Custom animations, Glassmorphism, "Calm/Earthy" aesthetic

**Backend (REST API)**
* **Environment:** Node.js
* **Framework:** Express.js
* **Database:** MongoDB (Atlas) & Mongoose ODM
* **Security:** JWT (JSON Web Tokens), `bcrypt` for password hashing


## Getting Started

Follow these instructions to run the project locally. The project is structured as a monorepo containing both the `frontend` and `backend`.

### 1. Backend Setup

Navigate to the backend directory:

```bash
cd backend
```

Install dependencies:
```bash
npm install
```
Create a .env file in the backend folder and add your environment variables:
```bash
PORT=5000
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_super_secret_jwt_key
```

Start the server:
``` bash
npm run dev
# Server should now be running on http://localhost:5000
```

### 2. Frontend Setup
   
Open a new terminal and navigate to the frontend directory:
```bash
cd frontend
```

Install Flutter packages:
```bash
flutter pub get
```
Run the app:
```bash
flutter run
```

## Roadmap & Future Enhancements:

* Nutrition & Fueling Station: Tracking hydration and game-day nutritional preparation.
* Wearable Integration: Pulling sleep/strain data directly from Apple Health/Google Fit APIs.
* Coach Dashboard: Allowing coaches to view aggregated, anonymized team burnout risks.
