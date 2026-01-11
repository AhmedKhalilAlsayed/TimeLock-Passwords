import 'package:timelockpassword/domain/domain_impl.dart';
import 'package:timelockpassword/domain/domain_interface.dart';
import 'package:timelockpassword/presentation/presentation_constants.dart';
import 'package:encrypt/encrypt.dart' deferred as encrypt_lib;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../state_handler.dart';
import '../generate_pass_hash_view/generation_view.dart' deferred as gen_view;

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (kIsWeb) ...[
            const Text(
              'These will be available when become stable',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () {},
              icon: SvgPicture.asset(
                'assets/windows.svg',
                width: 24,
                height: 24,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: SvgPicture.asset('assets/linux.svg', width: 24, height: 24),
            ),
            IconButton(
              onPressed: () {},
              icon: SvgPicture.asset(
                'assets/android.svg',
                width: 24,
                height: 24,
              ),
            ),
          ] else
            IconButton(
              onPressed: () => _launchUrl(
                'https://ahmedkhalilalsayed.github.io/TimeLock-Passwords-Web-Demo/',
              ),
              icon: SvgPicture.asset('assets/web.svg', width: 24, height: 24),
            ),
          IconButton(
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: PresentationConstants.appName,
                applicationVersion: PresentationConstants.appVersion,
                applicationIcon: Icon(
                  Icons.lock_clock,
                  size: 50,
                  color: Theme.of(context).colorScheme.primary,
                ),
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    PresentationConstants.howItWorks,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(PresentationConstants.appWorkDescription),
                  const SizedBox(height: 24),
                  const Text(
                    PresentationConstants.developerInfo,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(PresentationConstants.developerName),
                  const SizedBox(height: 8),
                  const SelectableText(PresentationConstants.developerGmail),
                  const SelectableText(PresentationConstants.developerLinkedIn),
                ],
              );
            },
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Use a breakpoint to decide which layout to show
            if (constraints.maxWidth > 600) {
              return _buildLandscapeLayout(context, textTheme, colorScheme);
            } else {
              return _buildPortraitLayout(context, textTheme, colorScheme);
            }
          },
        ),
      ),
    );
  }

  /// Layout for portrait mode or narrow screens.
  Widget _buildPortraitLayout(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              (Scaffold.of(context).appBarMaxHeight ?? 0) -
              MediaQuery.of(context).padding.top,
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: _WelcomeInfo(
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                ),
              ),
              Expanded(
                flex: 4,
                child: _ActionButtons(colorScheme: colorScheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Layout for landscape mode or wider screens.
  Widget _buildLandscapeLayout(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _WelcomeInfo(textTheme: textTheme, colorScheme: colorScheme),
        ),
        const VerticalDivider(width: 1),
        Expanded(flex: 1, child: _ActionButtons(colorScheme: colorScheme)),
      ],
    );
  }
}

/// Extracted widget for the top "Welcome" section.
class _WelcomeInfo extends StatelessWidget {
  const _WelcomeInfo({required this.textTheme, required this.colorScheme});

  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_clock, size: 80, color: colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Welcome to ${PresentationConstants.appName} ${PresentationConstants.appVersion}',
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            PresentationConstants.breif,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

/// Extracted widget for the action buttons.
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    String hashInput = "";
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ActionCard(
            title: 'Generate New Password',
            icon: Icons.add_moderator,
            color: colorScheme.primary,
            onTap: () async {
              await gen_view.loadLibrary();
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => gen_view.GenerationView(),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 20),
          _ActionCard(
            title: 'Retrieve Password from Hash',
            icon: Icons.vpn_key_outlined,
            color: colorScheme.secondary,
            onTap: () {
              print('Navigate to Get Password from Hash');

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  TextEditingController? hashInputContrloller;
                  return AlertDialog(
                    title: const Text('Enter Hash'),
                    content: TextField(
                      controller: hashInputContrloller,
                      onChanged: (value) {
                        hashInput = value;
                        print(hashInput);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Enter your hash here',
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () async {
                          if (hashInput.isNotEmpty) {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return const AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 16),
                                      Text("Retrieving password..."),
                                    ],
                                  ),
                                );
                              },
                            );

                            late StateHandler<DomainErrorStates, String>
                                passHandler;

                            await encrypt_lib.loadLibrary();

                            try {
                              passHandler = await DomainInterface.impl()
                                  .getPassFromHash(
                                encrypt_lib.Encrypted.fromBase64(hashInput),
                              )
                                  .onError((handleError, e) {
                                return StateHandler(
                                  DomainErrorStates.failed,
                                  e.toString(),
                                );
                              });
                            } catch (e) {
                              passHandler = StateHandler(
                                DomainErrorStates.failed,
                                e.toString(),
                              );
                            }

                            String textMessage = "";
                            switch (passHandler.state) {
                              case DomainErrorStates.success:
                                textMessage =
                                    "The extracted password: ${passHandler.value}";
                                break;

                              case DomainErrorStates
                                    .pleaseWaitTheOpeningDateTime:
                                textMessage =
                                    "${DomainErrorStates.pleaseWaitTheOpeningDateTime.name}: ${passHandler.value}";
                                break;

                              case DomainErrorStates
                                    .yourDeviceClockNotSyncedWithNetwork:
                                textMessage = DomainErrorStates
                                    .yourDeviceClockNotSyncedWithNetwork.name;
                                break;
                              default:
                                textMessage =
                                    "Undefined error, may be the network please! or ${passHandler.value}";
                                break;
                            }

                            Navigator.of(
                              context,
                            ).pop(); // Okay button closes the AlertDialog

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Retrieved Password'),
                                  content: SelectableText(
                                    textMessage,
                                    textAlign: TextAlign.center,
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Close'),
                                      onPressed: () {
                                        Navigator.of(
                                          context,
                                        ).pop(); // Close the password display dialog
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 28),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: color == colorScheme.primary
            ? colorScheme.onPrimary
            : colorScheme.onSecondary,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
