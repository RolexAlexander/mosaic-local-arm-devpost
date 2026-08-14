import 'package:flutter/material.dart';

import 'domain/models.dart';
import 'screens/campaigns_screen.dart';
import 'screens/creative_studio_screen.dart';
import 'screens/performance_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/workspace_screen.dart';
import 'services/benchmark.dart';
import 'services/image_generation_engine.dart';
import 'services/local_store.dart';
import 'services/mosaic_engine.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'widgets/app_header.dart';

/// Root application widget for Mosaic Local.
class MosaicApp extends StatelessWidget {
  const MosaicApp({super.key, required this.engine});

  final MosaicEngine engine;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mosaic Local',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: MosaicHome(engine: engine),
    );
  }
}

/// Main stateful shell hosting tabs, persistent storage, and background engines.
class MosaicHome extends StatefulWidget {
  const MosaicHome({super.key, required this.engine});

  final MosaicEngine engine;

  @override
  State<MosaicHome> createState() => _MosaicHomeState();
}

class _MosaicHomeState extends State<MosaicHome> {
  final LocalStore _store = LocalStore();
  final ImageGenerationEngine _imageEngine = ImageGenerationEngine();

  BrandProfile? _brand;
  List<Campaign> _campaigns = [];
  BenchmarkResult? _benchmark;
  CampaignPost? _creativeSelectedPost;

  int _currentTab = 0;
  bool _booting = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final loadedBrand = await _store.loadBrand();
    final loadedCampaigns = await _store.loadCampaigns();
    await _imageEngine.restoreModel();
    await widget.engine.load();

    if (!mounted) return;
    setState(() {
      _brand = loadedBrand;
      _campaigns = loadedCampaigns;
      _booting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_booting) {
      return Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.irisGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.iris.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.hub_rounded, color: Colors.white, size: 36),
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.mint,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Initializing Mosaic Local on Arm…',
                style: TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top brand bar from banner mockup
            AppHeader(
              state: widget.engine.state,
              onTapStatus: () => setState(() => _currentTab = 4), // go to settings
            ),

            // Main Tab Content
            Expanded(
              child: IndexedStack(
                index: _currentTab,
                children: [
                  WorkspaceScreen(
                    brand: _brand,
                    campaigns: _campaigns,
                    engine: widget.engine,
                    benchmark: _benchmark,
                    onBrandSaved: _saveBrand,
                    onCampaignCreated: _addCampaign,
                    onNavigateToTab: (index) => setState(() => _currentTab = index),
                  ),
                  CampaignsScreen(
                    campaigns: _campaigns,
                    onCampaignUpdated: _updateCampaign,
                    onNavigateToCreative: (post) {
                      setState(() {
                        _creativeSelectedPost = post;
                        _currentTab = 2; // switch to creative tab
                      });
                    },
                  ),
                  CreativeStudioScreen(
                    campaigns: _campaigns,
                    textEngine: widget.engine,
                    imageEngine: _imageEngine,
                    onCampaignUpdated: _updateCampaign,
                    initialPost: _creativeSelectedPost,
                  ),
                  PerformanceScreen(benchmark: _benchmark),
                  SettingsScreen(
                    engine: widget.engine,
                    onModelChanged: () => setState(() {}),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (index) => setState(() => _currentTab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_customize_outlined),
            selectedIcon: Icon(Icons.dashboard_customize_rounded),
            label: 'Workspace',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.palette_outlined),
            selectedIcon: Icon(Icons.palette_rounded),
            label: 'Creative',
          ),
          NavigationDestination(
            icon: Icon(Icons.speed_outlined),
            selectedIcon: Icon(Icons.speed_rounded),
            label: 'Arm Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Future<void> _saveBrand(BrandProfile value) async {
    await _store.saveBrand(value);
    setState(() => _brand = value);
  }

  Future<void> _addCampaign(GenerationOutput output) async {
    await _store.saveCampaign(output.campaign);
    setState(() {
      _campaigns.insert(0, output.campaign);
      _benchmark = output.benchmark;
    });
  }

  Future<void> _updateCampaign(Campaign campaign) async {
    await _store.saveCampaign(campaign);
    setState(() {
      final index = _campaigns.indexWhere((item) => item.id == campaign.id);
      if (index >= 0) {
        _campaigns[index] = campaign;
      }
    });
  }
}
