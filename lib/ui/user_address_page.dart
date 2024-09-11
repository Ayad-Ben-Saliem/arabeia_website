import 'package:arabiya/ui/widgets/custom_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:arabiya/main.dart';

final nameProvider = StateProvider((ref) => sharedPreferences.getString('name') ?? '');
final phoneProvider = StateProvider((ref) => sharedPreferences.getString('phone') ?? '');
final addressProvider = StateProvider((ref) => sharedPreferences.getString('address') ?? '');
final locationProvider = StateProvider<LatLng>(
  (ref) => LatLng(
    sharedPreferences.getDouble('latitude') ?? 32.904396192173024,
    sharedPreferences.getDouble('longitude') ?? 13.262683314191843,
  ),
);

class UserAddressPage extends ConsumerWidget {
  const UserAddressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('بيانات المستلم'),
      ),
      body: width > 600 ? pcBody(context, ref) : mobileBody(context, ref),
    );
  }

  Widget pcBody(BuildContext context, WidgetRef ref) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // address details
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
                            // controller: TextEditingController(
                            //   text: ref.read(nameProvider),
                            // ),
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  // map
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: ref.watch(locationProvider),
                              initialZoom: 15.0,
                              onTap: (tapPosition, point) {
                                ref.watch(locationProvider.notifier).state = point;
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                subdomains: const ['a', 'b', 'c'],
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    width: 80.0,
                                    height: 80.0,
                                    point: ref.watch(locationProvider),
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 40.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isValid(ref) ? confirm(context, ref) : null,
                child: const Text('تأكيد'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget mobileBody(BuildContext context, WidgetRef ref) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                // controller: TextEditingController(
                //   text: ref.read(nameProvider),
                // ),
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
                // controller: TextEditingController(
                //   text: ref.read(phoneProvider),
                // ),
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
                // controller: TextEditingController(
                //   text: ref.read(addressProvider),
                // ),
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
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: ref.watch(locationProvider),
                      initialZoom: 15.0,
                      onLongPress: (tapPosition, point) {
                        ref.watch(locationProvider.notifier).state = point;
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: ref.watch(locationProvider),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isValid(ref) ? confirm(context, ref) : null,
              child: const Text('تأكيد'),
            ),
          ],
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
    sharedPreferences.setDouble('latitude', ref.watch(locationProvider).latitude);
    sharedPreferences.setDouble('longitude', ref.watch(locationProvider).longitude);

    return () => Navigator.pushNamed(context, '/checkout');
  }
}
