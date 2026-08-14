import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'domain/models.dart';
import 'services/benchmark.dart';
import 'services/image_generation_engine.dart';
import 'services/local_store.dart';
import 'services/mosaic_engine.dart';

const ink = Color(0xFF17151C);
const canvas = Color(0xFFF5F2EB);
const violet = Color(0xFF6D43E5);
const coral = Color(0xFFF05D4E);
const mint = Color(0xFFBCEBD7);

class MosaicApp extends StatelessWidget {
  const MosaicApp({super.key, required this.engine});
  final MosaicEngine engine;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mosaic Local',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: violet,
            brightness: Brightness.light,
            surface: canvas,
          ),
          scaffoldBackgroundColor: canvas,
          useMaterial3: true,
          fontFamily: 'sans',
          cardTheme: const CardThemeData(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.zero,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        home: MosaicHome(engine: engine),
      );
}

class MosaicHome extends StatefulWidget {
  const MosaicHome({super.key, required this.engine});
  final MosaicEngine engine;

  @override
  State<MosaicHome> createState() => _MosaicHomeState();
}

class _MosaicHomeState extends State<MosaicHome> {
  final store = LocalStore();
  final imageEngine = ImageGenerationEngine();
  BrandProfile? brand;
  List<Campaign> campaigns = [];
  BenchmarkResult? benchmark;
  int tab = 0;
  bool booting = true;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final loadedBrand = await store.loadBrand();
    final loadedCampaigns = await store.loadCampaigns();
    await imageEngine.restoreModel();
    await widget.engine.load();
    if (!mounted) return;
    setState(() {
      brand = loadedBrand;
      campaigns = loadedCampaigns;
      booting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (booting) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(state: widget.engine.state),
            Expanded(
              child: IndexedStack(
                index: tab,
                children: [
                  _Dashboard(
                    brand: brand,
                    campaigns: campaigns,
                    engine: widget.engine,
                    benchmark: benchmark,
                    onBrand: _saveBrand,
                    onCampaign: _addCampaign,
                  ),
                  _CampaignList(campaigns: campaigns, onChanged: _updateCampaign),
                  _CreativeStudio(
                    campaigns: campaigns,
                    textEngine: widget.engine,
                    imageEngine: imageEngine,
                    onCampaignChanged: _updateCampaign,
                  ),
                  _Performance(benchmark: benchmark),
                  _ModelSetup(engine: widget.engine, onReady: () => setState(() {})),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: 'Create'),
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Campaigns'),
          NavigationDestination(icon: Icon(Icons.image_outlined), label: 'Creative'),
          NavigationDestination(icon: Icon(Icons.speed_rounded), label: 'Arm stats'),
          NavigationDestination(icon: Icon(Icons.memory_rounded), label: 'Model'),
        ],
      ),
    );
  }

  Future<void> _saveBrand(BrandProfile value) async {
    await store.saveBrand(value);
    setState(() => brand = value);
  }

  Future<void> _addCampaign(GenerationOutput output) async {
    await store.saveCampaign(output.campaign);
    setState(() {
      campaigns.insert(0, output.campaign);
      benchmark = output.benchmark;
    });
  }

  Future<void> _updateCampaign(Campaign campaign) async {
    await store.saveCampaign(campaign);
    setState(() {
      final index = campaigns.indexWhere((item) => item.id == campaign.id);
      if (index >= 0) campaigns[index] = campaign;
    });
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.state});
  final EngineState state;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: ink,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.blur_on_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MOSAIC', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.6)),
                  Text('Your marketing team. On your phone.', style: TextStyle(fontSize: 11)),
                ],
              ),
            ),
            _Pill(
              icon: state == EngineState.ready ? Icons.lock : Icons.memory,
              label: state == EngineState.ready ? '100% LOCAL' : 'MODEL SETUP',
              color: state == EngineState.ready ? mint : const Color(0xFFFFD8A8),
            ),
          ],
        ),
      );
}

class _Dashboard extends StatefulWidget {
  const _Dashboard({
    required this.brand,
    required this.campaigns,
    required this.engine,
    required this.benchmark,
    required this.onBrand,
    required this.onCampaign,
  });
  final BrandProfile? brand;
  final List<Campaign> campaigns;
  final MosaicEngine engine;
  final BenchmarkResult? benchmark;
  final ValueChanged<BrandProfile> onBrand;
  final ValueChanged<GenerationOutput> onCampaign;

