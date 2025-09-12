// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../models/project_model.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/client_card.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class FreelancerClientsPage extends StatefulWidget {
  const FreelancerClientsPage({super.key});

  @override
  State<FreelancerClientsPage> createState() => _FreelancerClientsPageState();
}

class _FreelancerClientsPageState extends State<FreelancerClientsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  List<UserModel> _clients = [];
  Map<String, List<ProjectModel>> _clientProjects = {};
  bool _isLoading = true;
  String? _selectedClientId;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        // Get projects where freelancer is assigned
        final projectsQuery = await FirebaseFirestore.instance
            .collection('projects')
            .where('freelancerId', isEqualTo: currentUser.uid)
            .where('isActive', isEqualTo: true)
            .get();

        final projects = projectsQuery.docs
            .map((doc) => ProjectModel.fromFirestore(doc))
            .toList();

        // Get unique client IDs
        final clientIds = projects.map((p) => p.clientId).toSet().toList();

        // Get client details
        final clients = <UserModel>[];
        final clientProjectsMap = <String, List<ProjectModel>>{};

        for (String clientId in clientIds) {
          try {
            final clientDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(clientId)
                .get();

            if (clientDoc.exists) {
              final client = UserModel.fromFirestore(clientDoc);
              clients.add(client);

              // Group projects by client
              final clientProjects = projects
                  .where((p) => p.clientId == clientId)
                  .toList();
              clientProjectsMap[clientId] = clientProjects;
            }
          } catch (e) {
            debugPrint('Error loading client $clientId: $e');
          }
        }

        setState(() {
          _clients = clients;
          _clientProjects = clientProjectsMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading clients: ${e.toString()}'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    if (_selectedClientId != null) {
      return _buildClientDetail(_selectedClientId!);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clients Grid
          if (_clients.isEmpty)
            CustomCard(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No clients yet',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Complete projects to build your client base',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 3;
                if (constraints.maxWidth < 1200) crossAxisCount = 2;
                if (constraints.maxWidth < 768) crossAxisCount = 1;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _clients.length,
                  itemBuilder: (context, index) {
                    final client = _clients[index];
                    final projects = _clientProjects[client.id] ?? [];
                    return ClientCard(
                      client: client,
                      projectCount: projects.length,
                      onTap: () => _selectClient(client.id),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildClientDetail(String clientId) {
    final client = _clients.firstWhere((c) => c.id == clientId);
    final projects = _clientProjects[clientId] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Row(
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _selectedClientId = null),
                icon: const Icon(Icons.arrow_back, color: AppColors.accentCyan),
                label: const Text(
                  'Back to Clients',
                  style: TextStyle(color: AppColors.accentCyan),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Client Info Header
          CustomCard(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentCyan.withOpacity(0.1),
                    AppColors.accentPink.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return Column(
                      children: [
                        _buildClientAvatar(client),
                        const SizedBox(height: 16),
                        _buildClientInfo(client),
                        const SizedBox(height: 16),
                        _buildClientStats(projects),
                      ],
                    );
                  } else {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildClientAvatar(client),
                        const SizedBox(width: 24),
                        Expanded(child: _buildClientInfo(client)),
                        const SizedBox(width: 24),
                        _buildClientStats(projects),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Projects with this client
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Projects with ${client.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (projects.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No projects with this client yet.',
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        return _buildProjectCard(projects[index]);
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientAvatar(UserModel client) {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accentCyan, AppColors.accentPink],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          client.name.isNotEmpty ? client.name[0].toUpperCase() : 'C',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildClientInfo(UserModel client) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          client.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          client.email,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 16,
          ),
        ),
        if (client.company?.isNotEmpty == true) ...[
          const SizedBox(height: 4),
          Text(
            client.company!,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 14,
            ),
          ),
        ],
        if (client.phone?.isNotEmpty == true) ...[
          const SizedBox(height: 4),
          Text(
            client.phone!,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildClientStats(List<ProjectModel> projects) {
    final completedProjects = projects.where((p) => p.status == ProjectStatus.completed).length;
    final activeProjects = projects.where((p) => p.status == ProjectStatus.inProgress).length;
    final totalEarnings = projects
        .where((p) => p.status == ProjectStatus.completed)
        // ignore: avoid_types_as_parameter_names
        .fold(0.0, (sum, p) => sum + (p.paidAmount ?? 0));

    return Column(
      children: [
        _buildStatItem('Total Projects', projects.length.toString()),
        const SizedBox(height: 12),
        _buildStatItem('Completed', completedProjects.toString()),
        const SizedBox(height: 12),
        _buildStatItem('Active', activeProjects.toString()),
        const SizedBox(height: 12),
        _buildStatItem('Earnings', '\$${totalEarnings.toStringAsFixed(0)}'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.accentCyan,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectCard(ProjectModel project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Budget: \$${project.budget.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.successGreen,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: project.progress / 100,
                  backgroundColor: AppColors.borderColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentCyan),
                ),
                const SizedBox(height: 4),
                Text(
                  '${project.progress}% Complete',
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(project.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              project.statusDisplayName,
              style: TextStyle(
                color: _getStatusColor(project.status),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.pending:
        return AppColors.warningYellow;
      case ProjectStatus.inProgress:
        return AppColors.accentCyan;
      case ProjectStatus.completed:
        return AppColors.successGreen;
      case ProjectStatus.cancelled:
        return AppColors.dangerRed;
      case ProjectStatus.onHold:
        return AppColors.textGrey;
    }
  }

  void _selectClient(String clientId) {
    setState(() {
      _selectedClientId = clientId;
    });
  }
}