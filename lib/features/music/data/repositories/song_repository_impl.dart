import 'package:hive/hive.dart';
import '../../domain/repositories/song_repository.dart';
import '../models/song_model.dart';

class SongRepositoryImpl implements SongRepository {
  final Box<SongModel> songBox;

  SongRepositoryImpl(this.songBox);

  @override
  Future<List<SongModel>> getSongs() async {
    return songBox.values.toList();
  }

  @override
  Future<void> addSong(SongModel song) async {
    await songBox.put(song.id, song);
  }

  @override
  Future<void> deleteSong(String id) async {
    await songBox.delete(id);
  }

  @override
  Future<void> toggleFavorite(SongModel song) async {
    final existingSong = songBox.get(song.id);
    if (existingSong != null) {
      final updatedSong = existingSong.copyWith(
        isFavorite: !(existingSong.isFavorite ?? false),
      );
      await songBox.put(song.id, updatedSong);
    } else {
      // If it's not in the box, add it as a favorite but not manual
      final newSong = song.copyWith(
        isFavorite: true,
        isManual: song.isManual ?? false,
      );
      await songBox.put(song.id, newSong);
    }
  }
}
