import '../models/student_profile.dart';
import '../models/team.dart';
import '../models/team_role.dart';
import '../models/team_request.dart';
import '../models/team_task.dart';
import '../models/chat_message.dart';
import '../models/filter_preset.dart';

class SeedData {
  // Current user's default profile (Zayan Ahmed, 7th Semester Software Engineering)
  static StudentProfile get defaultCurrentUser => StudentProfile(
    id: 'user_current',
    name: 'Zayan Ahmed',
    department: 'Software Engineering',
    semester: 7,
    skills: ['Flutter', 'Dart', 'UI/UX Design', 'Firebase'],
    interests: ['Mobile Apps', 'Artificial Intelligence', 'UI/UX'],
    projectType: 'Final Year Project',
    availability: 'Full-time (20+ hrs/wk)',
    bio:
        'Passionate Flutter & cross-platform mobile developer looking to build an impactful AI-powered campus assistant FYP.',
    avatar: 'avatar_1',
    isCurrentUser: true,
  );

  // 16 Diverse & Realistic Student Profiles
  static List<StudentProfile> get seedStudents => [
    StudentProfile(
      id: 'stu_1',
      name: 'Hamza Tariq',
      department: 'Software Engineering',
      semester: 7,
      skills: ['Flutter', 'Dart', 'Firebase', 'State Management'],
      interests: ['Mobile Apps', 'Software Engineering', 'UI/UX'],
      projectType: 'Final Year Project',
      availability: 'Full-time (20+ hrs/wk)',
      bio:
          'Experienced in Flutter mobile architecture, clean code practices, and reactive UI patterns. Ready for FYP.',
      avatar: 'avatar_2',
    ),
    StudentProfile(
      id: 'stu_2',
      name: 'Ayesha Noor',
      department: 'Computer Science',
      semester: 7,
      skills: ['Python', 'Machine Learning', 'AI', 'Data Science'],
      interests: ['Artificial Intelligence', 'Data Science', 'Research'],
      projectType: 'Final Year Project',
      availability: 'Full-time (20+ hrs/wk)',
      bio:
          'NLP & Computer Vision researcher with hands-on PyTorch & TensorFlow experience. Keen to integrate AI models into apps.',
      avatar: 'avatar_3',
    ),
    StudentProfile(
      id: 'stu_3',
      name: 'Bilal Khan',
      department: 'Computer Science',
      semester: 7,
      skills: ['Node.js', 'Python', 'SQL', 'Backend Development', 'DevOps'],
      interests: ['Cloud Computing', 'Web Development', 'Software Engineering'],
      projectType: 'Both',
      availability: 'Flexible',
      bio:
          'Backend architect specializing in scalable microservices, REST/GraphQL APIs, and relational database schema design.',
      avatar: 'avatar_4',
    ),
    StudentProfile(
      id: 'stu_4',
      name: 'Fatima Zahra',
      department: 'Software Engineering',
      semester: 6,
      skills: ['UI/UX Design', 'Figma', 'Testing', 'Flutter', 'Documentation'],
      interests: ['UI/UX', 'Mobile Apps', 'Software Engineering'],
      projectType: 'Final Year Project',
      availability: 'Part-time (10-20 hrs/wk)',
      bio:
          'Product designer focusing on accessible user journeys, component design systems, and rapid interactive prototyping.',
      avatar: 'avatar_5',
    ),
    StudentProfile(
      id: 'stu_5',
      name: 'Usman Ali',
      department: 'Artificial Intelligence',
      semester: 6,
      skills: ['Python', 'AI', 'Machine Learning', 'SQL'],
      interests: ['Artificial Intelligence', 'Robotics', 'Data Science'],
      projectType: 'Semester Project',
      availability: 'Evenings & Weekends',
      bio:
          'AI enthusiast interested in predictive analytics, large language model prompt engineering, and intelligent campus solutions.',
      avatar: 'avatar_6',
    ),
    StudentProfile(
      id: 'stu_6',
      name: 'Zainab Bibi',
      department: 'Cyber Security',
      semester: 7,
      skills: ['Cybersecurity', 'Python', 'Backend Development', 'Testing'],
      interests: ['Cybersecurity', 'Cloud Computing', 'Research'],
      projectType: 'Final Year Project',
      availability: 'Full-time (20+ hrs/wk)',
      bio:
          'Information security and cryptography specialist focusing on application penetration testing and secure API authorization.',
      avatar: 'avatar_1',
    ),
    StudentProfile(
      id: 'stu_7',
      name: 'Daniyal Qureshi',
      department: 'Computer Science',
      semester: 8,
      skills: ['Flutter', 'React', 'JavaScript', 'Mobile Development'],
      interests: ['Mobile Apps', 'Web Development', 'Game Development'],
      projectType: 'Final Year Project',
      availability: 'Weekends Only',
      bio:
          'Senior student with industry internship experience in Flutter and React Native. Looking for a strong team for FYP submission.',
      avatar: 'avatar_2',
    ),
    StudentProfile(
      id: 'stu_8',
      name: 'Mahnoor Shah',
      department: 'Software Engineering',
      semester: 5,
      skills: ['Java', 'C++', 'SQL', 'Documentation', 'Testing'],
      interests: ['Software Engineering', 'Research', 'Mobile Apps'],
      projectType: 'Semester Project',
      availability: 'Flexible',
      bio:
          'Disciplined engineer with a strong foundation in Object-Oriented Design, data structures, and comprehensive automated testing.',
      avatar: 'avatar_3',
    ),
    StudentProfile(
      id: 'stu_9',
      name: 'Saad Farooq',
      department: 'Electrical Engineering',
      semester: 7,
      skills: ['IoT', 'C++', 'Python', 'Robotics'],
      interests: ['IoT', 'Robotics', 'Artificial Intelligence'],
      projectType: 'Both',
      availability: 'Evenings & Weekends',
      bio:
          'Hardware-software co-designer experienced with ESP32, Arduino, sensors, and connecting IoT hardware to mobile dashboards.',
      avatar: 'avatar_4',
    ),
    StudentProfile(
      id: 'stu_10',
      name: 'Sana Javed',
      department: 'Artificial Intelligence',
      semester: 7,
      skills: ['Python', 'Machine Learning', 'Data Science', 'SQL'],
      interests: ['Artificial Intelligence', 'Data Science', 'Research'],
      projectType: 'Final Year Project',
      availability: 'Full-time (20+ hrs/wk)',
      bio:
          'Data scientist experienced in feature engineering, sentiment analysis, and statistical evaluation of predictive algorithms.',
      avatar: 'avatar_5',
    ),
    StudentProfile(
      id: 'stu_11',
      name: 'Ahmed Raza',
      department: 'Computer Science',
      semester: 4,
      skills: ['Java', 'C++', 'SQL', 'Testing'],
      interests: ['Game Development', 'Software Engineering', 'Mobile Apps'],
      projectType: 'Semester Project',
      availability: 'Part-time (10-20 hrs/wk)',
      bio:
          'Eager sophomore building algorithmic problem-solving skills and seeking a semester project team to learn collaborative git workflow.',
      avatar: 'avatar_6',
    ),
    StudentProfile(
      id: 'stu_12',
      name: 'Hira Mustafa',
      department: 'Software Engineering',
      semester: 7,
      skills: ['Flutter', 'Dart', 'UI/UX Design', 'Web Development'],
      interests: ['Mobile Apps', 'UI/UX', 'Cloud Computing'],
      projectType: 'Final Year Project',
      availability: 'Full-time (20+ hrs/wk)',
      bio:
          'Full-stack mobile enthusiast creating visually captivating Flutter user interfaces with fluid animations and responsive designs.',
      avatar: 'avatar_1',
    ),
    StudentProfile(
      id: 'stu_13',
      name: 'Kashif Mehmood',
      department: 'Cyber Security',
      semester: 6,
      skills: ['Cybersecurity', 'DevOps', 'Python', 'Backend Development'],
      interests: ['Cybersecurity', 'Cloud Computing', 'IoT'],
      projectType: 'Both',
      availability: 'Flexible',
      bio:
          'Infrastructure and security engineer focused on Docker containerization, CI/CD pipeline automation, and identity management.',
      avatar: 'avatar_2',
    ),
    StudentProfile(
      id: 'stu_14',
      name: 'Rabia Iftikhar',
      department: 'Computer Science',
      semester: 7,
      skills: ['Node.js', 'React', 'SQL', 'Backend Development'],
      interests: ['Web Development', 'Software Engineering', 'Cloud Computing'],
      projectType: 'Final Year Project',
      availability: 'Full-time (20+ hrs/wk)',
      bio:
          'Full stack web & API developer eager to collaborate on building reliable backend web services and real-time socket connections.',
      avatar: 'avatar_3',
    ),
    StudentProfile(
      id: 'stu_15',
      name: 'Ali Hassan',
      department: 'Artificial Intelligence',
      semester: 8,
      skills: ['Machine Learning', 'AI', 'Python', 'DevOps'],
      interests: ['Artificial Intelligence', 'Robotics', 'Research'],
      projectType: 'Final Year Project',
      availability: 'Part-time (10-20 hrs/wk)',
      bio:
          'Deep learning practitioner working on edge AI models and model optimization for mobile edge devices.',
      avatar: 'avatar_4',
    ),
    StudentProfile(
      id: 'stu_16',
      name: 'Nida Anjum',
      department: 'Data Science',
      semester: 6,
      skills: ['Python', 'SQL', 'Data Science', 'Documentation'],
      interests: ['Data Science', 'Artificial Intelligence', 'Research'],
      projectType: 'Semester Project',
      availability: 'Evenings & Weekends',
      bio:
          'Data visualization and statistical modeling specialist capable of extracting actionable insights from university datasets.',
      avatar: 'avatar_5',
    ),
  ];

