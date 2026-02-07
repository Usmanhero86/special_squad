import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:special_squad/services/member_service.dart';
import 'package:special_squad/services/location_service.dart';
import '../../models/duty_member.dart';
import '../../models/location_location.dart';
import '../members/member_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<DutyMember> _allMembers = [];
  List<DutyMember> _filteredMembers = [];
  List<Location> _locations = [];
  List<String> _filterOptions = ['All'];

  bool _isLoading = true;
  bool _isLoadingLocations = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadLocations();
    _loadMembers();
    _searchController.addListener(_filterMembers);
  }

  Future<void> _loadLocations() async {
    try {
      final locationService = context.read<LocationService>();
      final locations = await locationService.fetchLocations();

      if (!mounted) return;

      setState(() {
        _locations = locations;
        _filterOptions = ['All', ...locations.map((l) => l.name)];
        _isLoadingLocations = false;
      });

      debugPrint('✅ LOCATIONS LOADED: ${locations.length}');
    } catch (e) {
      debugPrint('❌ LOCATION LOAD ERROR: $e');

      if (mounted) {
        setState(() {
          _isLoadingLocations = false;
          // Fallback to default locations if API fails
          _filterOptions = [
            'All',
            'HQ',
            'Marte',
            'Baga',
            'Sabon gari',
            'Mallum fatori',
          ];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load locations: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    try {
      final service = context.read<MemberService>();
      final members = await service.getAllDutyMembers();

      if (!mounted) return;

      setState(() {
        _allMembers = members;
        _filteredMembers = members;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ SEARCH LOAD ERROR: $e');

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterMembers() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredMembers = _allMembers.where((m) {
        final matchesSearch =
            m.fullName.toLowerCase().contains(query) ||
            m.rifleNo.toLowerCase().contains(query) ||
            m.position.toLowerCase().contains(query);

        final matchesFilter =
            _selectedFilter == 'All' || m.location == _selectedFilter;

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Members'), centerTitle: true),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMembers.isEmpty
                ? _buildEmptyState()
                : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search by name, rifle no or position',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          _isLoadingLocations
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Loading locations...',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                )
              : DropdownButtonFormField<String>(
                  initialValue: _selectedFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filter by location',
                    border: OutlineInputBorder(),
                  ),
                  items: _filterOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedFilter = value!);
                    _filterMembers();
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: _filteredMembers.length,
      itemBuilder: (context, index) {
        final member = _filteredMembers[index];

        return ListTile(
          leading: CircleAvatar(child: Text(member.fullName[0].toUpperCase())),
          title: Text(member.fullName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rifle No: ${member.rifleNo}'),
              Text(member.position),
              Text(member.location),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MemberDetailScreen(memberId: member.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('No members found', style: TextStyle(fontSize: 16)),
    );
  }
}
