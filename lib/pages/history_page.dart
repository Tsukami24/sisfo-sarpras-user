import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sisfo_sarpras_users/model/loan_model.dart';
import 'package:sisfo_sarpras_users/model/return_model.dart';
import 'package:sisfo_sarpras_users/Service/loan_service.dart';
import 'package:sisfo_sarpras_users/Service/return_service.dart';

class LoanHistoryPage extends StatefulWidget {
  final LoanService loanService;

  LoanHistoryPage({required this.loanService});

  @override
  _LoanHistoryPageState createState() => _LoanHistoryPageState();
}

class _LoanHistoryPageState extends State<LoanHistoryPage> {
  late Future<List<LoanHistory>> futureLoanHistory;

  @override
  void initState() {
    super.initState();
    futureLoanHistory = widget.loanService.getLoanHistory();
  }

  String _formatDate(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate);
      return DateFormat('dd MMM yyyy – HH:mm', 'id').format(dt);
    } catch (e) {
      return rawDate;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'returned':
        return Colors.green;
      case 'pending':
        return Colors.blueGrey;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Peminjaman',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 0, 97, 215),
        centerTitle: true,
      ),
      body: FutureBuilder<List<LoanHistory>>(
        future: futureLoanHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Belum ada riwayat peminjaman.'));
          }

          final histories = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: histories.length,
            itemBuilder: (context, index) {
              final history = histories[index];
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tanggal Peminjaman: ${_formatDate(history.loanDate)}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (history.returnDate != null &&
                                  history.status != 'pending' &&
                                  history.status != 'rejected')
                                Text(
                                  'Tanggal Pengembalian: ${_formatDate(history.returnDate!)}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),

                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 6, horizontal: 12),
                            decoration: BoxDecoration(
                              color: _getStatusColor(history.status)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              history.status.toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(history.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        history.status == 'returned' &&
                                history.returns.isNotEmpty
                            ? 'Detail Pengembalian:'
                            : 'Detail Peminjaman:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      if (history.status == 'returned' &&
                          history.returns.isNotEmpty)
                        Column(
                          children: history.returns.map((ret) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.assignment_return,
                                  color: Colors.green),
                              title: Text('${ret.itemName} (${ret.quantity}x)'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Kondisi: ${ret.condition}'),
                                  Text('Denda: Rp ${ret.fine}'),
                                  Text(
                                    'Tanggal Dikembali: ${ret.returnedDate != null ? _formatDate(ret.returnedDate!) : '-'}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        )
                      else
                        Column(
                          children: history.items.map((item) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.inventory_2,
                                  color: Colors.blueAccent),
                              title: Text('${item.name} (${item.quantity}x)'),
                            );
                          }).toList(),
                        ),
                      SizedBox(height: 12),
                      if (history.status != 'returned' &&
                          history.status != 'pending' &&
                          history.status != 'rejected')
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final returnService = ReturnService(
                                  'http://127.0.0.1:8000/api');
                              final success = await returnService.returnItems(
                                history.id,
                                history.items,
                              );

                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Pengembalian berhasil diajukan')),
                                );
                                setState(() {
                                  futureLoanHistory =
                                      widget.loanService.getLoanHistory();
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Pengembalian gagal diajukan')),
                                );
                              }
                            },

                            icon: Icon(Icons.keyboard_return),
                            label: Text('Kembalikan',style: TextStyle(
                              color: Colors.white
                            )),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 0, 97, 215),
                              iconColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
