import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/getAllMember.dart';
import '../../models/member_overview.dart';
import '../../services/member_service.dart';
import '../../services/members.dart';
import 'add_member_screen.dart';
import 'member_detail_screen.dart';

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
        !photo.contains('example.com'); // 🚫 block fake URLs
  }

  int _page = 1;
  final int _limit = 10;
  MemberOverview? _overview;
  bool _isOverviewLoading = true;

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
      final memberService = context.read<MemberServices>();
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
      final memberService = context.read<MemberServices>();
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

  // int get _totalMembers => _allMembers.length;
  // int get _activeMembers => _allMembers.where((m) => m.isActive).length;
  // int get _inactiveMembers => _totalMembers - _activeMembers;

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
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 1,
            ),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
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
                  'ID: ${member.rifleNo}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  member.position,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemberDetailScreen(memberId: member.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
