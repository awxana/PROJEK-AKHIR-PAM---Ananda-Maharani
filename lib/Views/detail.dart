import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // 🔹 tambahin ini buat formatting angka
import 'package:shared_preferences/shared_preferences.dart';

class AgentDetailPage extends StatefulWidget {
  final dynamic agent;

  const AgentDetailPage({super.key, required this.agent});

  @override
  _AgentDetailPageState createState() => _AgentDetailPageState();
}

class _AgentDetailPageState extends State<AgentDetailPage> {
  bool isFavorite = false;
  String selectedCurrency = 'USD';
  double convertedValue = 0.0;
  bool isLoading = false;

  // tema pink
  static const Color valoPink = Color(0xFFFF8FAB);
  static const Color valoDark = Color(0xFF201628);
  static const Color valoCard = Color(0xFF2A1E37);
  static const Color valoText = Colors.white;
  static const Color valoAccent = Color(0xFFFBEA2D);

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    _updateConversion();
  }

  Future<void> _loadFavoriteStatus() async {
    isFavorite = await FavoriteAgents().isFavorite(widget.agent);
    setState(() {});
  }

  void toggleFavorite() async {
    setState(() {
      isFavorite = !isFavorite;
    });

    if (isFavorite) {
      await FavoriteAgents().addToFavorites(widget.agent);
      _showSnackBar('Agent added to favorites!', valoPink);
    } else {
      await FavoriteAgents().removeFromFavorites(widget.agent);
      _showSnackBar('Agent removed from favorites!', valoCard);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: valoText, fontFamily: 'ValorantFont'),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showAbilityDescription(String abilityName, String abilityDescription) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: valoCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            abilityName.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'ValorantFont',
              color: valoPink,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            abilityDescription,
            style: const TextStyle(
              fontFamily: 'ValorantFont',
              color: valoText,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'CLOSE',
                style: TextStyle(
                  fontFamily: 'ValorantFont',
                  color: valoPink,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateConversion() async {
    setState(() {
      isLoading = true;
    });

    final baseUSD =
        double.tryParse(widget.agent['contractValueUSD'].toString()) ?? 0;
    if (selectedCurrency == 'USD') {
      convertedValue = baseUSD;
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response =
          await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rate = data['rates'][selectedCurrency] ?? 1.0;

        setState(() {
          convertedValue = baseUSD * rate;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _currencySymbol(String code) {
    switch (code) {
      case 'USD':
        return '\$';
      case 'IDR':
        return 'Rp';
      case 'EUR':
        return '€';
      case 'KWD':
        return 'KD';
      default:
        return '';
    }
  }

  String _formatCurrency(double value, String code) {
    switch (code) {
      case 'IDR':
        return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(value);
      case 'USD':
        return NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2).format(value);
      case 'EUR':
        return NumberFormat.currency(locale: 'en_EU', symbol: '€', decimalDigits: 2).format(value);
      case 'KWD':
        return NumberFormat.currency(locale: 'ar_KW', symbol: 'KD', decimalDigits: 3).format(value);
      default:
        return value.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: valoDark,
      appBar: AppBar(
        backgroundColor: valoDark,
        elevation: 0,
        foregroundColor: valoText,
        title: Text(
          (widget.agent['displayName'] ?? '').toUpperCase(),
          style: const TextStyle(
            fontFamily: 'ValorantFont',
            color: valoText,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.3,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? valoPink : valoText.withOpacity(0.6),
            ),
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/valobackground.jpg',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.1),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  valoDark.withOpacity(0.3),
                  valoDark.withOpacity(0.95),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // portrait
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    widget.agent['fullPortraitV2'] ??
                        widget.agent['fullPortrait'] ??
                        '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.45,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: valoCard,
                      height: 250,
                      child: const Center(
                        child: Icon(Icons.broken_image,
                            color: valoPink, size: 40),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // description
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: valoCard.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: valoPink.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (widget.agent['role'] != null
                                ? widget.agent['role']['displayName']
                                : 'Unknown Role')
                            .toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'ValorantFont',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: valoAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.agent['description'] ?? 'No description available.',
                        style: const TextStyle(
                          fontFamily: 'ValorantFont',
                          fontSize: 14,
                          color: valoText,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Abilities
                _buildAbilitySection(),

                const SizedBox(height: 24),

                // Contract section
                _buildContractSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbilitySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: valoCard.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: valoPink.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ABILITIES',
            style: TextStyle(
              fontFamily: 'ValorantFont',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valoPink,
            ),
          ),
          const SizedBox(height: 14),
          if (widget.agent['abilities'] != null &&
              widget.agent['abilities'].isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.2,
              ),
              itemCount: widget.agent['abilities'].length,
              itemBuilder: (context, index) {
                final ability = widget.agent['abilities'][index];
                if (ability['displayIcon'] == null ||
                    ability['displayName'] == null ||
                    ability['description'] == null) {
                  return const SizedBox.shrink();
                }
                return _buildAbilityCard(ability);
              },
            )
          else
            const Text(
              'No abilities information available.',
              style: TextStyle(
                fontFamily: 'ValorantFont',
                color: valoText,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAbilityCard(dynamic ability) {
    return GestureDetector(
      onTap: () {
        _showAbilityDescription(
          ability['displayName'],
          ability['description'],
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: valoDark.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: valoPink.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (ability['displayIcon'] != null)
              Image.network(
                ability['displayIcon'],
                height: 40,
                width: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  color: valoPink,
                  size: 30,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              ability['displayName'].toUpperCase(),
              style: const TextStyle(
                fontFamily: 'ValorantFont',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valoText,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: valoCard.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: valoPink.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CONTRACT VALUE',
            style: TextStyle(
              fontFamily: 'ValorantFont',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valoPink,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          // Dropdown currency
          Row(
            children: [
              const Text(
                'Currency:',
                style: TextStyle(
                  fontFamily: 'ValorantFont',
                  color: valoText,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: selectedCurrency,
                dropdownColor: valoCard,
                style: const TextStyle(
                  fontFamily: 'ValorantFont',
                  color: valoText,
                ),
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'USD', child: Text('USD')),
                  DropdownMenuItem(value: 'IDR', child: Text('IDR')),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                  DropdownMenuItem(value: 'KWD', child: Text('KWD')),
                ],
                onChanged: (val) {
                  setState(() {
                    selectedCurrency = val!;
                  });
                  _updateConversion();
                },
              ),
            ],
          ),

          const SizedBox(height: 10),
          isLoading
              ? const Center(child: CircularProgressIndicator(color: valoPink))
              : Text(
                  _formatCurrency(convertedValue, selectedCurrency),
                  style: const TextStyle(
                    fontFamily: 'ValorantFont',
                    fontSize: 22,
                    color: valoText,
                  ),
                ),
        ],
      ),
    );
  }
}

// Favorite storage
class FavoriteAgents {
  static final FavoriteAgents _instance = FavoriteAgents._internal();
  factory FavoriteAgents() => _instance;
  FavoriteAgents._internal();

  static const String _favoritesKey = 'favoriteAgents';
  List<dynamic> _favoriteAgents = [];
  bool _isInitialized = false;

  Future<void> _init() async {
    if (!_isInitialized) {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString(_favoritesKey);
      if (favoritesJson != null) {
        _favoriteAgents = json.decode(favoritesJson);
      }
      _isInitialized = true;
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String favoritesJson = json.encode(_favoriteAgents);
    await prefs.setString(_favoritesKey, favoritesJson);
  }

  Future<void> addToFavorites(dynamic agent) async {
    await _init();
    if (!_favoriteAgents.any((favAgent) => favAgent['uuid'] == agent['uuid'])) {
      _favoriteAgents.add(agent);
      await _saveFavorites();
    }
  }

  Future<void> removeFromFavorites(dynamic agent) async {
    await _init();
    _favoriteAgents
        .removeWhere((favAgent) => favAgent['uuid'] == agent['uuid']);
    await _saveFavorites();
  }

  Future<bool> isFavorite(dynamic agent) async {
    await _init();
    return _favoriteAgents.any((favAgent) => favAgent['uuid'] == agent['uuid']);
  }

  Future<List<dynamic>> getFavorites() async {
    await _init();
    return List.from(_favoriteAgents);
  }
}
