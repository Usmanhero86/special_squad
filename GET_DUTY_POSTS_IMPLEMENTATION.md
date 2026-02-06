# Get Duty Posts API Implementation

## Overview
Implemented the `getDutyPosts` API integration to fetch duty posts from the backend with pagination support.

## API Details

### Endpoint
```
GET {{CJTF}}/api/v1/admin/duty?page=1&limit=10
```

### Response Format
```json
{
  "responseSuccessful": true,
  "responseMessage": "Duty posts successfully fetched",
  "responseBody": {
    "data": [
      {
        "id": "f61a6e01-274e-4023-abc3-5af7e4756d8b",
        "postName": "Sample post",
        "description": null
      },
      {
        "id": "f48ba00e-e14c-4c8b-89c3-7982e0e45321",
        "postName": "Duty Post",
        "description": null
      }
    ],
    "total": 9,
    "page": 1,
    "limit": 10
  }
}
```

## Changes Made

### 1. Updated DutyPost Model
**File:** `lib/models/duty_post.dart`

Added support for the optional `description` field:

```dart
class DutyPost {
  final String id;
  final String name;
  final String? description;  // NEW

  DutyPost({
    required this.id,
    required this.name,
    this.description,  // NEW
  });

  factory DutyPost.fromJson(Map<String, dynamic> json) {
    return DutyPost(
      id: json['id'] ?? '',
      name: json['postName'] ?? '',
      description: json['description'],  // NEW
    );
  }

  Map<String, dynamic> toJson() {  // NEW
    return {
      'id': id,
      'postName': name,
      'description': description,
    };
  }
}
```

### 2. Updated Duty Service
**File:** `lib/services/duty_service.dart`

Added new `getDutyPosts()` method with pagination:

```dart
Future<List<DutyPost>> getDutyPosts({int page = 1, int limit = 10}) async {
  debugPrint('🟡 FETCH DUTY POSTS STARTED');
  debugPrint('📍 URL: $baseUrl/api/v1/admin/duty?page=$page&limit=$limit');

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');

  if (token == null) {
    throw Exception('Session expired');
  }

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/admin/duty?page=$page&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('📥 STATUS: ${response.statusCode}');
    debugPrint('📥 BODY: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch duty posts: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);

    if (data['responseSuccessful'] != true) {
      throw Exception(data['responseMessage'] ?? 'Failed to fetch duty posts');
    }

    final List list = data['responseBody']['data'] ?? [];
    final posts = list.map((e) => DutyPost.fromJson(e)).toList();

    debugPrint('✅ DUTY POSTS FETCHED: ${posts.length}');
    
    return posts;
  } catch (e) {
    debugPrint('❌ ERROR FETCHING DUTY POSTS: $e');
    rethrow;
  }
}
```

**Features:**
- Pagination support with `page` and `limit` parameters
- Bearer token authentication
- Comprehensive error handling
- Debug logging for troubleshooting
- Parses response into `DutyPost` objects

### 3. Completely Rewrote Duty Post Screen
**File:** `lib/screens/duty/duty_post_screen.dart`

#### New Features:

1. **API Integration**
   - Fetches duty posts from the API on screen load
   - Displays real data from the backend

2. **Pagination Support**
   - Loads 10 posts at a time
   - Infinite scroll to load more posts
   - Shows loading indicator while fetching more data
   - Tracks if more posts are available

3. **Refresh Functionality**
   - Added refresh button in app bar
   - Resets pagination and reloads data

4. **Enhanced UI**
   - Clean, modern design
   - Empty state with helpful message
   - Loading states for better UX
   - Smooth scrolling with pagination

5. **Improved Duty Post Details Modal**
   - Beautiful bottom sheet design
   - Shows post name with icon
   - Displays description (if available)
   - Shows post ID
   - "Assign Duty" button to navigate to assignment screen
   - Handle bar for better UX
   - Proper spacing and layout

6. **Add Duty Post Dialog**
   - Support for post name (required)
   - Support for description (optional)
   - Adds new post to the beginning of the list
   - Success/error feedback

