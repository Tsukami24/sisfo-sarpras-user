import 'package:flutter/material.dart';
import 'package:sisfo_sarpras_users/Service/auth_service.dart';
import 'package:sisfo_sarpras_users/Service/item_service.dart';
import 'package:sisfo_sarpras_users/model/item_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sisfo_sarpras_users/pages/detail_page.dart';
import 'package:sisfo_sarpras_users/model/loan_model.dart';

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
  List<Item>? filteredItems;
  String selectedCategory = 'Semua';
  List<String> categories = ['Semua'];

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
    final fetchedCategories = await ItemService.getCategories();

    setState(() {
      items = fetchedItems;
      filteredItems = fetchedItems;
      categories = ['Semua', ...fetchedCategories];
    });
  }

  void handleLogout() async {
    final confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );

    if (confirmLogout == true) {
      await authService.logout();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _searchItem(String query) {
    final lowerQuery = query.toLowerCase();
    final filtered = items!
        .where((item) =>
            item.name.toLowerCase().contains(lowerQuery) ||
            item.categoryName.toLowerCase().contains(lowerQuery))
        .toList();

    setState(() {
      filteredItems = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = user == null || items == null;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Beranda',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: const Color.fromARGB(255, 0, 97, 215),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      drawer: isLoading
          ? null
          : Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(user!['name'],
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    accountEmail: Text(user!['class']),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 0, 97, 215),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Logout'),
                    onTap: handleLogout,
                  ),
                ],
              ),
            ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          onChanged: _searchItem,
                          decoration: InputDecoration(
                            hintText: 'Cari barang...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCategory,
                              isExpanded: true,
                              items: categories
                                  .map((category) => DropdownMenuItem(
                                        value: category,
                                        child: Text(category),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  selectedCategory = value;
                                  if (value == 'Semua') {
                                    filteredItems = items;
                                  } else {
                                    filteredItems = items!
                                        .where((item) =>
                                            item.categoryName == value)
                                        .toList();
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Daftar Item:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      itemCount: filteredItems!.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.7,
                      ),
                      itemBuilder: (context, index) {
                        final item = filteredItems![index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => DetailPage(item: item)),
                            );
                            if (result != null && result is LoanItem) {
                              Navigator.pushNamed(context, '/loan');
                            }
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(16)),
                                        child: CachedNetworkImage(
                                          imageUrl: item.image_url,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          placeholder: (context, url) =>
                                              const Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.broken_image),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text('Kategori: ${item.categoryName}',
                                              style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 0, 97, 215),
                                                fontWeight: FontWeight.bold,
                                              )),
                                          const SizedBox(height: 4),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color.fromARGB(
                                                    255, 0, 97, 215),
                                              ),
                                              padding: const EdgeInsets.all(6),
                                              child: Icon(
                                                Icons.arrow_forward,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Stok: ${item.stock}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 0, 97, 215),
                                      ),
                                    ),
                                  ),
                                ),
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
