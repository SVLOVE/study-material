class ExamCategory {
  final String id;
  final String name;

  const ExamCategory({required this.id, required this.name});
}

class ExamDefinition {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final List<String> subjects;

  const ExamDefinition({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.subjects,
  });
}

const List<ExamCategory> staticCategories = [
  ExamCategory(id: 'tnpsc', name: 'TNPSC'),
  ExamCategory(id: 'ssc', name: 'SSC'),
  ExamCategory(id: 'rrb', name: 'RRB'),
  ExamCategory(id: 'banking', name: 'Banking'),
  ExamCategory(id: 'upsc', name: 'UPSC'),
  ExamCategory(id: 'defence', name: 'Defence'),
  ExamCategory(id: 'teaching', name: 'Teaching'),
  ExamCategory(id: 'police', name: 'Police'),
];

const List<ExamDefinition> staticExams = [
  // TNPSC
  ExamDefinition(id: 'tnpsc_group1', categoryId: 'tnpsc', name: 'Group 1', description: 'Tamil Nadu government highest recruitment examination.', subjects: ['General Studies', 'Aptitude', 'Current Affairs']),
  ExamDefinition(id: 'tnpsc_group2', categoryId: 'tnpsc', name: 'Group 2', description: 'Tamil Nadu subordinate services examination.', subjects: ['General Studies', 'Aptitude', 'Tamil']),
  ExamDefinition(id: 'tnpsc_group2a', categoryId: 'tnpsc', name: 'Group 2A', description: 'Non-interview posts for Tamil Nadu services.', subjects: ['General Studies', 'Aptitude', 'Tamil/English']),
  ExamDefinition(id: 'tnpsc_group4', categoryId: 'tnpsc', name: 'Group 4', description: 'Tamil Nadu government recruitment examination for Group IV.', subjects: ['General Studies', 'Aptitude', 'Tamil']),
  ExamDefinition(id: 'tnpsc_group5a', categoryId: 'tnpsc', name: 'Group 5A', description: 'Tamil Nadu secretariat service examination.', subjects: ['General Studies', 'Secretariat Services']),
  ExamDefinition(id: 'tnpsc_group7b', categoryId: 'tnpsc', name: 'Group 7B', description: 'Executive Officer, Grade-III in Hindu Religious & Charitable Endowments.', subjects: ['General Studies', 'Hinduism', 'Saivism']),
  ExamDefinition(id: 'tnpsc_group8', categoryId: 'tnpsc', name: 'Group 8', description: 'Executive Officer, Grade-IV.', subjects: ['General Studies', 'Hindu Religion']),

  // SSC
  ExamDefinition(id: 'ssc_cgl', categoryId: 'ssc', name: 'CGL', description: 'Combined Graduate Level Examination.', subjects: ['Reasoning', 'Awareness', 'Aptitude', 'English']),
  ExamDefinition(id: 'ssc_chsl', categoryId: 'ssc', name: 'CHSL', description: 'Combined Higher Secondary Level Examination.', subjects: ['Reasoning', 'Awareness', 'Aptitude', 'English']),
  ExamDefinition(id: 'ssc_mts', categoryId: 'ssc', name: 'MTS', description: 'Multi Tasking Staff Examination.', subjects: ['Reasoning', 'Numerical', 'English', 'Awareness']),
  ExamDefinition(id: 'ssc_gd', categoryId: 'ssc', name: 'GD Constable', description: 'Constables (GD) in Central Armed Police Forces.', subjects: ['Intelligence', 'Knowledge', 'Mathematics', 'English/Hindi']),
  ExamDefinition(id: 'ssc_cpo', categoryId: 'ssc', name: 'CPO', description: 'Sub-Inspector in Delhi Police and CAPFs.', subjects: ['Reasoning', 'Knowledge', 'Aptitude', 'English']),
  ExamDefinition(id: 'ssc_steno', categoryId: 'ssc', name: 'Stenographer', description: 'Stenographer Grade C and D Examination.', subjects: ['Reasoning', 'Awareness', 'English']),

  // RRB / Railway
  ExamDefinition(id: 'rrb_ntpc', categoryId: 'rrb', name: 'NTPC', description: 'Non-Technical Popular Categories.', subjects: ['Mathematics', 'Intelligence', 'Awareness']),
  ExamDefinition(id: 'rrb_group_d', categoryId: 'rrb', name: 'Group D', description: 'Railway Group D Recruitment.', subjects: ['Mathematics', 'Intelligence', 'Science', 'Awareness']),
  ExamDefinition(id: 'rrb_alp', categoryId: 'rrb', name: 'ALP', description: 'Assistant Loco Pilot and Technician.', subjects: ['Mathematics', 'Intelligence', 'Science', 'Awareness']),
  ExamDefinition(id: 'rrb_tech', categoryId: 'rrb', name: 'Technician', description: 'Railway Technician Recruitment.', subjects: ['Mathematics', 'Intelligence', 'Science']),
  ExamDefinition(id: 'rrb_je', categoryId: 'rrb', name: 'JE', description: 'Junior Engineer Recruitment.', subjects: ['Mathematics', 'Intelligence', 'Awareness', 'Technical']),

  // Banking
  ExamDefinition(id: 'bank_ibps_po', categoryId: 'banking', name: 'IBPS PO', description: 'Probationary Officers / Management Trainees.', subjects: ['English', 'Quantitative', 'Reasoning']),
  ExamDefinition(id: 'bank_ibps_clerk', categoryId: 'banking', name: 'IBPS Clerk', description: 'Clerical Cadre Recruitment.', subjects: ['English', 'Numerical', 'Reasoning']),
  ExamDefinition(id: 'bank_sbi_po', categoryId: 'banking', name: 'SBI PO', description: 'State Bank of India Probationary Officers.', subjects: ['English', 'Quantitative', 'Reasoning']),
  ExamDefinition(id: 'bank_sbi_clerk', categoryId: 'banking', name: 'SBI Clerk', description: 'State Bank of India Junior Associates.', subjects: ['English', 'Numerical', 'Reasoning']),
  ExamDefinition(id: 'bank_ibps_rrb', categoryId: 'banking', name: 'IBPS RRB', description: 'Regional Rural Banks Recruitment.', subjects: ['Reasoning', 'Quantitative']),
  ExamDefinition(id: 'bank_rbi_assistant', categoryId: 'banking', name: 'RBI Assistant', description: 'Reserve Bank of India Assistant.', subjects: ['English', 'Numerical', 'Reasoning']),

  // UPSC
  ExamDefinition(id: 'upsc_cse', categoryId: 'upsc', name: 'Civil Services Examination', description: 'India\'s premier central recruiting exam.', subjects: ['General Studies', 'CSAT', 'Optional']),
  ExamDefinition(id: 'upsc_nda', categoryId: 'upsc', name: 'NDA', description: 'National Defence Academy Examination.', subjects: ['Mathematics', 'General Ability']),
  ExamDefinition(id: 'upsc_cds', categoryId: 'upsc', name: 'CDS', description: 'Combined Defence Services Examination.', subjects: ['English', 'General Knowledge', 'Mathematics']),
  ExamDefinition(id: 'upsc_capf', categoryId: 'upsc', name: 'CAPF', description: 'Central Armed Police Forces Examination.', subjects: ['General Ability', 'General Studies', 'Essay']),

  // Defence
  ExamDefinition(id: 'def_nda', categoryId: 'defence', name: 'NDA', description: 'National Defence Academy Examination.', subjects: ['Mathematics', 'General Ability']),
  ExamDefinition(id: 'def_cds', categoryId: 'defence', name: 'CDS', description: 'Combined Defence Services Examination.', subjects: ['English', 'General Knowledge', 'Mathematics']),
  ExamDefinition(id: 'def_afcat', categoryId: 'defence', name: 'AFCAT', description: 'Air Force Common Admission Test.', subjects: ['Verbal', 'Numerical', 'Reasoning', 'Aptitude']),
  ExamDefinition(id: 'def_agniveer', categoryId: 'defence', name: 'Agniveer', description: 'Armed Forces Agnipath Scheme.', subjects: ['General Knowledge', 'Science', 'Mathematics']),

  // Teaching
  ExamDefinition(id: 'teach_tntet', categoryId: 'teaching', name: 'TNTET', description: 'Tamil Nadu Teacher Eligibility Test.', subjects: ['Child Development', 'Language I', 'Language II', 'Mathematics']),
  ExamDefinition(id: 'teach_trb', categoryId: 'teaching', name: 'TRB', description: 'Teachers Recruitment Board.', subjects: ['Subject Knowledge', 'Educational Methodology']),
  ExamDefinition(id: 'teach_ctet', categoryId: 'teaching', name: 'CTET', description: 'Central Teacher Eligibility Test.', subjects: ['Child Development', 'Language I', 'Language II', 'Mathematics']),
  ExamDefinition(id: 'teach_pg', categoryId: 'teaching', name: 'PG Assistant', description: 'Post Graduate Assistants Recruitment.', subjects: ['Main Subject', 'Educational Methodology', 'General Knowledge']),
  ExamDefinition(id: 'teach_tet', categoryId: 'teaching', name: 'TET', description: 'Teacher Eligibility Test.', subjects: ['Child Development', 'Pedagogy', 'Subject Knowledge']),

  // Police
  ExamDefinition(id: 'pol_tnusrb_si', categoryId: 'police', name: 'TNUSRB SI', description: 'Sub-Inspector of Police Recruitment.', subjects: ['General Knowledge', 'Psychology', 'Numerical']),
  ExamDefinition(id: 'pol_tnusrb_constable', categoryId: 'police', name: 'TNUSRB Constable', description: 'Police Constable Recruitment.', subjects: ['General Knowledge', 'Psychology']),
  ExamDefinition(id: 'pol_ssc_gd', categoryId: 'police', name: 'SSC GD', description: 'Constables in Central Armed Police Forces.', subjects: ['Intelligence', 'Knowledge', 'Mathematics']),
  ExamDefinition(id: 'pol_recruit', categoryId: 'police', name: 'Police Recruitment', description: 'General Police Department Recruitments.', subjects: ['General Knowledge', 'Reasoning', 'Physical Test']),
];
