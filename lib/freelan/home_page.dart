// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'projects_page.dart';
import 'clients_page.dart';
import 'documents_page.dart';
import 'reports_page.dart';
import 'notes_todo_page.dart';
import 'settings_page.dart';
import '../widgets/data_models.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? _selectedClientId;
  bool _showCategorizedView = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Color constants
  static const Color bgPrimary = Color(0xFF1E1A3C);
  static const Color bgSecondary = Color(0xFF1B1737);
  static const Color accentPink = Color(0xFFFF1EC0);
  static const Color accentCyan = Color(0xFF33CFFF);
  static const Color textWhite = Colors.white;

  // Data structures
  final Map<String, ProjectData> projectData = {
    'ecommerce-1': const ProjectData(
      id: 'ecommerce-1',
      title: 'E-commerce Website',
      client: 'TechCorp Inc.',
      clientId: 'techcorp',
      status: ProjectStatus.inProgress,
      priority: Priority.high,
      progress: 75,
      dueDate: 'Dec 1, 2024',
      description: 'Full-featured e-commerce website with payment integration and inventory management.',
      budget: '\$8,500',
      timeSpent: '65h',
      notes: 'Payment gateway integration in progress. Stripe and PayPal support required.',
      tasks: [
        TaskData(name: 'Project planning', status: TaskStatus.done, id: ''),
        TaskData(name: 'Database design', status: TaskStatus.done, id: ''),
        TaskData(name: 'Frontend development', status: TaskStatus.done, id: ''),
        TaskData(name: 'Payment integration', status: TaskStatus.progress, id: ''),
        TaskData(name: 'Testing & deployment', status: TaskStatus.todo, id: ''),
      ],
    ),
    'mobile-app-1': const ProjectData(
      id: 'mobile-app-1',
      title: 'Mobile App Design',
      client: 'StartupXYZ',
      clientId: 'startupxyz',
      status: ProjectStatus.inProgress,
      priority: Priority.high,
      progress: 45,
      dueDate: 'Nov 30, 2024',
      description: 'iOS and Android app design for fitness tracking application.',
      budget: '\$3,500',
      timeSpent: '32h',
      notes: 'Focus on intuitive navigation and data visualization for fitness metrics.',
      tasks: [
        TaskData(name: 'User research', status: TaskStatus.done, id: ''),
        TaskData(name: 'Wireframing', status: TaskStatus.done, id: ''),
        TaskData(name: 'UI design', status: TaskStatus.progress, id: ''),
        TaskData(name: 'Prototyping', status: TaskStatus.todo, id: ''),
        TaskData(name: 'Design handoff', status: TaskStatus.todo, id: ''),
      ],
    ),
    'brand-identity-1': const ProjectData(
      id: 'brand-identity-1',
      title: 'Brand Identity Package',
      client: 'Creative Agency',
      clientId: 'creative-agency',
      status: ProjectStatus.inProgress,
      priority: Priority.medium,
      progress: 90,
      dueDate: 'Nov 28, 2024',
      description: 'Complete brand identity including logo, colors, typography, and guidelines.',
      budget: '\$2,200',
      timeSpent: '28h',
      notes: 'Final brand guidelines document in preparation. Client loves the chosen direction.',
      tasks: [
        TaskData(name: 'Brand research', status: TaskStatus.done, id: ''),
        TaskData(name: 'Logo concepts', status: TaskStatus.done, id: ''),
        TaskData(name: 'Color palette', status: TaskStatus.done, id: ''),
        TaskData(name: 'Typography selection', status: TaskStatus.done, id: ''),
        TaskData(name: 'Brand guidelines', status: TaskStatus.progress, id: ''),
      ],
    ),
    'marketing-campaign': const ProjectData(
      id: 'marketing-campaign',
      title: 'Digital Marketing Campaign',
      client: 'Marketing Pro Agency',
      clientId: 'marketing-pro',
      status: ProjectStatus.overdue,
      priority: Priority.high,
      progress: 30,
      dueDate: 'Nov 18, 2024',
      description: 'Comprehensive digital marketing campaign for Q4 product launch.',
      budget: '\$3,200',
      timeSpent: '18h',
      notes: 'Campaign assets need approval. Social media strategy finalization pending.',
      tasks: [
        TaskData(name: 'Market research', status: TaskStatus.done, id: ''),
        TaskData(name: 'Strategy development', status: TaskStatus.done, id: ''),
        TaskData(name: 'Asset creation', status: TaskStatus.progress, id: ''),
        TaskData(name: 'Campaign setup', status: TaskStatus.todo, id: ''),
        TaskData(name: 'Launch & monitoring', status: TaskStatus.todo, id: ''),
      ],
    ),
    'website-redesign': const ProjectData(
      id: 'website-redesign',
      title: 'Website Redesign',
      client: 'Creative Agency',
      clientId: 'creative-agency',
      status: ProjectStatus.completed,
      priority: Priority.high,
      progress: 100,
      dueDate: '',
      completedDate: 'Nov 10, 2024',
      description: 'Complete redesign of agency website with modern aesthetics and improved UX.',
      budget: '\$5,600',
      timeSpent: '48h',
      notes: 'Project completed successfully. Client extremely satisfied with the results.',
      tasks: [
        TaskData(name: 'Design research', status: TaskStatus.done, id: ''),
        TaskData(name: 'Wireframes & mockups', status: TaskStatus.done, id: ''),
        TaskData(name: 'Frontend development', status: TaskStatus.done, id: ''),
        TaskData(name: 'Content migration', status: TaskStatus.done, id: ''),
        TaskData(name: 'Launch & optimization', status: TaskStatus.done, id: ''),
      ],
    ),
  };

  final Map<String, ClientData> clientData = {
    'techcorp': const ClientData(
      id: 'techcorp',
      name: 'TechCorp Inc.',
      contact: 'Sarah Johnson',
      email: 'sarah@techcorp.com',
      phone: '+1 (555) 123-4567',
      industry: 'Technology',
      avatar: 'TC',
      avatarColor: LinearGradient(colors: [Colors.blue, Colors.cyan]),
      totalRevenue: '\$15,200',
      projects: ['ecommerce-1'],
      activeProjects: 1,
      description: 'Leading technology company specializing in enterprise software solutions and digital transformation.',
      joinDate: 'Jan 2024',
      lastContact: '2 days ago',
    ),
    'startupxyz': const ClientData(
      id: 'startupxyz',
      name: 'StartupXYZ',
      contact: 'Mike Chen',
      email: 'mike@startupxyz.com',
      phone: '+1 (555) 987-6543',
      industry: 'Startup',
      avatar: 'SX',
      avatarColor: LinearGradient(colors: [Colors.purple, Colors.pink]),
      totalRevenue: '\$8,500',
      projects: ['mobile-app-1'],
      activeProjects: 1,
      description: 'Innovative fitness technology startup focused on creating engaging health and wellness experiences.',
      joinDate: 'Mar 2024',
      lastContact: '1 day ago',
    ),
    'creative-agency': const ClientData(
      id: 'creative-agency',
      name: 'Creative Agency',
      contact: 'Lisa Rodriguez',
      email: 'lisa@creativeagency.com',
      phone: '+1 (555) 456-7890',
      industry: 'Creative',
      avatar: 'CA',
      avatarColor: LinearGradient(colors: [Colors.green, Colors.teal]),
      totalRevenue: '\$7,800',
      projects: ['brand-identity-1', 'website-redesign'],
      activeProjects: 1,
      description: 'Full-service creative agency specializing in brand identity and digital experiences.',
      joinDate: 'Feb 2024',
      lastContact: '3 days ago',
    ),
    'marketing-pro': const ClientData(
      id: 'marketing-pro',
      name: 'Marketing Pro Agency',
      contact: 'David Wilson',
      email: 'david@marketingpro.com',
      phone: '+1 (555) 789-0123',
      industry: 'Marketing',
      avatar: 'MP',
      avatarColor: LinearGradient(colors: [Colors.orange, Colors.red]),
      totalRevenue: '\$3,200',
      projects: ['marketing-campaign'],
      activeProjects: 1,
      description: 'Digital marketing agency focused on performance-driven campaigns and brand growth.',
      joinDate: 'Oct 2024',
      lastContact: '5 days ago',
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgPrimary,
      drawer: MediaQuery.of(context).size.width < 1024 ? _buildSidebar() : null,
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width >= 1024) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildMainContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 256,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bgSecondary, Color(0xFF1A1635)],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'FreelanceHub',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textWhite,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (MediaQuery.of(context).size.width < 1024)
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[400]),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(0, Icons.home, 'Dashboard'),
                _buildNavItem(1, Icons.folder, 'Projects'),
                _buildNavItem(2, Icons.people, 'Clients'),
                _buildNavItem(3, Icons.chat, 'Communication'),
                _buildNavItem(4, Icons.description, 'Documents'),
                _buildNavItem(5, Icons.bar_chart, 'Reports'),
                _buildNavItem(6, Icons.note, 'Notes & To-Do'),
                _buildNavItem(7, Icons.settings, 'Settings'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    bool isActive = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? accentPink.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isActive ? accentPink : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: textWhite, size: 20),
        title: Text(
          title,
          style: const TextStyle(color: textWhite, fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          setState(() {
            _selectedIndex = index;
            _selectedClientId = null;
          });
          if (MediaQuery.of(context).size.width < 1024) {
            Navigator.of(context).pop();
          }
        },
        dense: true,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        border: Border(bottom: BorderSide(color: Colors.grey[700]!)),
      ),
      child: Row(
        children: [
          if (MediaQuery.of(context).size.width < 1024)
            IconButton(
              icon: const Icon(Icons.menu, color: textWhite),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          Expanded(
            child: Text(
              _getPageTitle(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: textWhite,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [accentPink, accentCyan]),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'JD',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textWhite,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return ProjectsPage(
          projectData: projectData,
          clientData: clientData,
          showCategorizedView: _showCategorizedView,
          onViewToggle: (bool categorized) {
            setState(() {
              _showCategorizedView = categorized;
            });
          }, onProjectUpdate: (String p1, ProjectData p2) {  },
        );
      case 2:
        return ClientsPage(
          clientData: clientData,
          projectData: projectData,
          selectedClientId: _selectedClientId,
          onClientSelected: (String? clientId) {
            setState(() {
              _selectedClientId = clientId;
            });
          },
        );
      case 3:
        return _buildCommunication();
      case 4:
        return const DocumentsPage();
      case 5:
        return ReportsPage(
          projectData: projectData,
          clientData: clientData,
        );
      case 6:
        return NotesToDoPage();
      case 7:
        return const SettingsPage();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              if (constraints.maxWidth < 600) {
                crossAxisCount = 2;
              } else if (constraints.maxWidth < 900) {
                crossAxisCount = 3;
              } else {
                crossAxisCount = 4;
              }
              
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatsCard('Active Projects', '14', accentCyan, Icons.folder),
                  _buildStatsCard('Total Clients', '6', accentPink, Icons.people),
                  _buildStatsCard('Tasks Due', '8', Colors.yellow, Icons.task),
                  _buildStatsCard('Revenue', '\$45.2K', Colors.green, Icons.attach_money),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 1024) {
                return Column(
                  children: [
                    _buildRecentProjects(),
                    const SizedBox(height: 24),
                    _buildTopClients(),
                  ],
                );
              } else {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _buildRecentProjects()),
                      const SizedBox(width: 24),
                      Expanded(child: _buildTopClients()),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [bgSecondary, Color(0xFF252147)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentProjects() {
    return Container(
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
            'Recent Projects',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textWhite,
            ),
          ),
          const SizedBox(height: 16),
          ...projectData.values.take(3).map((project) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () => _showProjectDetail(project.id),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: textWhite,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            project.client,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey[700],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: project.progress / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [accentCyan, accentPink],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${project.progress}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTopClients() {
    return Container(
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
            'Top Clients by Revenue',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textWhite,
            ),
          ),
          const SizedBox(height: 16),
          ...clientData.values.take(3).map((client) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () => _showClientDetail(client.id),
                child: Row(
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
                            fontSize: 12,
                            color: textWhite,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: textWhite,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${client.projects.length} Projects',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              client.totalRevenue,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
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
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCommunication() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Communication',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: textWhite,
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 1024) {
                return Column(
                  children: [
                    _buildRecentConversations(),
                    const SizedBox(height: 24),
                    _buildChatArea(),
                  ],
                );
              } else {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 1, child: _buildRecentConversations()),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _buildChatArea()),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentConversations() {
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
        children: [
          const Text(
            'Recent Conversations',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textWhite,
            ),
          ),
          const SizedBox(height: 12),
          ...[
            {'name': 'Sarah Johnson', 'message': 'Great work on the wireframes...', 'time': '2h', 'color': Colors.blue},
            {'name': 'Mike Chen', 'message': 'When can we schedule the review?', 'time': '1d', 'color': Colors.purple},
            {'name': 'Lisa Rodriguez', 'message': 'The logo concepts look amazing!', 'time': '2d', 'color': Colors.green},
          ].map((conversation) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: conversation['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (conversation['name'] as String).split(' ').map((n) => n[0]).join(''),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textWhite,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversation['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: textWhite,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          conversation['message'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    conversation['time'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Sarah Johnson - E-commerce Project',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textWhite,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.attach_file, color: accentCyan),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('SJ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[700],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Hi John! I\'ve reviewed the latest wireframes and they look fantastic. The user flow is much clearer now.',
                                style: TextStyle(fontSize: 14, color: textWhite),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Today 2:30 PM',
                              style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: accentPink,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Thank you! I\'m glad you like the improvements. Should we proceed with the prototype phase?',
                                style: TextStyle(fontSize: 14, color: textWhite),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Today 2:45 PM',
                              style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [accentPink, accentCyan]),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('JD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textWhite)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: const Color(0xFF1F2937),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: accentCyan),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: const TextStyle(color: textWhite),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {},
                child: const Icon(Icons.send, size: 18),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentPink,
                  foregroundColor: textWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                  minimumSize: const Size(48, 48),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showProjectDetail(String projectId) {
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 600) {
                          return Column(
                            children: [
                              _buildProjectOverview(project),
                              const SizedBox(height: 24),
                              _buildTaskBreakdown(project),
                            ],
                          );
                        } else {
                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: _buildProjectOverview(project)),
                                const SizedBox(width: 24),
                                Expanded(child: _buildTaskBreakdown(project)),
                              ],
                            ),
                          );
                        }
                      },
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

  Widget _buildProjectOverview(ProjectData project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textWhite,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            _buildOverviewRow('Client:', project.client),
            _buildOverviewRow('Status:', _getStatusText(project.status)),
            _buildOverviewRow('Priority:', _getPriorityText(project.priority)),
            _buildOverviewRow(
              project.status == ProjectStatus.completed ? 'Completed:' : 'Due Date:',
              project.completedDate ?? project.dueDate,
            ),
            _buildOverviewRow('Budget:', project.budget),
            _buildOverviewRow('Time Spent:', project.timeSpent),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Progress',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textWhite,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(6),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: project.progress / 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: project.status == ProjectStatus.completed 
                    ? const LinearGradient(colors: [Colors.green, Colors.green])
                    : const LinearGradient(colors: [accentCyan, accentPink]),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${project.progress}% Complete',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Description',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textWhite,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          project.description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[300],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Notes',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textWhite,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          project.notes,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: textWhite),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskBreakdown(ProjectData project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Task Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textWhite,
          ),
        ),
        const SizedBox(height: 16),
        ...project.tasks.map((task) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getTaskStatusColor(task.status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.name,
                    style: TextStyle(
                      color: task.status == TaskStatus.done ? Colors.grey[500] : textWhite,
                      decoration: task.status == TaskStatus.done ? TextDecoration.lineThrough : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTaskStatusColor(task.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getTaskStatusText(task.status),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getTaskStatusColor(task.status),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 24),
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textWhite,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.5,
          children: [
            _buildQuickActionButton('Edit Project', Icons.edit, accentPink),
            _buildQuickActionButton('Message Client', Icons.message, Colors.grey[700]!),
            _buildQuickActionButton('View Documents', Icons.description, Colors.grey[700]!),
            _buildQuickActionButton('Log Time', Icons.access_time, Colors.grey[700]!),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 14),
      label: Flexible(
        child: Text(
          title,
          style: const TextStyle(fontSize: 10),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      ),
    );
  }

  void _showClientDetail(String clientId) {
    setState(() {
      _selectedClientId = clientId;
      _selectedIndex = 2;
    });
  }

  String _getPageTitle() {
    if (_selectedClientId != null) {
      return clientData[_selectedClientId!]?.name ?? 'Client Details';
    }
    
    switch (_selectedIndex) {
      case 0: return 'Dashboard';
      case 1: return 'Projects';
      case 2: return 'Clients';
      case 3: return 'Communication';
      case 4: return 'Documents';
      case 5: return 'Reports';
      case 6: return 'Notes & To-Do';
      case 7: return 'Settings';
      default: return 'FreelanceHub';
    }
  }

  String _getStatusText(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.todo: return 'To Do';
      case ProjectStatus.inProgress: return 'In Progress';
      case ProjectStatus.overdue: return 'Overdue';
      case ProjectStatus.completed: return 'Completed';
    }
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.low: return 'Low';
      case Priority.medium: return 'Medium';
      case Priority.high: return 'High';
    }
  }

  String _getTaskStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo: return 'To Do';
      case TaskStatus.progress: return 'In Progress';
      case TaskStatus.done: return 'Done';
    }
  }

  Color _getTaskStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo: return Colors.grey;
      case TaskStatus.progress: return Colors.yellow;
      case TaskStatus.done: return Colors.green;
    }
  }
}