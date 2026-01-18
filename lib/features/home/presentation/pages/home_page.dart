import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kistream/core/theme/app_theme.dart';
import 'package:kistream/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kistream/features/auth/data/models/user_model.dart';
import 'package:kistream/features/music/data/models/song_model.dart';
import 'package:kistream/features/music/presentation/bloc/player_bloc.dart';
import 'package:kistream/features/music/presentation/bloc/song_bloc.dart';
import 'package:kistream/features/shared/widgets/song_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load songs when home page is initialized
    context.read<SongBloc>().add(LoadSongs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const SizedBox(height: 15),
              const HomeHeader(),
              const SizedBox(height: 20),

              // Search / Mood
              const FeelingWidget(),
              const SizedBox(height: 30),

              /*
              // Recommendations
              Text(
                "Recommendations",
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildSongCard(
                      context,
                      id: "1",
                      image: "https://picsum.photos/200/200?random=1",
                      title: "Song Name",
                      artist: "Artist Name",
                    ),
                    _buildSongCard(
                      context,
                      id: "2",
                      image: "https://picsum.photos/200/200?random=2",
                      title: "Bounce",
                      artist: "Bounce Artist",
                    ),
                    _buildSongCard(
                      context,
                      id: "3",
                      image: "https://picsum.photos/200/200?random=3",
                      title: "Starboy",
                      artist: "The Weeknd",
                    ),
                    _buildSongCard(
                      context,
                      id: "7",
                      image: "https://picsum.photos/200/200?random=7",
                      title: "Save Your Tears",
                      artist: "The Weeknd",
                    ),
                    _buildSongCard(
                      context,
                      id: "8",
                      image: "https://picsum.photos/200/200?random=8",
                      title: "Good 4 U",
                      artist: "Olivia Rodrigo",
                    ),
                    _buildSongCard(
                      context,
                      id: "9",
                      image: "https://picsum.photos/200/200?random=9",
                      title: "Heat Waves",
                      artist: "Glass Animals",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),
              */

              /*
              // Recently Played
              Text(
                "Recently Played",
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildSongCard(
                      context,
                      id: "20",
                      image: "https://picsum.photos/200/200?random=20",
                      title: "Circles",
                      artist: "Post Malone",
                    ),
                    _buildSongCard(
                      context,
                      id: "21",
                      image: "https://picsum.photos/200/200?random=21",
                      title: "Sunflower",
                      artist: "Post Malone & Swae Lee",
                    ),
                    _buildSongCard(
                      context,
                      id: "22",
                      image: "https://picsum.photos/200/200?random=22",
                      title: "Memories",
                      artist: "Maroon 5",
                    ),
                    _buildSongCard(
                      context,
                      id: "23",
                      image: "https://picsum.photos/200/200?random=23",
                      title: "Someone You Loved",
                      artist: "Lewis Capaldi",
                    ),
                    _buildSongCard(
                      context,
                      id: "24",
                      image: "https://picsum.photos/200/200?random=24",
                      title: "Dance Monkey",
                      artist: "Tones and I",
                    ),
                    _buildSongCard(
                      context,
                      id: "25",
                      image: "https://picsum.photos/200/200?random=25",
                      title: "Señorita",
                      artist: "Shawn Mendes & Camila Cabello",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              */

              // Trending / Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Trending Songs",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.queue_music_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      context.push('/add-song');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildSongCard(
                      context,
                      id: "4",
                      image: "https://picsum.photos/200/200?random=4",
                      title: "Dreaming",
                      artist: "Dream Artist",
                    ),
                    _buildSongCard(
                      context,
                      id: "5",
                      image: "https://picsum.photos/200/200?random=5",
                      title: "Peace",
                      artist: "Peace Artist",
                    ),
                    _buildSongCard(
                      context,
                      id: "6",
                      image: "https://picsum.photos/200/200?random=6",
                      title: "Enjoy World",
                      artist: "World Artist",
                    ),
                    _buildSongCard(
                      context,
                      id: "13",
                      image: "https://picsum.photos/200/200?random=13",
                      title: "As It Was",
                      artist: "Harry Styles",
                    ),
                    _buildSongCard(
                      context,
                      id: "14",
                      image: "https://picsum.photos/200/200?random=14",
                      title: "Anti-Hero",
                      artist: "Taylor Swift",
                    ),
                    _buildSongCard(
                      context,
                      id: "15",
                      image: "https://picsum.photos/200/200?random=15",
                      title: "Flowers",
                      artist: "Miley Cyrus",
                    ),
                    _buildSongCard(
                      context,
                      id: "16",
                      image: "https://picsum.photos/200/200?random=16",
                      title: "Calm Down",
                      artist: "Rema & Selena Gomez",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Newly Added Songs
              Text(
                "Newly Added Songs",
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              BlocBuilder<SongBloc, SongState>(
                builder: (context, state) {
                  if (state is SongLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SongLoaded) {
                    final manualSongs = state.songs
                        .where((s) => s.isManual == true)
                        .toList();
                    if (manualSongs.isEmpty) {
                      return const Text(
                        "No songs added yet.",
                        style: TextStyle(color: Colors.grey),
                      );
                    }
                    return SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: manualSongs.length,
                        itemBuilder: (context, index) {
                          final song = manualSongs[index];
                          return SongCard(
                            songImage: song.songImage,
                            songName: song.songName,
                            onTap: () {
                              context.read<PlayerBloc>().add(
                                PlaySong(song, queue: manualSongs),
                              );
                              context.push('/player', extra: song);
                            },
                          );
                        },
                      ),
                    );
                  } else if (state is SongError) {
                    return Text(
                      "Error: ${state.message}",
                      style: const TextStyle(color: Colors.red),
                    );
                  }
                  return const Text(
                    "No manual songs added yet.",
                    style: TextStyle(color: Colors.grey),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSongCard(
    BuildContext context, {
    required String id,
    required String image,
    required String title,
    required String artist,
  }) {
    final song = SongModel(
      id: id,
      songName: title,
      artistName: artist,
      songImage: image,
      audioFile: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      dateAdded: DateTime.now(),
    );

    return SongCard(
      songImage: image,
      songName: title,
      onTap: () {
        context.read<PlayerBloc>().add(PlaySong(song));
        context.push('/player', extra: song);
      },
    );
  }
}

class FeelingWidget extends StatefulWidget {
  const FeelingWidget({super.key});

  @override
  State<FeelingWidget> createState() => _FeelingWidgetState();
}

class _FeelingWidgetState extends State<FeelingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    const curve = Curves.easeOutQuart;

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    // Unified slide from slight bottom to center
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    _startAnimationLoop();
  }

  void _startAnimationLoop() async {
    while (mounted) {
      // 1. Slide Out (Reveal)
      await _controller.forward();
      // 2. Wait 5 seconds
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) break;
      // 3. Slide In (Hide/Reset)
      await _controller.reverse();
      // 4. Loop repeats immediately as while loop continues
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go('/search');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 10),
                  Text(
                    "What do you want to listen to?",
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        UserModel? user;
        if (state is Authenticated) {
          user = state.user;
        }

        final hour = DateTime.now().hour;
        String greeting = "Good Evening,";
        if (hour < 12) {
          greeting = "Good Morning,";
        } else if (hour < 17) {
          greeting = "Good Afternoon,";
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  user?.displayName ?? "Guest",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            GestureDetector(
              onTap: () => context.go('/profile'),
              child: CircleAvatar(
                radius: 25,
                backgroundImage:
                    (user?.photoUrl != null &&
                        File(user!.photoUrl!).existsSync())
                    ? FileImage(File(user.photoUrl!)) as ImageProvider
                    : NetworkImage(
                        user?.photoUrl ??
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS-DXFpesytRtBxTDt3pmlwFLKZAPbUkQ_CDg&s",
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
