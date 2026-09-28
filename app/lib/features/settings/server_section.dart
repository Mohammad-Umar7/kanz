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
          _AddressField(
            label: l10n.settingsServerUrl,
            controller: _url,
            helper: l10n.settingsServerHelper(Env.apiBase),
            error: _error,
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: KanzSpace.s16),
          _StatusLine(status: status, detail: detail),
          const SizedBox(height: KanzSpace.s16),
          Wrap(
            spacing: KanzSpace.s8,
            runSpacing: KanzSpace.s8,
            children: [
              KanzButton.secondary(
                label: _edited
                    ? l10n.settingsServerSave
                    : l10n.settingsServerTest,
                icon: _edited ? KanzIcons.save : KanzIcons.retry,
                loading: testing,
                loadingLabel: l10n.settingsServerTesting,
                onPressed: _edited ? _save : _test,
              ),
              if (override != null)
                KanzButton.tertiary(
                  label: l10n.settingsServerReset,
                  onPressed: _reset,
                ),
            ],
          ),
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
    Widget code(String value) => Text(
      value,
      style: context.kanzType.dataStrong,
      textDirection: TextDirection.ltr,
    );
    return DataGrid(
      entries: [
        for (final entry in health.models.entries)
          DataGridEntry(modelLabel(entry.key), child: code(entry.value)),
        DataGridEntry(
          l10n.settingsKnowledge,
          value: health.ragReady
              ? l10n.settingsKnowledgeDocs(health.knowledgeDocs)
              : l10n.settingsKnowledgeKeyword(health.knowledgeDocs),
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

/// The server address field: a [KanzTextField] layout whose text always
/// runs left to right, since a URL reads that way in Arabic too.
class _AddressField extends StatelessWidget {
  const _AddressField({
    required this.label,
    required this.controller,
    required this.helper,
    required this.error,
    required this.onChanged,
    required this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String helper;
  final String? error;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final t = context.textStyles;
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: t.labelMedium),
          const SizedBox(height: KanzSpace.s8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            style: t.bodyLarge,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: Env.apiBase,
              hintTextDirection: TextDirection.ltr,
              helperText: helper,
              errorText: error,
              helperMaxLines: 3,
              errorMaxLines: 3,
              prefixIcon: const Icon(KanzIcons.website, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
