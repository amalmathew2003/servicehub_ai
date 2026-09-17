# ServiceHub — Final MVP Plan & Implementation Guide

## Project
ServiceHub is an AI-assisted service booking app. A user describes a service problem naturally, Groq understands it, asks for missing details, and the backend finds real nearby available staff. The user can book the staff member, receive status updates, see live staff location during the trip, and rate the completed service.

## Final Stack
- Flutter / Dart
- BLoC
- Dio
- GetIt
- GoRouter
- Firebase Auth
- Cloud Firestore
- Firebase Cloud Functions
- Firebase Cloud Messaging
- Firebase Storage
- Groq API
- Geolocator
- Google Maps (later in MVP)

## Architecture Rule
**Groq = conversation and understanding.**
**Firebase/Cloud Functions = trusted business logic and real data.**
Groq must never invent staff, availability, distance, or booking results.

---

# Current Progress

## Completed
- Flutter project created
- Required packages installed
- Firebase connected
- Email/password authentication enabled
- Google authentication enabled
- `AppUser` entity
- `AppUserModel`
- `AuthDatasource`
- `AuthRepository`
- `AuthRepositoryImpl`
- Register/Login/Google/Logout/GetCurrentUser use cases
- `AuthBloc`, events and states
- Login page
- Register page
- Auth gate
- Dependency injection with GetIt

Current authentication architecture:

```text
UI
 ↓
AuthBloc
 ↓
UseCase
 ↓
AuthRepository
 ↓
AuthRepositoryImpl
 ↓
AuthDatasource
 ↓
Firebase
```

## Not Completed Yet
- Proper role-based home navigation
- Staff registration/profile
- Staff service selection and experience
- Staff location and availability
- User Home
- Service categories
- AI chat UI
- Groq integration
- Groq tool/function calling
- Nearby staff search
- Distance calculation
- Staff cards
- Booking
- FCM notifications
- Staff accept/reject
- Live GPS
- User live map
- Arrived/in-progress/completed states
- Reviews
- Booking history
- Firestore security rules
- Final testing

---

# Firestore Collections

## users/{uid}

```json
{
  "uid": "user123",
  "name": "Amal",
  "email": "amal@gmail.com",
  "phone": "9999999999",
  "role": "user",
  "profileImage": null,
  "createdAt": "timestamp"
}
```

## staff/{staffId}

```json
{
  "uid": "staff123",
  "name": "Raj",
  "email": "raj@gmail.com",
  "phone": "9999999999",
  "role": "staff",
  "serviceType": "AC Repair",
  "experience": 5,
  "address": "Thrissur",
  "latitude": 10.52,
  "longitude": 76.21,
  "geohash": "...",
  "rating": 4.7,
  "isOnline": true,
  "isAvailable": true,
  "fcmToken": null,
  "profileImage": null,
  "createdAt": "timestamp"
}
```

## services/{serviceId}

Initial services:

```text
AC Repair
Plumbing
Electrical
Washing Machine Repair
Refrigerator Repair
Home Cleaning
Vehicle Service
```

## bookings/{bookingId}

```json
{
  "userId": "user123",
  "staffId": "staff123",
  "service": "AC Repair",
  "problem": "AC is not cooling",
  "date": "2026-09-20",
  "time": "17:00",
  "userLatitude": 10.52,
  "userLongitude": 76.21,
  "staffLatitude": 10.54,
  "staffLongitude": 76.20,
  "status": "pending",
  "createdAt": "timestamp",
  "acceptedAt": null,
  "completedAt": null
}
```

Statuses:

```text
pending
accepted
rejected
on_the_way
arrived
in_progress
completed
cancelled
```

## reviews/{reviewId}

```json
{
  "bookingId": "booking123",
  "userId": "user123",
  "staffId": "staff123",
  "rating": 5,
  "comment": "Excellent service",
  "createdAt": "timestamp"
}
```

---

# Step-by-Step Implementation Plan

## STEP 1 — Project Setup
**Status: COMPLETED**

Flutter project, packages and Firebase setup are done.

## STEP 2 — Authentication Architecture
**Status: COMPLETED**

Datasource → Repository → UseCases → BLoC are done.

## STEP 3 — Authentication UI
**Status: MOSTLY COMPLETED**

