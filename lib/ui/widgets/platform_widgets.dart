import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Адаптивная кнопка
class PlatformButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? color;
  final double? minSize;

  const PlatformButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.minSize,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoButton(
        onPressed: onPressed,
        color: color,
        child: child, minimumSize: Size(minSize ?? 44.0, minSize ?? 44.0),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: color != null
          ? ElevatedButton.styleFrom(backgroundColor: color)
          : null,
      child: child,
    );
  }
}

// Адаптивный переключатель
class PlatformSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;

  const PlatformSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: activeColor,
      );
    }

    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: activeColor,
    );
  }
}

// Адаптивный индикатор загрузки
class PlatformLoadingIndicator extends StatelessWidget {
  final double? radius;

  const PlatformLoadingIndicator({super.key, this.radius});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoActivityIndicator(radius: radius ?? 10);
    }

    return CircularProgressIndicator(
      strokeWidth: (radius ?? 10) / 5,
    );
  }
}

// Адаптивный диалог
class PlatformDialog {
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
  }) {
    if (Platform.isIOS) {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            if (cancelText != null)
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelText),
              ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(true),
              isDefaultAction: true,
              child: Text(confirmText ?? 'OK'),
            ),
          ],
        ),
      );
    }

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText ?? 'OK'),
          ),
        ],
      ),
    );
  }
}

// Адаптивная иконка
class PlatformIcon extends StatelessWidget {
  final IconData materialIcon;
  final IconData? cupertinoIcon;
  final double? size;
  final Color? color;

  const PlatformIcon({
    super.key,
    required this.materialIcon,
    this.cupertinoIcon,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS && cupertinoIcon != null) {
      return Icon(
        cupertinoIcon,
        size: size,
        color: color,
      );
    }

    return Icon(
      materialIcon,
      size: size,
      color: color,
    );
  }
}

