// lib/widgets/location_picker.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vocattio/services/location/location_service.dart';
import 'package:vocattio/widgets/snackbars.dart';
import 'package:vocattio/widgets/text_field.dart'; 
import 'package:geolocator/geolocator.dart';

class LocationPickerWidget extends StatefulWidget {
  final LatLng initialLocation;
  final Function(LatLng) onLocationChanged;
  final bool isEditing;

  const LocationPickerWidget({
    super.key,
    required this.initialLocation,
    required this.onLocationChanged,
    this.isEditing = false
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  late LatLng _selectedLocation;
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  bool _isMapLoading = true;
  bool _isDisposed = false;

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();
  final locationService = LocationService();
  
  @override
  void initState() {
    super.initState();
    _isDisposed = false;
    _updateLocation(widget.initialLocation, shouldNotifyParent: false);
    
    locationService.checkLocationPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialMapPosition();
    });
  }

  void _safeDisposeController() {
  try {
    if (!kIsWeb) {
      _mapController?.dispose();
    } else {
      _mapController = null;
    }
  } catch (e) {
    debugPrint('Falha ao liberar mapa: $e');
  }
}

 @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _safeDisposeController());
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  void _updateLocation(LatLng location, {bool shouldNotifyParent = true}) {
    if(_isDisposed) return;
    setState(() {
      _selectedLocation = location;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId("selected_location"),
          position: location,
          draggable: true,
          onDragEnd: (newPosition) {
            _updateLocation(newPosition);
          },
        ),
      );
      _latController.text = location.latitude.toStringAsFixed(6);
      _lonController.text = location.longitude.toStringAsFixed(6);
    });

    if (shouldNotifyParent) {
      widget.onLocationChanged(location);
    }
  }


  Future<void> _goToMyLocation() async {
    setState(() { _isMapLoading = true; });
    try {
      final position = await ValidadorLocalizacao.obterPosicaoAtual(); 
      if (!mounted) return;
      if (position != null) {
        final newPos = LatLng(position.latitude, position.longitude);
        _updateLocation(newPos);
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newPos, 17.0));
        
        if (position.accuracy > 40) {
          if (mounted) showTopSnackBar('Localização com baixa precisão. Ajuste manualmente.', context, isError: true);
        }
      } else {
        if (mounted) showTopSnackBar('Erro ao obter localização', context, isError: true);
      }
    } catch (e) {
      if (mounted) showTopSnackBar('Não foi possível obter localização', context, isError: true);
    } finally {
      setState(() { _isMapLoading = false; });
    }
  }

  Future<void> _loadInitialMapPosition() async {
    setState(() { _isMapLoading = true; });
    Position? posRapida = await LocationService.obterPosicaoInicialRapida();
    if (!mounted) return;
    LatLng localInicial;
    if(widget.isEditing){ // caso uma turma esteja sendo editada, preferivel usar a loc da turma ao inves da do usuario ao abrir o mapa
      localInicial = widget.initialLocation;
    }else{ // caso contrario, usamos a localizacao do usuario
      localInicial = (posRapida != null)
          ? LatLng(posRapida.latitude, posRapida.longitude)
          : widget.initialLocation;

      if(posRapida != null && posRapida.accuracy > 100 && mounted){
        showTopSnackBar('Localização imprecisa. Use o mapa para selecionar.', context, isError: true);
      }
    }
      _updateLocation(localInicial, shouldNotifyParent: false); 
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(localInicial, 15.0));
      setState(() { _isMapLoading = false; });
    
  }

  void _updateMapFromTextFields() {
    try {
      final lat = double.parse(_latController.text);
      final lon = double.parse(_lonController.text);
      final newPos = LatLng(lat, lon);
      _updateLocation(newPos);
      _mapController?.animateCamera(CameraUpdate.newLatLng(newPos));
    } catch (e) {
      _updateLocation(_selectedLocation, shouldNotifyParent: false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Este é o Column que você colou, agora dentro de um widget
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: theme.colorScheme.outline),
          ),
          height: 300,
          width: 400,
          clipBehavior: Clip.antiAlias, // Garante que o mapa respeite o border radius
          child: Stack(
            alignment: Alignment.center,
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _selectedLocation,
                  zoom: 15.0,
                ),
                onMapCreated: (controller) async {
                  if (!mounted) return;
                  _mapController = controller;

                  // Garante que o iframe esteja completamente montado
                  await Future.delayed(const Duration(milliseconds: 200));

                  if (!mounted) return;
                  try {
                    await _loadInitialMapPosition();
                  } catch (e) {
                    debugPrint('Erro ao carregar mapa: $e');
                  }
                },
                onTap: (pos) => _updateLocation(pos),
                markers: _markers,
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<EagerGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
              ),
              if (_isMapLoading)
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              Positioned(
                top: 16.0,
                right: 16.0,
                child: FloatingActionButton(
                  mini: true,
                  onPressed: _goToMyLocation,
                  child: const Icon(Icons.my_location),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Ou digite manualmente',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.primaryFixed,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    _updateMapFromTextFields();
                  }
                },
                child: TextFieldDesign( 
                  controller: _latController,
                  hintText: 'Latitude',
                  context: context,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    _updateMapFromTextFields();
                  }
                },
                child: TextFieldDesign(
                  controller: _lonController,
                  hintText: 'Longitude',
                  context: context,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ValidadorLocalizacao {
  static Future<Position?> obterPosicaoAtual() async {
    final locationService = LocationService();
    try {
      return await locationService.getCurrentPositionWithPermissions();
    } catch (e) {
      return null;
    }
  }
}