# Get Assigned Members for Duty Post Implementation

## Overview
Implemented the API to fetch assigned members under each duty post, displaying them in a beautiful, detailed view.

## API Details

### Endpoint
```
GET {{CJTF}}/api/v1/admin/duty/assign/{dutyPostId}
```

### Example Request
```bash
curl --location -g '{{CJTF}}/api/v1/admin/duty/assign/f61a6e01-274e-4023-abc3-5af7e4756d8b'
```

### Response Format
```json
{
  "responseSuccessful": true,
  "responseMessage": "Duty posts successfully fetched",
  "responseBody": [
    {
      "memberId": "46096eb5-e5ab-413e-9cc0-7a1913571329",
      "member": {
        "id": "46096eb5-e5ab-413e-9cc0-7a1913571329",
        "fullName": "Zakiyya Gambo",
        "idNo": "AK-89",
        "rifleNo": "AK-89",
        "tribe": "kjhgf",
        "religion": "hkugjyfhtg",
        "dateOfBirth": "2026-02-01T23:00:00.000Z",
        "phoneNumber": "098765",
        "locationId": "e3c919f8-2ad7-4e29-ad09-15cdfe721cae",
        "gender": "female",
        "permanentAddress": "khgjyfhtcgdx",
        "maritalStatus": "khjghfgdsz",
        "position": "jihkugjyfh",
        "ninNo": "jlhkugjyf",
        "state": "jlihkugjvh",
        "accountNo": "jkhjghfcg",
        "unitArea": "jhkujgyhfc",
        "unitAreaType": "boyce batch b",
        "photo": "https://res.cloudinary.com/...",
        "guarantorFullName": "hkgjyfhdg",
        "guarantorRelationship": "kjhgf",
        "guarantorTribe": "lkhjgf",
        "guarantorPhoneNumber": "kjhvgc",
        "emergencyFullName": "highflying",
        "emergencyAddress": "klkjgfhg",
        "emergencyPhoneNumber": "hgjyfhgx",
        "nextOfKinFullName": "ljhvcg",
        "nextOfKinAddress": "kjhgf",
        "nextOfKinPhoneNumber": "hkjgyfh",
        "status": "ACTIVE",
        "createdAt": "2026-02-03T15:36:31.495Z",
        "updatedAt": "2026-02-03T15:36:31.495Z",
        "dutyPostId": null
      },
      "day": "2026-02-06",
      "assignmentId": "a7d9d20b-8534-44d2-a9d5-2db49765ec4a"
    }
  ]
}
```

## Changes Made

### 1. New Model: DutyAssignment
**File:** `lib/models/duty_assignment.dart`

Created comprehensive models for duty assignments:

#### DutyAssignment Class
```dart
class DutyAssignment {
  final String memberId;
  final AssignedMember member;
  final String day;
  final String assignmentId;
}
```

#### AssignedMember Class
Complete member information including:
- Personal details (name, ID, rifle number, etc.)
- Contact information
- Location and unit details
- Photo URL
- Guarantor information
- Emergency contact
- Next of kin details
- Status and timestamps

**Features:**
- Full member data structure
- Helper methods (`dateOfBirthParsed`, `displayPhoto`, `hasPhoto`)
- JSON serialization/deserialization
- Null safety for all optional fields

### 2. Updated Duty Service
**File:** `lib/services/duty_service.dart`

Added new method `getAssignedMembers(dutyPostId)`:

```dart
Future<List<DutyAssignment>> getAssignedMembers(String dutyPostId) async {
  debugPrint('🟡 FETCH ASSIGNED MEMBERS STARTED');
  debugPrint('📍 DUTY POST ID: $dutyPostId');
  
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');

  if (token == null) {
    throw Exception('Session expired');
  }

  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/admin/duty/assign/$dutyPostId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  // Parse and return assignments
  final data = jsonDecode(response.body);
  final List list = data['responseBody'] ?? [];
  return list.map((e) => DutyAssignment.fromJson(e)).toList();
}
```

**Features:**
- Fetches assigned members for a specific duty post
- Bearer token authentication
- Comprehensive error handling
- Debug logging
- Returns list of `DutyAssignment` objects

### 3. Enhanced Duty Post Screen
**File:** `lib/screens/duty/duty_post_screen.dart`

#### New Widget: DutyPostDetailsSheet

Created a stateful widget to display duty post details with assigned members:

**Features:**

1. **Automatic Data Loading**
   - Fetches assigned members when modal opens
   - Shows loading indicator while fetching
   - Handles errors gracefully

2. **Beautiful Member Cards**
   - Profile picture (from URL or initials)
   - Member name and rifle number
   - Assignment date with calendar icon
   - Status badge (ACTIVE/INACTIVE)
   - Clean, card-based layout

3. **Member Count Badge**
   - Shows total number of assigned members
   - Color-coded badge next to section title

4. **Empty State**
   - Friendly message when no members assigned
   - Icon and helpful text
   - Encourages user to assign members

5. **Enhanced Layout**
   - Increased modal height to 80% for more space
   - Scrollable content
   - Proper spacing and padding
   - Handle bar for better UX

