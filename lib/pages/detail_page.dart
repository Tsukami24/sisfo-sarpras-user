import 'package:flutter/material.dart';
import 'package:sisfo_sarpras_users/model/item_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sisfo_sarpras_users/model/loan_model.dart';
import 'package:sisfo_sarpras_users/pages/loan_page.dart';

class DetailPage extends StatelessWidget {
  final Item item;

  const DetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Detail', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,)),
        backgroundColor: const Color.fromARGB(255, 0, 97, 215),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: item.image_url,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image, size: 100),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              item.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.category, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  item.categoryName,
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.inventory, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Stock: ${item.stock}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 0, 97, 215),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Deskripsi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.description,
              style: TextStyle(fontSize: 15, color: Colors.grey[800]),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 97, 215),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  if (item.stock <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Maaf, stok barang ini sudah habis.'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  final newItem = LoanItem(
                    id: item.id,
                    name: item.name,
                    quantity: 1,
                  );

                  final alreadyExists =
                      globalLoanItems.any((i) => i.id == newItem.id);
                  if (!alreadyExists) {
                    globalLoanItems.add(newItem);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Barang berhasil ditambahkan ke keranjang'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Barang sudah ada di keranjang'),
                        backgroundColor: Colors.orange,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.add_circle, color: Colors.white),
                label: const Text(
                  'Tambah ke Keranjang',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
