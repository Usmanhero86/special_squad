# Special Squad - Organization Management App

A Flutter-based organization management application for managing members, duties, and payments within an organization.

## Features

- **Member Management**: Register new members, view member lists, store member profiles with photos
- **Duty Management**: Create duty posts, schedule duty rosters, assign duties to members
- **Payment Tracking**: Record payments, view payment history, manage financial transactions
- **Local Authentication**: Secure login/registration system with local database storage
- **Dashboard**: Central hub with quick access to all features

## Technical Stack

- **Frontend**: Flutter for cross-platform mobile development
- **Database**: SQLite for local data storage
- **Authentication**: Custom local authentication with password hashing
- **File Storage**: Local file system for images and attachments
- **State Management**: Provider pattern
- **UI Components**: Syncfusion widgets for advanced UI components (data grids, calendars)
- **PDF Generation**: Built-in PDF generation and printing capabilities

## Getting Started

### Prerequisites

- Flutter SDK (3.10.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd special_squad
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Database Setup

The app uses SQLite for local data storage. The database is automatically created on first run with the following tables:

- `users` - User authentication data
- `members` - Organization member information
- `payments` - Payment records and history
- `duty_posts` - Available duty positions
- `duty_rosters` - Duty assignments and schedules

### File Storage

- Member profile images: `<app_documents>/members/<member_id>/`
- Payment attachments: `<app_documents>/payments/<payment_id>/`

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── member.dart
│   ├── payment.dart
│   ├── duty_post.dart
│   └── duty_roster.dart
├── services/                 # Business logic services
│   ├── auth_service.dart     # Authentication service
│   ├── database_helper.dart  # SQLite database helper
│   ├── member_service.dart   # Member management
│   ├── payment_service.dart  # Payment management
│   └── duty_service.dart     # Duty management
├── screens/                  # UI screens
│   ├── auth/                 # Authentication screens
│   ├── members/              # Member management screens
│   ├── payments/             # Payment screens
│   ├── duty/                 # Duty management screens
│   └── dashboard.dart        # Main dashboard
└── widgets/                  # Reusable UI components
```

## Key Features

### Authentication
- Local user registration and login
- Password hashing with SHA-256
- Session management with SharedPreferences
- User profile management

### Member Management
- Add/edit/delete members
- Profile image storage
- Search and filter members
- Member status tracking

### Payment Management
- Record payments with multiple methods
- Attach receipts and documents
- Payment history and reporting
- Member payment tracking

### Duty Management
- Create and manage duty posts
- Schedule duty rosters
- Assign members to duties
- Track duty status and completion

## Development

### Adding New Features

1. Create models in `lib/models/`
2. Add database tables in `database_helper.dart`
3. Implement service logic in `lib/services/`
4. Create UI screens in `lib/screens/`
5. Add navigation routes in `main.dart`

### Database Migrations

To add new tables or modify existing ones:

1. Update the `_onCreate` method in `database_helper.dart`
2. Increment the database version
3. Add migration logic in `_onUpgrade` method

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact the development team or create an issue in the repository.
