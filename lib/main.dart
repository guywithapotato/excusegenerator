import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibration/vibration.dart';

import 'data/excuse_repository.dart';
import 'models/excuse.dart';
import 'services/app_state.dart';
import 'services/strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState(ExcuseRepository());
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  await state.load(locale);
  runApp(BahaneApp(state: state));
}

class BahaneApp extends StatelessWidget {
  const BahaneApp({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final seed = const Color(0xff19d17f);
        return StringScope(
          strings: S(state.language),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'bahane üretici 3000',
            locale: Locale(state.language.name),
            supportedLocales: const [Locale('tr'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            themeMode: state.themeMode,
            theme: _theme(seed, Brightness.light),
            darkTheme: _theme(seed, Brightness.dark),
            home: state.onboardingDone ? Shell(state: state) : OnboardingScreen(state: state),
          ),
        );
      },
    );
  }
}

ThemeData _theme(Color seed, Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: brightness == Brightness.dark ? const Color(0xff0f1720) : const Color(0xfff6f7fb),
    fontFamily: 'Roboto',
    textTheme: const TextTheme().apply(fontFamily: 'Roboto'),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
    ),
  );
}

class Shell extends StatefulWidget {
  const Shell({super.key, required this.state});
  final AppState state;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final pages = [
      HomeScreen(state: widget.state),
      FavoritesScreen(state: widget.state),
      HistoryScreen(state: widget.state),
      StatsScreen(state: widget.state),
      SettingsScreen(state: widget.state),
    ];
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        child: pages[index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        height: 74,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.auto_awesome_outlined), selectedIcon: const Icon(Icons.auto_awesome), label: s.t('home')),
          NavigationDestination(icon: const Icon(Icons.favorite_border), selectedIcon: const Icon(Icons.favorite), label: s.t('favorites')),
          NavigationDestination(icon: const Icon(Icons.history), selectedIcon: const Icon(Icons.history), label: s.t('history')),
          NavigationDestination(icon: const Icon(Icons.query_stats), selectedIcon: const Icon(Icons.query_stats), label: s.t('stats')),
          NavigationDestination(icon: const Icon(Icons.tune), selectedIcon: const Icon(Icons.tune), label: s.t('settings')),
        ],
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.state});
  final AppState state;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int page = 0;
  final art = ['welcome', 'database', 'share', 'legendary', 'welcome'];

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  _ChoiceChipGroup<AppLanguage>(
                    values: AppLanguage.values,
                    current: widget.state.language,
                    label: (v) => v == AppLanguage.tr ? 'türkçe' : 'english',
                    onChanged: widget.state.setLanguage,
                  ),
                  const Spacer(),
                  TextButton(onPressed: _finish, child: Text(s.t('skip'))),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller,
                onPageChanged: (value) => setState(() => page = value),
                itemCount: 5,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/illustrations/${art[i]}.svg', height: 230),
                      const SizedBox(height: 34),
                      Text(
                        s.onboardingTitles[i],
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        s.onboardingDescriptions[i],
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      if (i == 0) ...[
                        const SizedBox(height: 28),
                        _ChoiceChipGroup<ThemeMode>(
                          values: ThemeMode.values,
                          current: widget.state.themeMode,
                          label: (v) => s.t(v.name),
                          onChanged: widget.state.setThemeMode,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  ...List.generate(5, (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        width: i == page ? 28 : 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: i == page ? scheme.primary : scheme.outlineVariant,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      )),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: page == 4 ? _finish : () => controller.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic),
                    icon: Icon(page == 4 ? Icons.rocket_launch : Icons.arrow_forward),
                    label: Text(page == 4 ? s.t('start') : s.t('continue')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finish() async {
    await widget.state.setOnboardingDone(true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).t('ready'))));
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.state});
  final AppState state;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ConfettiController confetti = ConfettiController(duration: const Duration(seconds: 2));
  StreamSubscription<AccelerometerEvent>? shakeSub;
  DateTime lastShake = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    shakeSub = accelerometerEventStream(samplingPeriod: SensorInterval.normalInterval).listen((event) {
      final force = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (force > 22 && DateTime.now().difference(lastShake).inMilliseconds > 900) {
        lastShake = DateTime.now();
        _generate();
      }
    });
  }

  @override
  void dispose() {
    shakeSub?.cancel();
    confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final excuse = widget.state.current ?? widget.state.dailyExcuse;
    return Stack(
      children: [
        _Page(
          title: s.t('app_title'),
          subtitle: s.t('subtitle'),
          action: IconButton(
            tooltip: s.t('search'),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchScreen(state: widget.state))),
            icon: const Icon(Icons.search),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _DailyCard(excuse: widget.state.dailyExcuse),
              const SizedBox(height: 16),
              _CategorySelector(state: widget.state),
              const SizedBox(height: 16),
              ExcuseCard(
                excuse: excuse,
                glowing: excuse.rarity == ExcuseRarity.legendary,
                onCopy: () => _copy(excuse.text),
                onShare: () => Share.share(excuse.text),
                onFavorite: () => widget.state.toggleFavorite(excuse),
                favorite: widget.state.isFavorite(excuse),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(58),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
                onPressed: _generate,
                icon: const Icon(Icons.casino),
                label: Text(s.t('generate'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: confetti,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.08,
            numberOfParticles: 24,
          ),
        ),
      ],
    );
  }

  Future<void> _generate() async {
    final excuse = await widget.state.generate();
    HapticFeedback.mediumImpact();
    if (excuse.rarity == ExcuseRarity.legendary) {
      confetti.play();
      if (widget.state.soundEnabled) SystemSound.play(SystemSoundType.alert);
      if (await Vibration.hasVibrator() == true) Vibration.vibrate(duration: 450);
    }
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.selectionClick();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).t('copied'))));
  }
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, required this.state});
  final AppState state;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final items = widget.state.favorites.where((e) => e.text.contains(query.toLowerCase()) || e.category.contains(query.toLowerCase())).toList();
    return _Page(
      title: s.t('favorites'),
      child: _SearchList(
        queryChanged: (value) => setState(() => query = value),
        empty: s.t('empty'),
        children: items.map((e) => _MiniExcuseTile(
          text: e.text,
          meta: '${e.category} · ${s.t(e.rarity.name)}',
          trailing: IconButton(
            tooltip: s.t('favorite_removed'),
            onPressed: () => widget.state.toggleFavorite(e),
            icon: const Icon(Icons.favorite),
          ),
        )).toList(),
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.state});
  final AppState state;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final items = widget.state.history.where((e) => e.text.contains(query.toLowerCase()) || e.category.contains(query.toLowerCase())).toList();
    return _Page(
      title: s.t('history'),
      action: TextButton.icon(onPressed: widget.state.clearHistory, icon: const Icon(Icons.delete_sweep), label: Text(s.t('clear_all'))),
      child: _SearchList(
        queryChanged: (value) => setState(() => query = value),
        empty: s.t('empty'),
        children: items.map((e) => _MiniExcuseTile(
          text: e.text,
          meta: '${e.category} · ${s.t(e.rarity.name)}',
          trailing: IconButton(
            tooltip: s.t('clear_history'),
            onPressed: () => widget.state.removeHistory(e.id),
            icon: const Icon(Icons.close),
          ),
        )).toList(),
      ),
    );
  }
}

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final achievements = _achievements(state, s);
    final unlocked = achievements.where((a) => a.progress >= 1).length;
    return _Page(
      title: s.t('stats'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width > 640 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.18,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _StatCard(label: s.t('total_generated'), value: state.totalGenerated.toString(), icon: Icons.auto_awesome),
              _StatCard(label: s.t('favorites_count'), value: state.favoriteIds.length.toString(), icon: Icons.favorite),
              _StatCard(label: s.t('history_count'), value: state.history.length.toString(), icon: Icons.history),
              _StatCard(label: s.t('legendary_found'), value: state.legendaryFound.toString(), icon: Icons.workspace_premium),
            ],
          ),
          const SizedBox(height: 18),
          _ProgressPanel(label: s.t('achievement_progress'), value: unlocked / achievements.length),
          const SizedBox(height: 18),
          Text(s.t('achievements'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...achievements.map((a) => _AchievementTile(a)),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return _Page(
      title: s.t('settings'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _Panel(children: [
            _SettingLine(label: s.t('language'), child: _ChoiceChipGroup<AppLanguage>(
              values: AppLanguage.values,
              current: state.language,
              label: (v) => v == AppLanguage.tr ? 'türkçe' : 'english',
              onChanged: state.setLanguage,
            )),
            _SettingLine(label: s.t('theme'), child: _ChoiceChipGroup<ThemeMode>(
              values: ThemeMode.values,
              current: state.themeMode,
              label: (v) => s.t(v.name),
              onChanged: state.setThemeMode,
            )),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(s.t('sound')),
              value: state.soundEnabled,
              onChanged: state.setSound,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(s.t('animations')),
              value: state.animationsEnabled,
              onChanged: state.setAnimations,
            ),
          ]),
          const SizedBox(height: 14),
          _Panel(children: [
            _ActionButton(icon: Icons.slideshow, label: s.t('show_onboarding'), onTap: () => state.setOnboardingDone(false)),
            _ActionButton(icon: Icons.favorite_border, label: s.t('clear_favorites'), onTap: state.clearFavorites),
            _ActionButton(icon: Icons.history, label: s.t('clear_history'), onTap: state.clearHistory),
            _ActionButton(icon: Icons.restart_alt, label: s.t('reset_data'), onTap: state.reset),
          ]),
        ],
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.state});
  final AppState state;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';
  String? category;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final results = widget.state.repository.search(widget.state.language, query, category);
    return _Page(
      title: s.t('search'),
      action: IconButton(
        tooltip: s.t('close'),
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.close),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          SearchBar(hintText: s.t('search'), onChanged: (value) => setState(() => query = value)),
          const SizedBox(height: 12),
          _CategoryChips(categories: widget.state.categories, selected: category, onChanged: (v) => setState(() => category = v)),
          const SizedBox(height: 12),
          ...results.map((e) => _MiniExcuseTile(text: e.text, meta: '${e.category} · ${s.t(e.rarity.name)}')),
        ],
      ),
    );
  }
}