  // Pre-configured Project Team for Current User
  static Team get defaultTeam => Team(
    id: 'team_smart_campus',
    title: 'Smart Campus Assistant',
    description:
        'An offline-first intelligent mobile companion for COMSATS students and faculty providing automated timetable management, peer collaboration, and campus resource matching.',
    projectType: 'Final Year Project',
    leaderId: 'user_current',
    roles: [
      TeamRole(
        id: 'role_lead',
        title: 'Team Lead & Flutter Mobile Architect',
        requiredSkills: ['Flutter', 'Dart', 'UI/UX Design'],
        assignedMemberId: 'user_current',
      ),
      TeamRole(
        id: 'role_ml',
        title: 'Machine Learning & AI Engineer',
        requiredSkills: ['Python', 'Machine Learning', 'AI'],
        assignedMemberId: null, // Open role
      ),
      TeamRole(
        id: 'role_backend',
        title: 'Backend & Cloud Services Developer',
        requiredSkills: ['Node.js', 'Python', 'SQL'],
        assignedMemberId: null, // Open role
      ),
      TeamRole(
        id: 'role_qa',
        title: 'UI/UX Designer & QA Specialist',
        requiredSkills: ['UI/UX Design', 'Testing', 'Documentation'],
        assignedMemberId: null, // Open role
      ),
    ],
    memberIds: ['user_current'],
    memberRoleMap: {'user_current': 'role_lead'},
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  );

