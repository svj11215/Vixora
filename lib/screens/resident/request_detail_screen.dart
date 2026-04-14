/// DetailScreen for viewing and managing a specific visitor request.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vixora/core/constants/app_constants.dart';
import 'package:vixora/models/visitor_request_model.dart';
import 'package:vixora/widgets/status_badge.dart';

class RequestDetailScreen extends StatefulWidget {
  /// The ID of the visitor request document in Firestore.
  final String requestId;

  const RequestDetailScreen({required this.requestId, super.key});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  late final TextEditingController _resolutionNotesController;

  @override
  void initState() {
    super.initState();
    _resolutionNotesController = TextEditingController();
  }

  @override
  void dispose() {
    _resolutionNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visitor Request')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(AppConstants.visitorRequestsCollection)
            .doc(widget.requestId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Request not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final requestModel = VisitorRequestModel.fromMap(
            data,
            widget.requestId,
          );
          final status = requestModel.status;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Visitor photo ──
                if (requestModel.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: requestModel.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => SizedBox(
                        height: 200,
                        child: Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Icon(Icons.image_not_supported)),
                  ),
                const SizedBox(height: 24),

                // ── Visitor details ──
                _buildDetailSection('Visitor Information', [
                  _buildDetailTile('Name', requestModel.visitorName),
                  _buildDetailTile('Phone', requestModel.visitorPhone),
                  _buildDetailTile('Purpose', requestModel.purpose),
                ]),

                const SizedBox(height: 24),

                // ── Request details ──
                _buildDetailSection('Request Information', [
                  _buildDetailTile('Status', requestModel.status.toUpperCase()),
                  _buildDetailTile(
                    'Submitted At',
                    _formatTimestamp(requestModel.createdAt),
                  ),
                  if (requestModel.approvedAt != null)
                    _buildDetailTile(
                      'Actioned At',
                      _formatTimestamp(requestModel.approvedAt!),
                    ),
                ]),

                const SizedBox(height: 24),

                // ── Action buttons — only if pending ──
                if (status == AppConstants.statusPending) ...[
                  TextField(
                    controller: _resolutionNotesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Resolution note (optional)',
                      hintText: 'Add a note about your decision...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              34,
                              177,
                              76,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text(
                            'Approve',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () => _updateStatus(
                            context,
                            widget.requestId,
                            AppConstants.statusApproved,
                            requestModel.residentId,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              185,
                              28,
                              28,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.close, color: Colors.white),
                          label: const Text(
                            'Reject',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () => _updateStatus(
                            context,
                            widget.requestId,
                            AppConstants.statusRejected,
                            requestModel.residentId,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else
                  Center(child: StatusBadge(status: status)),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds a section with a title and list of detail tiles.
  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  /// Builds a single detail tile with label and value.
  Widget _buildDetailTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Formats a Firestore Timestamp to a readable string.
  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Updates the status of the visitor request in Firestore.
  Future<void> _updateStatus(
    BuildContext context,
    String requestId,
    String newStatus,
    String residentId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection(AppConstants.visitorRequestsCollection)
          .doc(requestId)
          .update({
            AppConstants.fieldStatus: newStatus,
            AppConstants.fieldApprovedAt: FieldValue.serverTimestamp(),
            if (_resolutionNotesController.text.isNotEmpty)
              AppConstants.fieldResolutionNote: _resolutionNotesController.text,
          });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request ${newStatus.toLowerCase()}'),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
