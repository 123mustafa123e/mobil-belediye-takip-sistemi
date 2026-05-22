import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(37.8746, 32.4932); // Konya (varsayılan)
  Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  /// Kullanıcının konumunu al
  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Konum servisleri kapalı.');
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Konum izni reddedildi.');
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Konum izni kalıcı olarak reddedildi. Ayarlardan açın.');
        setState(() => _isLoading = false);
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 8), onTimeout: () {
        throw Exception('Konum zaman aşımı');
      });

      _updateLocation(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Konum hatası: $e');
      // Son bilinen konumu dene
      try {
        final Position? last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          _updateLocation(last.latitude, last.longitude);
          return;
        }
      } catch (_) {}
      // Varsayılan konum ile devam et
      setState(() => _isLoading = false);
    }
  }

  void _updateLocation(double lat, double lng) {
    setState(() {
      _currentPosition = LatLng(lat, lng);
      _isLoading = false;
      _markers = {
        ..._markers,
        Marker(
          markerId: const MarkerId('current'),
          position: _currentPosition,
          infoWindow: const InfoWindow(title: 'Konumunuz'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      };
    });
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition, 15),
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  /// Haritaya tıklanınca seçilen konuma marker ekle
  void _onMapTap(LatLng position) {
    setState(() {
      final newMarkers = Set<Marker>.from(_markers);
      newMarkers.removeWhere((m) => m.markerId.value == 'selected');
      newMarkers.add(Marker(
        markerId: const MarkerId('selected'),
        position: position,
        infoWindow: const InfoWindow(title: 'Seçilen Konum'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
      _markers = newMarkers;
      _currentPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Arıza Haritası',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Konumuma Git',
            onPressed: _getLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Harita ──────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) => _mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 14,
                  ),
                  markers: _markers,
                  onTap: _onMapTap,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),

          // ── Alt Kısım ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Konum: ${_currentPosition.latitude.toStringAsFixed(5)}, '
                    '${_currentPosition.longitude.toStringAsFixed(5)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, _currentPosition),
                    icon: const Icon(Icons.check),
                    label: const Text('Bu Konumu Seç'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