#### Member Card Design

```dart
Widget _buildMemberCard(BuildContext context, DutyAssignment assignment) {
  return Container(
    // Card with border and background
    child: Row(
      children: [
        // Profile Picture (CircleAvatar)
        // Member Info (name, rifle no, date)
        // Status Badge (ACTIVE/INACTIVE)
      ],
    ),
  );
}
```

**Card Features:**
- Profile picture with fallback to initials
- Member full name (bold)
- Rifle number (if available)
- Assignment date with icon
- Status badge with color coding
- Responsive layout

## User Experience Flow

1. **View Duty Post**
   - User taps on a duty post card
   - Modal slides up from bottom

2. **Loading Assigned Members**
   - Loading indicator appears
   - API fetches assigned members
   - Data is displayed

3. **View Assigned Members**
   - See list of all assigned members
   - Each member shows:
     - Profile picture
     - Name and rifle number
     - Assignment date
     - Status badge
   - Member count badge shows total

4. **Empty State**
   - If no members assigned
   - Shows friendly empty state
   - User can tap "Assign Duty" button

5. **Assign More Members**
   - User taps "Assign Duty" button
   - Navigates to assignment screen
   - Can assign additional members

## UI Components

### Member Card Layout
```
┌─────────────────────────────────────────┐
│  ┌──┐  Zakiyya Gambo         [ACTIVE]  │
│  │ZG│  Rifle No: AK-89                 │
│  └──┘  📅 6/2/2026                      │
└─────────────────────────────────────────┘
```

### Details Modal Structure
```
┌─────────────────────────────────────────┐
│  ━━━━  (handle bar)                     │
├─────────────────────────────────────────┤
│  🏢  Sample Post                        │
│      Duty Post                          │
│                                         │
│  Description                            │
│  ┌───────────────────────────────────┐ │
│  │ Post description here             │ │
│  └───────────────────────────────────┘ │
│                                         │
│  🔑 Post ID                             │
│     f61a6e01-274e-4023-abc3...         │
│                                         │
│  Assigned Members              [2]     │
│  ┌───────────────────────────────────┐ │
│  │ 👤 Zakiyya Gambo    [ACTIVE]     │ │
│  │    Rifle: AK-89                   │ │
│  │    📅 6/2/2026                    │ │
│  └───────────────────────────────────┘ │
│  ┌───────────────────────────────────┐ │
│  │ 👤 Salma Gambo      [ACTIVE]     │ │
│  │    Rifle: AK-865                  │ │
│  │    📅 6/2/2026                    │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  👥 Assign Duty                   │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## Features

### Data Display
- ✅ Fetches assigned members from API
- ✅ Shows member profile pictures
- ✅ Displays member names and rifle numbers
- ✅ Shows assignment dates
- ✅ Color-coded status badges
- ✅ Member count badge

### UI/UX
- ✅ Beautiful card-based layout
- ✅ Loading indicators
- ✅ Empty state handling
- ✅ Error handling with SnackBar
- ✅ Scrollable content
- ✅ Responsive design
- ✅ Handle bar for modal

### Functionality
- ✅ Automatic data loading
- ✅ Navigate to assign duty screen
- ✅ View all member details
- ✅ Status indicators
- ✅ Date formatting

## Error Handling

1. **Session Expired**: Shows error message
2. **Network Errors**: Displays SnackBar with error details
3. **API Errors**: Shows user-friendly error message
4. **Empty Data**: Shows empty state with helpful message
5. **Loading States**: Shows progress indicators

## Benefits

1. **Complete Information**: Users see all assigned members at a glance
2. **Beautiful UI**: Modern, clean design with proper visual hierarchy
3. **Real-time Data**: Fetches latest assignments from API
4. **Easy Navigation**: Quick access to assign more members
5. **Status Visibility**: Clear indication of member status
6. **Date Tracking**: Shows when members were assigned
7. **Profile Pictures**: Visual identification of members
8. **Responsive**: Works well on different screen sizes

## Testing Checklist

- [x] Fetch assigned members for duty post
- [x] Display members in cards
- [x] Show profile pictures (URL or initials)
- [x] Display member names and rifle numbers
- [x] Show assignment dates
- [x] Display status badges
- [x] Show member count
- [x] Handle empty state
- [x] Show loading indicator
- [x] Handle errors gracefully
- [x] Navigate to assign duty screen
- [x] Scroll through long lists

## Future Enhancements

1. **Remove Assignment**: Add ability to remove members from duty
2. **Edit Assignment**: Change assignment date
3. **Member Details**: Tap member card to view full details
4. **Filter/Search**: Search assigned members
5. **Sort**: Sort by name, date, or status
6. **Export**: Export assignment list
7. **Notifications**: Notify members of assignments
8. **History**: View assignment history
9. **Shift Management**: Assign members to specific shifts
10. **Attendance**: Track member attendance for duty

## Conclusion

The assigned members feature is now fully implemented with a beautiful, user-friendly interface. Users can view all members assigned to each duty post, see their details, and easily assign more members as needed.
