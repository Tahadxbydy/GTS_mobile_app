import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/assets.dart';
import '../../providers/audio_provider.dart';
import '../../providers/home_provider.dart';
import '../widgets/custom_animated_button.dart';
import 'download_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Server Health Status')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Consumer<HomeProvider>(
          builder: (context, provider, child) {
            final isHealthy = !provider.hasError && !provider.isLoading;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: provider.isLoading
                  ? [Image.asset(height: 100, AppAssets.girigo)]
                  : [
                      Image.asset(
                        isHealthy ? AppAssets.gojoOk : AppAssets.nobara,
                        height: 200,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isHealthy ? 'Server is Online' : 'Server is Offline',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isHealthy
                            ? 'All background services are healthy and responding.'
                            : (provider.errorMessage ??
                                  'Unable to connect to backend service.'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 40),
                      isHealthy
                          ? Column(
                              children: [
                                Text(
                                  "Service: ${provider.healthResponse?.service}",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 16),
                                Text(
                                  "Status: ${provider.healthResponse?.status}",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 16),
                                Text(
                                  "Version: ${provider.healthResponse?.version}",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 16),
                                Text(
                                  "Time: ${provider.healthResponse?.timeStamp}",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 16),
                              ],
                            )
                          : SizedBox(),
                      ElevatedButton.icon(
                        onPressed: () {
                          provider.checkHealth();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Re-check Status'),
                      ),
                      const SizedBox(height: 16),
                      CustomAnimatedButton(
                        text: 'Proceed to Download',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            DownloadScreen.routeName,
                          );
                        },
                      ),
                    ],
            );
          },
        ),
      ),
    );
  }
}
