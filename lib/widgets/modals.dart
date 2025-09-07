// ignore_for_file: deprecated_member_use, sized_box_for_whitespace

import 'package:flutter/material.dart';
import '../models.dart';

class FreelancerModal extends StatelessWidget {
  final Freelancer freelancer;

  const FreelancerModal({
    super.key,
    required this.freelancer, required onAssignProject,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;
    final maxWidth = isMobile ? screenSize.width - 32 : 600.0;
    final maxHeight = isMobile ? screenSize.height - 80 : 700.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(isMobile ? 16 : 40),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          minHeight: 400,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF262047),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${freelancer.name} - Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  children: [
                    // Profile Image and Basic Info
                    Column(
                      children: [
                        Container(
                          width: isMobile ? 80 : 96,
                          height: isMobile ? 80 : 96,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF33CFFF), Colors.blue],
                            ),
                            borderRadius: BorderRadius.circular(isMobile ? 40 : 48),
                          ),
                          child: Center(
                            child: Text(
                              freelancer.name.isNotEmpty ? freelancer.name[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 36 : 44,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          freelancer.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          freelancer.role,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: isMobile ? 14 : 16,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 20 : 24),
                    
                    // Contact and Performance
                    isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
                    
                    SizedBox(height: isMobile ? 16 : 20),
                    
                    // Skills
                    _buildSkillsSection(isMobile),
                    
                    SizedBox(height: isMobile ? 16 : 20),
                    
                    // Bio
                    _buildBioSection(isMobile),
                  ],
                ),
              ),
            ),
            
            // Action Buttons
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: isMobile ? _buildMobileButtons(context) : _buildDesktopButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildContactSection(true),
        const SizedBox(height: 16),
        _buildPerformanceSection(true),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildContactSection(false)),
          const SizedBox(width: 24),
          Expanded(child: _buildPerformanceSection(false)),
        ],
      ),
    );
  }

  Widget _buildContactSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Contact Information",
            style: TextStyle(
              color: const Color(0xFF33CFFF),
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 14 : 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildContactRow(Icons.email_outlined, freelancer.email, isMobile),
          const SizedBox(height: 8),
          _buildContactRow(Icons.phone_outlined, freelancer.phone, isMobile),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text, bool isMobile) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[400], size: isMobile ? 16 : 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 12 : 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Performance",
            style: TextStyle(
              color: const Color(0xFF33CFFF),
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 14 : 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: isMobile ? 16 : 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Rating: ${freelancer.rating}/5.0",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.work_outline, color: Colors.grey[400], size: isMobile ? 16 : 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Workload: ${freelancer.workload}%",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(bool isMobile) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Skills & Expertise",
            style: TextStyle(
              color: const Color(0xFF33CFFF),
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 14 : 16,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: freelancer.skills
                .map((skill) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : 12,
                        vertical: isMobile ? 4 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF33CFFF).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                          color: const Color(0xFF33CFFF),
                          fontSize: isMobile ? 11 : 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection(bool isMobile) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bio",
            style: TextStyle(
              color: const Color(0xFF33CFFF),
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 14 : 16,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              freelancer.bio,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: isMobile ? 13 : 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showAssignProjectDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF1EC0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Assign Project"),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF33CFFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Message"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Projects"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showAssignProjectDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF1EC0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Assign Project"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF33CFFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Send Message"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("View Projects"),
          ),
        ),
      ],
    );
  }

  void _showAssignProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AssignProjectDialog(freelancerName: freelancer.name),
    );
  }
}

class AssignProjectDialog extends StatefulWidget {
  final String freelancerName;

  const AssignProjectDialog({
    super.key,
    required this.freelancerName,
  });

  @override
  State<AssignProjectDialog> createState() => _AssignProjectDialogState();
}

