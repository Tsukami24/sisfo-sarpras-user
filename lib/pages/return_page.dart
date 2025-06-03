import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sisfo_sarpras_users/Service/return_service.dart';
import 'package:sisfo_sarpras_users/model/return_model.dart';
import 'package:sisfo_sarpras_users/model/loan_model.dart';

class ReturnPage extends StatefulWidget {
  final LoanHistory loan;
  final ReturnService returnService;

  ReturnPage({
    required this.loan,
    required this.returnService,
  });

  @override
  State<ReturnPage> createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage> {
  final _formKey = GlobalKey<FormState>();

  void _returnItem() async {
    if (_formKey.currentState!.validate()) {
      final shouldReturn = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi Pengembalian'),
          content:
              const Text('Apakah Anda yakin ingin mengembalikan barang ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ya'),
            ),
          ],
        ),
      );

      if (shouldReturn != true) return; // Jika user tekan "Tidak", hentikan

      final loan = widget.loan;
      List<ReturnItem> itemsToReturn = loan.items.map((item) {
        return ReturnItem(
          itemId: item.id,
          loanId: loan.id,
          quantity: item.quantity,
        );
      }).toList();

      try {
        await widget.returnService.returnItems(itemsToReturn);

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Pengembalian Berhasil Diajukan'),
            content: Text('Menunggu Konfirmasi Admin'),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        String errorMessage = e.toString().replaceAll('Exception: ', '');

        if (errorMessage.toLowerCase().contains('false') ||
            errorMessage.toLowerCase().contains('success')) {
          errorMessage =
              'Barang ini telah dikembalikan dan saat ini sedang menunggu konfirmasi dari admin.';
        }

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Gagal Mengembalikan'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Tutup'),
              ),
            ],
          ),
        );
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    final loan = widget.loan;
    final formattedDate =
        DateFormat('dd MMM yyyy').format(DateTime.parse(loan.loanDate));

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Pengembalian Barang', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 0, 97, 215),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Tanggal Peminjaman',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(formattedDate),
              SizedBox(height: 20),

              Text(
                'Daftar Barang Dipinjam',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 10),
              ...loan.items.map((item) {
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(Icons.inventory_2, color: Color.fromARGB(255, 0, 97, 215)),
                    title: Text(item.name,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Jumlah: ${item.quantity}'),
                  ),
                );
              }).toList(),
              SizedBox(height: 20),

              // Info Peminjaman
              Text(
                'Informasi Peminjaman',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                color: Colors.grey[100],
                elevation: 0,
                child: ListTile(
                  leading: Icon(Icons.assignment, color: Colors.orange),
                  title: Text('Peminjaman Ke ${loan.id}'),
                  subtitle: Text('Status: ${loan.status}'),
                ),
              ),
              SizedBox(height: 30),

              if (loan.status != 'returned')
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _returnItem,
                    icon: Icon(Icons.assignment_return_outlined,color: Colors.white),
                    label: Text('Kembalikan Barang', style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 0, 97, 215),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      textStyle:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
