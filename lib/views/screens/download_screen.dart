import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/assets.dart';
import '../../providers/audio_provider.dart';
import '../widgets/custom_animated_button.dart';

class DownloadScreen extends StatelessWidget {
  DownloadScreen({super.key});
  static const routeName = '/download';

  final TextEditingController _urlController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        context.read<AudioProvider>().clear();
      },
      canPop: true,
      child: Scaffold(
        appBar: AppBar(title: const Text('GTS Extractor')),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Consumer<AudioProvider>(
            builder: (context, audioProvider, child) {
              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    StatefulBuilder(
                      builder: (context, setState) {
                        final hasText = _urlController.text.isNotEmpty;

                        return TextFormField(
                          controller: _urlController,
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter URL";
                            }
                            final uri = Uri.tryParse(value.trim());
                            final valid =
                                uri != null &&
                                (uri.scheme == 'http' ||
                                    uri.scheme == 'https') &&
                                uri.hasAuthority;
                            if (!valid) {
                              return "Please! enter a valid URL";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Paste YouTube URL',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                hasText ? Icons.clear : Icons.content_paste,
                              ),
                              onPressed: () async {
                                if (hasText) {
                                  // Clear input
                                  _urlController.clear();
                                  setState(() {});
                                } else {
                                  // Paste from clipboard
                                  final data = await Clipboard.getData(
                                    Clipboard.kTextPlain,
                                  );
                                  if (data?.text != null &&
                                      data!.text!.isNotEmpty) {
                                    _urlController.text = data.text!;
                                    setState(() {});
                                  }
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomAnimatedButton(
                      text: audioProvider.extractingData
                          ? "Extracting..."
                          : 'Extract Audio',
                      textColor: audioProvider.extractingData
                          ? Colors.green
                          : null,
                      gradientColors: audioProvider.extractingData
                          ? [
                              Colors.lime,
                              Colors.lightGreenAccent,
                              Colors.greenAccent,
                            ]
                          : null,

                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          Provider.of<AudioProvider>(
                            context,
                            listen: false,
                          ).extractAudio(_urlController.text.trim());
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    (audioProvider.extractionData != null)
                        ? Column(
                            children: [
                              const SizedBox(height: 16),
                              Image.asset(AppAssets.middleFinger, height: 150),
                              const SizedBox(height: 16),
                              Text(
                                'Download Ready',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                audioProvider.extractionData?.title ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              // const SizedBox(height: 8),
                              // Text(
                              //   "Format: ${audioProvider.extractionData?.duration ?? ''}",
                              //   textAlign: TextAlign.center,
                              //   style: Theme.of(context).textTheme.titleSmall
                              //       ?.copyWith(fontWeight: FontWeight.bold),
                              // ),
                              const SizedBox(height: 8),
                              CustomAnimatedButton(
                                text: audioProvider.downloadingAudio
                                    ? "Downloading ${(audioProvider.downloadProgress * 100).toStringAsFixed(0)}%"
                                    : 'Download Audio',
                                textColor: audioProvider.downloadingAudio
                                    ? Colors.green
                                    : null,
                                gradientColors: audioProvider.downloadingAudio
                                    ? [
                                        Colors.lime,
                                        Colors.lightGreenAccent,
                                        Colors.greenAccent,
                                      ]
                                    : null,
                                onTap: audioProvider.downloadingAudio
                                    ? () {}
                                    : () => audioProvider.downloadAudio(),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