  @override
  State<_Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<_Dashboard> {
  bool generating = false;
  String stage = '';
  String preview = '';

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text(
            widget.brand == null ? 'Build your brand brain.' : 'What are we creating today?',
            style: const TextStyle(fontSize: 32, height: 1.05, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Text(
            widget.brand == null
                ? 'Your brand stays on this device—from strategy to finished campaign.'
                : 'Mosaic already knows ${widget.brand!.name}. Generate a complete campaign without sending a byte to the cloud.',
            style: TextStyle(color: ink.withOpacity(.65), height: 1.45),
          ),
          const SizedBox(height: 22),
          if (widget.brand == null)
            _BrandForm(onSaved: widget.onBrand)
          else ...[
            _BrandCard(profile: widget.brand!, onEdit: () => _editBrand(context)),
            const SizedBox(height: 16),
            if (generating) _GenerationCard(stage: stage, preview: preview),
            if (!generating)
              FilledButton.icon(
                onPressed: widget.engine.state == EngineState.ready ? _generate : null,
                style: FilledButton.styleFrom(
                  backgroundColor: ink,
                  minimumSize: const Size.fromHeight(58),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                icon: const Icon(Icons.auto_awesome),
                label: Text(
                  widget.engine.state == EngineState.ready
                      ? 'Generate 3-post campaign locally'
                      : 'Install model in the Model tab',
                ),
              ),
            const SizedBox(height: 22),
            const _PrivacyStrip(),
          ],
        ],
      );

  Future<void> _generate() async {
    setState(() {
      generating = true;
      preview = '';
      stage = 'Warming up the Arm inference engine';
    });
    try {
      final output = await widget.engine.createCampaign(
        widget.brand!,
        onStage: (value) => setState(() => stage = value),
        onToken: (value) => setState(() {
          preview += value;
          if (preview.length > 240) preview = preview.substring(preview.length - 240);
        }),
      );
      widget.onCampaign(output);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Campaign created and stored locally.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => generating = false);
    }
  }

  void _editBrand(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
        child: _BrandForm(initial: widget.brand, onSaved: widget.onBrand),
      ),
    );
  }
}

class _BrandForm extends StatefulWidget {
  const _BrandForm({required this.onSaved, this.initial});
  final ValueChanged<BrandProfile> onSaved;
  final BrandProfile? initial;

  @override
  State<_BrandForm> createState() => _BrandFormState();
}

class _BrandFormState extends State<_BrandForm> {
  late final List<TextEditingController> fields = [
    TextEditingController(text: widget.initial?.name),
    TextEditingController(text: widget.initial?.product),
    TextEditingController(text: widget.initial?.audience),
    TextEditingController(text: widget.initial?.voice),
    TextEditingController(text: widget.initial?.goal),
  ];
  final labels = ['Business name', 'What do you sell?', 'Who is it for?', 'Brand voice', 'Campaign goal'];

  @override
  Widget build(BuildContext context) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              for (var index = 0; index < fields.length; index++) ...[
                TextField(controller: fields[index], decoration: InputDecoration(labelText: labels[index])),
                const SizedBox(height: 10),
              ],
              FilledButton(
                onPressed: () {
                  if (fields.any((field) => field.text.trim().isEmpty)) return;
                  widget.onSaved(BrandProfile(
                    name: fields[0].text.trim(),
                    product: fields[1].text.trim(),
                    audience: fields[2].text.trim(),
                    voice: fields[3].text.trim(),
                    goal: fields[4].text.trim(),
                  ));
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                child: const Text('Save private brand profile'),
              ),
            ],
          ),
        ),
      );
}

class _BrandCard extends StatelessWidget {
  const _BrandCard({required this.profile, required this.onEdit});
  final BrandProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: violet,
                child: Text(profile.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(profile.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  Text('${profile.voice} · ${profile.region}', maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
              IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
            ],
          ),
        ),
      );
}

class _GenerationCard extends StatelessWidget {
  const _GenerationCard({required this.stage, required this.preview});
  final String stage;
  final String preview;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const LinearProgressIndicator(color: mint, backgroundColor: Colors.white12),
          const SizedBox(height: 18),
          Text(stage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text(preview, maxLines: 5, overflow: TextOverflow.fade,
              style: const TextStyle(color: Colors.white60, fontFamily: 'monospace', fontSize: 11)),
        ]),
      );
}

