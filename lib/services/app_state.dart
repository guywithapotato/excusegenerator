import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/excuse_repository.dart';
import '../models/excuse.dart';

class AppState extends ChangeNotifier {
  AppState(this.repository);

  final ExcuseRepository repository;
  SharedPreferences? _prefs;
  AppLanguage language = AppLanguage.en;
  ThemeMode themeMode = ThemeMode.system;
  bool onboardingDone = false;
  bool soundEnabled = true;
  bool animationsEnabled = true;
  int totalGenerated = 0;
  int legendaryFound = 0;
  final Set<String> favoriteIds = {};
  final List<HistoryEntry> history = [];
  Excuse? current;
  String? selectedCategory;

  Future<void> load(Locale systemLocale) async {
    _prefs = await SharedPreferences.getInstance();
    language = AppLanguage.values.byName(
      _prefs!.getString('language') ?? (systemLocale.languageCode == 'tr' ? 'tr' : 'en'),
    );
    themeMode = ThemeMode.values.byName(_prefs!.getString('themeMode') ?? 'system');
    onboardingDone = _prefs!.getBool('onboardingDone') ?? false;
    soundEnabled = _prefs!.getBool('soundEnabled') ?? true;
    animationsEnabled = _prefs!.getBool('animationsEnabled') ?? true;
    totalGenerated = _prefs!.getInt('totalGenerated') ?? 0;
    legendaryFound = _prefs!.getInt('legendaryFound') ?? 0;
    favoriteIds
      ..clear()
      ..addAll(_prefs!.getStringList('favoriteIds') ?? const []);
    history
      ..clear()
      ..addAll((_prefs!.getStringList('history') ?? const []).map((item) => HistoryEntry.fromJson(jsonDecode(item))));
    current = dailyExcuse;
    notifyListeners();
  }

  List<Excuse> get visibleExcuses => repository.byLanguage(language);
  List<String> get categories => repository.categories(language);
  List<Excuse> get favorites => favoriteIds.map(repository.byId).where((e) => e.language == language).toList();
  Excuse get dailyExcuse {
    final list = visibleExcuses;
    final day = DateTime.now().difference(DateTime(2024)).inDays;
    return list[day % list.length];
  }

  Future<void> setLanguage(AppLanguage value) async {
    language = value;
    selectedCategory = null;
    current = dailyExcuse;
    await _prefs?.setString('language', value.name);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode value) async {
    themeMode = value;
    await _prefs?.setString('themeMode', value.name);
    notifyListeners();
  }

  void setSelectedCategory(String? value) {
    selectedCategory = value;
    notifyListeners();
  }

  Future<void> setOnboardingDone(bool value) async {
    onboardingDone = value;
    await _prefs?.setBool('onboardingDone', value);
    notifyListeners();
  }

  Future<void> setSound(bool value) async {
    soundEnabled = value;
    await _prefs?.setBool('soundEnabled', value);
    notifyListeners();
  }

  Future<void> setAnimations(bool value) async {
    animationsEnabled = value;
    await _prefs?.setBool('animationsEnabled', value);
    notifyListeners();
  }

  Future<Excuse> generate() async {
    final pool = visibleExcuses.where((excuse) => selectedCategory == null || excuse.category == selectedCategory).toList();
    final excuse = pool[Random().nextInt(pool.length)];
    current = excuse;
    totalGenerated++;
    if (excuse.rarity == ExcuseRarity.legendary) legendaryFound++;
    history.insert(0, HistoryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      excuseId: excuse.id,
      text: excuse.text,
      category: excuse.category,
      rarity: excuse.rarity,
      createdAt: DateTime.now(),
    ));
    if (history.length > 300) history.removeRange(300, history.length);
    await _persistStats();
    notifyListeners();
    return excuse;
  }

  Future<void> toggleFavorite(Excuse excuse) async {
    favoriteIds.contains(excuse.id) ? favoriteIds.remove(excuse.id) : favoriteIds.add(excuse.id);
    await _prefs?.setStringList('favoriteIds', favoriteIds.toList());
    notifyListeners();
  }

  bool isFavorite(Excuse excuse) => favoriteIds.contains(excuse.id);

  Future<void> removeHistory(String id) async {
    history.removeWhere((entry) => entry.id == id);
    await _saveHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    history.clear();
    await _saveHistory();
    notifyListeners();
  }

  Future<void> clearFavorites() async {
    favoriteIds.clear();
    await _prefs?.setStringList('favoriteIds', []);
    notifyListeners();
  }

  Future<void> reset() async {
    await _prefs?.clear();
    favoriteIds.clear();
    history.clear();
    totalGenerated = 0;
    legendaryFound = 0;
    onboardingDone = false;
    soundEnabled = true;
    animationsEnabled = true;
    themeMode = ThemeMode.system;
    language = AppLanguage.en;
    current = dailyExcuse;
    notifyListeners();
  }

  Future<void> _persistStats() async {
    await _prefs?.setInt('totalGenerated', totalGenerated);
    await _prefs?.setInt('legendaryFound', legendaryFound);
    await _saveHistory();
  }

  Future<void> _saveHistory() async {
    await _prefs?.setStringList('history', history.map((entry) => jsonEncode(entry.toJson())).toList());
  }
}