class ExcuseCard extends StatelessWidget {
  const ExcuseCard({
    super.key,
    required this.excuse,
    required this.onCopy,
    required this.onShare,
    required this.onFavorite,
    required this.favorite,
    this.glowing = false,
  });

  final Excuse excuse;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onFavorite;
  final bool favorite;
  final bool glowing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: glowing
              ? [const Color(0xffffd447), const Color(0xffff6bcb), scheme.primary]
              : [scheme.surfaceContainerHighest, scheme.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (glowing ? const Color(0xffffd447) : scheme.shadow).withValues(alpha: glowing ? .45 : .12),
            blurRadius: glowing ? 34 : 20,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _RarityBadge(rarity: excuse.rarity),
                const Spacer(),
                IconButton(tooltip: s.t('copy'), onPressed: onCopy, icon: const Icon(Icons.copy_rounded)),
                IconButton(tooltip: s.t('share'), onPressed: onShare, icon: const Icon(Icons.ios_share_rounded)),
                IconButton(tooltip: s.t('favorites'), onPressed: onFavorite, icon: Icon(favorite ? Icons.favorite : Icons.favorite_border)),
              ],
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(position: Tween(begin: const Offset(0, .08), end: Offset.zero).animate(animation), child: child),
              ),
              child: Text(
                excuse.text,
                key: ValueKey(excuse.id),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.18),
              ),
            ),
            const SizedBox(height: 20),
            Text(excuse.category, style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.title, this.subtitle, this.action, required this.child});
  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                      if (subtitle != null) Text(subtitle!, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                if (action != null) action!,
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _DailyCard extends StatelessWidget {
  const _DailyCard({required this.excuse});
  final Excuse excuse;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return _Panel(children: [
      Row(children: [
        const Icon(Icons.wb_sunny_outlined),
        const SizedBox(width: 10),
        Text(s.t('daily'), style: const TextStyle(fontWeight: FontWeight.w900)),
      ]),
      const SizedBox(height: 10),
      Text(excuse.text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
    ]);
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return _CategoryChips(
      categories: state.categories,
      selected: state.selectedCategory,
      onChanged: (value) {
        state.setSelectedCategory(value);
      },
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.categories, required this.selected, required this.onChanged});
  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(selected: selected == null, label: Text(s.t('all')), onSelected: (_) => onChanged(null)),
          ),
          ...categories.map((c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(selected: selected == c, label: Text(c), onSelected: (_) => onChanged(c)),
              )),
        ],
      ),
    );
  }
}