class _CampaignList extends StatelessWidget {
  const _CampaignList({required this.campaigns, required this.onChanged});
  final List<Campaign> campaigns;
  final ValueChanged<Campaign> onChanged;

  @override
  Widget build(BuildContext context) {
    if (campaigns.isEmpty) {
      return const Center(child: Text('Your locally generated campaigns will appear here.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: campaigns.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final campaign = campaigns[index];
        return ExpansionTile(
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(campaign.name, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text('v${campaign.version} · ${campaign.posts.length} posts · Stored on device'),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Text(campaign.strategy),
                const SizedBox(height: 14),
                for (var postIndex = 0; postIndex < campaign.posts.length; postIndex++)
                  _PostCard(
                    post: campaign.posts[postIndex],
                    onApproved: () {
                      final posts = [...campaign.posts];
                      posts[postIndex] = posts[postIndex].copyWith(approved: !posts[postIndex].approved);
                      onChanged(campaign.copyWith(posts: posts, version: campaign.version + 1));
                    },
                  ),
              ]),
            ),
          ],
        );
      },
    );
  }
}

class _CreativeStudio extends StatefulWidget {
  const _CreativeStudio({
    required this.campaigns,
    required this.textEngine,
    required this.imageEngine,
    required this.onCampaignChanged,
  });

  final List<Campaign> campaigns;
  final MosaicEngine textEngine;
  final ImageGenerationEngine imageEngine;
  final ValueChanged<Campaign> onCampaignChanged;

  @override
  State<_CreativeStudio> createState() => _CreativeStudioState();
}

class _CreativeStudioState extends State<_CreativeStudio> {
  final modelUrl = TextEditingController(
    text: 'https://huggingface.co/Green-Sky/SD-Turbo-GGUF/resolve/main/sd_turbo-f16-q8_0.gguf',
  );
  final prompt = TextEditingController();
  final negativePrompt = TextEditingController(
    text: 'blurry, distorted, low quality, watermark, text artifacts, extra fingers',
  );
  final seedController = TextEditingController(text: '-1');
  double downloadProgress = 0;
  int steps = 4;
  bool busy = false;
  ImageGenerationResult? result;
  CampaignPost? selectedPost;

