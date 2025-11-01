import 'package:flutter/material.dart';
import 'package:projectakhir_mobile/Views/detail.dart';

class FavoriteAgentsPage extends StatefulWidget {
  const FavoriteAgentsPage({super.key});

  @override
  State<FavoriteAgentsPage> createState() => _FavoriteAgentsPageState();
}

class _FavoriteAgentsPageState extends State<FavoriteAgentsPage> {
  late Future<List<dynamic>> _favoriteAgentsFuture;

  // Define Valorant-inspired colors for consistency
  static const Color valorantRed = Color(0xFFFF4655);
  static const Color valorantDarkBlue =
      Color(0xFF0F1923); // A very dark blue, almost black
  static const Color valorantGrey =
      Color(0xFF272D38); // Dark grey for cards/background
  static const Color valorantLightGrey =
      Color(0xFFEFEFEF); // Off-white for text
  static const Color valorantAccentYellow =
      Color(0xFFFBEA2D); // Subtle accent (if needed)

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    _favoriteAgentsFuture = FavoriteAgents().getFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: valorantDarkBlue, // Main background
      appBar: AppBar(
        backgroundColor: valorantDarkBlue,
        elevation: 0,
        // UBAH DI SINI: Mengatur warna ikon dan teks foreground AppBar menjadi valorantLightGrey
        foregroundColor: valorantLightGrey,
        title: const Text(
          'FAVORITE AGENTS',
          style: TextStyle(
            fontFamily: 'ValorantFont', // Custom font
            color: valorantLightGrey,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _favoriteAgentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    valorantRed), // Valorant Red indicator
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'ERROR LOADING FAVORITES: ${snapshot.error}',
                style: const TextStyle(
                  fontFamily: 'ValorantFont',
                  color: valorantRed,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bookmark_border, // Use the bookmark icon
                    color: valorantGrey,
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'NO FAVORITE AGENTS YET',
                    style: TextStyle(
                      fontFamily: 'ValorantFont',
                      color: valorantLightGrey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Add agents to your favorites from their detail pages.',
                    style: TextStyle(
                      fontFamily: 'ValorantFont',
                      color: valorantLightGrey.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else {
            List<dynamic> favoriteAgents = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteAgents.length,
              itemBuilder: (context, index) {
                dynamic agent = favoriteAgents[index];
                return Padding(
                  padding: const EdgeInsets.only(
                      bottom: 12.0), // Spacing between list tiles
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AgentDetailPage(agent: agent),
                        ),
                      ).then((_) =>
                          _loadFavorites()); // Reload favorites when returning from detail page
                    },
                    child: Card(
                      color: valorantGrey, // Dark grey card background
                      elevation: 6, // Subtle shadow
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Rounded corners
                        side: BorderSide(
                          color:
                              valorantRed.withOpacity(0.4), // Subtle red border
                          width: 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            ClipOval(
                              // Circular image for leading icon
                              child: Image.network(
                                agent['displayIcon'] ?? '',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: valorantDarkBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.broken_image,
                                      color: valorantRed, size: 30),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (agent['displayName'] ?? '').toUpperCase(),
                                    style: const TextStyle(
                                      fontFamily: 'ValorantFont',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          valorantRed, // Agent name in Valorant Red
                                      letterSpacing: 0.8,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    (agent['role'] != null
                                            ? agent['role']['displayName']
                                            : 'Unknown Role')
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'ValorantFont',
                                      fontSize: 14,
                                      color: valorantLightGrey.withOpacity(
                                          0.8), // Role in light grey
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    agent['description'] ??
                                        'No description available.',
                                    style: TextStyle(
                                      fontFamily: 'ValorantFont',
                                      fontSize: 12,
                                      color: valorantLightGrey.withOpacity(
                                          0.6), // Description in lighter grey
                                    ),
                                    maxLines: 2, // Limit description to 2 lines
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
