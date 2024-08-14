import 'dart:async';

import 'package:arabiya/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final nameProvider = StateProvider((ref) => sharedPreferences.getString('name') ?? '');
final phoneProvider = StateProvider((ref) => sharedPreferences.getString('phone') ?? '');
final addressProvider = StateProvider((ref) => sharedPreferences.getString('address') ?? '');
final locationProvider = StateProvider<LatLng>(
  (ref) => LatLng(
    sharedPreferences.getDouble('latitude') ?? 32.8829352,
    sharedPreferences.getDouble('longitude') ?? 13.1677362,
  ),
);

class UserAddressPage extends ConsumerWidget {
  const UserAddressPage({super.key});

  @override
  Widget build(context, ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بيانات المستلم'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1024),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: TextEditingController(
                    text: ref.read(nameProvider),
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'اسم المستلم',
                  ),
                  onChanged: (txt) {
                    ref.read(nameProvider.notifier).state = txt;
                  },
                  textInputAction: TextInputAction.next,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: TextEditingController(
                    text: ref.read(phoneProvider),
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'رقم هاتف المستلم',
                  ),
                  onChanged: (txt) {
                    ref.read(phoneProvider.notifier).state = txt;
                  },
                  keyboardType: TextInputType.phone,
                  autocorrect: false,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: TextEditingController(
                    text: ref.read(addressProvider),
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'عنوان الاستلام',
                    hintText: 'المدينة، المنطقة، الشارع، أقرب نقطة دالة',
                  ),
                  onChanged: (txt) {
                    ref.read(addressProvider.notifier).state = txt;
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LocationMap(
                    target: ref.read(locationProvider),
                    onMapMove: (position) {
                      ref.read(locationProvider.notifier).state = position.target;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer(
                  builder: (context, ref, widget) {
                    return ElevatedButton(
                      onPressed: _isValid(ref) ? confirm(context, ref) : null,
                      child: const Text('تأكيد'),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool _isValid(WidgetRef ref) {
    return ref.watch(nameProvider).trim().isNotEmpty && ref.watch(phoneProvider).trim().isNotEmpty && ref.watch(addressProvider).trim().isNotEmpty;
  }

  VoidCallback confirm(BuildContext context, WidgetRef ref) {
    sharedPreferences.setString('name', ref.read(nameProvider));
    sharedPreferences.setString('phone', ref.read(phoneProvider));
    sharedPreferences.setString('address', ref.read(addressProvider));
    sharedPreferences.setDouble('latitude', ref.read(locationProvider).latitude);
    sharedPreferences.setDouble('longitude', ref.read(locationProvider).longitude);

    return () => Navigator.pushNamed(context, '/checkout');
  }
}

class LocationMap extends StatelessWidget {
  final LatLng target;

  final Completer<GoogleMapController> _completer = Completer<GoogleMapController>();

  final CameraPositionCallback? onMapMove;

  LocationMap({super.key, required this.target, this.onMapMove});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high),
      builder: (context, snapshot) {
        // if (snapshot.hasError) {
        //   return Center(child: Text('${snapshot.error}'));
        // }

        if (snapshot.hasData) {
          goto(
            CameraPosition(
              target: LatLng(
                snapshot.data!.latitude,
                snapshot.data!.longitude,
              ),
              zoom: 12,
            ),
          );
        }

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: target, zoom: 14),
              onMapCreated: (controller) => _completer.complete(controller),
              myLocationEnabled: true,
              onCameraMove: onMapMove,
            ),
            if (snapshot.connectionState == ConnectionState.waiting) const Center(child: CircularProgressIndicator()),
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.pin_drop_outlined), Text('مكان التوصيل')],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<GoogleMapController> get controller async => _completer.future;

  Future<void> goto(CameraPosition position) async {
    final controller = await _completer.future;
    return controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }
}
