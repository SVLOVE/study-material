-- 1. ADDING INDEXES FOR PERFORMANCE
-- These were missing in the initial schema and are crucial for fast queries.

CREATE INDEX IF NOT EXISTS idx_exams_category_id ON public.exams(category_id);
CREATE INDEX IF NOT EXISTS idx_subjects_exam_id ON public.subjects(exam_id);
CREATE INDEX IF NOT EXISTS idx_topics_subject_id ON public.topics(subject_id);
CREATE INDEX IF NOT EXISTS idx_questions_topic_id ON public.questions(topic_id);


-- 2. DEVELOPMENT SEED DATA
-- Let's insert some sample data to test our application.

-- Insert a category
INSERT INTO public.exam_categories (id, name, description) 
VALUES ('c1b4227e-855c-43f1-b92f-b4b6f1201d51', 'TNPSC', 'Tamil Nadu Public Service Commission Exams')
ON CONFLICT DO NOTHING;

-- Insert an exam
INSERT INTO public.exams (id, category_id, name, description, is_active)
VALUES ('e8b4227e-855c-43f1-b92f-b4b6f1201d52', 'c1b4227e-855c-43f1-b92f-b4b6f1201d51', 'Group 4', 'TNPSC Group 4 Examination', true)
ON CONFLICT DO NOTHING;

-- Insert a subject (Fixed valid UUID format)
INSERT INTO public.subjects (id, exam_id, name, description)
VALUES ('f4b4227e-855c-43f1-b92f-b4b6f1201d53', 'e8b4227e-855c-43f1-b92f-b4b6f1201d52', 'General Tamil', 'Pothu Tamil for Group 4')
ON CONFLICT DO NOTHING;

-- Insert a topic (Fixed valid UUID format)
INSERT INTO public.topics (id, subject_id, name, description)
VALUES ('f9b4227e-855c-43f1-b92f-b4b6f1201d54', 'f4b4227e-855c-43f1-b92f-b4b6f1201d53', 'Ilakkanam', 'Grammar part')
ON CONFLICT DO NOTHING;

-- Insert a sample question
INSERT INTO public.questions (topic_id, question_text, option_a, option_b, option_c, option_d, correct_option, explanation, difficulty, is_premium)
VALUES (
  'f9b4227e-855c-43f1-b92f-b4b6f1201d54', 
  'Which of the following is a vowel in Tamil?', 
  'க்', 
  'ச்', 
  'அ', 
  'த்', 
  'C', 
  'அ is a uyir ezhuthu (vowel).', 
  'Easy', 
  false
);
