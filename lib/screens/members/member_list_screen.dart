import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:special_squad/services/member_service.dart';
import '../../models/getAllMember.dart';
import '../../models/member_overview.dart';
import '../../models/member.dart';
import '../../services/location_provider.dart';
import 'add_member_screen.dart';
import 'member_detail_screen.dart';
import 'edit_member_screen.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Members> _allMembers = [];
  List<Members> _filteredMembers = [];
  bool _isLoading = true;
  bool _membersLoaded = false;
  bool _overviewLoaded = false;
  bool hasValidPhoto(String? photo) {
    return photo != null &&
        photo.isNotEmpty &&
        photo.startsWith('http') &&
        !photo.contains('example.com');
  }

  final int _page = 1;
  final int _limit = 10;
  MemberOverview? _overview;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _membersLoaded = false;
    _overviewLoaded = false;

    _loadMembers();
    _loadOverview();

    _searchController.addListener(_onSearchChanged);
  }

  void _updateLoadingState() {
    if (_membersLoaded && _overviewLoaded) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadOverview() async {
    try {
      final memberService = context.read<MemberService>();
      final overview = await memberService.getMemberOverview();

      if (!mounted) return;

      _overview = overview;
      _overviewLoaded = true;
    } catch (e) {
      debugPrint('OVERVIEW ERROR: $e');
      _overviewLoaded = true;
    } finally {
      _updateLoadingState();
    }
  }

  Future<void> _loadMembers() async {
    try {
      final memberService = context.read<MemberService>();
      final members = await memberService.getMembers(
        page: _page,
        limit: _limit,
      );

      if (!mounted) return;

      _allMembers = members;
      _filteredMembers = members;
      _membersLoaded = true;
    } catch (e) {
      debugPrint('LOAD MEMBERS ERROR: $e');
      _membersLoaded = true;
    } finally {
      _updateLoadingState();
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _loadMembers();
  //   _loadOverview();
  //   _searchController.addListener(_onSearchChanged);
  // }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredMembers = _allMembers;
      } else {
        _filteredMembers = _allMembers.where((member) {
          return member.fullName.toLowerCase().contains(query) ||
              member.rifleNo.toLowerCase().contains(query) ||
              member.position.toLowerCase().contains(query) ||
              (member.location?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  void _viewMember(Members member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberDetailScreen(memberId: member.id),
      ),
    );
  }

  void _editMember(Members member) async {
    try {
      // Show loading indicator while fetching full member details
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Loading member details...'),
              ],
            ),
          );
        },
      );

      // Fetch full member details from API
      final memberService = context.read<MemberService>();
      final memberDetail = await memberService.getMemberById(member.id);

      // Ensure locations are loaded for conversion
      final locationProvider = context.read<LocationProvider>();
      if (locationProvider.locations.isEmpty) {
        debugPrint('🔄 Loading locations for conversion...');
        await locationProvider.loadLocations();
        debugPrint('✅ Loaded ${locationProvider.locations.length} locations');
      }

      if (!mounted) return;

      Navigator.of(context).pop(); // Close loading dialog

      // The API returns location name but expects location UUID
      // We need to convert the location name to UUID
      String locationId = memberDetail.location;

      debugPrint('🔍 Original location value: "$locationId"');
      debugPrint(
        '🔍 Available locations: ${locationProvider.locations.map((l) => '${l.name} (${l.id})').join(", ")}',
      );

      // If location looks like a name (not a UUID), try to find the UUID
      if (locationId.isNotEmpty && !locationId.contains('-')) {
        // It's a location name, need to find the UUID
        try {
          final matchingLocation = locationProvider.locations.firstWhere(
            (loc) => loc.name.toLowerCase() == locationId.toLowerCase(),
          );
          locationId = matchingLocation.id;
          debugPrint(
            '✅ Converted location name "${memberDetail.location}" to UUID: $locationId',
          );
        } catch (e) {
          debugPrint('⚠️ Could not find location UUID for: "$locationId"');
          // Keep the original value if not found
          locationId = '';
        }
      }

      // Parse additional info from memberDetail
      final additionalInfo = <String, dynamic>{
        'tribe': memberDetail.tribe,
        'religion': memberDetail.religion,
        'gender': memberDetail.gender,
        'maritalStatus': memberDetail.maritalStatus,
        'ninNo': memberDetail.ninNo,
        'bvnNo': memberDetail.bvnNo,
        'state': memberDetail.state,
        'accountNo': memberDetail.accountNo,
        'unitArea': memberDetail.unitArea,
        'unitAreaType': memberDetail.unitAreaType,
        'guarantorFullName': memberDetail.guarantorFullName,
        'guarantorRelationship': memberDetail.guarantorRelationship,
        'guarantorTribe': memberDetail.guarantorTribe,
        'guarantorPhoneNumber': memberDetail.guarantorPhoneNumber,
        'emergencyFullName': memberDetail.emergencyFullName,
        'emergencyAddress': memberDetail.emergencyAddress,
        'emergencyPhoneNumber': memberDetail.emergencyPhoneNumber,
        'nextOfKinFullName': memberDetail.nextOfKinFullName,
        'nextOfKinAddress': memberDetail.nextOfKinAddress,
        'nextOfKinPhoneNumber': memberDetail.nextOfKinPhoneNumber,
      };

      // Convert MemberDetail to Member for EditMemberScreen
      final memberForEdit = Member(
        id: member.id,
        fullName: memberDetail.fullName,
        rifleNumber: memberDetail.rifleNo,
        phone: memberDetail.phoneNumber,
        dateOfBirth: memberDetail.dateOfBirth,
        address: memberDetail.permanentAddress,
        position: memberDetail.position,
        joinDate: memberDetail.createdAt,
        profileImage: memberDetail.photo,
        isActive: member.isActive,
        location: locationId, // ✅ Pass the location UUID here
        additionalInfo: additionalInfo, // ✅ Pass all additional info
      );

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditMemberScreen(member: memberForEdit),
        ),
      );

      if (result == true) {
        _loadMembers(); // Refresh the list
        _loadOverview(); // Refresh overview stats
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading member details: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(Members member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to delete this member?'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('ID: ${member.rifleNo}'),
                    Text('Position: ${member.position}'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This action cannot be undone.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMember(member);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMember(Members member) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Deleting member...'),
              ],
            ),
          );
        },
      );

      final memberService = context.read<MemberService>();
      await memberService.deleteMember(member.id);

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${member.fullName} has been deleted successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Refresh the list and overview
        _loadMembers();
        _loadOverview();
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting member: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Members',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMemberScreen()),
                );
                if (result == true) {
                  _loadMembers(); // Refresh the list
                }
              },
              tooltip: 'Add Member',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: _overview == null
                ? const SizedBox.shrink()
                : Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total',
                          _overview!.totalMembers.toString(),
                          'Total members',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Active',
                          _overview!.activeMembers.toString(),
                          'Active members',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Inactive',
                          _overview!.inactiveMembers.toString(),
                          'Inactive members',
                        ),
                      ),
                    ],
                  ),
          ),

          // Statistics Cards
          // Container(
          //   margin: const EdgeInsets.symmetric(horizontal: 20),
          //   child: Row(
          //     children: [
          //       Container(
          //         margin: const EdgeInsets.symmetric(horizontal: 20),
          //         child: Row(
          //           children: [
          //             Expanded(
          //               child: _buildStatCard(
          //                 'Total',
          //                 _totalMembers.toString(),
          //                 'Total members',
          //               ),
          //             ),
          //             ...
          //           ],
          //         ),
          //       ),
          //       // Expanded(
          //       //   child: _buildStatCard(
          //       //     'Total',
          //       //     _totalMembers.toString,
          //       //     'Total members',
          //       //   ),
          //       // ),
          //       const SizedBox(width: 8),
          //       // Expanded(
          //       //   child: _buildStatCard(
          //       //     'Active',
          //       //     _activeMembers.toString(),
          //       //     'Active members',
          //       //   ),
          //       // ),
          //       const SizedBox(width: 8),
          //       // Expanded(
          //       //   child: _buildStatCard(
          //       //     'Inactive',
          //       //     _inactiveMembers.toString(),
          //       //     'Inactive members',
          //       //   ),
          //       // ),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 20),

          // Content Area
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMembers.isEmpty
                ? _buildEmptyState()
                : _buildMembersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Silhouette Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Main Message
            Text(
              'Nothing here. For now.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'This is where you\'ll find your\nfinished projects.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Add First Member Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddMemberScreen()),
                  );
                  if (result == true) {
                    _loadMembers(); // Refresh the list
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add First Member',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: _filteredMembers.length,
      itemBuilder: (context, index) {
        final member = _filteredMembers[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              child: hasValidPhoto(member.photo)
                  ? ClipOval(
                      child: Image.network(
                        member.photo!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      member.fullName.isNotEmpty
                          ? member.fullName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
            ),
            title: Text(
              member.fullName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rifle: ${member.rifleNo}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  'Location: ${member.location}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    _viewMember(member);
                    break;
                  case 'edit':
                    _editMember(member);
                    break;
                  case 'delete':
                    _showDeleteConfirmation(member);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 20),
                      SizedBox(width: 12),
                      Text('View Details'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20, color: Colors.blue),
                      SizedBox(width: 12),
                      Text('Edit Member'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Delete Member'),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => _viewMember(member),
          ),
        );
      },
    );
  }
}
