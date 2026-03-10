class ResumeModel {
  String fullName;
  String email;
  String phone;
  String jobTitle;
  String summary;
  String skills;
  String selectedTemplate; // ⬅️ Naya addition

  ResumeModel({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.jobTitle = '',
    this.summary = '',
    this.skills = '',
    this.selectedTemplate = 'Classic', // ⬅️ Default design 'Classic' hoga
  });
}