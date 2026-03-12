class ExperienceItem {
  String company;
  String role;
  String duration;
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

class ResumeModel {
  String fullName;
  String email;
  String phone;
  String address;
  String jobTitle;
  String summary;
  String skills;
  String languages;
  String selectedTemplate;

  String? imagePath;
  String github;
  String linkedin;

  // --- 🌟 NAYE CUSTOMIZATION FEATURES 🌟 ---
  String themeColor;       // Hex code format e.g., '#1A237E'
  double pageMargin;       // Page ke kinaron ka fasla
  double headingTextSize;  // Headings ka size
  double bodyTextSize;     // Normal text ka size
  String fontStyle;        // Font ka style (e.g., 'Roboto', 'OpenSans')

  List<ExperienceItem> experienceList;
  List<EducationItem> educationList;
  List<ProjectItem> projectList;

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

    // Default Styling Values
    this.themeColor = '#1A237E',
    this.pageMargin = 40.0,
    this.headingTextSize = 18.0,
    this.bodyTextSize = 11.0,
    this.fontStyle = 'Roboto',

    List<ExperienceItem>? experienceList,
    List<EducationItem>? educationList,
    List<ProjectItem>? projectList,
  }) :
        experienceList = experienceList ?? [],
        educationList = educationList ?? [],
        projectList = projectList ?? [];
}