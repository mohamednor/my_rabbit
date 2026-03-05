import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameStateService extends ChangeNotifier {
  SharedPreferences? _prefs;
  
  int _coins = 0;
  int _highestLevel = 1;
  int _bunnySize = 1;
  int _totalCandies = 0;
  
  String _currentHat = 'none';
  String _currentOutfit = 'pink';
  
  Set<String> _ownedHats = {'none'};
  Set<String> _ownedOutfits = {'pink'};
  
  final Map<int, int> _levelStars = {};
  final Map<int, int> _levelScores = {};
  
  int get coins => _coins;
  int get highestLevel => _highestLevel;
  int get bunnySize => _bunnySize;
  int get totalCandies => _totalCandies;
  String get currentHat => _currentHat;
  String get currentOutfit => _currentOutfit;
  Set<String> get ownedHats => _ownedHats;
  Set<String> get ownedOutfits => _ownedOutfits;
  
  int get totalStars => _levelStars.values.fold(0, (a, b) => a + b);
  int get completedLevels => _levelStars.values.where((s) => s > 0).length;
  
  Future<void> loadState() async {
    _prefs = await SharedPreferences.getInstance();
    
    _coins = _prefs!.getInt('coins') ?? 0;
    _highestLevel = _prefs!.getInt('highestLevel') ?? 1;
    _bunnySize = _prefs!.getInt('bunnySize') ?? 1;
    _totalCandies = _prefs!.getInt('totalCandies') ?? 0;
    _currentHat = _prefs!.getString('currentHat') ?? 'none';
    _currentOutfit = _prefs!.getString('currentOutfit') ?? 'pink';
    _ownedHats = (_prefs!.getStringList('ownedHats') ?? ['none']).toSet();
    _ownedOutfits = (_prefs!.getStringList('ownedOutfits') ?? ['pink']).toSet();
    
    final levelCount = _prefs!.getInt('levelCount') ?? 0;
    for (int i = 1; i <= levelCount; i++) {
      _levelStars[i] = _prefs!.getInt('level_${i}_stars') ?? 0;
      _levelScores[i] = _prefs!.getInt('level_${i}_score') ?? 0;
    }
    
    notifyListeners();
  }
  
  Future<void> _saveState() async {
    if (_prefs == null) return;
    
    await _prefs!.setInt('coins', _coins);
    await _prefs!.setInt('highestLevel', _highestLevel);
    await _prefs!.setInt('bunnySize', _bunnySize);
    await _prefs!.setInt('totalCandies', _totalCandies);
    await _prefs!.setString('currentHat', _currentHat);
    await _prefs!.setString('currentOutfit', _currentOutfit);
    await _prefs!.setStringList('ownedHats', _ownedHats.toList());
    await _prefs!.setStringList('ownedOutfits', _ownedOutfits.toList());
    
    await _prefs!.setInt('levelCount', _levelStars.length);
    for (final entry in _levelStars.entries) {
      await _prefs!.setInt('level_${entry.key}_stars', entry.value);
    }
    for (final entry in _levelScores.entries) {
      await _prefs!.setInt('level_${entry.key}_score', entry.value);
    }
  }
  
  void addCoins(int amount) {
    _coins += amount;
    _saveState();
    notifyListeners();
  }
  
  bool spendCoins(int amount) {
    if (_coins >= amount) {
      _coins -= amount;
      _saveState();
      notifyListeners();
      return true;
    }
    return false;
  }
  
  void setBunnySize(int size) {
    if (size > _bunnySize) {
      _bunnySize = size;
      _saveState();
      notifyListeners();
    }
  }
  
  void addCandies(int count) {
    _totalCandies += count;
    _saveState();
    notifyListeners();
  }
  
  void completeLevel(int level, int stars, int score) {
    if (level >= _highestLevel) {
      _highestLevel = level + 1;
    }
    if (stars > (_levelStars[level] ?? 0)) {
      _levelStars[level] = stars;
    }
    if (score > (_levelScores[level] ?? 0)) {
      _levelScores[level] = score;
    }
    _saveState();
    notifyListeners();
  }
  
  bool isLevelUnlocked(int level) => level <= _highestLevel;
  int getStars(int level) => _levelStars[level] ?? 0;
  int getScore(int level) => _levelScores[level] ?? 0;
  
  void purchaseHat(String id) {
    _ownedHats.add(id);
    _saveState();
    notifyListeners();
  }
  
  void purchaseOutfit(String id) {
    _ownedOutfits.add(id);
    _saveState();
    notifyListeners();
  }
  
  void equipHat(String id) {
    if (_ownedHats.contains(id)) {
      _currentHat = id;
      _saveState();
      notifyListeners();
    }
  }
  
  void equipOutfit(String id) {
    if (_ownedOutfits.contains(id)) {
      _currentOutfit = id;
      _saveState();
      notifyListeners();
    }
  }
}
