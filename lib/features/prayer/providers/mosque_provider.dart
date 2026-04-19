import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:takwa/features/prayer/data/mosque_repository.dart';

final mosqueRepositoryProvider = Provider<MosqueRepository>((ref) {
  return MosqueRepository();
});

final nearbyMosquesProvider = FutureProvider.autoDispose<List<Mosque>>((ref) async {
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw Exception('يرجى تفعيل صلاحية الموقع لرؤية المساجد القريبة');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    throw Exception('يجب تفعيل صلاحيات الموقع من إعدادات الجهاز');
  }
  
  final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
  final repo = ref.read(mosqueRepositoryProvider);
  return repo.fetchNearbyMosques(position, radius: 5000);
});
