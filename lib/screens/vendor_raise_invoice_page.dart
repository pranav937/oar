import 'package:flutter/material.dart';
import '../theme/otr_theme.dart';
import '../services/api_service.dart';
import '../models/work_order_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class VendorRaiseInvoicePage extends StatefulWidget {
  const VendorRaiseInvoicePage({super.key});

  @override
  State<VendorRaiseInvoicePage> createState() => _VendorRaiseInvoicePageState();
}

class _VendorRaiseInvoicePageState extends State<VendorRaiseInvoicePage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _baseAmountController = TextEditingController(text: '0');
  final TextEditingController _taxAmountController = TextEditingController(text: '0');
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  bool _isLoading = true;
  List<WorkOrderModel> _workOrders = [];
  WorkOrderModel? _selectedWorkOrder;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchWorkOrders();
  }

  Future<void> _fetchWorkOrders() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final result = await _apiService.getVendorWorkOrders();
      if (result['success'] == true) {
        setState(() {
          _workOrders = (result['data'] as List)
              .map((item) => WorkOrderModel.fromJson(item))
              .toList();
        });
      } else {
        setState(() => _error = result['message'] ?? 'Failed to load work orders');
      }
    } catch (e) {
      setState(() => _error = 'An error occurred: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  double get _totalAmount {
    double base = double.tryParse(_baseAmountController.text) ?? 0;
    double tax = double.tryParse(_taxAmountController.text) ?? 0;
    return base + tax;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: OtrTheme.darkNavy,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Raise New Invoice',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
        ),
      ),
      body: _isLoading
          ? const Center(child: SpinKitPulse(color: OtrTheme.primaryBlue, size: 50))
          : Column(
              children: [
                _buildPortalHeader(),
                Expanded(
                  child: _error.isNotEmpty
                      ? _buildErrorPlaceholder()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('SELECT WORK ORDER *'),
                              _buildDropdown(),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('BASE AMOUNT (₹) *'),
                                        _buildTextField(_baseAmountController, '0', keyboardType: TextInputType.number),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('TAX AMOUNT (₹)'),
                                        _buildTextField(_taxAmountController, '0', keyboardType: TextInputType.number),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              _buildTotalBanner(),
                              const SizedBox(height: 32),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('INVOICE DATE *'),
                                        _buildDatePicker('14-05-2026'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('DUE DATE'),
                                        _buildDatePicker('dd-mm-yyyy', isPlaceholder: true),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildLabel('INVOICE DOCUMENT URL'),
                              _buildTextField(_urlController, 'https://example.com/invoice.pdf'),
                              const SizedBox(height: 24),
                              _buildLabel('REMARKS'),
                              _buildTextField(_remarksController, 'Additional details about this milestone...', maxLines: 4),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                ),
                if (_error.isEmpty) _buildActionFooter(),
              ],
            ),
    );
  }

  Widget _buildPortalHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: const BoxDecoration(
        color: OtrTheme.darkNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: const Text(
        'SUBMIT FINANCIAL CLAIM FOR EXECUTED WORK',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.2), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<WorkOrderModel?>(
          isExpanded: true,
          value: _selectedWorkOrder,
          hint: const Text('Choose a work order...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey)),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blueGrey),
          items: _workOrders.map((WorkOrderModel wo) {
            return DropdownMenuItem<WorkOrderModel>(
              value: wo,
              child: Text(
                '${wo.woNumber} - ${wo.scopeOfWork}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: OtrTheme.darkNavy),
              ),
            );
          }).toList(),
          onChanged: (WorkOrderModel? newValue) {
            setState(() => _selectedWorkOrder = newValue);
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: OtrTheme.darkNavy),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.blueGrey.withValues(alpha: 0.2), width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: OtrTheme.primaryBlue, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildDatePicker(String date, {bool isPlaceholder = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isPlaceholder ? FontWeight.w500 : FontWeight.w700,
              color: isPlaceholder ? Colors.grey : OtrTheme.darkNavy,
            ),
          ),
          const Icon(Icons.calendar_month_outlined, size: 18, color: Colors.blueGrey),
        ],
      ),
    );
  }

  Widget _buildTotalBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'TOTAL INVOICE AMOUNT',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: OtrTheme.primaryBlue, letterSpacing: 0.5),
          ),
          Text(
            '₹${_totalAmount.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: OtrTheme.darkNavy),
          ),
        ],
      ),
    );
  }

  Widget _buildActionFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _selectedWorkOrder == null ? null : () => Navigator.pop(context),
              icon: const Icon(Icons.receipt_long_rounded, size: 18),
              label: const Text('Submit Invoice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: OtrTheme.darkNavy,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
            const SizedBox(height: 24),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: OtrTheme.darkNavy),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _fetchWorkOrders,
              child: const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }
}

