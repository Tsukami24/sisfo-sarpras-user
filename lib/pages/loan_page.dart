import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisfo_sarpras_users/model/loan_model.dart';
import 'package:sisfo_sarpras_users/Service/loan_service.dart';

class LoanPage extends StatefulWidget {
  final LoanService loanService;
  final LoanItem? initialItem;

  const LoanPage({Key? key, required this.loanService, this.initialItem})
      : super(key: key);

  @override
  State<LoanPage> createState() => _LoanPageState();
}
List<LoanItem> globalLoanItems = [];

class _LoanPageState extends State<LoanPage> {
  final _formKey = GlobalKey<FormState>();
  final _loanDateController = TextEditingController();
  final _loanTimeController = TextEditingController();
  final _reasonController = TextEditingController();

  List<LoanItem> _loanItems = [];
  int? _userId;
  String? _responseMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loanItems = List.from(globalLoanItems);
    _loadUserId();

    final now = DateTime.now();
    _loanDateController.text = DateFormat('yyyy-MM-dd').format(now);
    _loanTimeController.text = DateFormat('hh:mm a').format(now);
  }


  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId');
    });
  }

 void _removeItem(int itemId) {
    setState(() {
      _loanItems.removeWhere((item) => item.id == itemId);
      globalLoanItems.removeWhere((item) => item.id == itemId); 
    });
  }
  Future<void> _submitLoan() async {
    if (_userId == null) {
      setState(() => _responseMessage = 'User ID tidak ditemukan.');
      return;
    }

    if (!_formKey.currentState!.validate() || _loanItems.isEmpty) return;

    setState(() {
      _isLoading = true;
      _responseMessage = null;
    });

    try {
      final combinedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(
        DateFormat('yyyy-MM-dd hh:mm a').parse(
          '${_loanDateController.text} ${_loanTimeController.text}',
        ),
      );

      final result = await widget.loanService.postLoan(
        userId: _userId!,
        loanDate: combinedDateTime,
        reason: _reasonController.text,
        items: _loanItems,
      );

      setState(() {
        _isLoading = false;
        if (result != null) {
          _responseMessage = 'Peminjaman berhasil diajukan!';
          _loanItems.clear();
          _loanDateController.clear();
          globalLoanItems.clear();
          _loanTimeController.clear();
          _reasonController.clear();
        } else {
          _responseMessage = 'Gagal mengajukan peminjaman.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _responseMessage = 'Terjadi kesalahan: ${e.toString()}';
      });
    }
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulir Peminjaman',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
            )),
        backgroundColor: Color.fromARGB(255, 0, 97, 215),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _loanDateController,
                      readOnly: true,
                      decoration: _inputDecoration(
                          'Tanggal sekarang', Icons.calendar_today),
                      style: const TextStyle(
                          color: Colors.black), 
                      enableInteractiveSelection:
                          false, 
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _loanTimeController,
                      readOnly: true,
                      decoration:
                          _inputDecoration('Jam sekarang', Icons.access_time),
                      style: const TextStyle(
                          color: Colors.black), 
                      enableInteractiveSelection: false,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonController,
                decoration: _inputDecoration(
                    'Masukkan alasan', Icons.note_alt_outlined),
                validator: (value) => value == null || value.isEmpty
                    ? 'Alasan harus diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loanItems.isEmpty
                    ? const Center(child: Text('Belum ada barang dipilih.'))
                    : ListView.builder(
                        itemCount: _loanItems.length,
                        itemBuilder: (context, index) {
                          final item = _loanItems[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(item.name),
                              subtitle: Text('Jumlah: ${item.quantity}'),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeItem(item.id),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _submitLoan,
                      label: const Text('Ajukan Peminjaman',style: TextStyle(color: Colors.white)),
                      icon: const Icon(Icons.send,color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 97, 215),
                        minimumSize: const Size.fromHeight(48),
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
