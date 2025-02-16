import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kitchen_copilot_app/screens/preference_config_screen.dart';
import '../constants.dart';
import '../widgets/feed_tab.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});
  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _showMap = false;

  // Adjustable heights for the search box and preference buttons
  final double searchBoxHeight = 50.0;
  final double preferenceButtonsHeight = 50.0;

  // Example preference list
  final List<String> preferences = ['Vegan', 'Halal', 'Dating', 'Local'];

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        if (_tabController.index != 2 && _showMap) {
          setState(() {
            _showMap = false;
          });
        } else {
          setState(() {}); // refresh for other changes
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Dummy function to create markers from posts.
  // In your actual app, loop through your posts (which include GPS coordinates)
  // to generate markers.
  Set<Marker> _createMarkers() {
    return {
      const Marker(
        markerId: MarkerId('1'),
        position: LatLng(1.3850327554469075, 103.96662908099094),
        infoWindow: InfoWindow(title: 'Post 1'),
      ),
      const Marker(
        markerId: MarkerId('2'),
        position: LatLng(1.3232510015632135, 103.80979258466508),
        infoWindow: InfoWindow(title: 'Post 2'),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight * 2.484),
        child: AppBar(
          backgroundColor: kPrimaryColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Center(
                    child: Text(
                      'COMMUNITY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        fontFamily: kFontFamily,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chat, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.notifications, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        // Navigate to PreferenceConfigScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => const PreferenceConfigScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 35,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TabBar(
                      controller: _tabController,
                      indicator: const BoxDecoration(color: Colors.white),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: kPrimaryColor,
                      unselectedLabelColor: Colors.white,
                      unselectedLabelStyle:
                          const TextStyle(fontWeight: FontWeight.w900),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w900),
                      tabs: const [
                        Tab(text: 'FOLLOW'),
                        Tab(text: 'EXPLORE'),
                        Tab(text: 'NEARBY'),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              color: Colors.white,
              child: TabBarView(
                controller: _tabController,
                children: [
                  const FeedTab(feedCategory: 'Follow'),
                  const FeedTab(feedCategory: 'Explore'),
                  _showMap
                      ? MapView(
                          searchBoxHeight: searchBoxHeight,
                          preferenceButtonsHeight: preferenceButtonsHeight,
                          preferences: preferences,
                          markers: _createMarkers(),
                          onExitMap: () {
                            setState(() {
                              _showMap = false;
                            });
                          },
                        )
                      : const FeedTab(feedCategory: 'community'),
                ],
              ),
            ),
          ),
          // Show MAP button only on the "NEARBY" tab
          if (_tabController.index == 2)
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: 35,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(135, 0, 0, 0),
                      side: const BorderSide(color: Colors.white),
                    ),
                    onPressed: () {
                      setState(() {
                        _showMap = true;
                      });
                    },
                    child: const Text(
                      'MAP',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MapView extends StatelessWidget {
  final double searchBoxHeight;
  final double preferenceButtonsHeight;
  final List<String> preferences;
  final Set<Marker> markers;
  final VoidCallback onExitMap;

  const MapView({
    super.key,
    required this.searchBoxHeight,
    required this.preferenceButtonsHeight,
    required this.preferences,
    required this.markers,
    required this.onExitMap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top section: Search box and preference buttons
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              // Search Box with Exit Button
              Container(
                height: searchBoxHeight,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search location...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onExitMap,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Horizontally scrollable preference buttons
              SizedBox(
                height: preferenceButtonsHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: preferences.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: OutlinedButton(
                        onPressed: () {
                          // Handle preference selection
                        },
                        child: Text(preferences[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Expanded section: Google Map
        Expanded(
          child: GoogleMap(
            onMapCreated: (GoogleMapController controller) {},
            mapType: MapType.normal,
            initialCameraPosition: const CameraPosition(
              target: LatLng(1.3521, 103.8198),
              zoom: 7,
            ),
            markers: markers,
          ),
        ),
      ],
    );
  }
}
