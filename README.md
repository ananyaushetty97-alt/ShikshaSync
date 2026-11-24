# ShikshaSync

> **ShikshaSync does not wait for the internet to educate a child.**

Offline-first, voice-assisted adaptive learning for rural multi-grade classrooms.  
Built by **Team Code Rangers**, RV College of Engineering, for **wHACKiest 2026** (UnlockED track).

---

## Problem

Rural classrooms face three simultaneous constraints that break most digital learning tools:

| Constraint | Reality | Typical Tool Assumption |
|------------|---------|------------------------|
| **Internet** | Unreliable 2G/3G, expensive data, frequent drops | Reliable broadband / cloud connectivity |
| **Devices** | One tablet shared by 5+ students | One device per child |
| **Teacher Time** | One teacher, multiple grades, no bandwidth to track individual gaps | Teacher can monitor each student |

**Existing solutions fall short:**
- Cloud/LLM tutors → fail offline, add latency & cost per question
- Video-heavy apps → too large for patchy connections
- Generic dashboards → show marks by grade, not skill-level gaps

---

## Solution

**ShikshaSync** is an offline-first, voice-assisted adaptive learning platform designed for these exact constraints.

**Student Side (Flutter Android App):**
- Downloads small regional-language lesson packs (JSON + SVG + MP3) when online
- Learns **completely offline** — lessons, quizzes, adaptation, audio all work in airplane mode
- On-device **mastery engine** adjusts difficulty per skill in real time
- **Shared-device mode**: avatar + 4-digit PIN profiles keep each child's progress separate
- **Regional voice**: pre-cached ElevenLabs narration in Kannada/Hindi/Tamil/English — helps low-literacy learners

**Sync (Delta, KB-sized):**
- Every answer → tiny event (few hundred bytes) appended to local SQLite queue
- When connectivity returns → upload only unsynced events, download only new/changed packs
- Unique `eventId` per event → safe retries, no duplicates

**Teacher Dashboard (React Web App):**
- Groups students by **weak skill** (not grade): *"4 students struggling with carry-over addition"*
- Shows sync status, completion by grade/subject
- Suggests 10-minute targeted group activities
- Multi-grade filter for single-teacher classrooms

---

## Features

| Feature | Description |
|---------|-------------|
| **Offline Lesson Packs** | JSON (structure), SVG (lightweight visuals), MP3 (compressed audio) — all cached locally |
| **On-Device Adaptive Engine** | Rule-based mastery (0.0–1.0): correct +0.12, wrong −0.18; 2 wrong → audio hint + easier question; 2 correct → harder; >0.80 mastered; <0.40 revision queued |
| **Regional-Language Voice** | ElevenLabs TTS pre-generated → MP3 cached in pack; narration, questions, hints, encouragement |
| **Shared-Device Profiles** | Avatar + PIN switching; isolated SQLite progress per student |
| **Delta Sync** | Append-only event queue; KB-sized payloads; idempotent via unique `eventId`; syncs on app open/resume/reconnect |
| **Skill-Gap Teacher Dashboard** | Weak-skill groups, multi-grade view, sync health, suggested activities |

---

## Architecture

### Diagram
![Architecture Diagram](docs/architecture.svg)

### Text Flow
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           CONTENT CREATION (Online, Once)                   │
│  Teacher Dashboard ──► Lambda (assemble pack) ──► ElevenLabs (TTS)          │
│       │                                                │                    │
│       └──────────────────────► S3 + CloudFront (lesson packs) ◄┘                    │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼ Download (brief online window)
┌─────────────────────────────────────────────────────────────────────────────┐
│                            STUDENT SIDE (Offline-First)                     │
│  Flutter Android App                                                        │
│  ├── SQLite: students, mastery scores, lesson packs, sync queue            │
│  ├── Adaptive Engine (Dart): rule-based mastery per skill                  │
│  ├── Audio Service: cached MP3 playback (Listen button)                    │
│  └── Sync Service: append-only queue, delta upload on reconnect            │
│                                                                             │
│  Airplane Mode ► "Offline Mode Active" badge ► Full learning works        │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼ Sync (when connectivity returns)
┌─────────────────────────────────────────────────────────────────────────────┐
│                              BACKEND & DASHBOARD                            │
│  API Gateway + Lambda (sync endpoint) ──► DynamoDB (events, metadata)      │
│                                                                             │
│  React Teacher Dashboard ◄─────────────────────────────────────────────────┘
│  └── Reads DynamoDB → Skill-gap groups, sync status, activity suggestions
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Tech Stack

| Layer | Technology | Why |
|-------|------------|-----|
| **Student App** | Flutter (Android) + SQLite (sqflite) | Reliable on low-end shared devices; true offline storage |
| **Adaptive Engine** | Dart (rule-based) | Explainable, zero API cost, works in airplane mode |
| **Voice** | ElevenLabs TTS → MP3 (pre-generated) | High-quality regional audio; no internet during learning |
| **Sync API** | AWS API Gateway + Lambda (Python) | Serverless, auto-scales, pay-per-use |
| **Database** | Amazon DynamoDB | Managed, low-latency, handles event streams |
| **Content Delivery** | Amazon S3 + CloudFront | Fast, cheap lesson pack downloads globally |
| **Auth** | Amazon Cognito | Teacher/admin login for dashboard |
| **Teacher Dashboard** | React + Vite (hosted on S3 + CloudFront) | Fast, offline-capable PWA for teachers |

---

## Repository Structure

```
ShikshaSync/
├── README.md
├── LICENSE
├── .gitignore
├── .env.example
├── docs/
│   └── architecture.png
├── app/                      # Flutter Android App (Student)
│   ├── pubspec.yaml
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/
│   │   ├── services/
│   │   │   ├── db_service.dart
│   │   │   ├── adaptive_engine.dart
│   │   │   ├── audio_service.dart
│   │   │   └── sync_service.dart
│   │   ├── screens/
│   │   │   ├── student_select.dart
│   │   │   ├── lesson_player.dart
│   │   │   └── offline_badge.dart
│   │   └── widgets/
│   └── assets/
│       └── lessons/
│           └── fractions-kannada/
├── backend/                  # AWS Lambda (Sync API)
│   ├── sync_handler.py
│   ├── manifest_handler.py
│   ├── requirements.txt
│   └── template.yaml
├── dashboard/                # React Teacher Dashboard
│   ├── package.json
│   ├── src/
│   │   ├── App.jsx
│   │   ├── components/
│   │   └── services/api.js
│   └── public/
└── lesson-packs/             # Source content for pack creation
    ├── fractions-kannada/
    └── manifest.json
```

---

## Run Locally

### Prerequisites
- Flutter SDK (≥3.16)
- Android Studio / VS Code with Flutter plugin
- Android emulator or physical device (API 24+)
- Node.js 18+ (for dashboard)
- AWS CLI + SAM CLI (for backend deploy — optional for local dev)

### Student App
```bash
cd app
flutter pub get
flutter run
```

### Teacher Dashboard
```bash
cd dashboard
npm install
npm run dev
```

### Backend (Local Testing with SAM)
```bash
cd backend
pip install -r requirements.txt
sam local start-api
```

### Environment Variables
Copy `.env.example` to `.env` and add your keys (`.env` is gitignored):
```bash
ELEVENLABS_API_KEY=your_key_here
AWS_REGION=us-east-1
DYNAMODB_TABLE=shikshasync-events
```

---

## License

MIT License — see [LICENSE](LICENSE) for details.

Copyright (c) 2026 Team Code Rangers, RV College of Engineering.