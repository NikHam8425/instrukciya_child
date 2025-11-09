# Мамин путь

Приложение для родителей с семейной синхронизацией, чек-листами и GPT-ассистентом.

## Функционал

- ✅ Динамические чек-листы для всех возрастов (беременность, 0-17 лет)
- ✅ GPT-ассистент с персонализацией
- ✅ Семейная синхронизация через Firebase
- ✅ Приглашения через WhatsApp
- ✅ Push-уведомления
- ✅ Система подписки (5 бесплатных действий)
- ✅ Аутентификация (Email, Apple, Google)

## Настройка Firebase

### 1. Создайте проект Firebase

1. Перейдите на [Firebase Console](https://console.firebase.google.com/)
2. Создайте новый проект
3. Добавьте iOS и Android приложения

### 2. Установите Firebase CLI

```bash
npm install -g firebase-tools
firebase login
flutterfire configure
```

### 3. Скачайте конфигурационные файлы

**iOS:**
- Скачайте `GoogleService-Info.plist`
- Поместите в `ios/Runner/`

**Android:**
- Скачайте `google-services.json`
- Поместите в `android/app/`

### 4. Настройте Authentication

В Firebase Console → Authentication → Sign-in method:
- ✅ Email/Password
- ✅ Google
- ✅ Apple (iOS)

### 5. Настройте Firestore

Создайте базу данных и добавьте правила безопасности (см. ниже)

### 6. Настройте Cloud Messaging

**iOS:**
1. Создайте APNs Key в Apple Developer
2. Загрузите в Firebase Console

**Android:**
Автоматически настроено

## Установка

```bash
flutter pub get
flutter run
```

## Новые файлы для создания

Создайте следующие файлы вручную:

### `lib/screens/auth/login_screen.dart`
### `lib/screens/auth/signup_screen.dart`
### `lib/screens/subscription_screen.dart`
### `lib/models/family_event.dart`
### `lib/services/notification_service.dart`

Полный код для этих файлов смотрите в `IMPLEMENTATION_GUIDE.md`

## Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /families/{familyId} {
      allow read: if request.auth != null && request.auth.uid in resource.data.memberIds;
      allow create: if request.auth != null;
      allow update: if request.auth != null && request.auth.uid in resource.data.memberIds;
    }
    
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /families/{familyId}/events/{eventId} {
      allow read, write: if request.auth != null && 
        exists(/databases/$(database)/documents/families/$(familyId)) &&
        request.auth.uid in get(/databases/$(database)/documents/families/$(familyId)).data.memberIds;
    }
  }
}
```

## Структура Firestore

```
families/
  {familyId}/
    - name: string
    - memberIds: array<string>
    - creatorId: string
    - inviteCode: string
    
    events/
      {eventId}/
        - title: string
        - type: string
        - createdBy: string
        - createdAt: timestamp

users/
  {userId}/
    - email: string
    - familyId: string
    - isPremium: boolean
    - freeActionsCount: number
    - fcmToken: string
```

## Следующие шаги

1. ✅ Примените все изменения
2. ✅ Запустите `flutter pub get`
3. ✅ Настройте Firebase (см. выше)
4. ✅ Создайте новые файлы (код ниже)
5. ✅ Запустите приложение
