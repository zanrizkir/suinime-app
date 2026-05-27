import 'package:flutter/material.dart';
import '../config/theme/app_theme.dart';
import '../utils/responsive.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.autofocus = false,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color),
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      obscureText: widget.isPassword && _obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: Responsive.fontSizeMedium(context),
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: AppColors.textHint,
          fontSize: Responsive.fontSizeMedium(context),
        ),
        filled: true,
        fillColor: AppColors.darkSurface,
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: AppColors.textSecondary,
                size: Responsive.iconSizeMedium(context),
              )
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                  size: Responsive.iconSizeMedium(context),
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        enabledBorder: _border(AppColors.border),
        focusedBorder: _border(AppColors.primary),
        errorBorder: _border(AppColors.error),
        focusedErrorBorder: _border(AppColors.error),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Responsive.paddingMedium(context),
          vertical: Responsive.paddingMedium(context),
        ),
      ),
    );
  }
}
