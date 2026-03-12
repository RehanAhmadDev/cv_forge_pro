class ExperienceItem {
  String company;
  String role;
  String duration;
  String description;

  ExperienceItem({this.company = '', this.role = '', this.duration = '', this.description = ''});

  // Data ko save karne ke liye
  Map<String, dynamic> toJson() => {
    'company': company,
    'role': role,
    'duration': duration,
    'description': description,
  };

  // Save kiye hue data ko wapas padhne ke liye
  factory ExperienceItem.fromJson(Map<String, dynamic> json) => ExperienceItem(
    company: json['company'] ?? '',
    role: json['role'] ?? '',
    duration: json['duration'] ?? '',
    description: json['description'] ?? '',
  );
}

class EducationItem {
  String institution;
  String degree;
  String year;
  String grade;

  EducationItem({this.institution = '', this.degree = '', this.year = '', this.grade = ''});

  Map<String, dynamic> toJson() => {
    'institution': institution,
    'degree': degree,
    'year': year,
    'grade': grade,
  };

  factory EducationItem.fromJson(Map<String, dynamic> json) => EducationItem(
    institution: json['institution'] ?? '',
    degree: json['degree'] ?? '',
    year: json['year'] ?? '',
    grade: json['grade'] ?? '',
  );
}

class ProjectItem {
  String title;
  String description;
  String link;

  ProjectItem({this.title = '', this.description = '', this.link = ''});

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'link': link,
  };

  factory ProjectItem.fromJson(Map<String, dynamic> json) => ProjectItem(
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    link: json['link'] ?? '',
  );
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

  String themeColor;
  double pageMargin;
  double headingTextSize;
  double bodyTextSize;
  String fontStyle;

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

  // Poori CV ko database mein save karne ke liye
  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'address': address,
    'jobTitle': jobTitle,
    'summary': summary,
    'skills': skills,
    'languages': languages,
    'selectedTemplate': selectedTemplate,
    'imagePath': imagePath,
    'github': github,
    'linkedin': linkedin,
    'themeColor': themeColor,
    'pageMargin': pageMargin,
    'headingTextSize': headingTextSize,
    'bodyTextSize': bodyTextSize,
    'fontStyle': fontStyle,
    'experienceList': experienceList.map((e) => e.toJson()).toList(),
    'educationList': educationList.map((e) => e.toJson()).toList(),
    'projectList': projectList.map((e) => e.toJson()).toList(),
  };

  // Database se CV wapas load karne ke liye
  factory ResumeModel.fromJson(Map<String, dynamic> json) => ResumeModel(
    fullName: json['fullName'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    address: json['address'] ?? '',
    jobTitle: json['jobTitle'] ?? '',
    summary: json['summary'] ?? '',
    skills: json['skills'] ?? '',
    languages: json['languages'] ?? '',
    selectedTemplate: json['selectedTemplate'] ?? 'Classic',
    imagePath: json['imagePath'],
    github: json['github'] ?? '',
    linkedin: json['linkedin'] ?? '',
    themeColor: json['themeColor'] ?? '#1A237E',
    pageMargin: json['pageMargin']?.toDouble() ?? 40.0,
    headingTextSize: json['headingTextSize']?.toDouble() ?? 18.0,
    bodyTextSize: json['bodyTextSize']?.toDouble() ?? 11.0,
    fontStyle: json['fontStyle'] ?? 'Roboto',
    experienceList: (json['experienceList'] as List<dynamic>?)?.map((e) => ExperienceItem.fromJson(e)).toList() ?? [],
    educationList: (json['educationList'] as List<dynamic>?)?.map((e) => EducationItem.fromJson(e)).toList() ?? [],
    projectList: (json['projectList'] as List<dynamic>?)?.map((e) => ProjectItem.fromJson(e)).toList() ?? [],
  );
}