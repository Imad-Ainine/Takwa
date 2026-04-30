
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../supabase/supabase_service.dart';
import '../supabase/supabase_providers.dart';

class FavoriteItemsNotifier extends StateNotifier<Set<int>> {
  final String _key;
  final Ref ref;

  FavoriteItemsNotifier(this._key, this.ref) : super({}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
    if (list != null) {
      state = list.map(int.parse).toSet();
    }
  }

  void toggle(int id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
    _save();
  }

  Future<void> _save({bool syncToRemote = true}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state.map((e) => e.toString()).toList());

    if (syncToRemote) {
      final isOnline = ref.read(connectivityProvider).value ?? false;
      final isAuth = ref.read(currentUserProvider) != null;
      if (isOnline && isAuth) {
        SupabaseService.updateSettings({
          _key: state.toList(),
        }).catchError((_) {}); // Handle silently in background
      }
    }
  }

  Future<void> syncFromRemote(List<dynamic> remoteList) async {
    final mapped = remoteList
        .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
        .toSet();
    if (mapped.isNotEmpty) {
      state = {...state, ...mapped};
      await _save(syncToRemote: false);
    }
  }
}

final favoriteDuasProvider =
    StateNotifierProvider<FavoriteItemsNotifier, Set<int>>((ref) {
      return FavoriteItemsNotifier('favorite_duas', ref);
    });

final favoriteAdhkarProvider =
    StateNotifierProvider<FavoriteItemsNotifier, Set<int>>((ref) {
      return FavoriteItemsNotifier('favorite_adhkar', ref);
    });
