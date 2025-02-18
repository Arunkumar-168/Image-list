// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:hello/API/update_user_model.dart';
// import 'package:hello/Bottom/Car.dart';
// import 'package:hello/Bottom/Provider.dart';
// import 'package:hello/APIID.dart';
// import 'package:hello/History/Ride.dart';
// import 'package:hello/Map.dart';
// import 'dart:async';
// import '../My Account/Profile.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// class DrawerPage extends StatefulWidget {
//   static const routeName = '/drawer';
//   const DrawerPage({super.key});
//
//   @override
//   _DrawerPageState createState() => _DrawerPageState();
// }
//
// class _DrawerPageState extends State<DrawerPage> with TickerProviderStateMixin {
//   TextEditingController searchController = TextEditingController();
//   TextEditingController _DropController = TextEditingController();
//   TextEditingController _markerController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   DateTime timeBackPressed = DateTime.now();
//   bool warningShown = false;
//   String _searchType = 'pickup';
//   String _markerType = 'marker';
//   String _searchDropType = 'drop';
//   Set<Polyline> polylines = {};
//   List<LatLng> polylineCoordinates = [];
//   List<UpdateUser> profileData = [];
//   final PolylinePoints polylinePoints = PolylinePoints();
//   late AnimationController _animationController;
//   late Animation<double> _animation;
//   late double _animationValue;
//   Set<Marker> markers = {};
//   GoogleMapController? mapController;
//   GoogleMapController? mapLevelController;
//   GoogleMapController? mapMarkerController;
//   LatLng markerLocation = const LatLng(11.02713, 77.02425);
//   BitmapDescriptor? customIcon;
//   String? pickupAddress; // State variable for pickup address
//   String? dropAddress;
//   LatLng? pickupLocation;
//   LatLng? dropLocation;
//   bool isSelected = false;
//   bool ispinkSelected = false;
//   String? firstname;
//   String? _userData;
//   String? email;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _clearSearch();
//     });
//     _setMarkerIcon();
//     // fetchProfile();
//     Edit();
//     _getCurrentLocation();
//     searchController = TextEditingController();
//     _DropController = TextEditingController();
//     _markerController = TextEditingController();
//     _animationController = AnimationController(
//       duration: const Duration(seconds: 5), // Adjust duration as needed
//       vsync: this,
//     );
//     _animation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );
//     _animationController.addListener(() {
//       setState(() {
//         _animationValue = _animation.value; // Use _animation.value instead
//       });
//     });
//     _animationController.forward(from: 0);
//     _animationValue = 50.0;
//   }
//
//   @override
//   void dispose() {
//     _DropController.dispose();
//     searchController.dispose();
//     _markerController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   Future<void> Edit() async {
//     const String apiUrl = Baseurl + 'get_profile';
//     final prefs = await SharedPreferences.getInstance();
//     final response = await http.post(Uri.parse(apiUrl),
//         body: {'customer_id': await prefs.getString('customer_id')});
//     print('User Profile: ${response.body}');
//     if (response.statusCode == 200) {
//       final List<dynamic> jsonData = json.decode(response.body);
//       setState(() {
//         profileData =
//             jsonData.map((data) => UpdateUser.fromJson(data)).toList();
//       });
//       for (final profile in profileData) {
//         firstname = profile.firstname + profile.lastname;
//         email = profile.email;
//       }
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//   }
//
//   void _clearSearch() {
//     setState(() {
//       searchController.clear();
//       Provider.of<PlacesProvider>(context, listen: false)
//           .clearPlaceSuggestions();
//       _DropController.clear();
//       _markerController.clear();
//       emailController.clear();
//     });
//   }
//
//   Future<String?> performLocationSearch(String query) async {
//     await Future.delayed(const Duration(seconds: 0));
//     return ' $query';
//   }
//
//   Future<void> _setMarkerIcon() async {
//     final markers = await _createMarkers();
//     setState(() {
//       markers;
//       _getPolyline();
//     });
//   }
//
//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       return Future.error(
//           'Location permissions are permanently denied, we cannot request permissions.');
//     }
//
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     final markerIcon = await BitmapDescriptor.fromAssetImage(
//       const ImageConfiguration(size: Size(24, 24)), // Try reducing the size
//       'assets/icon/red.png',
//     );
//     setState(() {
//       markerLocation = LatLng(position.latitude, position.longitude);
//       _createMarkers(); // Call to update markers with the new location
//       markers.add(
//         Marker(
//           markerId: MarkerId('markerLocation'),
//           position: markerLocation,
//           icon: markerIcon,
//         ),
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         final difference = DateTime.now().difference(timeBackPressed);
//         final isExitWarning = difference >= Duration(seconds: 2);
//         timeBackPressed = DateTime.now();
//         emailController.clear();
//         if (isExitWarning) {
//           warningShown = false;
//         }
//         if (!warningShown) {
//           warningShown = true;
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Press back again to exit'),
//             ),
//           );
//           return false;
//         }
//         return true;
//       },
//       child: Scaffold(
//         resizeToAvoidBottomInset: false,
//         body: Stack(
//           children: <Widget>[
//             Container(
//               width: double.infinity,
//               height: 640, // Adjusted height
//               child: Consumer<PlacesProvider>(
//                 builder: (context, placesProvider, child) {
//                   return GoogleMap(
//                     initialCameraPosition: CameraPosition(
//                       target: markerLocation,
//                       zoom: 15,
//                     ),
//                     onMapCreated: (GoogleMapController controller) {
//                       mapController = controller;
//                       mapLevelController = controller;
//                       mapMarkerController = controller;
//                     },
//                     myLocationEnabled: true,
//                     markers: markers,
//                     polylines: polylines,
//                   );
//                 },
//               ),
//             ),
//             Positioned(
//               top: MediaQuery.of(context).padding.top + 30,
//               left: 8,
//               child: Builder(
//                 builder: (context) => Container(
//                   decoration: BoxDecoration(
//                     color: Colors.pink.shade900,
//                     shape: BoxShape.circle,
//                   ),
//                   child: IconButton(
//                     icon: const Icon(Icons.menu),
//                     color: Colors.white,
//                     onPressed: () {
//                       Scaffold.of(context).openDrawer();
//                     },
//                   ),
//                 ),
//               ),
//             ),
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 padding: const EdgeInsets.all(16.0),
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black26,
//                       blurRadius: 10.0,
//                     ),
//                   ],
//                 ),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(6),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   ispinkSelected = !ispinkSelected;
//                                 });
//                                 Navigator.of(context).pushReplacement(
//                                   MaterialPageRoute(
//                                       builder: (context) => const DrawerPage()),
//                                 );
//                               },
//                               child: Container(
//                                 width: 170,
//                                 padding: EdgeInsets.all(1),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12.0),
//                                   border: Border.all(color: Colors.black),
//                                   color: ispinkSelected
//                                       ? Colors.pink[50]
//                                       : Colors
//                                       .white, // Change background color based on selection
//                                 ),
//                                 child: Column(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Image.asset('assets/images/ic_mini.png',
//                                         width: 50, height: 50),
//                                     SizedBox(width: 8.0),
//                                     // Space between image and text
//                                     Text(
//                                       'Local',
//                                       style: TextStyle(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 10),
//                             GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   isSelected = !isSelected;
//                                 });
//                                 Navigator.of(context).pushReplacement(
//                                   MaterialPageRoute(
//                                       builder: (context) => const DrawerPage()),
//                                 );
//                               },
//                               child: Container(
//                                 width: 170,
//                                 padding: EdgeInsets.all(1),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12.0),
//                                   border: Border.all(color: Colors.black),
//                                   color: isSelected
//                                       ? Colors.pink[50]
//                                       : Colors
//                                       .white, // Change background color based on selection
//                                 ),
//                                 child: Column(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Image.asset('assets/images/bag.png',
//                                         width: 50, height: 50),
//                                     SizedBox(width: 8.0),
//                                     // Space between image and text
//                                     Text(
//                                       'Outstation',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold,
//                                         color: isSelected
//                                             ? Colors.pink
//                                             : Colors.black,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const Padding(
//                         padding:
//                         EdgeInsets.symmetric(horizontal: 10, vertical: 1),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Pickup at...',
//                               style: TextStyle(
//                                 fontSize: 15,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(1),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             buildLocationContainer(
//                               context,
//                               'Pickup at...',
//                               Icons.location_on,
//                               'pickup',
//                               pickupAddress,
//                             ),
//                           ],
//                         ),
//                       ),
//                       Row(
//                         children: [
//                           const SizedBox(width: 20),
//                           Expanded(
//                             child: CustomPaint(
//                               size: const Size(10, 2),
//                               painter: DottedPainter(
//                                 Horizontal: true,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 1),
//                       Row(
//                         children: [
//                           const SizedBox(width: 10),
//                           Padding(
//                             padding: const EdgeInsets.all(1),
//                             child: Column(
//                               children: [
//                                 CustomPaint(
//                                   size: const Size(10, 35),
//                                   painter:
//                                   DottedLinePainter(isHorizontal: false),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       Padding(
//                         padding:
//                         EdgeInsets.symmetric(horizontal: 10, vertical: 1),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Drop at...',
//                               // textAlign: TextAlign.start,
//                               style: TextStyle(
//                                 fontSize: 15,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 1),
//                       Padding(
//                         padding: const EdgeInsets.all(1),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             buildDropContainer(
//                               context,
//                               '',
//                               Icons.location_on,
//                               dropAddress,
//                               'drop',
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Padding(
//                         padding: const EdgeInsets.all(1),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: Container(
//                                 height: 40,
//                                 padding: const EdgeInsets.all(1),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                   gradient: const LinearGradient(
//                                     colors: [Colors.pink, Colors.purple],
//                                   ),
//                                 ),
//                                 child: TextButton(
//                                   onPressed: () {
//                                     if (pickupAddress == null) {
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(
//                                         const SnackBar(
//                                           content: Text(
//                                               'Please select a pickup location'),
//                                         ),
//                                       );
//                                       return;
//                                     }
//                                     Navigator.pushNamed(
//                                       context,
//                                       BrandPage.routeName,
//                                       arguments: {
//                                         'markers': markers,
//                                         'polylines': polylines,
//                                       },
//                                     );
//                                     if (dropAddress == null) {
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(
//                                         const SnackBar(
//                                           content: Text(
//                                               'Please select a drop location'),
//                                         ),
//                                       );
//                                       return;
//                                     }
//                                     Navigator.pushNamed(
//                                       context,
//                                       BrandPage.routeName,
//                                       arguments: {
//                                         'markers': markers,
//                                         'polylines': polylines,
//                                       },
//                                     );
//                                     _clearSearch();
//                                   },
//                                   // onPressed: () {
//                                   //   final placesProvider =
//                                   //   context.read<PlacesProvider>();
//                                   //   final pickupLocation =
//                                   //       placesProvider.pickupLocation;
//                                   //   final dropLocation =
//                                   //       placesProvider.dropLocation;
//                                   //   final markerLocation =
//                                   //       placesProvider.markerLocation;
//                                   //   if (pickupLocation == markerLocation) {
//                                   //     if (dropLocation == null) {
//                                   //       ScaffoldMessenger.of(context)
//                                   //           .showSnackBar(
//                                   //         const SnackBar(
//                                   //           content: Text(
//                                   //               'Please select a drop location'),
//                                   //         ),
//                                   //       );
//                                   //       return;
//                                   //     }
//                                   //     Navigator.pushNamed(
//                                   //       context,
//                                   //       BrandPage.routeName,
//                                   //       arguments: {
//                                   //         'markers': markers,
//                                   //         'polylines': polylines,
//                                   //       },
//                                   //     );
//                                   //   } else {
//                                   //     ScaffoldMessenger.of(context)
//                                   //         .showSnackBar(
//                                   //       const SnackBar(
//                                   //         content: Text(''),
//                                   //       ),
//                                   //     );
//                                   //   }
//                                   //   if (pickupLocation == null) {
//                                   //     ScaffoldMessenger.of(context)
//                                   //         .showSnackBar(
//                                   //       const SnackBar(
//                                   //         content: Text(''),
//                                   //       ),
//                                   //     );
//                                   //     return;
//                                   //   }
//                                   //   Navigator.pushNamed(
//                                   //     context,
//                                   //     BrandPage.routeName,
//                                   //     arguments: {
//                                   //       'markers': markers,
//                                   //       'polylines': polylines,
//                                   //     },
//                                   //   );
//                                   //   if (dropLocation == null) {
//                                   //     ScaffoldMessenger.of(context)
//                                   //         .showSnackBar(
//                                   //       const SnackBar(
//                                   //         content: Text(
//                                   //             'Please select a drop location'),
//                                   //       ),
//                                   //     );
//                                   //     return;
//                                   //   }
//                                   //   Navigator.pushNamed(
//                                   //     context,
//                                   //     BrandPage.routeName,
//                                   //     arguments: {
//                                   //       'markers': markers,
//                                   //       'polylines': polylines,
//                                   //     },
//                                   //   );
//                                   //   _clearSearch();
//                                   // },
//                                   child: const Text(
//                                     'Continue',
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         drawer: Drawer(
//           child: Stack(
//             children: [
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 10, vertical: 60),
//                 child: Column(
//                   children: [
//                     Stack(
//                       children: [
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.pushNamed(
//                               context,
//                               ProfilePage.routeName,
//                               arguments: {
//                                 'firstname': firstname ?? '',
//                                 'email': email ?? '',
//                               },
//                             );
//                           },
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Image.asset(
//                                 'assets/images/user.png',
//                                 width: 60,
//                                 height: 60,
//                               ),
//                               SizedBox(
//                                   width:
//                                   10), // Adds spacing between image and text
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     firstname ?? '',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   SizedBox(height: 4.0),
//                                   Text(
//                                     email ?? '',
//                                     style: TextStyle(fontSize: 13),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const Divider(),
//                     Padding(
//                       padding: EdgeInsets.all(8),
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.of(context).pushNamed(RiderPage
//                               .routeName); // Handle ride history action
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Icon(Icons.account_circle, color: Colors.pink),
//                             SizedBox(width: 8.0),
//                             Text(
//                               'Book Your Ride',
//                               style: const TextStyle(
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.all(8),
//                       child: GestureDetector(
//                         onTap: () {},
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Icon(
//                               Icons.info,
//                               color: Colors.pink,
//                             ),
//                             SizedBox(width: 8.0),
//                             Text('Booking History'),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.all(8),
//                       child: GestureDetector(
//                         onTap: () {},
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Icon(Icons.contact_phone, color: Colors.pink),
//                             SizedBox(width: 8.0),
//                             Text('Notification&Offers'),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.all(8),
//                       child: GestureDetector(
//                         onTap: () {},
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Icon(Icons.share, color: Colors.pink),
//                             SizedBox(width: 8.0),
//                             Text('Payment Methods'),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.all(8),
//                       child: GestureDetector(
//                         onTap: () {},
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Icon(Icons.privacy_tip, color: Colors.pink),
//                             SizedBox(width: 8.0),
//                             Text('Help & Support'),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.all(8),
//                       child: GestureDetector(
//                         onTap: () {},
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Icon(Icons.article_outlined, color: Colors.pink),
//                             SizedBox(width: 8.0),
//                             Text('About'),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const Divider(), // Divider line added here
//                   ],
//                 ),
//               ),
//               Positioned(
//                 bottom: 10,
//                 right: 10,
//                 left: 10,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Text(
//                         'Version 1.1',
//                         textAlign: TextAlign.end,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildLocationContainer(BuildContext context, String label, IconData icon, String type, String? address) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _searchType = type;
//         });
//         _clearSearch();
//         _showLocationSearch(context, type);
//       },
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Icon(icon, color: Colors.green, size: 24.0),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               address ?? label,
//               style: const TextStyle(color: Colors.black),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           if (address != null)
//             IconButton(
//               icon: const Icon(Icons.clear, color: Colors.black),
//               onPressed: () {
//                 _clearSearch();
//                 if (type == 'pickup') {
//                   pickupAddress = null;
//                   context.read<PlacesProvider>().setPickupLocation(null, null);
//                 } else {
//                   dropAddress = null;
//                   context.read<PlacesProvider>().setDropLocation(null, null);
//                 }
//               },
//             ),
//         ],
//       ),
//     );
//   }
//   void _showLocationSearch(BuildContext context, String type) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.all(10),
//           height: 600,
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(1),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       type == 'pickup'
//                           ? 'Choose pickup location'
//                           : 'Choose drop location',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                         fontFamily: 'Arial',
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () {
//                         _clearSearch();
//                         Navigator.of(context).pop();
//                       },
//                       icon: const Icon(
//                         Icons.clear,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: Container(
//                   height: 50.0,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10.0),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Colors.black26,
//                         offset: Offset(0, 4),
//                         blurRadius: 10.0,
//                       ),
//                     ],
//                   ),
//                   child: TextField(
//                     controller: searchController,
//                     decoration: const InputDecoration(
//                       hintText: 'Search the location...',
//                       border: InputBorder.none,
//                       contentPadding:
//                       EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                     ),
//                     onSubmitted: (query) {
//                       _searchLocation(query, type); // Handle location search
//                     },
//                   ),
//                 ),
//               ),
//               // Flexible(
//               //   child: Consumer<PlacesProvider>(
//               //     builder: (context, placesProvider, child) {
//               //       if (searchController.text.isNotEmpty &&
//               //           placesProvider.placeSuggestions.isNotEmpty) {
//               //         return ListView.builder(
//               //           itemCount: placesProvider.placeSuggestions.length,
//               //           itemBuilder: (context, index) {
//               //             return ListTile(
//               //               title: Text(placesProvider.placeSuggestions[index]
//               //                   ['description']),
//               //               onTap: () async {
//               //                 final details =
//               //                     await placesProvider.getPlaceDetails(
//               //                         placesProvider.placeSuggestions[index]
//               //                             ['place_id']);
//               //                 final latLng = details['latLng']!.split(',');
//               //                 final location = LatLng(double.parse(latLng[0]),
//               //                     double.parse(latLng[1]));
//               //                 if (_searchType == 'pickup') {
//               //                   placesProvider.setPickupLocation(
//               //                       location, details['address']);
//               //                 } else if (_markerType == 'marker') {
//               //                   placesProvider.setMarkerLocation(
//               //                       location, details['address']);
//               //                 } else {
//               //                   placesProvider.setPickupLocation(
//               //                       location, details['address']);
//               //                 }
//               //                 Navigator.pop(context);
//               //                 _getPolyline();
//               //               },
//               //             );
//               //           },
//               //         );
//               //       } else if (searchController.text.isEmpty) {
//               //         return SingleChildScrollView(
//               //           child: Column(
//               //             children: [
//               //               const SizedBox(height: 20),
//               //               Padding(
//               //                 padding:
//               //                     const EdgeInsets.symmetric(vertical: 8.0),
//               //                 child: Row(
//               //                   children: [
//               //                     Expanded(
//               //                       child: GestureDetector(
//               //                         onTap: () async {
//               //                           Navigator.of(context).pushNamed(
//               //                             MapScreen.routeName,
//               //                             arguments: 'pickup',
//               //                           );
//               //                           _getPolyline();
//               //                         },
//               //                         child: Container(
//               //                           height: 60,
//               //                           child: Card(
//               //                             shape: RoundedRectangleBorder(
//               //                               side: const BorderSide(
//               //                                   color: Colors.grey),
//               //                               borderRadius:
//               //                                   BorderRadius.circular(25),
//               //                             ),
//               //                             child: const Padding(
//               //                               padding: EdgeInsets.all(8.0),
//               //                               child: Row(
//               //                                 children: [
//               //                                   Icon(Icons.location_pin,
//               //                                       color: Colors.pink),
//               //                                   SizedBox(width: 8),
//               //                                   Text(
//               //                                     'Choose on map',
//               //                                     style: TextStyle(
//               //                                       fontSize: 18,
//               //                                       fontWeight: FontWeight.bold,
//               //                                       color: Colors.black,
//               //                                       fontFamily: 'Arial',
//               //                                     ),
//               //                                   ),
//               //                                 ],
//               //                               ),
//               //                             ),
//               //                           ),
//               //                         ),
//               //                       ),
//               //                     ),
//               //                   ],
//               //                 ),
//               //               ),
//               //             ],
//               //           ),
//               //         );
//               //       } else {
//               //         return Container(); // Hide suggestions when there's no text or no suggestions
//               //       }
//               //     },
//               //   ),
//               // ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//   void _searchLocation(String query, String type) async {
//     String? pickupLocation;
//     String? dropLocation;
//     pickupLocation = await performLocationSearch(query);
//     dropLocation = await performLocationSearch(query);
//     setState(() {
//       if (type == 'pickup') {
//         pickupAddress = pickupLocation;
//       } else if (type == 'drop') {
//         dropAddress = pickupLocation;
//       }
//     });
//     setState(() {
//       if (type == 'drop') {
//         dropAddress = dropLocation;
//       } else if (type == 'pickup') {
//         pickupAddress = dropLocation;
//       }
//     });
//     Navigator.of(context).pop();
//   }
//
//   // Widget buildPickupContainer(BuildContext context, String label, IconData icon, String? address, String type) {
//   //   return GestureDetector(
//   //     onTap: () {
//   //       setState(() {
//   //         _searchType = type;
//   //       });
//   //       _clearSearch();
//   //       _showPickupLocationSearch(context);
//   //     },
//   //     child: Row(
//   //       mainAxisAlignment: MainAxisAlignment.start,
//   //       children: [
//   //         Icon(icon, color: Colors.green, size: 24.0),
//   //         const SizedBox(width: 8),
//   //         Expanded(
//   //           child: Text(
//   //             address ?? '91,civil Aerodrome Past,Opp,CMC,Dr,Jaganathan...',
//   //             // Show 'Pickup at...' if address is null
//   //             style: const TextStyle(color: Colors.black),
//   //             overflow: TextOverflow.ellipsis, // Handle long text
//   //           ),
//   //         ),
//   //         if (address != null)
//   //           IconButton(
//   //             icon: const Icon(Icons.clear, color: Colors.black),
//   //             onPressed: () {
//   //               _clearSearch();
//   //               if (type == 'pickup') {
//   //                 context.read<PlacesProvider>().setPickupLocation(null, null);
//   //               } else {
//   //                 context.read<PlacesProvider>().setDropLocation(
//   //                     null, null); // Assuming this should be for drop
//   //               }
//   //             },
//   //           ),
//   //       ],
//   //     ),
//   //   );
//   // }
//   // void _showPickupLocationSearch(BuildContext context) {
//   //   showModalBottomSheet(
//   //     context: context,
//   //     isScrollControlled: true,
//   //     builder: (context) {
//   //       return Container(
//   //         padding: const EdgeInsets.all(10),
//   //         height: 600,
//   //         child: Column(
//   //           children: [
//   //             Padding(
//   //               padding: EdgeInsets.all(1),
//   //               child: Row(
//   //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                 children: [
//   //                   Text(
//   //                     'Choose rider pickup location',
//   //                     style: TextStyle(
//   //                       fontSize: 18,
//   //                       fontWeight: FontWeight.bold,
//   //                       color: Colors.black,
//   //                       fontFamily: 'Arial',
//   //                     ),
//   //                   ),
//   //                   IconButton(
//   //                     onPressed: () {
//   //                       _clearSearch();
//   //                       Navigator.of(context).pop();
//   //                     },
//   //                     icon: const Icon(
//   //                       Icons.clear,
//   //                       color: Colors.black,
//   //                     ),
//   //                   ),
//   //                 ],
//   //               ),
//   //             ),
//   //             const SizedBox(height: 10),
//   //             Padding(
//   //               padding: const EdgeInsets.symmetric(vertical: 8.0),
//   //               child: Container(
//   //                 height: 50.0,
//   //                 decoration: BoxDecoration(
//   //                   color: Colors.white,
//   //                   borderRadius: BorderRadius.circular(10.0),
//   //                   boxShadow: const [
//   //                     BoxShadow(
//   //                       color: Colors.black26,
//   //                       offset: Offset(0, 4),
//   //                       blurRadius: 10.0,
//   //                     ),
//   //                   ],
//   //                 ),
//   //                 child: TextField(
//   //                   controller: searchController,
//   //                   decoration: InputDecoration(
//   //                     hintText: 'Search the location...',
//   //                     border: InputBorder.none,
//   //                     contentPadding: const EdgeInsets.symmetric(
//   //                         horizontal: 10, vertical: 10),
//   //                     suffixIcon: searchController.text.isNotEmpty
//   //                         ? IconButton(
//   //                       icon: const Icon(Icons.clear),
//   //                       onPressed: () {
//   //                         _clearSearch();
//   //                       },
//   //                     )
//   //                         : const Icon(Icons.search),
//   //                   ),
//   //                   onChanged: (value) {
//   //                     if (value.isNotEmpty) {
//   //                       Provider.of<PlacesProvider>(context, listen: false)
//   //                           .getPlaceSuggestions(value);
//   //                     }
//   //                     if (value.isNotEmpty) {
//   //                       Provider.of<PlacesProvider>(context, listen: false)
//   //                           .getMarkerPlaceSuggestions(value);
//   //                     } else {
//   //                       Provider.of<PlacesProvider>(context, listen: false)
//   //                           .clearPlaceSuggestions();
//   //                     }
//   //                   },
//   //                 ),
//   //               ),
//   //             ),
//   //             Flexible(
//   //               child: Consumer<PlacesProvider>(
//   //                 builder: (context, placesProvider, child) {
//   //                   if (searchController.text.isNotEmpty &&
//   //                       placesProvider.placeSuggestions.isNotEmpty) {
//   //                     return ListView.builder(
//   //                       itemCount: placesProvider.placeSuggestions.length,
//   //                       itemBuilder: (context, index) {
//   //                         return ListTile(
//   //                           title: Text(placesProvider.placeSuggestions[index]
//   //                           ['description']),
//   //                           onTap: () async {
//   //                             final details =
//   //                             await placesProvider.getPlaceDetails(
//   //                                 placesProvider.placeSuggestions[index]
//   //                                 ['place_id']);
//   //                             final latLng = details['latLng']!.split(',');
//   //                             final location = LatLng(double.parse(latLng[0]),
//   //                                 double.parse(latLng[1]));
//   //                             if (_searchType == 'pickup') {
//   //                               placesProvider.setPickupLocation(
//   //                                   location, details['address']);
//   //                             } else if (_markerType == 'marker') {
//   //                               placesProvider.setMarkerLocation(
//   //                                   location, details['address']);
//   //                             } else {
//   //                               placesProvider.setPickupLocation(
//   //                                   location, details['address']);
//   //                             }
//   //                             Navigator.pop(context);
//   //                             _getPolyline();
//   //                           },
//   //                         );
//   //                       },
//   //                     );
//   //                   } else if (searchController.text.isEmpty) {
//   //                     return SingleChildScrollView(
//   //                       child: Column(
//   //                         children: [
//   //                           const SizedBox(height: 20),
//   //                           Padding(
//   //                             padding:
//   //                             const EdgeInsets.symmetric(vertical: 8.0),
//   //                             child: Row(
//   //                               children: [
//   //                                 Expanded(
//   //                                   child: GestureDetector(
//   //                                     onTap: () async {
//   //                                       Navigator.of(context).pushNamed(
//   //                                         MapScreen.routeName,
//   //                                         arguments: 'pickup',
//   //                                       );
//   //                                       _getPolyline();
//   //                                     },
//   //                                     child: Container(
//   //                                       height: 60,
//   //                                       child: Card(
//   //                                         shape: RoundedRectangleBorder(
//   //                                           side: const BorderSide(
//   //                                               color: Colors.grey),
//   //                                           borderRadius:
//   //                                           BorderRadius.circular(25),
//   //                                         ),
//   //                                         child: const Padding(
//   //                                           padding: EdgeInsets.all(8.0),
//   //                                           child: Row(
//   //                                             children: [
//   //                                               Icon(Icons.location_pin,
//   //                                                   color: Colors.pink),
//   //                                               SizedBox(width: 8),
//   //                                               Text(
//   //                                                 'Choose on map',
//   //                                                 style: TextStyle(
//   //                                                   fontSize: 18,
//   //                                                   fontWeight: FontWeight.bold,
//   //                                                   color: Colors.black,
//   //                                                   fontFamily: 'Arial',
//   //                                                 ),
//   //                                               ),
//   //                                             ],
//   //                                           ),
//   //                                         ),
//   //                                       ),
//   //                                     ),
//   //                                   ),
//   //                                 ),
//   //                               ],
//   //                             ),
//   //                           ),
//   //                         ],
//   //                       ),
//   //                     );
//   //                   } else {
//   //                     return Container(); // Hide suggestions when there's no text or no suggestions
//   //                   }
//   //                 },
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //       );
//   //     },
//   //   );
//   // }
//   Widget buildDropContainer(BuildContext context, String label, IconData icon, String? address, String type) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _clearSearch();
//           _searchDropType = type;
//         });
//         _clearSearch();
//         _showDropLocationSearch(context, 'drop');
//       },
//       child: Container(
//         padding: EdgeInsets.all(1),
//         child: Column(
//           children: [
//             const SizedBox(height: 1),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Icon(icon, color: Colors.red, size: 24.0),
//                 const SizedBox(width: 1), // Changed from height to width
//                 Expanded(
//                   child: Text(
//                     address ?? label,
//                     style: const TextStyle(color: Colors.black),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 if (address != null)
//                   IconButton(
//                     icon: const Icon(Icons.clear, color: Colors.black),
//                     onPressed: () {
//                       _clearSearch();
//                       dropAddress = null;
//                       context
//                           .read<PlacesProvider>()
//                           .setDropLocation(null, null);
//                     },
//                   ),
//               ],
//             ),
//             Row(
//               children: [
//                 const SizedBox(width: 20),
//                 Expanded(
//                   child: CustomPaint(
//                     size: const Size(double.infinity, 2),
//                     painter: ThirdPainter(horizontal: true),
//                   ),
//                 ),
//               ],
//             ),
//             if (address != null)
//               Padding(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
//                 child: Consumer<PlacesProvider>(
//                   builder: (context, placesProvider, child) {
//                     final LatLng? pickupLocation =
//                         placesProvider.pickupLocation;
//                     final LatLng? dropLocation = placesProvider.dropLocation;
//                     if (pickupLocation != null && dropLocation != null) {
//                       return FutureBuilder<Map<String, String>>(
//                         future: placesProvider.getDirections(
//                             pickupLocation, dropLocation, markerLocation),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.done) {
//                             if (snapshot.hasData) {
//                               final data = snapshot.data!;
//                               return Text(
//                                 'Distance: ${data['distance']}, Duration: ${data['duration']}',
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.pink,
//                                 ),
//                               );
//                             } else if (snapshot.hasError) {
//                               return const Text(
//                                 'Error fetching data',
//                                 style: TextStyle(color: Colors.red),
//                               );
//                             }
//                           }
//                           return const SizedBox.shrink();
//                         },
//                       );
//                     } else if (dropLocation != null && markerLocation != null) {
//                       return FutureBuilder<Map<String, String>>(
//                         future: placesProvider.getDirections(
//                             dropLocation, markerLocation, dropLocation),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.done) {
//                             if (snapshot.hasData) {
//                               final data = snapshot.data!;
//                               return Text(
//                                 'Distance: ${data['distance']}, Duration: ${data['duration']}',
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.pink,
//                                 ),
//                               );
//                             } else if (snapshot.hasError) {
//                               return const Text(
//                                 'Error fetching data',
//                                 style: TextStyle(color: Colors.red),
//                               );
//                             }
//                           }
//                           return const SizedBox.shrink();
//                         },
//                       );
//                     } else {
//                       return const SizedBox.shrink();
//                     }
//                   },
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//   void _showDropLocationSearch(BuildContext context, String type) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.all(10),
//           height: 600,
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Choose rider drop location',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                         fontFamily: 'Arial',
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       icon: const Icon(
//                         Icons.clear,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: Container(
//                   height: 50.0,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10.0),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Colors.black26,
//                         offset: Offset(0, 4),
//                         blurRadius: 10.0,
//                       ),
//                     ],
//                   ),
//                   child: TextField(
//                     controller: searchController,
//                     decoration: const InputDecoration(
//                       hintText: 'Search the location...',
//                       border: InputBorder.none,
//                       contentPadding:
//                       EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                     ),
//                     onSubmitted: (query) {
//                       _searchLocation(query, type); // Handle location search
//                     },
//                   ),
//                   // TextField(
//                   //   controller: _DropController,
//                   //   decoration: InputDecoration(
//                   //     hintText: 'Search the location...',
//                   //     border: InputBorder.none,
//                   //     contentPadding: const EdgeInsets.symmetric(
//                   //         horizontal: 15.0, vertical: 15.0),
//                   //     suffixIcon: _DropController.text.isNotEmpty
//                   //         ? IconButton(
//                   //             icon: const Icon(Icons.clear),
//                   //             onPressed: () {
//                   //               _DropController.clear();
//                   //               Provider.of<PlacesProvider>(context,
//                   //                       listen: false)
//                   //                   .clearPlaceSuggestions();
//                   //             },
//                   //           )
//                   //         : const Icon(Icons.search),
//                   //   ),
//                   //   onChanged: (value) {
//                   //     final text = _DropController.text;
//                   //     if (text.isNotEmpty) {
//                   //       Provider.of<PlacesProvider>(context, listen: false)
//                   //           .getDropPlaceSuggestions(value);
//                   //     }
//                   //   },
//                   // ),
//                 ),
//               ),
//               Flexible(
//                 child: Consumer<PlacesProvider>(
//                   builder: (context, placesProvider, child) {
//                     if (_DropController.text.isNotEmpty &&
//                         placesProvider.dropSuggestions.isNotEmpty) {
//                       return ListView.builder(
//                         itemCount: placesProvider.dropSuggestions.length,
//                         itemBuilder: (context, index) {
//                           return ListTile(
//                             title: Text(placesProvider.dropSuggestions[index]
//                             ['description']),
//                             onTap: () async {
//                               final details =
//                               await placesProvider.getDropPlaceDetails(
//                                   placesProvider.dropSuggestions[index]
//                                   ['place_id']);
//                               final latLng = details['latLng']!.split(',');
//                               final location = LatLng(double.parse(latLng[0]),
//                                   double.parse(latLng[1]));
//                               if (_searchDropType == 'drop') {
//                                 placesProvider.setDropLocation(
//                                     location, details['address']);
//                               } else if (_markerType == 'marker') {
//                                 placesProvider.setMarkerLocation(
//                                     location, details['address']);
//                               } else {
//                                 placesProvider.setDropLocation(
//                                     location, details['address']);
//                               }
//                               Navigator.pop(context);
//                               _getPolyline();
//                             },
//                           );
//                         },
//                       );
//                     } else if (_DropController.text.isEmpty) {
//                       return SingleChildScrollView(
//                         child: Column(
//                           children: [
//                             const SizedBox(height: 20),
//                             Padding(
//                               padding:
//                               const EdgeInsets.symmetric(vertical: 8.0),
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     child: GestureDetector(
//                                       onTap: () async {
//                                         // print('drop Map$type');
//                                         Navigator.of(context).pushNamed(
//                                           MapScreen.routeName,
//                                           arguments: 'drop',
//                                         );
//                                         _getPolyline();
//                                       },
//                                       child: Container(
//                                         height: 60,
//                                         child: Card(
//                                           shape: RoundedRectangleBorder(
//                                             side: const BorderSide(
//                                                 color: Colors.grey),
//                                             borderRadius:
//                                             BorderRadius.circular(25),
//                                           ),
//                                           child: const Padding(
//                                             padding: EdgeInsets.all(8.0),
//                                             child: Row(
//                                               children: [
//                                                 Icon(Icons.location_pin,
//                                                     color: Colors.pink),
//                                                 SizedBox(width: 8),
//                                                 Text(
//                                                   'Choose on map',
//                                                   style: TextStyle(
//                                                     fontSize: 18,
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.black,
//                                                     fontFamily: 'Arial',
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     } else {
//                       return Container(); // Hide suggestions when there's no text or no suggestions
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//   Future<void> _createMarkers() async {
//     final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
//     final markers = <Marker>{};
//     if (placesProvider.pickupLocation != null) {
//       final pickupMarker = Marker(
//         markerId: const MarkerId('pickup'),
//         position: placesProvider.pickupLocation!,
//         infoWindow: InfoWindow(
//           title: 'Pickup Location',
//           // snippet: placesProvider.pickupAddress ?? '',
//           snippet: pickupAddress ?? '',
//         ),
//         icon: await BitmapDescriptor.fromAssetImage(
//           const ImageConfiguration(size: Size(48, 48)),
//           'assets/icon/red.png',
//         ),
//       );
//       mapLevelController?.animateCamera(
//         CameraUpdate.newLatLngZoom(
//             placesProvider.pickupLocation!, 13), // Adjust padding as needed
//       );
//       markers.add(pickupMarker);
//     }
//     if (placesProvider.dropLocation != null) {
//       final dropMarker = Marker(
//         markerId: const MarkerId('drop'),
//         position: placesProvider.dropLocation!,
//         infoWindow: InfoWindow(
//           title: 'Drop Location',
//           // snippet: placesProvider.dropAddress ?? '',
//           snippet: dropAddress ?? '',
//         ),
//         icon: await BitmapDescriptor.fromAssetImage(
//           const ImageConfiguration(size: Size(48, 48)),
//           'assets/icon/green.png',
//         ),
//       );
//       mapMarkerController?.animateCamera(
//         CameraUpdate.newLatLngZoom(
//             placesProvider.dropLocation!, 13), // Adjust padding as needed
//       );
//       markers.add(dropMarker);
//     }
//     if (placesProvider.pickupLocation == null &&
//         placesProvider.dropLocation != null &&
//         markerLocation != null) {
//       final currentLocationMarker = Marker(
//         markerId: const MarkerId('currentLocation'),
//         position: markerLocation,
//         infoWindow: const InfoWindow(
//           title: 'Current Location',
//         ),
//         icon: await BitmapDescriptor.fromAssetImage(
//           const ImageConfiguration(size: Size(48, 48)),
//           'assets/icon/red.png',
//         ),
//       );
//       mapLevelController?.animateCamera(
//         CameraUpdate.newLatLngZoom(
//             placesProvider.markerLocation!, 13), // Adjust padding as needed
//       );
//       markers.add(currentLocationMarker);
//     }
//     setState(() {
//       this.markers.clear(); // Clear existing markers
//       this.markers.addAll(markers); // Add the new set of markers
//     });
//   }
//   void _addPolyLine() {
//     PolylineId id = const PolylineId("poly");
//     int pointCount = (_animationValue * polylineCoordinates.length).round();
//     List<LatLng> animatedPoints = polylineCoordinates.take(pointCount).toList();
//     Polyline polyline = Polyline(
//       polylineId: id,
//       color: Colors.black,
//       points: animatedPoints,
//       width: 2,
//     );
//     setState(() {
//       polylines.add(polyline);
//     });
//     _createMarkers();
//     _animationController.forward(from: 0); // Start from 0 for the animation
//   }
//   Future<void> _getPolyline() async {
//     final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
//     final pickupLocation = placesProvider.pickupLocation ?? markerLocation;
//     if (placesProvider.dropLocation != null) {
//       PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//         googleApiKey: googleApiKey,
//         request: PolylineRequest(
//           origin: PointLatLng(
//             pickupLocation.latitude,
//             pickupLocation.longitude,
//           ),
//           destination: PointLatLng(
//             placesProvider.dropLocation!.latitude,
//             placesProvider.dropLocation!.longitude,
//           ),
//           mode: TravelMode.driving,
//         ),
//       );
//       if (result.points.isNotEmpty) {
//         setState(() {
//           polylineCoordinates.clear();
//           result.points.forEach((PointLatLng point) {
//             polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//           });
//         });
//         _addPolyLine();
//       }
//     }
//   }
// }
//
// class DottedLinePainter extends CustomPainter {
//   final bool isHorizontal;
//
//   DottedLinePainter({this.isHorizontal = true});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = Colors.black
//       ..strokeWidth = 1
//       ..style = PaintingStyle.stroke;
//
//     double dashWidth = 4, dashSpace = 4, startX = 0, startY = 0;
//     if (isHorizontal) {
//       while (startX < size.width) {
//         canvas.drawLine(
//             Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
//         startX += dashWidth + dashSpace;
//       }
//     } else {
//       while (startY < size.height) {
//         canvas.drawLine(
//             Offset(0, startY), Offset(0, startY + dashWidth), paint);
//         startY += dashWidth + dashSpace;
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return false;
//   }
// }
//
// class DottedPainter extends CustomPainter {
//   final bool Horizontal;
//
//   DottedPainter({this.Horizontal = true});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = Colors.pink
//       ..strokeWidth = 1
//       ..style = PaintingStyle.stroke;
//
//     double dashWidth = 4, dashSpace = 4, startX = 0, startY = 0;
//     if (Horizontal) {
//       while (startX < size.width) {
//         canvas.drawLine(
//             Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
//         startX += dashWidth + dashSpace;
//       }
//     } else {
//       while (startY < size.height) {
//         canvas.drawLine(
//             Offset(0, startY), Offset(0, startY + dashWidth), paint);
//         startY += dashWidth + dashSpace;
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return false;
//   }
// }
//
// class ThirdPainter extends CustomPainter {
//   final bool horizontal;
//
//   ThirdPainter({this.horizontal = true});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = Colors.pink
//       ..strokeWidth = 1
//       ..style = PaintingStyle.stroke;
//
//     double dashWidth = 4, dashSpace = 4, startX = 0, startY = 0;
//     if (horizontal) {
//       while (startX < size.width) {
//         canvas.drawLine(
//             Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
//         startX += dashWidth + dashSpace;
//       }
//     } else {
//       while (startY < size.height) {
//         canvas.drawLine(
//             Offset(0, startY), Offset(0, startY + dashWidth), paint);
//         startY += dashWidth + dashSpace;
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return false;
//   }
// }