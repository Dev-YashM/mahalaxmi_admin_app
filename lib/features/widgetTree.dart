import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({
    super.key,
    required this.title,
    required this.mobileNumber,
  });

  final String title;
  final String mobileNumber;

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  int selectedIndex = 0;

  late List<Widget> features;

  @override
  void initState() {
    super.initState();

    features = [
      // const HomeScreen(),
      // ProfileScreen(mobileNumber: widget.mobileNumber),
    ];
  }

  void navigateToIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,

      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(
          color: AppColors.surface,
        ),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [

            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/darkLogo.png', height: 60, width: 60),
                  const SizedBox(height: 10),
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.mobileNumber,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () => navigateToIndex(0),
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("My Profile"),
              onTap: () => navigateToIndex(1),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text("My Cart"),
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen(),));
              },
            ),

            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text("My Orders"),
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context) => MyOrdersScreen(),)
                // );
              },
            ),

            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text("Wishlist"),
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context) => WishlistScreen(),));
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.contact_support_sharp),
              title: const Text("Contact Us"),
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context) => ContactUsScreen(),));
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red,),
              title: const Text("Logout", style: TextStyle(color: Colors.red),),
              onTap: () {
                // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SplashScreen(),));
              },
            ),
          ],
        ),
      ),

      body: features[selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        indicatorColor: Theme.of(context).colorScheme.primary,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}