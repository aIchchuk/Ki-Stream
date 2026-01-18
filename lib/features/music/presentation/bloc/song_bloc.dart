import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/song_model.dart';
import '../../domain/repositories/song_repository.dart';

// Events
abstract class SongEvent extends Equatable {
  const SongEvent();

  @override
  List<Object> get props => [];
}

class LoadSongs extends SongEvent {}

class AddSong extends SongEvent {
  final SongModel song;
  const AddSong(this.song);

  @override
  List<Object> get props => [song];
}

class DeleteSong extends SongEvent {
  final String id;
  const DeleteSong(this.id);

  @override
  List<Object> get props => [id];
}

class ToggleFavorite extends SongEvent {
  final SongModel song;
  const ToggleFavorite(this.song);

  @override
  List<Object> get props => [song];
}

// States
abstract class SongState extends Equatable {
  const SongState();

  @override
  List<Object> get props => [];
}

class SongInitial extends SongState {}

class SongLoading extends SongState {}

class SongLoaded extends SongState {
  final List<SongModel> songs;
  const SongLoaded(this.songs);

  @override
  List<Object> get props => [songs];
}

class SongError extends SongState {
  final String message;
  const SongError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class SongBloc extends Bloc<SongEvent, SongState> {
  final SongRepository repository;

  SongBloc(this.repository) : super(SongInitial()) {
    on<LoadSongs>(_onLoadSongs);
    on<AddSong>(_onAddSong);
    on<DeleteSong>(_onDeleteSong);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadSongs(LoadSongs event, Emitter<SongState> emit) async {
    emit(SongLoading());
    try {
      final songs = await repository.getSongs();
      // Sort by date added descending
      songs.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      emit(SongLoaded(songs));
    } catch (e) {
      emit(SongError(e.toString()));
    }
  }

  Future<void> _onAddSong(AddSong event, Emitter<SongState> emit) async {
    try {
      await repository.addSong(event.song);
      add(LoadSongs());
    } catch (e) {
      emit(SongError(e.toString()));
    }
  }

  Future<void> _onDeleteSong(DeleteSong event, Emitter<SongState> emit) async {
    try {
      await repository.deleteSong(event.id);
      add(LoadSongs());
    } catch (e) {
      emit(SongError(e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<SongState> emit,
  ) async {
    final currentState = state;
    if (currentState is SongLoaded) {
      // Optimistic update
      final updatedSongs = currentState.songs.map((song) {
        if (song.id == event.song.id) {
          return song.copyWith(isFavorite: !(song.isFavorite ?? false));
        }
        return song;
      }).toList();
      emit(SongLoaded(updatedSongs));
    }

    try {
      await repository.toggleFavorite(event.song);
      // Reload from repository to ensure consistency with DB
      final songs = await repository.getSongs();
      songs.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      emit(SongLoaded(songs));
    } catch (e) {
      emit(SongError(e.toString()));
    }
  }
}
