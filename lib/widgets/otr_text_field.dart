import 'package:flutter/material.dart';
import '../theme/otr_theme.dart';

class OtrTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final bool enabled;
  final TextInputType keyboardType;
  final int maxLines;

  const OtrTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  State<OtrTextField> createState() => _OtrTextFieldState();
}

class _OtrTextFieldState extends State<OtrTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: OtrTheme.darkNavy,
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: widget.enabled ? Colors.white : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.enabled ? Colors.grey.shade100 : Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: OtrTheme.softShadow,
          ),
          child: TextField(
            controller: widget.controller,
            enabled: widget.enabled,
            keyboardType: widget.keyboardType,
            obscureText: widget.isPassword ? _obscureText : false,
            maxLines: widget.maxLines,
            style: TextStyle(
              fontSize: 15,
              color: widget.enabled ? OtrTheme.darkNavy : Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  widget.icon,
                  color: OtrTheme.primaryBlue,
                  size: 22,
                ),
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: Colors.grey.shade400,
                        size: 22,
                      ),
                      onPressed: () =>
                          setState(() => _obscureText = !_obscureText),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 20,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

