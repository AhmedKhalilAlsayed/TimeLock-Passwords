import 'package:delay_pass/domain/domain_impl.dart';
import 'package:delay_pass/domain/domain_interface.dart';
import 'package:delay_pass/state_handler.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';

class GenerationView extends StatefulWidget {
  const GenerationView({super.key});

  @override
  State<GenerationView> createState() => _GenerationViewState();
}

class _GenerationViewState extends State<GenerationView> {
  bool _includeCapitalLetters = true;
  bool _includeSmallLetters = true;
  bool _includeSymbols = true;
  int _passwordLength = 16;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final DomainInterface _domainInterface = DomainInterface.impl();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customize your password')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Password Options ---
              CheckboxListTile(
                title: const Text('Include Capital Letters'),
                value: _includeCapitalLetters,
                onChanged: (value) =>
                    setState(() => _includeCapitalLetters = value ?? false),
              ),
              CheckboxListTile(
                title: const Text('Include Small Letters'),
                value: _includeSmallLetters,
                onChanged: (value) =>
                    setState(() => _includeSmallLetters = value ?? false),
              ),
              const CheckboxListTile(
                title: Text('Include Numbers'),
                value: true,
                onChanged: null,
              ),
              CheckboxListTile(
                title: const Text('Include Symbols'),
                value: _includeSymbols,
                onChanged: (value) =>
                    setState(() => _includeSymbols = value ?? false),
              ),
              const SizedBox(height: 24.0),

              // --- Password Length ---
              Text('Password Length: ${_passwordLength.toInt()}'),
              Slider(
                value: _passwordLength.toDouble(),
                min: 8,
                max: 64,
                // divisions: 24,
                label: _passwordLength.toInt().toString(),
                onChanged: (value) =>
                    setState(() => _passwordLength = value.round()),
              ),
              const SizedBox(height: 24.0),

              // --- DateTime Picker ---
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
                title: Text(
                  _selectedDate == null
                      ? 'Select Retrieval Date And Time'
                      : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]} Time: ${_selectedTime!.format(context)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDateAndTime,
              ),
              const SizedBox(height: 16.0),

              // --- Generate Button ---
              ElevatedButton.icon(
                icon: const Icon(Icons.lock_outline),
                label: const Text('Generate Secret'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  if (_selectedDate != null && _selectedTime != null) {
                    // validation of all inputs is true
                    StateHandler<DomainErrorStates, String> passHandler =
                        _domainInterface.generatePass(
                          isContainNumbers: true,
                          isContainSmallChars: _includeSmallLetters,
                          isContainCapitalChars: _includeCapitalLetters,
                          isContainSigns: _includeSymbols,
                          length: _passwordLength,
                        );

                    print(_selectedDate!); // for debugging

                    // if the password is good
                    if (passHandler.state == DomainErrorStates.success) {
                      StateHandler<DomainErrorStates, Encrypted> hashHandler =
                          _domainInterface.generateHashWithPassAndTime(
                            passHandler.value!,
                            _selectedDate!,
                          );

                      if (hashHandler.state == DomainErrorStates.success) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Your Secret'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                      const SizedBox(width: 8),
                                      // Wrap the Text widget with Flexible to prevent overflow
                                      const Flexible(
                                        child: Text(
                                          'Please copy your password and hash. They will not be shown again.',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(">Your Password: "),
                                      Flexible(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: SelectableText(
                                            passHandler.value!,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(">Your Hash: "),
                                      Flexible(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: SelectableText(
                                            hashHandler.value!.base64,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Close'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Warning"),
                        content: const Text(
                          "Please select both a date and a time for retrieval.",
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateAndTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 356 * 3)),
    );
    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    setState(() {
      _selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _selectedTime = pickedTime;
    });
  }
}
