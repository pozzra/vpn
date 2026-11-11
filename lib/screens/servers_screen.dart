import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/country_dataset.dart';
import '../models/vpn_server.dart';
import '../services/vpn_service.dart';
import '../theme/app_theme.dart';
import '../widgets/server_tile.dart';

class ServersScreen extends StatefulWidget {
  const ServersScreen({super.key});

  @override
  State<ServersScreen> createState() => _ServersScreenState();
}

class _ServersScreenState extends State<ServersScreen> {
  final TextEditingController _searchController = TextEditingController();
  ServerCategory _selectedCategory = ServerCategory.all;
  String _selectedRegion = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vpn = context.watch<VpnService>();
    final fastestServer = vpn.getFastestServer();
    final filteredServers = vpn.filterServers(
      query: _searchController.text,
      category: _selectedCategory,
      region: _selectedRegion,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global VPN Servers & IPs'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF223048)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search by Country, City, or IP address...',
                  hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryCyan),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: AppTheme.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildCategoryChip('All Servers', ServerCategory.all, Icons.public_rounded),
                _buildCategoryChip('Fastest Ping', ServerCategory.fastest, Icons.bolt_rounded),
                _buildCategoryChip('Streaming', ServerCategory.streaming, Icons.play_circle_fill_rounded),
                _buildCategoryChip('Gaming', ServerCategory.gaming, Icons.sports_esports_rounded),
                _buildCategoryChip('P2P Torrent', ServerCategory.p2p, Icons.downloading_rounded),
                _buildCategoryChip('Dedicated IP', ServerCategory.dedicated, Icons.vpn_key_rounded),
                _buildCategoryChip('Favorites', ServerCategory.favorites, Icons.star_rounded),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Region Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: CountryDataset.getRegions().map((region) {
                final isSelected = _selectedRegion == region;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(region),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedRegion = region);
                    },
                    backgroundColor: AppTheme.surface,
                    selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.25),
                    checkmarkColor: AppTheme.primaryCyan,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryCyan : AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryCyan : const Color(0xFF223048),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),

          // Fastest Auto-Connect Banner (if search is empty and on All category)
          if (_searchController.text.isEmpty && _selectedCategory == ServerCategory.all)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F3028), Color(0xFF14243C)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.flash_on_rounded, color: AppTheme.accentGreen, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'RECOMMENDED FASTEST LOCATION',
                            style: TextStyle(
                              color: AppTheme.accentGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            '${fastestServer.countryName} - ${fastestServer.city} (${fastestServer.ipAddress}) • ${fastestServer.pingMs}ms',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        vpn.selectServer(fastestServer);
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.accentGreen,
                        backgroundColor: AppTheme.accentGreen.withValues(alpha: 0.15),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      child: const Text('SELECT', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
            ),

          // Server Count Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredServers.length} LOCATIONS AVAILABLE',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  '${CountryDataset.getServers().length} Global IP Nodes',
                  style: const TextStyle(
                    color: AppTheme.primaryCyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Server List
          Expanded(
            child: filteredServers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textTertiary),
                        SizedBox(height: 12),
                        Text(
                          'No country or IP location matched your search.',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredServers.length,
                    itemBuilder: (context, index) {
                      final server = filteredServers[index];
                      final isSelected = vpn.selectedServer?.id == server.id;

                      return ServerTile(
                        server: server,
                        isSelected: isSelected,
                        onTap: () {
                          vpn.selectServer(server);
                          Navigator.pop(context);
                        },
                        onToggleFavorite: () {
                          vpn.toggleFavorite(server.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, ServerCategory category, IconData icon) {
    final isSelected = _selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _selectedCategory = category),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryCyan : AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryCyan : const Color(0xFF223048),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.black : AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