  Iterable<CampaignPost> get posts => widget.campaigns.expand((campaign) => campaign.posts);

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Creative Engine', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Generate the final campaign visual entirely on this Arm-powered phone.'),
          const SizedBox(height: 18),
          if (widget.imageEngine.modelPath == null) _modelInstaller() else _generator(),
        ],
      );

  Widget _modelInstaller() => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const _Pill(label: 'ON-DEVICE · SD-TURBO', color: mint),
            const SizedBox(height: 14),
            const Text('Install the visual model', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text('One-time download. About 2 GB. The model is then available offline.'),
            const SizedBox(height: 14),
            TextField(controller: modelUrl, decoration: const InputDecoration(labelText: 'GGUF model URL')),
            if (busy) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: downloadProgress == 0 ? null : downloadProgress),
              const SizedBox(height: 5),
              Text('${(downloadProgress * 100).toStringAsFixed(0)}% downloaded'),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: busy ? null : _downloadAndLoad,
              icon: const Icon(Icons.download),
              label: const Text('Install Creative Engine'),
            ),
          ]),
        ),
      );

  Widget _generator() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (posts.isNotEmpty) ...[
          const Text('Use a campaign direction', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: posts.take(6).map((post) => ActionChip(
                  label: Text('Day ${post.day}: ${post.pillar}'),
                  avatar: Icon(selectedPost == post ? Icons.check : Icons.image_outlined, size: 16),
                  onPressed: () => setState(() {
                    selectedPost = post;
                    prompt.text = post.visual;
                  }),
                )).toList(),
          ),
          const SizedBox(height: 14),
        ],
        TextField(
          controller: prompt,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Visual prompt', alignLabelWithHint: true),
        ),
        const SizedBox(height: 10),
        TextField(controller: negativePrompt, maxLines: 2, decoration: const InputDecoration(labelText: 'Negative prompt')),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Text('Steps: $steps', style: const TextStyle(fontWeight: FontWeight.w700))),
          Expanded(
            flex: 2,
            child: Slider(
              value: steps.toDouble(),
              min: 1,
              max: 8,
              divisions: 7,
              onChanged: busy ? null : (value) => setState(() => steps = value.round()),
            ),
          ),
        ]),
        TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Seed (-1 = random)'),
          controller: seedController,
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: busy || prompt.text.trim().isEmpty ? null : _generate,
          style: FilledButton.styleFrom(backgroundColor: ink, minimumSize: const Size.fromHeight(56)),
          icon: busy
              ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.auto_awesome),
          label: Text(busy ? 'Generating locally…' : 'Generate 512×512 visual'),
        ),
        if (result != null) ...[
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.file(File(result!.path), fit: BoxFit.cover),
          ),
          const SizedBox(height: 10),
          const _PrivacyStrip(),
          const SizedBox(height: 8),
          Text(
            '${(result!.elapsedMs / 1000).toStringAsFixed(1)}s · ${result!.steps} steps · seed ${result!.seed} · 0 network calls',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ],
      ]);

  Future<void> _downloadAndLoad() async {
    setState(() => busy = true);
    try {
      final path = await widget.imageEngine.downloadModel(
        modelUrl.text.trim(),
        onProgress: (value) {
          if (mounted) setState(() => downloadProgress = value);
        },
      );
      await widget.textEngine.unload();
      await widget.imageEngine.initialize(path);
      await widget.imageEngine.release();
      await widget.textEngine.load();
    } catch (error) {
      await widget.imageEngine.release();
      await widget.textEngine.load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _generate() async {
    setState(() => busy = true);
    try {
      await widget.textEngine.unload();
      if (widget.imageEngine.state != CreativeEngineState.ready) {
        await widget.imageEngine.initialize(widget.imageEngine.modelPath!);
      }
      final generated = await widget.imageEngine.generate(
        prompt: prompt.text.trim(),
        negativePrompt: negativePrompt.text.trim(),
        steps: steps,
        cfgScale: 1,
        seed: int.tryParse(seedController.text) ?? -1,
      );
      await widget.imageEngine.release();
      await widget.textEngine.load();
      _attachToCampaign(generated.path);
      setState(() => result = generated);
    } catch (error) {
      await widget.imageEngine.release();
      await widget.textEngine.load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _attachToCampaign(String imagePath) {
    final target = selectedPost;
    if (target == null) return;
    for (final campaign in widget.campaigns) {
      final index = campaign.posts.indexOf(target);
      if (index < 0) continue;
      final updatedPosts = [...campaign.posts];
      updatedPosts[index] = target.copyWith(imagePath: imagePath);
      widget.onCampaignChanged(
        campaign.copyWith(posts: updatedPosts, version: campaign.version + 1),
      );
      return;
    }
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post, required this.onApproved});
  final CampaignPost post;
  final VoidCallback onApproved;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: canvas, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (post.imagePath != null && File(post.imagePath!).existsSync()) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(File(post.imagePath!), height: 180, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
          ],
          Row(children: [
            _Pill(label: 'DAY ${post.day}', color: mint),
            const SizedBox(width: 8),
            Text(post.pillar, style: const TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            IconButton(
              onPressed: onApproved,
              icon: Icon(post.approved ? Icons.check_circle : Icons.circle_outlined,
                  color: post.approved ? Colors.green : null),
            ),
          ]),
          Text(post.hook, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19)),
          const SizedBox(height: 8),
          Text(post.caption),
          const SizedBox(height: 10),
          Text('Visual direction: ${post.visual}', style: const TextStyle(fontStyle: FontStyle.italic)),
          const SizedBox(height: 8),
          Text('${post.cta}\n${post.hashtags.join(' ')}', style: const TextStyle(color: violet)),
        ]),
      );
}

class _Performance extends StatelessWidget {
  const _Performance({required this.benchmark});
  final BenchmarkResult? benchmark;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Arm performance', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Measured on this device—not estimated in the cloud.'),
          const SizedBox(height: 20),
          if (benchmark == null)
            const _EmptyBenchmark()
          else ...[
            Row(children: [
              Expanded(child: _Metric(value: '${benchmark!.firstTokenMs} ms', label: 'First token')),
              const SizedBox(width: 12),
              Expanded(child: _Metric(value: benchmark!.estimatedTokensPerSecond.toStringAsFixed(1), label: 'Est. tok/s')),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _Metric(value: '${benchmark!.totalMs} ms', label: 'Total latency')),
              const SizedBox(width: 12),
              const Expanded(child: _Metric(value: '0', label: 'Network calls')),
            ]),
            const SizedBox(height: 18),
            SelectableText(const JsonEncoder.withIndent('  ').convert(benchmark!.toJson()),
                style: const TextStyle(fontFamily: 'monospace')),
          ],
          const SizedBox(height: 22),
          const _OptimizationCard(),
        ],
      );
}

