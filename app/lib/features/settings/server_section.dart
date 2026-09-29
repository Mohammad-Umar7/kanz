import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import '../../core/data/models/models.dart';
import '../../core/design/design.dart';
import '../../core/state/connectivity_providers.dart';
import '../../core/state/core_providers.dart';
import '../../core/state/settings_providers.dart';
import '../../l10n/l10n.dart';

/// Whether [text] is a usable backend address: http or https with a host.
bool isValidServerUrl(String text) {
  final uri = Uri.tryParse(text.trim());
  return uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty;
}

/// Settings > Server: the backend address, a connection test, the status in
/// words and, when connected, what the server runs (models, knowledge base,
/// places sources).
class ServerSection extends ConsumerStatefulWidget {
  const ServerSection({super.key});

  @override
  ConsumerState<ServerSection> createState() => _ServerSectionState();
}

class _ServerSectionState extends ConsumerState<ServerSection> {
  late final TextEditingController _url = TextEditingController(
    text: ref.read(apiBaseUrlProvider),
  );
  String? _error;

  /// The user asked for a check that has not answered yet.
  bool _testing = false;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  bool get _edited => _url.text.trim() != ref.read(apiBaseUrlProvider);

  Future<void> _save() async {
    final text = _url.text.trim();
    if (!isValidServerUrl(text)) {
      setState(() => _error = context.l10n.settingsServerInvalid);
      return;
    }
    setState(() => _error = null);
    FocusScope.of(context).unfocus();
    final controller = ref.read(settingsProvider.notifier);
    // The build default is stored as "no override", so a later change of
    // the default still applies.
    await controller.setApiBaseUrl(text == Env.apiBase ? null : text);
    // A new address rebuilds the client, which re-runs the health check;
    // the same address needs an explicit refresh.
    setState(() => _testing = true);
    ref.invalidate(healthProvider);
  }

  Future<void> _reset() async {
    await ref.read(settingsProvider.notifier).setApiBaseUrl(null);
    _url.text = Env.apiBase;
    setState(() => _error = null);
  }

  void _test() {
    setState(() => _testing = true);
    ref.invalidate(healthProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = ref.watch(backendStatusProvider);
    final health = ref.watch(healthProvider).value;
    final override = ref.watch(settingsProvider.select((s) => s.apiBaseUrl));
    final checking = status == BackendStatus.checking;
    // Only a check the user started turns the button into a spinner, so a
    // slow launch check never blocks saving a new address.
    if (!checking) _testing = false;
    final testing = _testing && checking;

    final detail = switch (status) {
      BackendStatus.offline => l10n.settingsServerOfflineDetail,
      BackendStatus.unreachable => l10n.settingsServerUnreachableDetail,
      BackendStatus.online when health != null && !health.aiConfigured =>
        l10n.settingsServerNoAi,
      _ => null,
    };

    return Padding(
      padding: KanzSpace.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A URL reads left to right in Arabic too.
          KanzTextField(
            label: l10n.settingsServerUrl,
            controller: _url,
            hint: Env.apiBase,
            helper: l10n.settingsServerHelper(Env.apiBase),
            error: _error,
            prefixIcon: KanzIcons.website,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            autocorrect: false,
            enableSuggestions: false,
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: KanzSpace.s16),
          _StatusLine(status: status, detail: detail),
          const SizedBox(height: KanzSpace.s16),
          // Full width, like every other action in Kanz.
          KanzButton.secondary(
            label: _edited ? l10n.settingsServerSave : l10n.settingsServerTest,
            // Saving tests the new address, so no storage glyph.
            icon: _edited ? null : KanzIcons.retry,
            loading: testing,
            loadingLabel: l10n.settingsServerTesting,
            expand: true,
            onPressed: _edited ? _save : _test,
          ),
          if (override != null) ...[
            const SizedBox(height: KanzSpace.s8),
            KanzButton.tertiary(
              label: l10n.settingsServerReset,
              expand: true,
              onPressed: _reset,
            ),
          ],
          if (status == BackendStatus.online && health != null) ...[
            const SizedBox(height: KanzSpace.s24),
            _HealthDetails(health: health),
          ],
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.status, required this.detail});

  final BackendStatus status;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    final color = switch (status) {
      BackendStatus.online => c.positive,
      BackendStatus.checking => c.inkSecondary,
      BackendStatus.offline || BackendStatus.unreachable => c.danger,
    };
    return Semantics(
      liveRegion: true,
      container: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 7),
            child: status == BackendStatus.checking
                ? SizedBox.square(
                    dimension: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: color,
                    ),
                  )
                : Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
          const SizedBox(width: KanzSpace.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(backendStatusLabel(l10n, status), style: t.titleMedium),
                if (detail != null) ...[
                  const SizedBox(height: KanzSpace.s2),
                  Text(
                    detail!,
                    style: t.bodySmall?.copyWith(color: c.inkSecondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthDetails extends StatelessWidget {
  const _HealthDetails({required this.health});

  final HealthResponse health;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String modelLabel(String role) => switch (role) {
      'vision' => l10n.settingsModelVision,
      'text' => l10n.settingsModelText,
      'image' => l10n.settingsModelImage,
      'embed' => l10n.settingsModelEmbed,
      _ => role,
    };
    final places = [
      if (health.placesGoogle) 'Google Places',
      if (health.placesOsm) 'OpenStreetMap',
    ];
    final type = context.kanzType;
    Widget code(String value) =>
        Text(value, style: type.dataStrong, textDirection: TextDirection.ltr);
    // Model ids run one per row, so a long id ("gemini-3.1-flash-image")
    // stays on one line at 360 dp instead of breaking at a hyphen.
    return DataGrid(
      entries: [
        for (final entry in health.models.entries)
          DataGridEntry(
            modelLabel(entry.key),
            span: true,
            child: code(entry.value),
          ),
        DataGridEntry(
          l10n.settingsKnowledge,
          child: Text(
            health.ragReady
                ? l10n.settingsKnowledgeDocs(health.knowledgeDocs)
                : l10n.settingsKnowledgeKeyword(health.knowledgeDocs),
            style: type.dataStrong,
          ),
        ),
        DataGridEntry(l10n.settingsServerVersion, child: code(health.version)),
        DataGridEntry(
          l10n.settingsPlaces,
          span: true,
          value: places.isEmpty
              ? l10n.settingsPlacesNone
              : places.join(l10n.settingsToolsListSeparator),
        ),
      ],
    );
  }
}
