# ShikshaSync Demo Video Script & Recording Guide

## 🎯 Video Goal
Create a 3-5 minute video demonstrating the **complete offline learning flow** for wHACKiest 2026 UnlockED track submission.

---

## 📋 Pre-Recording Checklist

### Device Setup
- [ ] Android emulator (API 28+) OR physical Android device (Android 8+)
- [ ] Flutter app built and running: `cd app && flutter run --release`
- [ ] Teacher dashboard running: `cd dashboard && npm run dev` (for final screen)
- [ ] Screen recording ready: OBS Studio / Android screen recorder / scrcpy
- [ ] Clean desktop, notifications OFF, 1080p recording
- [ ] Good microphone (earphones with mic recommended)

### Test Data Ready
- [ ] **Student A**: "Priya" (PIN: 1234, Kannada, Grade 6, Avatar 1)
- [ ] **Student B**: "Arjun" (PIN: 5678, Kannada, Grade 6, Avatar 2)

---

## 🎬 Recording Script (Target: ~4:30 minutes)

### Segment 1: Intro & Problem (0:00–0:30)
**Speaker**: Ananya U Shetty (Team Lead)
**Visual**: App icon → Cover slide (3-5 sec) → Student select screen

> "Hello judges, we are **Team Code Rangers** from **RV College of Engineering**, competing in the **UnlockED track** of wHACKiest 2026. Our project is **ShikshaSync**, and our core idea is simple: **ShikshaSync does not wait for the internet to educate a child.**"
>
> "In rural schools, one teacher handles multiple grades with unreliable internet and shared devices. Most apps fail in these conditions. ShikshaSync is built for this reality."

### Segment 2: Student Selection & Shared Device (0:30–1:00)
**Visual**: Student select screen with two profiles

> "Here we have **two students sharing one device** — Priya and Arjun. Each has their own avatar, 4-digit PIN, language, and completely separate progress."
>
> *Tap Priya's avatar → Enter PIN 1234 → Show "Enter" button press → Navigate to lesson*

### Segment 3: Offline Mode & Lesson Start (1:00–1:30)
**Visual**: Lesson screen → Turn ON Airplane Mode (show notification shade)

> "Now I'm turning on **Airplane Mode**. Notice the **'Offline Mode Active' badge** — everything still works."
>
> *Show badge clearly, wait 1 sec*
>
> "Priya starts the fractions lesson in **Kannada**. She can listen to the narration."

**Action**: Tap "Listen to Lesson" button → Audio plays (placeholder)

### Segment 4: Adaptive Engine — Student Struggles (1:30–2:30) ⭐ KEY DEMO MOMENT
**Visual**: Question 1 (¼ + ¼ = ?) → Wrong answer → Hint appears

> "Priya answers the first question... **incorrectly**."
>
> *Tap wrong option (e.g., "¼") → Show red feedback*
>
> "She tries again on Question 2... **incorrect again**."
>
> *Tap wrong option on Q2 → Show red feedback*
>
> "Watch what happens: **two wrong answers in a row** triggers the adaptive engine. It instantly:"
> 1. **Plays a Kannada audio hint** (pre-cached, works offline)
> 2. **Shows a visual hint** with the pizza analogy
> 3. **Lowers difficulty** for the next question
> 4. **Updates her mastery score** from 50% → 32% → 14%

**Action**: 
- Q1: Select "¼" (wrong) → Submit → Show feedback
- Q2: Select "⅓" (wrong) → Submit → Wait for hint to appear → Play hint audio → Show visual hint
- Point to mastery % dropping: 50% → 32% → 14%

### Segment 5: Student Switching — Different Level (2:30–3:15)
**Visual**: Back to student select → Tap Arjun → Enter PIN 5678

> "Now let's switch to **Arjun** — separate profile, separate progress."
>
> *Enter PIN 5678 → Navigate to lesson*
>
> "Arjun answers Question 1... **correctly**."
>
> *Tap "½" → Submit → Green feedback*
>
> "Question 2... **correct again**. Two correct in a row means the engine **accelerates him to harder questions**."
>
> *Q2 correct → Show mastery rising: 50% → 62% → 74%*
>
> "His mastery is now **74%** — approaching mastery threshold of 80%."

