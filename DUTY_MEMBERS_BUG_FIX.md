# Duty Members Not Showing - Bug Fix

## Issue Description
When trying to assign members to duty posts, the app displays "No HQ Members Available" even though members are registered in the system with HQ location.

## Root Cause
The backend API endpoint `/api/v1/admin/duty/members` was returning an empty data array despite having members in the database.

### API Response (Before Fix):
```json
{
  "responseSuccessful": true,
  "responseMessage": "Members fetched successfully",
  "responseBody": {
    "data": [],      // ❌ Empty array
    "total": 3,      // ✅ Shows 3 members exist
    "page": 1,
    "limit": 10
  }
}
```

## Solution
Added pagination parameters (`page=1&limit=100`) to the API request to ensure the backend returns the actual member data.

### Changes Made:

**File: `lib/services/member_service.dart`**

```dart
// BEFORE
final response = await api!.get('/api/v1/admin/duty/members');

// AFTER
final response = await api!.get('/api/v1/admin/duty/members?page=1&limit=100');
```

## Technical Details

The backend endpoint requires pagination parameters to return data:
- `page`: Page number (starting from 1)
- `limit`: Number of records per page

Without these parameters, the backend returns metadata (total count) but no actual data records.

## Testing
1. Login to the app
2. Navigate to Duty Posts screen
3. Create a duty post (if none exists)
4. Click on the duty post to assign members
5. Verify that HQ members are now displayed in the dropdown

## Expected Result
Members with HQ location should now appear in the "Select Members (HQ Only)" dropdown when assigning duty.

## Related Files
- `lib/services/member_service.dart` - Added pagination parameters
- `lib/screens/duty/assign_duty_screen.dart` - Consumes the duty members data

## Backend Note
The backend team should consider:
1. Making pagination parameters optional with sensible defaults
2. Returning all records when pagination params are not provided
3. Or documenting that pagination is required for this endpoint
