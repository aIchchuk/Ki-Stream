import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/player_bloc.dart';
import '../bloc/song_bloc.dart';
import '../../data/models/song_model.dart';

class PlayerPage extends StatelessWidget {
  final SongModel song;

  const PlayerPage({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: BlocBuilder<PlayerBloc, PlayerState>(
          builder: (context, state) {
            // Use the current song from state if available, otherwise fallback to initial song
            final currentSong = (state is PlayerPlaying) ? state.song : song;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Top Navigation
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: () => context.pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Album Art
                    Hero(
                      tag: 'song_${currentSong.id}',
                      child: Container(
                        height: 350,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: _getImageProvider(currentSong.songImage),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 15,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title and Artist (Centered)
                    Column(
                      children: [
                        Text(
                          currentSong.songName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentSong.artistName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Action Row (Like, Add to, More)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          (currentSong.isFavorite ?? false)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          "Like",
                          onTap: () {
                            final newFavoriteStatus =
                                !(currentSong.isFavorite ?? false);
                            // Immediate UI update in PlayerBloc
                            context.read<PlayerBloc>().add(
                              UpdateFavoriteStatus(
                                currentSong.id,
                                newFavoriteStatus,
                              ),
                            );
                            // Background persistence in SongBloc
                            context.read<SongBloc>().add(
                              ToggleFavorite(currentSong),
                            );
                          },
                        ),
                        _buildActionButton(Icons.add, "Add to"),
                        _buildActionButton(Icons.more_horiz, "More"),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Progress Bar
                    StreamBuilder<Duration>(
                      stream: context.read<PlayerBloc>().positionStream,
                      builder: (context, positionSnapshot) {
                        final position = positionSnapshot.data ?? Duration.zero;
                        return StreamBuilder<Duration?>(
                          stream: context.read<PlayerBloc>().durationStream,
                          builder: (context, durationSnapshot) {
                            final duration =
                                durationSnapshot.data ?? Duration.zero;
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formatDuration(position),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      formatDuration(duration),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: AppTheme.primaryColor,
                                    inactiveTrackColor: Colors.grey.withValues(
                                      alpha: 0.3,
                                    ),
                                    thumbColor: AppTheme.primaryColor,
                                    trackHeight: 2,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 5,
                                    ),
                                  ),
                                  child: Slider(
                                    value: position.inMilliseconds.toDouble(),
                                    max: duration.inMilliseconds.toDouble() > 0
                                        ? duration.inMilliseconds.toDouble()
                                        : 1.0,
                                    onChanged: (val) {
                                      context.read<PlayerBloc>().add(
                                        Seek(
                                          Duration(milliseconds: val.toInt()),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 30),

                    // Playback Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.shuffle,
                            color: AppTheme.primaryColor,
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.skip_previous,
                            size: 32,
                            color: AppTheme.primaryColor,
                          ),
                          onPressed: () {
                            context.read<PlayerBloc>().add(PlayPrevious());
                          },
                        ),
                        GestureDetector(
                          onTap: () {
                            context.read<PlayerBloc>().add(TogglePlay());
                          },
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryColor,
                            ),
                            child: Icon(
                              (state is PlayerPlaying && state.isPlaying)
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 32,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next,
                            size: 32,
                            color: AppTheme.primaryColor,
                          ),
                          onPressed: () {
                            context.read<PlayerBloc>().add(PlayNext());
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.file_download_outlined,
                            color: AppTheme.primaryColor,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http') || path.startsWith('https')) {
      return CachedNetworkImageProvider(path);
    } else if (File(path).existsSync()) {
      return FileImage(File(path));
    } else {
      return const NetworkImage("https://picsum.photos/200/200?random=error");
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
