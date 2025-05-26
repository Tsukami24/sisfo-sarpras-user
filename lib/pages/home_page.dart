import 'package:flutter/material.dart';
import 'package:sisfo_sarpras_users/Service/auth_service.dart';
import 'package:sisfo_sarpras_users/Service/item_service.dart';
import 'package:sisfo_sarpras_users/model/item_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sisfo_sarpras_users/pages/detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authService = AuthService();
  final itemService = ItemService();
  Map<String, dynamic>? user;
  List<Item>? items;

  @override
  void initState() {
    super.initState();
    fetchUser();
    fetchItems();
  }

  Future<void> fetchUser() async {
    final fetchedUser = await authService.getUser();
    if (fetchedUser != null) {
      setState(() {
        user = fetchedUser;
      });
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> fetchItems() async {
    final fetchedItems = await ItemService.getItems();
    setState(() {
      items = fetchedItems;
    });
  }

  void handleLogout() async {
    await authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = user == null || items == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 0, 97, 215),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: isLoading
          ? null
          : Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 0, 97, 215),
                    ),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user!['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            user!['class'],
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                    onTap: handleLogout,
                  ),
                ],
              ),
            ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Halo, ${user!['name']}",
                      style: TextStyle(fontSize: 22)),
                  SizedBox(height: 10),
                  Text("Selamat datang di aplikasi Anda!",
                      style: TextStyle(color: Colors.green)),
                  SizedBox(height: 30),
                  Text("Daftar Item:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      itemCount: items!.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        final item = items![index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: item.image_url,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  item.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Stock: ${item.stock}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        const Color.fromARGB(255, 0, 97, 215),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.add_circle,
                                      color:
                                          const Color.fromARGB(255, 0, 97, 215),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetailPage(item: item),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