class _SearchList extends StatelessWidget {
  const _SearchList({required this.queryChanged, required this.empty, required this.children});
  final ValueChanged<String> queryChanged;
  final String empty;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        SearchBar(hintText: s.t('search'), leading: const Icon(Icons.search), onChanged: queryChanged),
        const SizedBox(height: 14),
        if (children.isEmpty)
          _Panel(children: [Center(child: Padding(padding: const EdgeInsets.all(18), child: Text(empty)))])
        else
          ...children,
      ],
    );
  }
}

class _MiniExcuseTile extends StatelessWidget {
  const _MiniExcuseTile({required this.text, required this.meta, this.trailing});
  final String text;
  final String meta;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _Panel(children: [
        Row(
          children: [
            Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 6),
        Text(meta, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .5)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _RarityBadge extends StatelessWidget {
  const _RarityBadge({required this.rarity});
  final ExcuseRarity rarity;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final color = switch (rarity) {
      ExcuseRarity.common => Colors.blueGrey,
      ExcuseRarity.rare => const Color(0xff19d17f),
      ExcuseRarity.epic => const Color(0xffff6bcb),
      ExcuseRarity.legendary => const Color(0xffffd447),
    };
    return AnimatedScale(
      duration: const Duration(milliseconds: 320),
      scale: rarity == ExcuseRarity.legendary ? 1.08 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: color.withValues(alpha: .18), borderRadius: BorderRadius.circular(999)),
        child: Text(s.t(rarity.name), style: TextStyle(color: color, fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _ChoiceChipGroup<T> extends StatelessWidget {
  const _ChoiceChipGroup({required this.values, required this.current, required this.label, required this.onChanged});
  final List<T> values;
  final T current;
  final String Function(T value) label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((value) => ChoiceChip(
            selected: current == value,
            label: Text(label(value)),
            onSelected: (_) => onChanged(value),
          )).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _Panel(children: [
      Icon(icon),
      const Spacer(),
      TweenAnimationBuilder<double>(
        tween: Tween(end: double.tryParse(value) ?? 0),
        duration: const Duration(milliseconds: 600),
        builder: (context, val, _) => Text(val.round().toString(), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
      ),
      Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ]);
  }
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return _Panel(children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
      const SizedBox(height: 12),
      ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(value: value.clamp(0, 1), minHeight: 12),
      ),
    ]);
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile(this.achievement);
  final _Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.progress >= 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _Panel(children: [
        Row(children: [
          Icon(unlocked ? Icons.verified : Icons.lock_outline),
          const SizedBox(width: 12),
          Expanded(child: Text(achievement.title, style: const TextStyle(fontWeight: FontWeight.w900))),
          Text('${(achievement.progress.clamp(0, 1) * 100).round()}%'),
        ]),
        const SizedBox(height: 10),
        LinearProgressIndicator(value: achievement.progress.clamp(0, 1)),
      ]),
    );
  }
}

class _SettingLine extends StatelessWidget {
  const _SettingLine({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        child,
      ]),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _Achievement {
  const _Achievement(this.title, this.progress);
  final String title;
  final double progress;
}

List<_Achievement> _achievements(AppState state, S s) => [
      _Achievement(s.t('first_excuse'), state.totalGenerated / 1),
      _Achievement(s.t('professional_procrastinator'), state.totalGenerated / 10),
      _Achievement(s.t('excuse_master'), state.totalGenerated / 50),
      _Achievement(s.t('legendary_hunter'), state.legendaryFound / 1),
      _Achievement(s.t('principal_believes'), state.favorites.length / 10),
      _Achievement(s.t('hundred_club'), state.totalGenerated / 100),
    ];
