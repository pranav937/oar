import 'package:flutter/material.dart';
import '../theme/otr_theme.dart';
import '../models/advertisement_model.dart';
import '../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ApplyNowPage extends StatefulWidget {
  const ApplyNowPage({super.key});

  @override
  State<ApplyNowPage> createState() => _ApplyNowPageState();
}

class _ApplyNowPageState extends State<ApplyNowPage> {
  final ApiService _apiService = ApiService();
  bool _declarationAccepted = false;
  bool _isLoading = true;
  Map<String, dynamic>? _formData;
  String? _selectedPost;
  String? _selectedCenter;
  bool _isSubmitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_formData == null) {
      final data = ModalRoute.of(context)!.settings.arguments as Advertisement;
      _fetchFormData(data.uuid);
    }
  }

  Future<void> _fetchFormData(String advUuid) async {
    try {
      final result = await _apiService.getApplicationForm(advUuid);
      if (result['success'] == true) {
        setState(() {
          _formData = result['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSubmit(String advUuid) async {
    if (_selectedPost == null || _selectedCenter == null || !_declarationAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields and accept the declaration')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final appData = {
        "advertisementUuid": advUuid,
        "postPreference1": _selectedPost,
        "examCentrePreference1": _selectedCenter,
        "category": "UR", // Usually from profile, but hardcoded for now
        "hasAcceptedTerms": true,
        "hasDeclarationSigned": true
      };

      final result = await _apiService.submitApplication(appData);

      if (result['success'] == true) {
        if (mounted) {
          Navigator.pushNamed(
            context,
            '/payment',
            arguments: {
              'applicationUuid': result['data']['uuid'],
              'amount': 500.0, // Should come from API/Form
              'title': _selectedPost,
            },
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Submission failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as Advertisement;

    return Scaffold(
      backgroundColor: OtrTheme.background,
      appBar: AppBar(
        title: const Text(
          'Application Form',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: OtrTheme.darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: SpinKitFadingCircle(color: OtrTheme.primaryBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildJobSummary(data),
                  const SizedBox(height: 32),
                  
                  const Text('PREFERENCES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black38)),
                  const SizedBox(height: 16),
                  
                  _buildDropdown(
                    label: 'Post Preference',
                    value: _selectedPost,
                    items: ['Senior Software Engineer', 'Data Analyst', 'Product Manager'], // Fallback
                    onChanged: (val) => setState(() => _selectedPost = val),
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown(
                    label: 'Exam Center Preference',
                    value: _selectedCenter,
                    items: ['Delhi', 'Mumbai', 'Bangalore', 'Ahmedabad'], // Fallback
                    onChanged: (val) => setState(() => _selectedCenter = val),
                  ),
                  
                  const SizedBox(height: 40),
                  _buildDeclarationCard(),
                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _handleSubmit(data.uuid),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OtrTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit Application', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDropdown({required String label, required String? value, required List<String> items, required Function(String?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: OtrTheme.darkNavy)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: OtrTheme.lightBlue),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text('Select $label'),
              items: items.map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJobSummary(Advertisement data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [OtrTheme.primaryBlue, OtrTheme.mediumBlue]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.work_outline, color: Colors.white)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.postName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                Text(data.organization, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeclarationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
      ),
      child: Column(
        children: [
          const Text('Declaration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          const Text(
            'I hereby declare that all information provided is true and I accept all terms and conditions of this recruitment.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          CheckboxListTile(
            title: const Text('I accept the terms', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            value: _declarationAccepted,
            onChanged: (val) => setState(() => _declarationAccepted = val ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: OtrTheme.primaryBlue,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