### Segment 6: Sync When Online (3:15–3:45) ⭐ KEY DEMO MOMENT
**Visual**: Turn OFF Airplane Mode → Show sync indicator

> "Now connectivity returns. I turn **Wi-Fi back on**."
>
> *Show offline badge change to "Online"*
>
> "The app **automatically syncs** only the new progress events — a **few kilobytes**, works even on 2G."
>
> *If sync UI exists, show it; otherwise mention it happens in background*

### Segment 7: Teacher Dashboard (3:45–4:15)
**Visual**: Browser → Teacher Dashboard (localhost:3000)

> "On the **Teacher Dashboard**, we can see **what actually matters**: students grouped by **skill gaps**, not grades."
>
> *Show Skill Gap Groups card: "3 students need help with Adding fractions"*
>
> "Priya is flagged at **14% mastery** — needs revision. Arjun at **74%** — almost mastered."
>
> *Show Student Progress table with mastery bars*
>
> "The dashboard even **suggests a 10-minute group activity**: 'Revision: Adding fractions — 2 students need foundational help.'"

### Segment 8: Close (4:15–4:30)
**Visual**: App icon / Team photo / Cover slide

> "ShikshaSync: **Offline-first. Voice-assisted. Adaptive. Built for real rural classrooms.**"
>
> "We use **ElevenLabs** for regional-language voice and **AWS** for delta sync and the teacher dashboard."
>
> "Thank you. **ShikshaSync does not wait for the internet to educate a child.**"

---

## 🎥 Recording Tips

### For OBS Studio (Recommended)
1. **Sources**: 
   - Window Capture: Chrome (dashboard) + scrcpy/emulator window
   - Audio Input: Microphone
2. **Settings**: 1920×1080, 30fps, CBR 6000 kbps
3. **Hotkeys**: Start/Stop recording (Ctrl+Shift+R)

### For Android Screen Record (Alternative)
```bash
# Via scrcpy (shows phone screen on PC, record from PC)
scrcpy --record=demo.mp4

# Or on device: Settings → Developer options → Screen record
```

### Segment Recording Strategy
- Record **each segment separately** (8 short clips)
- Re-record any flubbed segment (don't restart all)
- Concatenate in editor (DaVinci Resolve free / CapCut / Clipchamp)

---

## 🔧 If Something Doesn't Work in Demo

| Issue | Fallback |
|-------|----------|
| Audio doesn't play | Say: "Audio plays here — pre-cached ElevenLabs MP3" |
| Sync doesn't show | Say: "Events queue locally, upload on reconnect" |
| Dashboard mock data | Say: "This is mock data showing the design; real data comes from DynamoDB" |
| App crashes | Have screenshot/video backup ready |

---

## 📤 Final Upload Checklist

- [ ] Video length: 3:00–5:00 minutes
- [ ] Title: `ShikshaSync | Team Code Rangers | wHACKiest 2026 | UnlockED`
- [ ] Description includes: GitHub link, PPT link, team members
- [ ] Visibility: **Unlisted** (or Public)
- [ ] Test in Incognito: link works
- [ ] Submit all 3 links on **Devnovate** before **11:59 PM today**

---

## 🎯 What Judges Want to See

1. ✅ **Real offline capability** (Airplane mode demo)
2. ✅ **Adaptive logic working** (wrong → hint → easier)
3. ✅ **Shared device profiles** (PIN switch, separate progress)
4. ✅ **Regional language** (Kannada text + audio)
5. ✅ **Teacher insight** (skill gaps, not just grades)
6. ✅ **Honesty** — call it "early prototype", show what works

---

## 📱 Quick Commands for Demo Day

```bash
# Terminal 1: Run Flutter app (release mode for speed)
cd D:/ShikshaSync/app
flutter run --release

# Terminal 2: Run Dashboard
cd D:/ShikshaSync/dashboard
npm run dev

# Terminal 3: (Optional) Test backend locally
cd D:/ShikshaSync/backend
sam local start-api
```

---

**Good luck Team Code Rangers! 🚀**