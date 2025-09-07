// ignore_for_file: deprecated_member_use, use_super_parameters, prefer_final_fields, unnecessary_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/data_models.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({Key? key}) : super(key: key);

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  List<Map<String, dynamic>> _documentsList = [
    {
      'title': 'Project Contract',
      'client': 'TechCorp Inc.',
      'size': 'PDF • 2.4 MB',
      'date': 'Nov 15',
      'icon': Icons.description,
      'color': accentCyan,
    },
    {
      'title': 'Logo Design Mockups',
      'client': 'Creative Agency',
      'size': 'PNG • 5.2 MB',
      'date': 'Nov 22',
      'icon': Icons.image,
      'color': accentPink,
    },
    {
      'title': 'Project Proposal Document',
      'client': 'StartupXYZ',
      'size': 'DOCX • 1.8 MB',
      'date': 'Nov 18',
      'icon': Icons.description,
      'color': Colors.yellow,
    },
    {
      'title': 'UI/UX Wireframes',
      'client': 'TechCorp Inc.',
      'size': 'FIG • 12.1 MB',
      'date': 'Nov 23',
      'icon': Icons.code,
      'color': Colors.green,
    },
    {
      'title': 'Brand Guidelines',
      'client': 'Creative Agency',
      'size': 'PDF • 8.7 MB',
      'date': 'Nov 20',
      'icon': Icons.palette,
      'color': Colors.purple,
    },
    {
      'title': 'Technical Specifications',
      'client': 'StartupXYZ',
      'size': 'DOCX • 3.2 MB',
      'date': 'Nov 19',
      'icon': Icons.engineering,
      'color': Colors.orange,
    },
  ];

  bool _isUploading = false;

  // Method to simulate file upload dialog
  Future<void> _showFileUploadDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: bgSecondary,
          title: const Text(
            'Upload File',
            style: TextStyle(color: textWhite),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose file type to upload:',
                style: TextStyle(color: textWhite),
              ),
              const SizedBox(height: 20),
              _buildFileTypeOption('PDF Document', Icons.picture_as_pdf, Colors.red, 'pdf'),
              _buildFileTypeOption('Word Document', Icons.description, Colors.blue, 'docx'),
              _buildFileTypeOption('Image File', Icons.image, Colors.green, 'png'),
              _buildFileTypeOption('Presentation', Icons.slideshow, Colors.orange, 'pptx'),
              _buildFileTypeOption('Spreadsheet', Icons.table_chart, Colors.green, 'xlsx'),
              _buildFileTypeOption('Design File', Icons.code, Colors.purple, 'fig'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: accentCyan),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFileTypeOption(String name, IconData icon, Color color, String extension) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        _simulateFileUpload(name, icon, color, extension);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              name,
              style: const TextStyle(
                color: textWhite,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Simulate file upload process
  Future<void> _simulateFileUpload(String fileName, IconData icon, Color color, String extension) async {
    setState(() {
      _isUploading = true;
    });

    // Show uploading feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Uploading $fileName...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );

    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate random file size
    final sizes = ['1.2 MB', '2.4 MB', '3.8 MB', '5.1 MB', '0.8 MB', '12.3 MB'];
    final randomSize = sizes[(DateTime.now().millisecondsSinceEpoch % sizes.length)];

    // Add the new file to the documents list
    setState(() {
      _documentsList.insert(0, {
        'title': 'New $fileName',
        'client': 'Current User',
        'size': '${extension.toUpperCase()} • $randomSize',
        'date': _formatCurrentDate(),
        'icon': icon,
        'color': color,
      });
      _isUploading = false;
    });

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fileName uploaded successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _formatCurrentDate() {
    DateTime now = DateTime.now();
    List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with responsive layout
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                // Mobile layout - stack vertically
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Documents',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: textWhite,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _showFileUploadDialog,
                        icon: _isUploading 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.upload_file),
                        label: Text(_isUploading ? 'Uploading...' : 'Upload File'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentPink,
                          foregroundColor: textWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Desktop layout - horizontal
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Documents',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: textWhite,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _showFileUploadDialog,
                      icon: _isUploading 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.upload_file),
                      label: Text(_isUploading ? 'Uploading...' : 'Upload File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentPink,
                        foregroundColor: textWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24),
          
          // Documents Grid with responsive column count
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              if (constraints.maxWidth < 600) {
                crossAxisCount = 1; // Mobile: 1 column
              } else if (constraints.maxWidth < 900) {
                crossAxisCount = 2; // Tablet: 2 columns
              } else if (constraints.maxWidth < 1200) {
                crossAxisCount = 3; // Small desktop: 3 columns
              } else {
                crossAxisCount = 4; // Large desktop: 4 columns
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.1,
                ),
                itemCount: _documentsList.length,
                itemBuilder: (context, index) {
                  final doc = _documentsList[index];
                  return _buildDocumentCard(
                    context,
                    doc['title']!,
                    doc['client']!,
                    doc['size']!,
                    doc['date']!,
                    doc['icon'] as IconData,
                    doc['color'] as Color,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 32),
          
          // Recent Activity Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textWhite,
                ),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activityList.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final activity = _activityList[index];
                  return _buildActivityItem(
                    activity['action']!,
                    activity['client']!,
                    activity['time']!,
                    activity['icon'] as IconData,
                    activity['color'] as Color,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    String title,
    String client,
    String size,
    String date,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentCyan.withOpacity(0.05),
            accentPink.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentCyan.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with icon and menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.more_vert, 
                    color: Colors.grey[400], 
                    size: 20,
                  ),
                  onPressed: () => _showDocumentMenu(context, title),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Title with proper overflow handling
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: textWhite,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          
          // Client with overflow handling
          Text(
            client,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Spacer to push footer to bottom
          const Spacer(),
          
          // Footer with size and date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  size,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String action,
    String client,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  action,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: textWhite,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$client • $time',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDocumentMenu(BuildContext context, String documentTitle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              documentTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textWhite,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            _buildMenuOption(Icons.download, 'Download', () {}),
            _buildMenuOption(Icons.share, 'Share', () {}),
            _buildMenuOption(Icons.edit, 'Rename', () {}),
            _buildMenuOption(Icons.delete, 'Delete', () {}, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? dangerRed : textWhite,
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isDestructive ? dangerRed : textWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Static data for recent activity
  static const List<Map<String, dynamic>> _activityList = [
    {
      'action': 'UI/UX Wireframes uploaded',
      'client': 'TechCorp Inc.',
      'time': '2 hours ago',
      'icon': Icons.upload_file,
      'color': Colors.green,
    },
    {
      'action': 'Logo Design Mockups updated',
      'client': 'Creative Agency',
      'time': '1 day ago',
      'icon': Icons.edit,
      'color': Colors.blue,
    },
    {
      'action': 'Project Contract downloaded',
      'client': 'TechCorp Inc.',
      'time': '2 days ago',
      'icon': Icons.download,
      'color': Colors.yellow,
    },
    {
      'action': 'Brand Guidelines shared',
      'client': 'Creative Agency',
      'time': '3 days ago',
      'icon': Icons.share,
      'color': Colors.purple,
    },
    {
      'action': 'Technical Specifications uploaded',
      'client': 'StartupXYZ',
      'time': '4 days ago',
      'icon': Icons.upload_file,
      'color': Colors.orange,
    },
  ];
}