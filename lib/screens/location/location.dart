import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/location_location.dart';
import '../../services/location_provider.dart';
import '../../models/location.dart';

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => context.read<LocationProvider>().loadLocations(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addLocation() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<LocationProvider>();
    final success = await provider.addLocation(_controller.text.trim());

    if (!mounted) return;

    if (success) {
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Something went wrong'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Locations'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔹 ADD LOCATION FORM
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Enter location name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                      v == null || v.trim().isEmpty
                          ? 'Required'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: provider.isLoading ? null : _addLocation,
                    child: provider.isLoading
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text('Add'),
                  ),
                ],
              ),
            ),
          ),

          const Divider(),

          // 🔹 LOCATIONS LIST
          Expanded(
            child: provider.isFetching
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : provider.locations.isEmpty
                ? const Center(
              child: Text('No locations added yet'),
            )
                : ListView.separated(
              itemCount: provider.locations.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final Location location = provider.locations[index];
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(location.name),
                  subtitle: location.address != null
                      ? Text(location.address!)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}