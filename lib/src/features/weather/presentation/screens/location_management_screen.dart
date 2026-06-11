import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../providers/saved_locations_provider.dart';
import '../providers/location_search_provider.dart';

class LocationManagementScreen extends ConsumerStatefulWidget {
  const LocationManagementScreen({super.key});

  @override
  ConsumerState<LocationManagementScreen> createState() => _LocationManagementScreenState();
}

class _LocationManagementScreenState extends ConsumerState<LocationManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(locationSearchProvider.notifier).search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(locationSearchProvider);
    final isSearching = _searchController.text.isNotEmpty;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Quản lý địa điểm', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF37474f), Color(0xFF263238), Color(0xFF1b2226)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: _GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm thành phố...',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                        border: InputBorder.none,
                        icon: const Icon(Icons.search, color: Colors.white70),
                        suffixIcon: isSearching
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white70),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(locationSearchProvider.notifier).clear();
                                },
                              )
                            : null,
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                ),

                // Content Area
                Expanded(
                  child: isSearching
                      ? _buildSearchResults(searchState)
                      : _buildSavedLocations(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(LocationSearchState searchState) {
    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (searchState.error != null) {
      return Center(
        child: Text(
          searchState.error!,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    if (searchState.results.isEmpty) {
      return const Center(
        child: Text('Không tìm thấy kết quả', style: TextStyle(color: Colors.white70)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: searchState.results.length,
      itemBuilder: (context, index) {
        final loc = searchState.results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _GlassContainer(
            child: ListTile(
              title: Text(loc.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(loc.country, style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
              trailing: const Icon(Icons.add_circle_outline, color: Colors.white),
              onTap: () {
                ref.read(savedLocationsProvider.notifier).addLocation(loc);
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavedLocations() {
    final savedState = ref.watch(savedLocationsProvider);
    final savedLocs = savedState.locations;
    final selectedLoc = savedState.selectedLocation;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        // GPS Item
        _GlassContainer(
          borderColor: selectedLoc == null ? Colors.blueAccent.withValues(alpha: 0.5) : null,
          child: ListTile(
            leading: const Icon(Icons.my_location, color: Colors.white),
            title: const Text('Vị trí hiện tại', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text('Sử dụng GPS', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
            trailing: selectedLoc == null ? const Icon(Icons.check_circle, color: Colors.blueAccent) : null,
            onTap: () {
              ref.read(savedLocationsProvider.notifier).selectGPS();
              Navigator.pop(context);
            },
          ),
        ),

        if (savedLocs.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(top: 24, bottom: 12),
            child: Text(
              'ĐỊA ĐIỂM ĐÃ LƯU',
              style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ),
          ...savedLocs.map((loc) {
            final isSelected = selectedLoc?.id == loc.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: ValueKey(loc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  ref.read(savedLocationsProvider.notifier).removeLocation(loc.id);
                },
                child: _GlassContainer(
                  borderColor: isSelected ? Colors.blueAccent.withValues(alpha: 0.5) : null,
                  child: ListTile(
                    title: Text(loc.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(loc.country, style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blueAccent) : null,
                    onTap: () {
                      ref.read(savedLocationsProvider.notifier).selectLocation(loc);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            );
          }),
        ]
      ],
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;

  const _GlassContainer({required this.child, this.padding, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
