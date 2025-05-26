import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisfo_sarpras_users/model/loan_model.dart';
import 'package:sisfo_sarpras_users/Service/loan_service.dart';

class LoanPage extends StatefulWidget {
  final LoanService loanService;

  const LoanPage({super.key, required this.loanService});

  @override
  State<LoanPage> createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage> {
  final _formKey = GlobalKey<FormState>();
  final _loanDateController = TextEditingController();
  final _quantityController = TextEditingController();

  List<Map<String, dynamic>> _allItems = [];
  List<LoanItem> _loanItems = [];
  int? _userId;
  int? _selectedItemId;

  bool _isLoading = false;
  String? _responseMessage;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadItems();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId');
    });
  }

  Future<void> _loadItems() async {
    try {
      final items = await widget.loanService.getItems();
      setState(() {
        _allItems = items;
      });
    } catch (e) {
      setState(() {
        _responseMessage = 'Gagal memuat daftar barang.';
      });
    }
  }

  void _addItem() {
    if (_selectedItemId != null && _quantityController.text.isNotEmpty) {
      final selectedItem = _allItems.firstWhere(
        (item) => item['id'] == _selectedItemId,
        orElse: () => {},
      );
      if (selectedItem.isNotEmpty) {
        setState(() {
          _loanItems.add(LoanItem(
            id: selectedItem['id'],
            name: selectedItem['name'],
            quantity: int.parse(_quantityController.text),
          ));
          _quantityController.clear();
          _selectedItemId = null; 
        });
      }
    }
  }

  Future<void> _submitLoan() async {
    if (_userId == null) {
      setState(() {
        _responseMessage = 'User ID tidak ditemukan. Silakan login ulang.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _responseMessage = null;
    });

    final result = await widget.loanService.postLoan(
      userId: _userId!,
      loanDate: _loanDateController.text,
      items: _loanItems,
    );

    setState(() {
      _isLoading = false;
      if (result != null) {
        _responseMessage = 'Peminjaman berhasil diajukan!';
        _loanItems.clear();
        _loanDateController.clear();
        _selectedItemId = null;
      } else {
        _responseMessage = 'Gagal mengajukan peminjaman.';
      }
    });
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }


  @override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isWide = screenWidth > 600;

  return Scaffold(
    appBar: AppBar(
      title: const Text('Ajukan Peminjaman', style: TextStyle(color: Colors.white)),
      backgroundColor: Color.fromARGB(255, 0, 97, 215),
      centerTitle: true,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_responseMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _responseMessage!.contains('berhasil')
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  border: Border.all(
                    color: _responseMessage!.contains('berhasil')
                        ? Colors.green
                        : Colors.red,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _responseMessage!,
                  style: TextStyle(
                    color: _responseMessage!.contains('berhasil')
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            /// Tanggal Peminjaman
            _buildSectionTitle('Tanggal Peminjaman'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _loanDateController,
              readOnly: true,
              decoration: _inputDecoration('Pilih tanggal peminjaman', Icons.calendar_today),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2030),
                );

                if (pickedDate != null) {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    final combinedDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );

                    _loanDateController.text =
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(combinedDateTime);
                  }
                }
              },
              validator: (value) =>
                  value == null || value.isEmpty ? 'Tanggal harus diisi' : null,
            ),

            const SizedBox(height: 20),

            /// Pilih Barang
            _buildSectionTitle('Pilih Barang'),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _selectedItemId,
              items: _allItems.map((item) {
                return DropdownMenuItem<int>(
                  value: item['id'],
                  child: Text(item['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedItemId = value;
                });
              },
              decoration: _inputDecoration('Pilih barang', Icons.inventory),
              validator: (value) => value == null ? 'Pilih barang' : null,
            ),

            const SizedBox(height: 20),

            /// Jumlah Barang
            _buildSectionTitle('Jumlah Barang'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Masukkan jumlah', Icons.confirmation_number),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Jumlah harus diisi';
                if (int.tryParse(value) == null) return 'Jumlah harus angka';
                return null;
              },
            ),

            const SizedBox(height: 16),

            /// Tombol Tambah Item
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Tambah', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 0, 97, 215),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            if (_loanItems.isNotEmpty) ...[
              _buildSectionTitle('Barang yang Dipinjam'),
              const SizedBox(height: 8),
              ..._loanItems.map(
                (item) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.list_alt, color: Color.fromARGB(255, 0, 97, 215)),
                    title: Text(item.name),
                    trailing: Text('x${item.quantity}'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            const Divider(height: 32, thickness: 1),

            /// Submit Button
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _submitLoan,
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text('Ajukan Peminjaman', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 0, 97, 215),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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