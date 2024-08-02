import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class TimePicker extends StatelessWidget {
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay?>? onChanged;
  final PromptMode mode;
  final Widget? placeholder;
  final Alignment? popoverAlignment;
  final Alignment? popoverAnchorAlignment;
  final EdgeInsets? popoverPadding;
  final bool? use24HourFormat;
  final bool showSeconds;

  const TimePicker({
    Key? key,
    required this.value,
    this.onChanged,
    this.mode = PromptMode.dialog,
    this.placeholder,
    this.popoverAlignment,
    this.popoverAnchorAlignment,
    this.popoverPadding,
    this.use24HourFormat,
    this.showSeconds = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ShadcnLocalizations localizations = ShadcnLocalizations.of(context);
    bool use24HourFormat =
        this.use24HourFormat ?? MediaQuery.of(context).alwaysUse24HourFormat;
    return ObjectFormField(
      value: value,
      placeholder: placeholder ?? Text(localizations.placeholderTimePicker),
      onChanged: onChanged,
      builder: (context, value) {
        return Text(localizations.formatTimeOfDay(value,
            use24HourFormat: use24HourFormat, showSeconds: showSeconds));
      },
      mode: mode,
      trailing: const Icon(Icons.access_time),
      editorBuilder: (context, value, onChanged) {
        return TimePickerDialog(
          initialValue: value,
          onChanged: onChanged,
          use24HourFormat: use24HourFormat,
          showSeconds: showSeconds,
        );
      },
    );
  }
}

class TimePickerDialog extends StatefulWidget {
  final TimeOfDay? initialValue;
  final ValueChanged<TimeOfDay?>? onChanged;
  final bool use24HourFormat;
  final bool showSeconds;

  const TimePickerDialog({
    Key? key,
    this.initialValue,
    this.onChanged,
    required this.use24HourFormat,
    this.showSeconds = false,
  }) : super(key: key);

  @override
  State<TimePickerDialog> createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<TimePickerDialog> {
  late TextEditingController _hourController;
  late TextEditingController _minuteController;
  late TextEditingController _secondController;
  late bool _pm;
  String _formatDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  Widget _buildInput(TextEditingController controller, String label) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        TextField(
          textAlign: TextAlign.center,
          controller: controller,
          style: const TextStyle(
            fontSize: 32,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            const _TimeFormatter(),
          ],
        ),
        Positioned(
          bottom: -16 - 4,
          child: Text(label).muted(),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return const Text(':', style: TextStyle(fontSize: 48))
        .withPadding(horizontal: 8);
  }

  void _onChanged() {
    int hour = int.tryParse(_hourController.text) ?? 0;
    int minute = int.tryParse(_minuteController.text) ?? 0;
    int second = int.tryParse(_secondController.text) ?? 0;
    if (widget.use24HourFormat) {
      hour = hour.clamp(0, 23);
      minute = minute.clamp(0, 59);
      second = second.clamp(0, 59);
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        widget.onChanged
            ?.call(TimeOfDay(hour: hour, minute: minute, second: second));
      });
    } else {
      if (_pm && hour < 12) {
        hour += 12;
      } else if (!_pm && hour == 12) {
        hour = 0;
      }
      hour = hour.clamp(0, 23);
      minute = minute.clamp(0, 59);
      second = second.clamp(0, 59);
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (!mounted) return;
        widget.onChanged
            ?.call(TimeOfDay(hour: hour, minute: minute, second: second));
      });
    }
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pm = (widget.initialValue?.hour ?? 0) >= 12;
    int initialHour = widget.initialValue?.hour ?? 0;
    int initialMinute = widget.initialValue?.minute ?? 0;
    int initialSecond = widget.initialValue?.second ?? 0;
    if (!widget.use24HourFormat && initialHour > 12 && initialHour <= 23) {
      initialHour -= 12;
      _pm = true;
    }
    _hourController = TextEditingController(
      text: _formatDigits(initialHour),
    );
    _minuteController = TextEditingController(
      text: _formatDigits(initialMinute),
    );
    _secondController = TextEditingController(
      text: _formatDigits(initialSecond),
    );
    _hourController.addListener(_onChanged);
    _minuteController.addListener(_onChanged);
    _secondController.addListener(_onChanged);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = ShadcnLocalizations.of(context);
    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: _buildInput(
                  _hourController,
                  localizations.timeHour,
                ),
              ),
              _buildSeparator(),
              Expanded(
                child: _buildInput(
                  _minuteController,
                  localizations.timeMinute,
                ),
              ),
              if (widget.showSeconds) ...[
                _buildSeparator(),
                // Expanded(child: TextField()),
                Expanded(
                  child: _buildInput(
                    _secondController,
                    localizations.timeSecond,
                  ),
                ),
              ],
              if (!widget.use24HourFormat) ...[
                Gap(8),
                IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Toggle(
                          value: !_pm,
                          onChanged: (value) {
                            setState(() {
                              _pm = !value;
                              _onChanged();
                            });
                          },
                          child: Text(localizations.timeAM),
                        ),
                      ),
                      Expanded(
                        child: Toggle(
                          value: _pm,
                          onChanged: (value) {
                            setState(() {
                              _pm = value;
                              _onChanged();
                            });
                          },
                          child: Text(localizations.timePM),
                        ),
                      ),
                    ],
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeFormatter extends TextInputFormatter {
  const _TimeFormatter();
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // make sure new value has leading zero
    var newText = newValue.text;
    int substringCount = 0;
    if (newText.length > 2) {
      substringCount = newText.length - 2;
      newText = newText.substring(substringCount);
    }
    int padLength = 2 - newText.length;
    var baseOffset2 = newValue.selection.baseOffset;
    var extentOffset2 = newValue.selection.extentOffset;
    if (padLength > 0) {
      newText = newText.padLeft(2, '0');
      baseOffset2 = baseOffset2 + padLength;
      extentOffset2 = extentOffset2 + padLength;
    }
    return newValue.copyWith(
      text: newText,
      composing: newValue.composing.isValid
          ? TextRange(
              start: newValue.composing.start.clamp(0, 2),
              end: newValue.composing.end.clamp(0, 2),
            )
          : newValue.composing,
      selection: TextSelection(
        baseOffset: baseOffset2.clamp(0, 2),
        extentOffset: extentOffset2.clamp(0, 2),
      ),
    );
  }
}
