class ResumeModel {
  String fullName;
  String email;
  String phone;
  String jobTitle;
  String summary;
  String skills;
  String selectedTemplate;

  // --- Naye Canva-Level Features ---
  String? imagePath; // Profile tasweer ka path
  String experience; // Kaam ka tajriba
  String education; // Taleem
  String github; // GitHub profile link
  String linkedin; // LinkedIn profile

  ResumeModel({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.jobTitle = '',
    this.summary = '',
    this.skills = '',
    this.selectedTemplate = 'Classic',
    this.imagePath,
    this.experience = '',
    this.education = '',
    this.github = '',
    this.linkedin = '',
  });
}