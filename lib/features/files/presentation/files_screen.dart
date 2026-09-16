import 'dart:io';

import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/constants/pi_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/device/data/raspberry_pi_device.dart';
import '../../../features/document/data/models/saved_document.dart';
import '../../../features/document/data/services/document_storage_service.dart';
import '../../../shared/models/document_output.dart';
import '../../../shared/widgets/empty_state.dart';

/// Files tab — two sub-tabs:
///
/// **Saved** — locally persisted documents (survive app restart).
///
/// **Session** — live captures from the current Pi session.
class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key, this.device});

  final RaspberryPiDevice? device;

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  _Tab _tab = _Tab.saved;

  // ── Saved docs ────────────────────────────────────────────────────
  final _storageService = DocumentStorageService();
  List<SavedDocument> _savedDocs = [];
  bool _savedLoading = false;
  String? _savedError;

  // ── Session captures ──────────────────────────────────────────────
  List<Map<String, dynamic>> _sessionCaptures = [];
  bool _sessionLoading = false;
  String? _sessionError;

  @override
  void initState() {
    super.initState();
    _loadSavedDocs();
  }

  // ─── Load saved documents ─────────────────────────────────────────

  Future<void> _loadSavedDocs() async {
    setState(() {
      _savedLoading = true;
      _savedError = null;
    });
    try {
      final docs = await _storageService.loadAllDocuments();
      if (mounted) {
        setState(() {
          _savedDocs = docs;
          _savedLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _savedError = 'Failed to load documents: $e';
          _savedLoading = false;
        });
      }
    }
  }

  // ─── Load session captures ────────────────────────────────────────

  Future<void> _loadSessionCaptures() async {
    if (widget.device == null) {
      setState(() =>
          _sessionError = 'Not connected to a Raspberry Pi session.');
      return;
    }
    setState(() {
      _sessionLoading = true;
      _sessionError = null;
    });
    try {
      final list = await widget.device!.getCaptureList();
      if (mounted) {
        setState(() {
          _sessionCaptures = list;
          _sessionLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _sessionError = 'Failed to load session captures: $e';
          _sessionLoading = false;
        });
      }
    }
  }

  // ─── Navigation ───────────────────────────────────────────────────

  Future<void> _openSavedDoc(SavedDocument doc) async {
    final deleted = await Navigator.of(context).pushNamed(
      AppRoutes.savedDocumentDetail,
      arguments: doc,
    );
    if (deleted == true) {
      await _loadSavedDocs();
    }
  }

  Future<void> _openSessionCapture(int pageNumber) async {
    if (widget.device == null) return;

    // Check if capture is already locally saved
    final existingDoc = await _storageService.findByPageNumber(pageNumber);
    if (existingDoc != null && mounted) {
      await _openSavedDoc(existingDoc);
      return;
    }

    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading capture…'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final details = await widget.device!.getCaptureDetails(pageNumber);
      if (!mounted) return;
      Navigator.of(context).pop();

      if (details == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load capture details.')),
        );
        return;
      }

      final imageRawUrl = details['image_url'] as String?;
      final originalText = ((details['text'] as String?) ?? '').trim();
      final summaryText = ((details['summary'] as String?) ?? '').trim();

      final output = DocumentOutput(
        originalText: originalText.isNotEmpty
            ? originalText
            : 'No text extracted.',
        summaryText: summaryText.isNotEmpty
            ? summaryText
            : 'No summary available.',
        imageUrl: widget.device!.getFullUrl(imageRawUrl),
        originalAudioUrl:
            '${PiConfig.baseUrl}/capture/$pageNumber/audio/original',
        summaryAudioUrl:
            '${PiConfig.baseUrl}/capture/$pageNumber/audio/summary',
      );

      // Auto-sync session capture to local storage
      SavedDocument? savedDoc;
      try {
        savedDoc = await _storageService.saveCompleteDocument(
          originalText: output.originalText,
          summaryText: output.summaryText,
          pageNumber: pageNumber,
          imageUrl: output.imageUrl,
          originalAudioUrl: output.originalAudioUrl,
          summaryAudioUrl: output.summaryAudioUrl,
        );
      } catch (_) {}

      if (!mounted) return;

      await Navigator.of(context).pushNamed(
        AppRoutes.documentResults,
        arguments: DocumentResultsArgs(
          output: output,
          savedDocument: savedDoc,
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Search + refresh ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: SearchBar(
                  hintText: _tab == _Tab.saved
                      ? 'Search saved documents'
                      : 'Search session captures',
                  leading: const Icon(Icons.search),
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _tab == _Tab.saved
                    ? _loadSavedDocs
                    : _loadSessionCaptures,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),

        // ── Tab chips ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Saved'),
                selected: _tab == _Tab.saved,
                onSelected: (_) {
                  setState(() => _tab = _Tab.saved);
                  _loadSavedDocs();
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Session'),
                selected: _tab == _Tab.session,
                onSelected: (_) {
                  setState(() => _tab = _Tab.session);
                  _loadSessionCaptures();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Content ───────────────────────────────────────────────
        Expanded(
          child: _tab == _Tab.saved
              ? _buildSavedTab()
              : _buildSessionTab(),
        ),
      ],
    );
  }

  // ─── Saved tab ────────────────────────────────────────────────────

  Widget _buildSavedTab() {
    if (_savedLoading) return _loadingWidget('Loading saved documents…');
    if (_savedError != null) {
      return _errorWidget(_savedError!, _loadSavedDocs);
    }
    if (_savedDocs.isEmpty) {
      return const EmptyState(
        title: 'No saved documents',
        subtitle:
            'After viewing scan results, tap "Save Complete Document" '
            'to save it permanently here.',
      );
    }
    return RefreshIndicator(
      onRefresh: _loadSavedDocs,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _savedDocs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final doc = _savedDocs[index];
          return _SavedDocCard(document: doc, onTap: () => _openSavedDoc(doc));
        },
      ),
    );
  }

  // ─── Session tab ──────────────────────────────────────────────────

  Widget _buildSessionTab() {
    if (_sessionLoading) return _loadingWidget('Loading session captures…');
    if (_sessionError != null) {
      return _errorWidget(_sessionError!, _loadSessionCaptures);
    }
    if (_sessionCaptures.isEmpty) {
      return const EmptyState(
        title: 'No session captures yet',
        subtitle:
            'Captures from the current Pi session appear here.\n'
            'Connect to the Pi and capture a document first.',
      );
    }
    return RefreshIndicator(
      onRefresh: _loadSessionCaptures,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _sessionCaptures.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final capture = _sessionCaptures[index];
          final page = capture['page_number'] as int? ?? (index + 1);
          final imageUrl = capture['image_url'] as String? ?? '';
          return _SessionCaptureCard(
            pageNumber: page,
            imageUrl: imageUrl,
            onTap: () => _openSessionCapture(page),
          );
        },
      ),
    );
  }

  // ─── Common state widgets ─────────────────────────────────────────

  Widget _loadingWidget(String msg) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.purple),
            const SizedBox(height: 16),
            Text(msg, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      );

  Widget _errorWidget(String error, VoidCallback retry) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined,
                  size: 40, color: Colors.black38),
              const SizedBox(height: 12),
              Text(error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab enum
// ─────────────────────────────────────────────────────────────────────────────

enum _Tab { saved, session }

// ─────────────────────────────────────────────────────────────────────────────
// Saved document card
// ─────────────────────────────────────────────────────────────────────────────

class _SavedDocCard extends StatelessWidget {
  const _SavedDocCard({required this.document, required this.onTap});

  final SavedDocument document;
  final VoidCallback onTap;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final d = document.captureDate;
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    final dateStr =
        '${d.day} ${_months[d.month - 1]} ${d.year} · $h:$m';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: _buildThumbnail(document.imagePath),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.documentTitle,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(dateStr,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black54)),
                    const SizedBox(height: 6),
                    Text(
                      document.textPreview,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.black54),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(String? imagePath) {
    if (imagePath != null) {
      final f = File(imagePath);
      if (f.existsSync()) {
        return Image.file(f, fit: BoxFit.cover);
      }
    }
    return Container(
      color: AppColors.cloud,
      child: const Center(
        child: Icon(Icons.description_outlined,
            color: Colors.black38, size: 26),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Session capture card
// ─────────────────────────────────────────────────────────────────────────────

class _SessionCaptureCard extends StatelessWidget {
  const _SessionCaptureCard({
    required this.pageNumber,
    required this.imageUrl,
    required this.onTap,
  });

  final int pageNumber;
  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _placeholder(),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return _placeholder();
                          },
                        )
                      : _placeholder(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Page $pageNumber',
                      style:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to view OCR text and AI summary',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.cloud,
        child: const Center(
          child: Icon(Icons.image_outlined,
              color: Colors.black38, size: 24),
        ),
      );
}