class _AssignProjectDialogState extends State<AssignProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _dueDate;

  @override
  void dispose() {
    _companyController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;
    final maxWidth = isMobile ? screenSize.width - 32 : 500.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(isMobile ? 16 : 40),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: screenSize.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF262047),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Assign Project to ${widget.freelancerName}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: const EdgeInsets.all(6),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company Name
                      Text(
                        "Company Name",
                        style: TextStyle(
                          color: const Color(0xFF33CFFF),
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 13 : 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _companyController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter company name",
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF33CFFF),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a company name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Project Title
                      Text(
                        "Project Title",
                        style: TextStyle(
                          color: const Color(0xFF33CFFF),
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 13 : 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter project title",
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF33CFFF),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a project title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Project Description
                      Text(
                        "Project Description",
                        style: TextStyle(
                          color: const Color(0xFF33CFFF),
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 13 : 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter project description",
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF33CFFF),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a project description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Start Date
                      Text(
                        "Start Date",
                        style: TextStyle(
                          color: const Color(0xFF33CFFF),
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 13 : 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectStartDate(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.grey[400],
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _startDate != null
                                    ? "${_startDate!.day}/${_startDate!.month}/${_startDate!.year}"
                                    : "Select start date",
                                style: TextStyle(
                                  color: _startDate != null
                                      ? Colors.white
                                      : Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Due Date
                      Text(
                        "Due Date",
                        style: TextStyle(
                          color: const Color(0xFF33CFFF),
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 13 : 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDueDate(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.grey[400],
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _dueDate != null
                                    ? "${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}"
                                    : "Select due date",
                                style: TextStyle(
                                  color: _dueDate != null
                                      ? Colors.white
                                      : Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Action Buttons
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _assignProject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF1EC0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Assign Project"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF33CFFF),
              onPrimary: Colors.white,
              surface: Color(0xFF262047),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? (_startDate?.add(const Duration(days: 7)) ?? DateTime.now().add(const Duration(days: 7))),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF33CFFF),
              onPrimary: Colors.white,
              surface: Color(0xFF262047),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _assignProject() {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a start date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_dueDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a due date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Here you can handle the project assignment logic
      // For now, just show a success message and close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Project "${_titleController.text}" assigned to ${widget.freelancerName}'),
          backgroundColor: const Color(0xFF33CFFF),
        ),
      );
      
      Navigator.of(context).pop();
      Navigator.of(context).pop(); // Close the freelancer modal as well
    }
  }
}

class ProjectModal extends StatelessWidget {
  final Project project;

  const ProjectModal({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;
    final maxWidth = isMobile ? screenSize.width - 32 : 700.0;
    final maxHeight = isMobile ? screenSize.height - 80 : 800.0;

    Color statusColor;
    String statusText;
    
    switch (project.status) {
      case ProjectStatus.inProgress:
        statusColor = const Color(0xFF33CFFF);
        statusText = "In Progress";
        break;
      case ProjectStatus.completed:
        statusColor = Colors.green;
        statusText = "Completed";
        break;
      case ProjectStatus.overdue:
        statusColor = Colors.red;
        statusText = "Overdue";
        break;
      case ProjectStatus.pending:
        statusColor = Colors.amber;
        statusText = "Pending";
        break;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(isMobile ? 16 : 40),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          minHeight: 400,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF262047),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${project.name} - Details",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Information and Progress
                    isMobile 
                        ? _buildMobileProjectInfo(statusColor, statusText, isMobile)
                        : _buildDesktopProjectInfo(statusColor, statusText, isMobile),
                    
                    SizedBox(height: isMobile ? 16 : 24),
                    
                    // Project Description
                    _buildDescriptionSection(isMobile),
                    
                    SizedBox(height: isMobile ? 16 : 20),
                    
                    // Recent Updates
                    _buildUpdatesSection(isMobile),
                  ],
                ),
              ),
            ),
            
            // Action Buttons
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: isMobile ? _buildMobileProjectButtons() : _buildDesktopProjectButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileProjectInfo(Color statusColor, String statusText, bool isMobile) {
    return Column(
      children: [
        _buildProjectInfoSection(isMobile),
        const SizedBox(height: 16),
        _buildProgressSection(statusColor, statusText, isMobile),
      ],
    );
  }

  Widget _buildDesktopProjectInfo(Color statusColor, String statusText, bool isMobile) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildProjectInfoSection(isMobile)),
          const SizedBox(width: 24),
          Expanded(child: _buildProgressSection(statusColor, statusText, isMobile)),
        ],
      ),
    );
  }

  Widget _buildProjectInfoSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Project Information",
            style: TextStyle(
              color: const Color(0xFF33CFFF),
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 14 : 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.person_outline, "Assigned to: ${project.assignee}", isMobile),
          _buildInfoRow(Icons.calendar_today_outlined, "Due Date: ${project.dueDate}", isMobile),
          _buildInfoRow(Icons.flag_outlined, "Priority: ${project.priority.name.toUpperCase()}", isMobile),
        ],
      ),
    );
  }

  Widget _buildProgressSection(Color statusColor, String statusText, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Progress & Status",
            style: TextStyle(
              color: const Color(0xFF33CFFF),
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 14 : 16,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 12,
              vertical: isMobile ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: isMobile ? 11 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Progress",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 13 : 14,
                ),
              ),
              Text(
                "${project.progress}%",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 13 : 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: (project.progress / 100).clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF33CFFF), Color(0xFFFF1EC0)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(bool isMobile) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Project Description",
            style: TextStyle(
              color: const Color(0xFF33CFFF),
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 14 : 16,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              project.description,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: isMobile ? 13 : 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatesSection(bool isMobile) {
    final updates = [
      {"text": "Database schema completed and tested", "time": "2 hours ago"},
      {"text": "UI mockups approved by client", "time": "1 day ago"},
      {"text": "Project milestone 2 completed", "time": "3 days ago"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Updates",
          style: TextStyle(
            color: const Color(0xFF33CFFF),
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
        const SizedBox(height: 12),
        ...updates.map((update) => Container(
          padding: EdgeInsets.all(isMobile ? 10 : 12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey[800]?.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                update["text"]!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 13 : 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                update["time"]!,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: isMobile ? 11 : 12,
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildMobileProjectButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF1EC0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text("Message ${project.assignee}"),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF33CFFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("View Files"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Edit"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopProjectButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF1EC0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text("Message ${project.assignee}"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF33CFFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("View Files"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Edit Project"),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400], size: isMobile ? 16 : 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 12 : 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}