import 'package:thermal_printer_plus/thermal_printer.dart';

class SelectablePrinter {
  final PrinterDevice device;
  final PrinterType type;

  SelectablePrinter({required this.device, required this.type});
}
