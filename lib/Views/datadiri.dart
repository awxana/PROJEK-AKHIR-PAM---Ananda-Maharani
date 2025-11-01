import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // warna tema
  static const Color valoPink = Color(0xFFFF8FAB);
  static const Color valoDark = Color(0xFF201628);
  static const Color valoCard = Color(0xFF2A1E37);
  static const Color valoText = Color(0xFFFFFFFF);

  String? _location;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    setState(() {
      _loading = true;
    });

    try {
      // cek service
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _location = 'Layanan lokasi tidak aktif';
          _loading = false;
        });
        return;
      }

      // cek izin
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _location = 'Izin lokasi ditolak';
            _loading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _location = 'Izin lokasi ditolak permanen. Aktifkan dari Pengaturan.';
          _loading = false;
        });
        return;
      }

      // ambil posisi
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // ubah ke alamat
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final place = placemarks.isNotEmpty ? placemarks[0] : null;

      // ambil kota
      final city = place?.locality?.isNotEmpty == true
          ? place!.locality
          : (place?.subAdministrativeArea?.isNotEmpty == true
              ? place!.subAdministrativeArea
              : place?.administrativeArea);

      // ambil negara
      final country = place?.country ?? '';

      // gabung biar ga null
      String cityCountry;
      if (city != null && country.isNotEmpty) {
        cityCountry = '$city, $country';
      } else if (city != null) {
        cityCountry = city;
      } else if (country.isNotEmpty) {
        cityCountry = country;
      } else {
        cityCountry = 'Lokasi tidak dikenal';
      }

      setState(() {
        _location = cityCountry;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _location = 'Gagal ambil lokasi: $e';
        _loading = false;
      });
    }
  }

  // buka IG
  Future<void> _launchInstagram() async {
    final Uri url = Uri.parse('https://instagram.com/anandamhrn__');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // kalau mau, bisa show snackbar di sini
      throw Exception('Gagal membuka Instagram');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: valoDark,
      appBar: AppBar(
        title: const Text(
          'PROFILE',
          style: TextStyle(
            fontFamily: 'ValorantFont',
            color: valoText,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: 20,
          ),
        ),
        backgroundColor: valoDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: valoText),
      ),
      body: Stack(
        children: [
          // background
          Positioned.fill(
            child: Image.asset(
              'assets/valobackground.jpg',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.12),
            ),
          ),
          // overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  valoDark.withValues(alpha: 0.3),
                  valoDark.withValues(alpha: 0.92),
                ],
              ),
            ),
          ),
          // konten
          SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // foto profil
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: valoPink, width: 3.0),
                    boxShadow: [
                      BoxShadow(
                        color: valoPink.withValues(alpha: 0.35),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 70.0,
                    backgroundColor: valoCard,
                    backgroundImage: AssetImage('assets/profil.jpg'),
                  ),
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'Ananda Maharani',
                  style: TextStyle(
                    fontFamily: 'ValorantFont',
                    fontSize: 22,
                    color: valoText,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mahasiswa Sistem Informasi',
                  style: TextStyle(
                    fontSize: 14,
                    color: valoText.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24.0),

                // CARD DATA PROFIL
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: valoCard.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: valoPink.withValues(alpha: 0.5),
                      width: 1.4,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DATA PROFIL',
                        style: TextStyle(
                          fontFamily: 'ValorantFont',
                          fontSize: 16.0,
                          color: valoText,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(
                        color: valoPink,
                        thickness: 1.5,
                      ),
                      const SizedBox(height: 14),

                      _buildProfileDetail(label: 'Nama', value: 'Ananda Maharani'),
                      _buildProfileDetail(label: 'NIM', value: '124230032'),
                      _buildProfileDetail(label: 'Kelas', value: 'SI-D'),
                      _buildProfileDetail(label: 'Dosen Favorit', value: 'Bapak Bagus'),
                      _buildProfileDetail(
                        label: 'Mata Kuliah Favorit',
                        value: 'Aplikasi Pemrograman Mobile',
                      ),
                      const SizedBox(height: 14),

                      // lokasi
                      _buildProfileDetail(
                        label: 'Lokasi Saya',
                        value: _loading
                            ? 'Mengambil lokasi...'
                            : (_location ?? 'Gagal mendapatkan lokasi'),
                      ),
                      const SizedBox(height: 14),

                      // IG bisa diklik
                      GestureDetector(
                        onTap: _launchInstagram,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              color: valoPink,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '@anandamhrn__',
                              style: TextStyle(
                                color: valoText,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetail({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'ValorantFont',
              fontSize: 12.5,
              color: valoPink.withValues(alpha: 0.9),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16.0,
              color: valoText,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
