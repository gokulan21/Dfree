// ignore_for_file: deprecated_member_use, use_super_parameters

import 'package:flutter/material.dart';
import '../widgets/data_models.dart';

class ClientsPage extends StatelessWidget {
  final Map<String, ClientData> clientData;
  final Map<String, ProjectData> projectData;
  final String? selectedClientId;
  final Function(String?) onClientSelected;

  const ClientsPage({
    Key? key,
    required this.clientData,
    required this.projectData,
    required this.selectedClientId,
    required this.onClientSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedClientId != null) {
      return _buildClientDetail(context, selectedClientId!);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'All Clients',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width < 768 ? 1 : 
                             MediaQuery.of(context).size.width < 1024 ? 2 : 3,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.2,
            ),
            itemCount: clientData.length,
            itemBuilder: (context, index) {
              final client = clientData.values.elementAt(index);
              return _buildClientCard(context, client);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClientCard(BuildContext context, ClientData client) {
    return InkWell(
      onTap: () => onClientSelected(client.id),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentCyan.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with avatar and name
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: client.avatarColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      client.avatar,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textWhite,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        client.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: textWhite,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        client.contact,
                        style: TextStyle(
                          fontSize: 11,
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
            const SizedBox(height: 12),
            
            // Contact details
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildContactRow(Icons.email, client.email, accentCyan),
                  const SizedBox(height: 3),
                  _buildContactRow(Icons.phone, client.phone, accentCyan),
                  const SizedBox(height: 3),
                  _buildContactRow(Icons.business, client.industry, accentCyan),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Footer with projects and revenue
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${client.activeProjects} Active Projects',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[400],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      client.totalRevenue,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      color: accentPink,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: textWhite,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildClientDetail(BuildContext context, String clientId) {
    final client = clientData[clientId];
    if (client == null) return Container();

    final clientProjects = client.projects
        .map((id) => projectData[id])
        .where((p) => p != null)
        .cast<ProjectData>()
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentCyan.withOpacity(0.1),
              border: Border.all(color: accentCyan.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => onClientSelected(null),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people, color: accentCyan, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Clients',
                        style: TextStyle(color: accentCyan, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    client.name,
                    style: const TextStyle(color: textWhite, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Back Button
          ElevatedButton.icon(
            onPressed: () => onClientSelected(null),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Clients'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentCyan.withOpacity(0.2),
              foregroundColor: accentCyan,
              side: const BorderSide(color: accentCyan),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Client Info Header
          Container(
            padding: const EdgeInsets.all(24),
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
              children: [
                // Responsive layout for client header
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      // Mobile layout - stack vertically
                      return Column(
                        children: [
                          _buildClientAvatar(client),
                          const SizedBox(height: 16),
                          _buildClientInfo(client),
                          const SizedBox(height: 16),
                          _buildClientStats(client),
                        ],
                      );
                    } else {
                      // Desktop layout - horizontal
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildClientAvatar(client),
                          const SizedBox(width: 24),
                          Expanded(child: _buildClientInfo(client)),
                          const SizedBox(width: 24),
                          _buildClientStats(client),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
                Container(
                  height: 1,
                  color: Colors.grey[700],
                ),
                const SizedBox(height: 24),
                
                // Contact and About sections
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      // Mobile layout - stack vertically
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildContactSection(client),
                          const SizedBox(height: 24),
                          _buildAboutSection(client),
                        ],
                      );
                    } else {
                      // Desktop layout - horizontal
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildContactSection(client)),
                          const SizedBox(width: 24),
                          Expanded(child: _buildAboutSection(client)),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Client Projects
          Container(
            padding: const EdgeInsets.all(24),
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
              children: [
                const Text(
                  'Projects',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: textWhite,
                  ),
                ),
                const SizedBox(height: 16),
                if (clientProjects.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No projects found for this client.',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width < 768 ? 1 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: clientProjects.length,
                    itemBuilder: (context, index) {
                      return _buildProjectCard(context, clientProjects[index]);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientAvatar(ClientData client) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: client.avatarColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          client.avatar,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: textWhite,
          ),
        ),
      ),
    );
  }

  Widget _buildClientInfo(ClientData client) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          client.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textWhite,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        const SizedBox(height: 8),
        Text(
          '${client.contact} • ${client.industry}',
          style: TextStyle(
            color: Colors.grey[400],
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          'Client since ${client.joinDate} • Last contact: ${client.lastContact}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildClientStats(ClientData client) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          children: [
            Text(
              client.projects.length.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: accentCyan,
              ),
            ),
            Text(
              'Total Projects',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        const SizedBox(width: 24),
        Column(
          children: [
            Text(
              client.totalRevenue,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Revenue',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactSection(ClientData client) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textWhite,
          ),
        ),
        const SizedBox(height: 8),
        _buildContactRow(Icons.email, client.email, accentCyan),
        const SizedBox(height: 4),
        _buildContactRow(Icons.phone, client.phone, accentCyan),
        const SizedBox(height: 4),
        _buildContactRow(Icons.business, client.industry, accentCyan),
      ],
    );
  }

  Widget _buildAboutSection(ClientData client) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textWhite,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          client.description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[300],
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectData project) {
    return InkWell(
      onTap: () => _showProjectDetail(context, project.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgSecondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accentCyan.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textWhite,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: getPriorityColor(project.priority).withOpacity(0.2),
                    border: Border.all(color: getPriorityColor(project.priority)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    getPriorityText(project.priority),
                    style: TextStyle(
                      fontSize: 9,
                      color: getPriorityColor(project.priority),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.status == ProjectStatus.completed 
                        ? 'Completed: ${project.completedDate}' 
                        : 'Due: ${project.dueDate}',
                    style: TextStyle(
                      fontSize: 10,
                      color: project.status == ProjectStatus.overdue 
                          ? Colors.red 
                          : Colors.grey[400],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: getStatusColor(project.status).withOpacity(0.2),
                    border: Border.all(color: getStatusColor(project.status)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    getStatusText(project.status),
                    style: TextStyle(
                      fontSize: 9,
                      color: getStatusColor(project.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: project.progress / 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: project.status == ProjectStatus.completed 
                        ? const LinearGradient(colors: [Colors.green, Colors.green])
                        : const LinearGradient(colors: [accentCyan, accentPink]),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${project.progress}% Complete',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                ),
                Text(
                  project.budget,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProjectDetail(BuildContext context, String projectId) {
    final project = projectData[projectId];
    if (project == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: bgPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 800,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[700]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          project.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textWhite,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey[400]),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Project details for ${project.title}',
                      style: const TextStyle(color: textWhite),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}