  // Pre-seeded Incoming and Outgoing Requests (at least 3 incoming pending!)
  static List<TeamRequest> get seedRequests {
    final now = DateTime.now();
    return [
      TeamRequest(
        id: 'req_inc_1',
        senderId: 'stu_2', // Ayesha Noor (ML Expert - matches Open Role!)
        receiverId: 'user_current',
        message:
            'Hi Zayan! I saw your Smart Campus FYP project. I have extensive Machine Learning & Python experience and would love to join your team to handle the AI modeling!',
        status: 'pending',
        createdAt: now.subtract(const Duration(hours: 12)),
        expiresAt: now.add(const Duration(hours: 60)),
      ),
      TeamRequest(
        id: 'req_inc_2',
        senderId:
            'stu_3', // Bilal Khan (Backend Specialist - matches Open Role!)
        receiverId: 'user_current',
        message:
            'Assalam-o-Alaikum! I specialize in Node.js, Python, and SQL backends. I can design the offline sync database architecture for our campus team.',
        status: 'pending',
        createdAt: now.subtract(const Duration(hours: 26)),
        expiresAt: now.add(const Duration(hours: 46)),
      ),
      TeamRequest(
        id: 'req_inc_3',
        senderId: 'stu_4', // Fatima Zahra (UI/UX)
        receiverId: 'user_current',
        message:
            'Hey Zayan, I reviewed your project scope. I can contribute high-fidelity Figma components and rigorous UI usability testing.',
        status: 'pending',
        createdAt: now.subtract(const Duration(hours: 50)),
        expiresAt: now.add(const Duration(hours: 22)),
      ),
      // Outgoing requests to demonstrate Sent tab
      TeamRequest(
        id: 'req_out_1',
        senderId: 'user_current',
        receiverId: 'stu_1', // Hamza Tariq
        message:
            'Hi Hamza, your Flutter architecture background aligns perfectly with our team. We would love to have you collaborate on the mobile frontend.',
        status: 'pending',
        createdAt: now.subtract(const Duration(hours: 18)),
        expiresAt: now.add(const Duration(hours: 54)),
      ),
      TeamRequest(
        id: 'req_out_2',
        senderId: 'user_current',
        receiverId: 'stu_6', // Zainab Bibi
        message:
            'Hello Zainab! We are looking for security guidance for our app local authentication and encrypted Hive persistence.',
        status: 'pending',
        createdAt: now.subtract(const Duration(hours: 36)),
        expiresAt: now.add(const Duration(hours: 36)),
      ),
    ];
  }