class _ModelSetup extends StatefulWidget {
  const _ModelSetup({required this.engine, required this.onReady});
  final MosaicEngine engine;
  final VoidCallback onReady;

  @override
  State<_ModelSetup> createState() => _ModelSetupState();
}

class _ModelSetupState extends State<_ModelSetup> {
  final url = TextEditingController(
    text: 'https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/Gemma3-1B-IT_multi-prefill-seq_q4_ekv4096.litertlm',
  );
  final token = TextEditingController();
  bool working = false;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Local model', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Install once, then switch off Wi-Fi. The model and every campaign remain on your phone.'),
          const SizedBox(height: 20),
          const _ModelCard(),
          const SizedBox(height: 16),
          if (widget.engine.state == EngineState.ready)
            Column(children: [
              SegmentedButton<MosaicBackend>(
                segments: const [
                  ButtonSegment(value: MosaicBackend.gpu, icon: Icon(Icons.bolt), label: Text('GPU')),
                  ButtonSegment(value: MosaicBackend.cpu, icon: Icon(Icons.memory), label: Text('CPU')),
                ],
                selected: {widget.engine.backend},
                onSelectionChanged: working ? null : (selection) => _switchBackend(selection.first),
              ),
              const SizedBox(height: 14),
              const _PrivacyStrip(),
            ])
          else ...[
            TextField(controller: url, decoration: const InputDecoration(labelText: 'Direct .litertlm model URL')),
            const SizedBox(height: 10),
            TextField(controller: token, obscureText: true, decoration: const InputDecoration(labelText: 'Hugging Face token (if gated)')),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: working ? null : _install,
              icon: working ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.download),
              label: const Text('Install INT4 model'),
            ),
          ],
        ],
      );

  Future<void> _install() async {
    if (url.text.trim().isEmpty) return;
    setState(() => working = true);
    try {
      await widget.engine.installFromNetwork(url.text.trim(), token: token.text.trim().isEmpty ? null : token.text.trim());
      widget.onReady();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) setState(() => working = false);
    }
  }

  Future<void> _switchBackend(MosaicBackend backend) async {
    setState(() => working = true);
    await widget.engine.load(useBackend: backend);
    if (mounted) {
      setState(() => working = false);
      widget.onReady();
    }
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.circular(24)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Pill(label: 'ARM64 · INT4', color: mint),
          SizedBox(height: 16),
          Text('Gemma 3 1B', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
          SizedBox(height: 5),
          Text('LiteRT-LM · GPU preferred · CPU fallback\n2,048-token context · one shared model',
              style: TextStyle(color: Colors.white60, height: 1.5)),
        ]),
      );
}

class _PrivacyStrip extends StatelessWidget {
  const _PrivacyStrip();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: mint, borderRadius: BorderRadius.circular(18)),
        child: const Row(children: [
          Icon(Icons.shield_outlined),
          SizedBox(width: 12),
          Expanded(child: Text('Private by architecture · Offline after setup · Zero cloud inference', style: TextStyle(fontWeight: FontWeight.w700))),
        ]),
      );
}

class _OptimizationCard extends StatelessWidget {
  const _OptimizationCard();
  @override
  Widget build(BuildContext context) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: const Padding(
          padding: EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Optimization stack', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
            SizedBox(height: 12),
            Text('✓ 4-bit quantized weights\n✓ Arm64-only native binaries\n✓ LiteRT-LM optimized kernels\n✓ GPU-first with CPU fallback\n✓ One weight set shared across specialist roles\n✓ Bounded context and output tokens\n✓ Streaming output and zero network round trips', style: TextStyle(height: 1.7)),
          ]),
        ),
      );
}

class _EmptyBenchmark extends StatelessWidget {
  const _EmptyBenchmark();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
        child: const Column(children: [
          Icon(Icons.speed_rounded, size: 42, color: violet),
          SizedBox(height: 12),
          Text('Generate a campaign to capture the first benchmark.', textAlign: TextAlign.center),
        ]),
      );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          Text(label),
        ]),
      );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(99)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 13), const SizedBox(width: 5)],
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: .4)),
        ]),
      );
}