Login, register, Google login and AuthGate are created.

Test:
- Email registration
- Email login
- Google login
- Logout
- App restart/current-user check

---

# STEP 4 — Role-Based Navigation
**NEXT**

Remove the temporary `HomePlaceholderPage`.

Create:

```text
lib/features/user/presentation/pages/user_home_page.dart
lib/features/staff/presentation/pages/staff_home_page.dart
```

After authentication:

```text
AuthAuthenticated
      ↓
user.role
   ┌──┴──┐
   ↓     ↓
 user   staff
   ↓     ↓
UserHome StaffHome
```

This is the immediate next task.

---

# STEP 5 — Staff Registration

Create staff registration with:

```text
Name
Phone
Email
Service
Experience
Address
Profile image
Location
```

Save to:

```text
staff/{uid}
```

Initial values:

```text
isOnline = false
isAvailable = false
rating = 0
```

---

# STEP 6 — Staff Dashboard

Show:

```text
Staff name
Service
Rating
Experience

Online / Offline
Available / Busy

Pending requests
Today's bookings
```

---

# STEP 7 — Staff Location

Use Geolocator to get:

```text
latitude
longitude
```

Save to Firestore.

For the first MVP, update location during active work/trip instead of continuously tracking all day.

---

# STEP 8 — User Home

Create the real User Home:

```text
Good morning

How can we help you?

[ Talk to ServiceHub AI ]

Popular Services

AC Repair
Plumbing
Electrical
Refrigerator
Washing Machine
Cleaning
```

---

# STEP 9 — AI Chat UI

Create the chat screen:

```text
ServiceHub AI

AI:
Hi! What can I help you with today?

User:
My AC isn't cooling.

AI:
I can help you find an AC technician.
When would you like the technician to visit?
```

Add message list, text field and send button.

Voice input can be added later.

---

# STEP 10 — Connect Groq

Do not put the Groq API key in Flutter.

Use:

```text
Flutter
 ↓
Firebase Cloud Function
 ↓
Groq API
```

Store the secret server-side.

Example setup:

```bash
firebase functions:secrets:set GROQ_API_KEY
```

Use the Groq Chat Completions endpoint from the Cloud Function.

---

# STEP 11 — First Groq Test

First make only simple conversation work.

Example:

```text
User:
My AC is not cooling.

Groq:
I can help you find an AC technician.
When would you like the technician to visit?
```

At this point there is no staff search yet.

---

# STEP 12 — Groq Tool Calling

Add backend tools:

```text
findNearbyStaff
getStaffDetails
createBooking
getBookingStatus
```

Flow:

```text
User message
 ↓
Groq
 ↓
Tool requested
 ↓
Cloud Function executes tool
 ↓
Firebase
 ↓
Real result
 ↓
Groq
 ↓
Natural response
```

Never trust AI output without backend validation.

---

# STEP 13 — Find Nearby Staff

Backend checks:

```text
serviceType matches
isOnline == true
isAvailable == true
valid location
```

Then:

```text
Find candidates
 ↓
Calculate exact distance
 ↓
Sort nearest
 ↓
Return real staff
```

For a larger dataset, use Firestore geohashes for geoqueries and exact-distance filtering.

---

# STEP 14 — Staff Cards

Display:

```text
Raj
AC Repair
5 years experience
⭐ 4.7
2.4 km away

[Book]
```

The distance comes from backend calculation.

---

# STEP 15 — Booking Confirmation

AI says:

```text
I found Raj, an AC technician,
2.4 km away.

Would you like to book Raj?
```

User confirms:

```text
Book Raj
```

Only then create the booking.

---

# STEP 16 — Create Booking

Backend validates:

```text
User authenticated?
Staff exists?
Correct service?
Staff available?
```

Then:

```text
bookings/{bookingId}
status = pending
```

---

# STEP 17 — FCM Notification

Booking creation triggers a notification to the staff device:

```text
New Service Request

Customer: Amal
Service: AC Repair
Problem: AC not cooling
Time: Tomorrow 5 PM

[View Request]
```

---

# STEP 18 — Staff Request Screen

Staff sees:

```text
AC Repair
Customer: Amal
Problem: AC is not cooling
Date: Tomorrow
Time: 5:00 PM

[Reject] [Accept]
```