  // Pre-seeded Interactive Team Tasks
  static List<TeamTask> get seedTasks {
    final now = DateTime.now();
    return [
      TeamTask(
        id: 'task_1',
        title: 'Finalize FYP Proposal Document & Scope',
        description:
            'Complete the problem statement, objectives, and system architecture diagrams for faculty approval.',
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 2)),
        assignedMemberId: 'user_current',
      ),
      TeamTask(
        id: 'task_2',
        title: 'Design Material 3 Design System & Prototypes',
        description:
            'Create standardized design components with Indigo & Slate color scheme in Figma.',
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 1)),
        assignedMemberId: 'user_current',
      ),
      TeamTask(
        id: 'task_3',
        title: 'Implement Smart Match Deterministic Engine',
        description:
            'Code the 4-part weighted formula with explainable match reasons and Jaccard similarity.',
        isCompleted: false,
        createdAt: now,
        assignedMemberId: 'user_current',
      ),
      TeamTask(
        id: 'task_4',
        title: 'Set up Offline Hive Persistent Storage',
        description:
            'Ensure profile, roster, and request modifications survive process restarts.',
        isCompleted: false,
        createdAt: now,
      ),
    ];
  }

  // Pre-seeded Simulated Team Chat Messages
  static List<ChatMessage> get seedMessages {
    final now = DateTime.now();
    return [
      ChatMessage(
        id: 'msg_1',
        senderId: 'system',
        senderName: 'TeamUp Bot',
        message:
            'Welcome to the team collaboration space for "Smart Campus Assistant"! All messages are stored offline.',
        timestamp: now.subtract(const Duration(hours: 8)),
        isMe: false,
      ),
      ChatMessage(
        id: 'msg_2',
        senderId: 'user_current',
        senderName: 'Zayan Ahmed (Lead)',
        message:
            'Hey team! Welcome aboard. Our primary goal this week is to finalize open roles and lock down our FYP specification.',
        timestamp: now.subtract(const Duration(hours: 6)),
        isMe: true,
      ),
      ChatMessage(
        id: 'msg_3',
        senderId: 'system',
        senderName: 'TeamUp Bot',
        message:
            'Tip: You can assign members to open role slots in the My Team dashboard.',
        timestamp: now.subtract(const Duration(hours: 4)),
        isMe: false,
      ),
    ];
  }

  // Pre-seeded Saved Filter Presets (FR-2.6 Bonus)
  static List<FilterPreset> get seedPresets => [
    FilterPreset(
      id: 'preset_1',
      name: '7th Semester Mobile Developers',
      department: 'Software Engineering',
      minSemester: 7,
      maxSemester: 7,
      skills: ['Flutter'],
      projectType: 'Final Year Project',
    ),
    FilterPreset(
      id: 'preset_2',
      name: 'AI & Data Researchers',
      department: 'Computer Science',
      minSemester: 6,
      maxSemester: 8,
      skills: ['Python', 'Machine Learning'],
      projectType: 'Final Year Project',
    ),
    FilterPreset(
      id: 'preset_3',
      name: 'Full Stack FYP Candidates',
      department: null,
      minSemester: 7,
      maxSemester: 8,
      skills: ['Flutter', 'Node.js'],
      projectType: 'Final Year Project',
    ),
  ];
}
