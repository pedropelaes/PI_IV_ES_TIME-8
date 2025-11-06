// lib/widgets/location_picker.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vocattio/services/location/location_service.dart';
import 'package:vocattio/widgets/snackbars.dart';
// Importe o SEU text_field.dart original, sem modificações
import 'package:vocattio/widgets/text_field.dart'; 
import 'package:geolocator/geolocator.dart';

class LocationPickerWidget extends StatefulWidget {
  final LatLng initialLocation;
  // Callback para notificar o pai (o modal) sobre a mudança de local
  final Function(LatLng) onLocationChanged;

  const LocationPickerWidget({
    super.key,
    required this.initialLocation,
    required this.onLocationChanged,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  late LatLng _selectedLocation;
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  bool _isMapLoading = true;

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateLocation(widget.initialLocation, shouldNotifyParent: false);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialMapPosition();
    });
  }

 @override
  void dispose() {
    // Só descarta o controller depois do próximo frame,
    // garantindo que o plugin web tenha completado o build do iframe.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _mapController?.dispose();
      } catch (e) {
        debugPrint('Erro ao descartar mapa: $e');
      }
      _mapController = null;
    });

    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  // Atualiza o estado interno, os marcadores, os textfields e notifica o pai
  void _updateLocation(LatLng location, {bool shouldNotifyParent = true}) {
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

  // Tenta obter a localização atual do usuário
  Future<void> _goToMyLocation() async {
    setState(() { _isMapLoading = true; });
    try {
      final position = await ValidadorLocalizacao.obterPosicaoAtual(); 
      if (!mounted) return;
      if (position != null) {
        final newPos = LatLng(position.latitude, position.longitude);
        _updateLocation(newPos);
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newPos, 17.0));
        
        if (position.accuracy > 40) { // Precisão mais rígida
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

  // Carrega a posição inicial do mapa
  Future<void> _loadInitialMapPosition() async {
    setState(() { _isMapLoading = true; });
    Position? posRapida = await LocationService.obterPosicaoInicialRapida();
    if (!mounted) return;
    LatLng localInicial = (posRapida != null)
        ? LatLng(posRapida.latitude, posRapida.longitude)
        : widget.initialLocation;

    if(posRapida != null && posRapida.accuracy > 100 && mounted){
       showTopSnackBar('Localização imprecisa. Use o mapa para selecionar.', context, isError: true);
    }

    _updateLocation(localInicial, shouldNotifyParent: false); 
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(localInicial, 15.0));
    setState(() { _isMapLoading = false; });
  }

  // Atualiza o mapa se o usuário digitar nos campos de texto
  void _updateMapFromTextFields() {
    try {
      final lat = double.parse(_latController.text);
      final lon = double.parse(_lonController.text);
      final newPos = LatLng(lat, lon);
      _updateLocation(newPos); // Notifica o pai
      _mapController?.animateCamera(CameraUpdate.newLatLng(newPos));
    } catch (e) {
      // Se a formatação estiver errada, reseta para o último valor válido
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
    try {
      return await Geolocator.getCurrentPosition(
        timeLimit: Duration(seconds: 10)
      );
    } catch (e) {
      return null;
    }
  }
}