---

# STEP 19 — Accept / Reject

Accept:

```text
pending → accepted
```

Reject:

```text
pending → rejected
```

User listens to the booking document and sees the update.

---

# STEP 20 — Start Trip

Staff taps:

```text
START TRIP
```

Status:

```text
on_the_way
```

GPS tracking starts for the active booking.

---

# STEP 21 — Live GPS

Flow:

```text
Staff phone
 ↓
Geolocator
 ↓
Firestore booking location
 ↓
User Firestore listener
 ↓
Map marker
```

Use a reasonable distance filter rather than sending GPS every second.

---

# STEP 22 — User Live Map

Show:

```text
User 📍
                  🚗 Staff
```

Show:

```text
Staff is on the way
Current location
Distance
Booking status
```

Google Maps integration is done here.

---

# STEP 23 — Arrived

Staff taps:

```text
ARRIVED
```

Status:

```text
arrived
```

User sees:

```text
Your technician has arrived.
```

---

# STEP 24 — Start Service

Staff taps:

```text
START SERVICE
```

Status:

```text
in_progress
```

---

# STEP 25 — Complete Service

Staff taps:

```text
COMPLETE
```

Status:

```text
completed
```

Save:

```text
completedAt
```

Stop active trip tracking.

---

# STEP 26 — Rating & Review

User sees:

```text
How was your service?

⭐ ⭐ ⭐ ⭐ ⭐

Write a review...

[Submit]
```

Save to:

```text
reviews/{reviewId}
```

Update staff rating.

---

# STEP 27 — User History

Show:

```text
My Bookings

AC Repair
Raj
Completed

Plumbing
Suresh
Completed

Electrical
John
Cancelled
```

---

# STEP 28 — Staff History

Show:

```text
My Jobs

Pending
Accepted
Completed
Cancelled
```

---

# STEP 29 — Security

Secure:

```text
users
staff
bookings
reviews
```

Users should only access their own protected data.

Staff should only access their own profile and assigned bookings.

Critical booking operations should be validated by trusted backend code.

Never expose:

```text
GROQ_API_KEY
```

in Flutter.

---

# STEP 30 — Final Testing

Test the complete flow:

```text
User Register
 ↓
Staff Register
 ↓
Staff Online
 ↓
User asks AI
 ↓
Groq understands
 ↓
AI asks missing details
 ↓
User location
 ↓
Nearby staff
 ↓
User books
 ↓
Staff notification
 ↓
Staff accepts
 ↓
Staff starts trip
 ↓
Live GPS
 ↓
Arrived
 ↓
In Progress
 ↓
Completed
 ↓
Rating
 ↓
History
```

---

# AI Example

User can say unexpected things:

```text
"My AC isn't giving cold air."
```

```text
"Fridge is running but everything is warm."
```

```text
"Water is leaking from under my sink."
```

```text
"My washing machine is making a strange noise."
```

Groq should understand the likely service and ask a question if it is uncertain.

If it cannot confidently identify the service:

```text
I can help with that. Is the problem related to
your AC, refrigerator, plumbing, electrical system,
or another appliance?
```

AI should ask rather than invent an answer.

---

# What We Are Building

The final portfolio story is:

> **ServiceHub is an AI-assisted local service booking platform where users describe problems naturally, Groq understands the request, Firebase finds real available nearby professionals, users can book them, staff receive notifications, and users can track the technician during the trip.**

---

# What We Do Next

You are currently here:

```text
STEP 1  ✅
STEP 2  ✅
STEP 3  🟡
STEP 4  ← NEXT
```

### Immediate next task:

**STEP 4 — Role-Based Navigation**

We will create:

```text
UserHomePage
StaffHomePage
```

and connect them to `AuthGate`.

After that:

```text
STEP 5
Staff Registration
```

Then:

```text
STEP 6
Staff Dashboard
```

Then:

```text
STEP 7
Staff Location
```

Then we start the user side and finally connect **Groq**.

---

# Development Rule

For every step:

```text
1. Create files
2. Add code
3. Run flutter analyze
4. Run the app
5. Test
6. Fix errors
7. Move to the next step
```

Do not implement multiple unfinished steps at once.
