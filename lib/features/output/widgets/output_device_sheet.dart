import 'package:flutter/material.dart';

class OutputDeviceSheet extends StatelessWidget {
  const OutputDeviceSheet({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  static const List<String> devices = [
    'Phone Speaker',
    'Bluetooth Earbuds',
    'Bluetooth Headphones',
    'Bluetooth Speaker',
    'Alien Reader Speaker',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Output Device',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ...devices.map(
              (device) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(device),
                trailing: Icon(
                  selected == device
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                ),
                onTap: () => onSelected(device),
              ),
            ),
            const Text(
              'Mock UI state only. Real Bluetooth and Raspberry Pi speaker routing will be integrated later.',
            ),
          ],
        ),
      ),
    );
  }
}