7. **Edit & Delete Placeholders**
   - Edit dialog with name and description fields
   - Delete confirmation dialog
   - Ready for future API implementation

#### Key Components:

**Pagination Variables:**
```dart
int _currentPage = 1;
final int _limit = 10;
bool _hasMore = true;
```

**Load Data Method:**
```dart
Future<void> _loadData() async {
  final dutyService = Provider.of<DutyService>(context, listen: false);

  try {
    setState(() {
      _isLoading = true;
    });

    final List<DutyPost> posts = await dutyService.getDutyPosts(
      page: _currentPage,
      limit: _limit,
    );

    if (mounted) {
      setState(() {
        _dutyPosts = posts;
        _isLoading = false;
        _hasMore = posts.length >= _limit;
      });
    }
  } catch (e) {
    // Error handling
  }
}
```

**Infinite Scroll:**
```dart
NotificationListener<ScrollNotification>(
  onNotification: (ScrollNotification scrollInfo) {
    if (!_isLoading &&
        _hasMore &&
        scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
      _loadMorePosts();
    }
    return false;
  },
  child: ListView.builder(
    itemCount: _dutyPosts.length + (_hasMore ? 1 : 0),
    itemBuilder: (context, index) {
      if (index == _dutyPosts.length) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        );
      }
      // ... render duty post card
    },
  ),
)
```

**Enhanced Details Modal:**
```dart
void showDutyPostDetails(DutyPost post) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          // Title with icon
          // Description (if available)
          // Post ID
          // Assign Duty button
        ],
      ),
    ),
  );
}
```

## User Experience Flow

1. **Screen Load**
   - Shows loading indicator
   - Fetches first 10 duty posts from API
   - Displays posts in a list

2. **Scroll to Load More**
   - User scrolls to bottom of list
   - Loading indicator appears
   - Next page of posts is fetched
   - New posts are appended to the list

3. **View Duty Post Details**
   - User taps on a duty post card
   - Beautiful modal slides up from bottom
   - Shows post name, description, and ID
   - User can tap "Assign Duty" to assign members

4. **Add New Duty Post**
   - User taps "+" button in app bar
   - Dialog appears with name and description fields
   - User enters information and taps "Add"
   - New post is created via API
   - New post appears at top of list

5. **Refresh Data**
   - User taps refresh button in app bar
   - Pagination resets to page 1
   - Data is reloaded from API

## Error Handling

1. **Session Expired**: Shows error message
2. **Network Errors**: Displays SnackBar with error details
3. **API Errors**: Shows user-friendly error message
4. **Empty State**: Shows helpful message with "Add First Duty Post" button

## Benefits

1. **Real Data**: Displays actual duty posts from the backend
2. **Pagination**: Efficient loading of large datasets
3. **Infinite Scroll**: Seamless user experience
4. **Refresh**: Easy way to reload data
5. **Beautiful UI**: Modern, clean design
6. **Error Resilience**: Graceful error handling
7. **Performance**: Only loads data when needed
8. **Extensible**: Ready for edit/delete functionality

## Testing Checklist

- [x] Fetch duty posts from API on screen load
- [x] Display posts in a list
- [x] Show loading indicator while fetching
- [x] Handle empty state
- [x] Scroll to load more posts (pagination)
- [x] Show loading indicator while loading more
- [x] Tap post to view details
- [x] Display description if available
- [x] Add new duty post
- [x] Refresh data
- [x] Handle network errors
- [x] Handle session expiration
- [x] Navigate to assign duty screen

## Future Enhancements

1. **Edit Duty Post**: Implement PUT endpoint
2. **Delete Duty Post**: Implement DELETE endpoint
3. **Search/Filter**: Add search functionality
4. **Sort**: Add sorting options
5. **Pull to Refresh**: Add pull-to-refresh gesture
6. **Caching**: Cache duty posts locally
7. **Offline Support**: Show cached data when offline
