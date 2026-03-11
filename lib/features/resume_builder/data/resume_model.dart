// ⬅️ Nayi Classes Dynamic Lists Ke Liye
class ExperienceItem {
  String company;
  String role;
  String duration; // e.g., "Jan 2024 - Present"
  String description;

  ExperienceItem({this.company = '', this.role = '', this.duration = '', this.description = ''});
}

class EducationItem {
  String institution;
  String degree;
  String year;
  String grade;

  EducationItem({this.institution = '', this.degree = '', this.year = '', this.grade = ''});
}

class ProjectItem {
  String title;
  String description;
  String link;

  ProjectItem({this.title = '', this.description = '', this.link = ''});
}

// ⬅️ Main Model Update Ho Gaya
class ResumeModel {
  String fullName;
  String email;
  String phone;
  String address; // Naya: Location/Address
  String jobTitle;
  String summary;
  String skills;
  String languages; // Naya: Zabanain
  String selectedTemplate;

  String? imagePath;
  String github;
  String linkedin;

  // --- Naye Dynamic Lists ---
  List<ExperienceItem> experienceList;
  List<EducationItem> educationList;
  List<ProjectItem> projectList; // Naya: Portfolio/Projects

  ResumeModel({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.jobTitle = '',
    this.summary = '',
    this.skills = '',
    this.languages = '',
    this.selectedTemplate = 'Classic',
    this.imagePath,
    this.github = '',
    this.linkedin = '',
    List<ExperienceItem>? experienceList,
    List<EducationItem>? educationList,
    List<ProjectItem>? projectList,
  }) :
  // Agar list null ho to khali list assign kar do
        experienceList = experienceList ?? [],
        educationList = educationList ?? [],
        projectList = projectList ?? [];
}