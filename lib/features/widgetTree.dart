import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  final String baseUrl = "https://ecombackend-1-j6ov.onrender.com";

  List<dynamic> users = [];
  List<dynamic> bookings = [];

  bool isLoadingUsers = false;
  bool isLoadingBookings = false;

  @override
  void initState() {
    super.initState();
    fetchUsers();
    fetchBookings();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoadingUsers = true);

    try {
      final response =
      await http.get(Uri.parse("$baseUrl/api/users/all"));

      if (response.statusCode == 200) {
        setState(() {
          users = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Users Fetch Error: $e");
    }

    setState(() => isLoadingUsers = false);
  }

  Future<void> fetchBookings() async {
    setState(() => isLoadingBookings = true);

    try {
      final response =
      await http.get(Uri.parse("$baseUrl/api/bookings/all"));

      if (response.statusCode == 200) {
        setState(() {
          bookings = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Bookings Fetch Error: $e");
    }

    setState(() => isLoadingBookings = false);
  }

  Future<void> updateOrderStatus(String bookingId, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/api/bookings/update-status/$bookingId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "orderStatus": newStatus,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Order status updated successfully"),
            backgroundColor: Colors.green,
          ),
        );
        fetchBookings();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update status"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Server error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,

      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primary,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.surface,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.surface),
      ),

      body: _getSelectedScreen(),

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        indicatorColor: AppColors.accent,
        backgroundColor: AppColors.surface,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.people), label: 'Users'),
          NavigationDestination(
              icon: Icon(Icons.book_online), label: 'Bookings'),
        ],
      ),
    );
  }

  Widget _getSelectedScreen() {
    switch (selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildUsers();
      case 2:
        return _buildBookings();
      default:
        return const SizedBox();
    }
  }

  //DASHBOARD
  Widget _dashboardCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    int totalUsers = users.length;
    int totalBookings = bookings.length;

    int confirmedBookings = bookings
        .where((b) => b["orderStatus"] == "CONFIRMED")
        .length;

    int deliveredBookings = bookings
        .where((b) => b["orderStatus"] == "DELIVERED")
        .length;

    int totalRevenue = bookings
        .where((b) => b["paymentStatus"] == "SUCCESS")
        .fold(0, (sum, item) => sum + (item["price"] as int? ?? 0));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              Image.asset('assets/images/lightLogo.png', height: 60,),

              const SizedBox(width: 5),

              Column(
                children: [
                  const Text(
                    "Admin Dashboard",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 1),

                  const Text(
                    "Overview of your system",
                    style: TextStyle(color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _dashboardCard("Users", totalUsers.toString(), Icons.people, Colors.blue),
              _dashboardCard("Bookings", totalBookings.toString(), Icons.book_online, Colors.orange),
              _dashboardCard("Delivered", deliveredBookings.toString(), Icons.local_shipping, Colors.green),
              _dashboardCard("Revenue", "₹ $totalRevenue", Icons.currency_rupee, Colors.purple),
            ],
          ),

          const SizedBox(height: 30),

          const Text(
            "Recent Bookings",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 12),

          ...bookings.take(3).map((booking) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  )
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.book_online, color: AppColors.secondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking["coolerTitle"] ?? "",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          booking["mobile"] ?? "",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(booking["orderStatus"]),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  //USERS
  Widget _infoRow(IconData icon, String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87),
                children: [
                  TextSpan(
                    text: "$title: ",
                    style: const TextStyle(
                        fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: value ?? "-"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsers() {
    if (isLoadingUsers) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (users.isEmpty) {
      return const Center(
        child: Text(
          "No Users Found",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final address = user["address"] ?? {};

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: ExpansionTile(
            tilePadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            childrenPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                (user["username"] ?? "U")[0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              user["username"] ?? "No Name",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(user["mobileNumber"] ?? ""),
            trailing: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: user["profileComplete"] == true
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user["profileComplete"] == true
                    ? "Complete"
                    : "Incomplete",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: user["profileComplete"] == true
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ),
            children: [

              _infoRow(Icons.badge, "User ID", user["id"]),
              _infoRow(Icons.phone, "Mobile", user["mobileNumber"]),
              _infoRow(Icons.lock, "PIN", user["pin"]),

              const Divider(height: 25),

              const Text(
                "Address",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),

              _infoRow(Icons.home, "Plot / Area",
                  "${address["plotNo"] ?? ""}, ${address["laneArea"] ?? ""}"),
              _infoRow(Icons.location_city, "City",
                  address["city"] ?? ""),
              _infoRow(Icons.map, "State",
                  address["state"] ?? ""),
              _infoRow(Icons.pin_drop, "Pin Code",
                  address["pinCode"] ?? ""),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

// BOOKINGS

  Widget _statusBadge(String? status) {
    Color bgColor = Colors.grey.withOpacity(0.1);
    Color textColor = Colors.grey;

    if (status == "CONFIRMED") {
      bgColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green;
    } else if (status == "PENDING") {
      bgColor = Colors.orange.withOpacity(0.1);
      textColor = Colors.orange;
    } else if (status == "DELIVERED") {
      bgColor = Colors.blue.withOpacity(0.1);
      textColor = Colors.blue;
    } else if (status == "CANCELLED") {
      bgColor = Colors.red.withOpacity(0.1);
      textColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status ?? "UNKNOWN",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildBookings() {
    if (isLoadingBookings) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (bookings.isEmpty) {
      return const Center(
        child: Text(
          "No Bookings Found",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        String selectedStatus = booking["orderStatus"] ?? "PENDING";

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: ExpansionTile(
            tilePadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            childrenPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: CircleAvatar(
              backgroundColor: AppColors.secondary,
              child: const Icon(Icons.book_online, color: Colors.white),
            ),
            title: Text(
              booking["coolerTitle"] ?? "No Title",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text("Mobile: ${booking["mobile"] ?? ""}"),
            trailing: _statusBadge(booking["orderStatus"]),
            children: [

              _infoRow(Icons.badge, "Booking ID", booking["id"]),
              _infoRow(Icons.phone, "Mobile", booking["mobile"]),
              _infoRow(Icons.calendar_month, "Rental Duration",
                  booking["rentalDuration"]),
              _infoRow(Icons.currency_rupee, "Price",
                  "₹ ${booking["price"] ?? 0}"),
              _infoRow(Icons.access_time, "Booked At",
                  booking["bookedAt"]),

              const Divider(height: 25),

              const Text(
                "Payment Details",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),

              _infoRow(Icons.receipt_long, "Razorpay Order ID",
                  booking["razorpayOrderId"]),
              _infoRow(Icons.payment, "Payment ID",
                  booking["razorpayPaymentId"]),
              _infoRow(Icons.verified, "Signature",
                  booking["razorpaySignature"]),
              _infoRow(Icons.check_circle, "Payment Status",
                  booking["paymentStatus"]),

              const SizedBox(height: 20),
              const Divider(),

              const Text(
                "Update Order Status",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 10),

              StatefulBuilder(
                builder: (context, setInnerState) {
                  return Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: "PENDING", child: Text("PENDING")),
                            DropdownMenuItem(
                                value: "CONFIRMED", child: Text("CONFIRMED")),
                            DropdownMenuItem(
                                value: "IN_TRANSIT", child: Text("IN-TRANSIT")),
                            DropdownMenuItem(
                                value: "DELIVERED", child: Text("DELIVERED")),
                            DropdownMenuItem(
                                value: "CANCELLED", child: Text("CANCELLED")),
                          ],
                          onChanged: (value) {
                            setInnerState(() {
                              selectedStatus = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          updateOrderStatus(
                              booking["id"], selectedStatus);
                        },
                        child: const Text(
                          "Update",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}