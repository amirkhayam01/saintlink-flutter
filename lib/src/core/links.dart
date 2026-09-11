import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/common.dart';

/// Opens a web page in the system browser, telling the customer if it cannot.
Future<void> openLink(BuildContext context, String url) async {
  final opened = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) showMessage(context, 'Could not open $url');
}
