

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pg_cron" WITH SCHEMA "pg_catalog";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "public";






CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";






CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."role_enum" AS ENUM (
    'superuser',
    'admin',
    'principal',
    'teacher',
    'student',
    'guest'
);


ALTER TYPE "public"."role_enum" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."assign_tag"("tag_uid" "text", "section_code" "text", "max_tags" integer DEFAULT 2) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    tag_id_var BIGINT;  -- Renamed variable for tag ID
    section_id_var BIGINT;  -- Renamed variable for section ID
BEGIN
    -- Insert tag if it doesn't exist
    INSERT INTO tag (uid) VALUES (tag_uid)
    ON CONFLICT (uid) DO NOTHING;
    
    -- Get the tag_id
    SELECT id INTO tag_id_var FROM tag WHERE uid = tag_uid;

    -- Get the section_id
    SELECT id INTO section_id_var FROM section WHERE code = section_code;
    IF section_id_var IS NULL THEN
        RAISE EXCEPTION 'Section not found';
    END IF;

    -- Delete all existing assignments for this tag and section
    DELETE FROM tag_assignment WHERE tag_id = tag_id_var AND section_id = section_id_var;  -- Use section_id_var

    -- Insert the new tag assignment
    INSERT INTO tag_assignment (tag_id, section_id) VALUES (tag_id_var, section_id_var);  -- Use section_id_var

    -- Ensure max assignments per section by deleting the oldest if necessary
    DELETE FROM tag_assignment
    WHERE id IN (
        SELECT id FROM tag_assignment
        WHERE section_id = section_id_var  -- Use section_id_var
        ORDER BY created_at ASC
        LIMIT GREATEST((SELECT COUNT(*) FROM tag_assignment WHERE section_id = section_id_var) - max_tags, 0)
    );

END;
$$;


ALTER FUNCTION "public"."assign_tag"("tag_uid" "text", "section_code" "text", "max_tags" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_small_test_data"("term" integer) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    student_id1 UUID;
    student_id2 UUID;
    teacher_id1 UUID;
    teacher_id2 UUID;
    section_ids BIGINT[];
BEGIN
    -- Insert 5 courses into the public.course table
    INSERT INTO public.course (code, name, is_test_data)
    VALUES
        ('AAA1U', 'Course AAA1U', true),
        ('BBB1U', 'Course BBB1U', true),
        ('CCC1U', 'Course CCC1U', true),
        ('DDD1U', 'Course DDD1U', true),
        ('EEE1U', 'Course EEE1U', true)
    ON CONFLICT (code) DO NOTHING;

    -- Insert sections into the public.section table
    INSERT INTO public.section (section_number, course_code, school_term_id, block_id, is_test_data)
    VALUES 
        ('1', 'AAA1U', term, 1, true),
        ('2', 'AAA1U', term, 2, true),
        ('1', 'BBB1U', term, 3, true),
        ('1', 'CCC1U', term, 4, true),
        ('1', 'DDD1U', term, 5, true),
        ('1', 'EEE1U', term, 6, true),
        ('2', 'BBB1U', term, 7, true),
        ('2', 'CCC1U', term, 8, true)
    ON CONFLICT DO NOTHING;

    -- Populate section_ids array with newly created section IDs
    SELECT ARRAY(SELECT id FROM public.section WHERE school_term_id = term) INTO section_ids;

    -- Assign the tag with uid '04576490780000' to every section
    WITH tag_info AS (
        SELECT id FROM public.tag WHERE uid = '04576490780000'
    )
    INSERT INTO public.tag_assignment (section_id, tag_id, is_test_data)
    SELECT s, t.id, true FROM unnest(section_ids) s, tag_info t;

    -- Insert 2 students if not exists
    INSERT INTO public.student (first_name, last_name, email, student_number, is_test_data) 
    VALUES
        ('Dev', 'Student', 'dev.codepet@gmail.com', '123456789', true),
        ('Test', 'Student', 'student@example.com', '000000001', true)
    ON CONFLICT (email) DO NOTHING;

    -- Get the student IDs
    SELECT id INTO student_id1 FROM public.student WHERE email = 'dev.codepet@gmail.com' LIMIT 1;
    SELECT id INTO student_id2 FROM public.student WHERE email = 'student@example.com' LIMIT 1;

    -- Ensure students exist before enrolling
    IF student_id1 IS NOT NULL THEN
        INSERT INTO public.student_enrolment (student_id, section_id, school_term_id, is_test_data)
        SELECT student_id1, s, term, true FROM unnest(section_ids) s
        ON CONFLICT DO NOTHING;
    END IF;

    IF student_id2 IS NOT NULL THEN
        INSERT INTO public.student_enrolment (student_id, section_id, school_term_id, is_test_data)
        SELECT student_id2, s, term, true FROM unnest(section_ids) s
        ON CONFLICT DO NOTHING;
    END IF;

    -- Insert teachers
    INSERT INTO public.teacher (first_name, last_name, email, is_test_data) 
    VALUES
        ('Dev', 'Teacher', 'codepetproject@gmail.com', true),
        ('Test', 'Teacher', 'teacher@example.com', true)
    ON CONFLICT (email) DO NOTHING;

    -- Get the teacher IDs
    SELECT id INTO teacher_id1 FROM public.teacher WHERE email = 'codepetproject@gmail.com' LIMIT 1;
    SELECT id INTO teacher_id2 FROM public.teacher WHERE email = 'teacher@example.com' LIMIT 1;

    -- Ensure teachers exist before assigning sections
    IF teacher_id1 IS NOT NULL THEN
        INSERT INTO public.teacher_assignment (section_id, teacher_id, school_term_id, is_test_data)
        SELECT s, teacher_id1, term, true FROM unnest(section_ids) s
        ON CONFLICT DO NOTHING;
    END IF;

    IF teacher_id2 IS NOT NULL THEN
        INSERT INTO public.teacher_assignment (section_id, teacher_id, school_term_id, is_test_data)
        SELECT s, teacher_id2, term, true FROM unnest(section_ids) s
        ON CONFLICT DO NOTHING;
    END IF;

END;
$$;


ALTER FUNCTION "public"."create_small_test_data"("term" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_test_data"("term" integer) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    unique_id UUID;
    first_name TEXT;
    last_name TEXT;
    section_ids BIGINT[];
    student_counter INTEGER := 0;
    current_section INTEGER := 1;
    names text[] := ARRAY[
        'Aragorn', 'Frodo', 'Gandalf', 'Legolas', 'Gimli', 'Samwise', 'Bilbo', 'Sauron', 'Gollum', 'Boromir',
        'Dumbledore', 'Harry', 'Hermione', 'Ron', 'Voldemort', 'Snape', 'Hagrid', 'Luna', 'Draco', 'Neville',
        'Luke', 'Leia', 'Han', 'Chewbacca', 'Yoda', 'Obi-Wan', 'Palpatine', 'Rey', 'Finn', 'Kylo',
        'Sonic', 'Tails', 'Knuckles', 'Amy', 'Shadow', 'Robotnik', 'Metal Sonic', 'Silver', 'Blaze', 'Cream',
        'Mario', 'Luigi', 'Peach', 'Bowser', 'Toad', 'Yoshi', 'Wario', 'Waluigi', 'Donkey Kong', 'Diddy Kong',
        'Pikachu', 'Charmander', 'Bulbasaur', 'Squirtle', 'Jigglypuff', 'Mewtwo', 'Eevee', 'Snorlax', 'Gengar', 'Lucario',
        'Gandalf', 'Bilbo', 'Faramir', 'Eowyn', 'Gollum', 'Thorin', 'Smaug', 'Dwalin', 'Balin', 'Kili',
        'Tauriel', 'Legolas', 'Galadriel', 'Elrond', 'Arwen', 'Boromir', 'Denethor', 'Faramir', 'Gimli', 'Haldir',
        'Ciri', 'Geralt', 'Yennefer', 'Triss', 'Dandelion', 'Zoltan', 'Vesemir', 'Emhyr', 'Dijkstra', 'Letho',
        'Sirius', 'Luna', 'Bellatrix', 'Draco', 'Neville', 'Ginny', 'Molly', 'Arthur', 'Fred', 'George',
        'Dobby', 'Hedwig', 'Fawkes', 'Buckbeak', 'Thestral', 'Nymphadora', 'Remus', 'Tonks', 'Kingsley', 'Minerva',
        'Arwen', 'Eomer', 'Theoden', 'Grima', 'Eomer', 'Pippin', 'Merry', 'Radagast', 'Tom Bombadil', 'Glorfindel',
        'She-Ra', 'He-Man', 'Skeletor', 'Teela', 'Orko', 'Man-At-Arms', 'Hordak', 'Catra', 'Glimmer', 'Bow',
        'Aang', 'Katara', 'Sokka', 'Toph', 'Zuko', 'Azula', 'Iroh', 'Appa', 'Momo', 'Roku',
        'Naruto', 'Sasuke', 'Sakura', 'Kakashi', 'Hinata', 'Gaara', 'Shikamaru', 'Neji', 'Rock Lee', 'Kiba',
        'Luffy', 'Zoro', 'Nami', 'Usopp', 'Sanji', 'Chopper', 'Robin', 'Franky', 'Brook', 'Jinbei',
        'Ash', 'Misty', 'Brock', 'May', 'Dawn', 'Serena', 'Clemont', 'Bonnie', 'Professor Oak', 'Team Rocket',
        'Link', 'Zelda', 'Ganondorf', 'Midna', 'Epona', 'Impa', 'Daruk', 'Mipha', 'Revali', 'Urbosa',
        'Lara', 'Chief', 'Solid Snake', 'Samus Aran', 'Kratos', 'Nathan Drake', 'Ellie', 'Joel', 'Aloy', 'Egad',
        'Cloud', 'Sephiroth', 'Aerith', 'Tifa', 'Barret', 'Cid', 'Vincent', 'Yuffie', 'Rikku', 'Tidus'
    ];

    student_email TEXT;
    student_id BIGINT;
    teacher_id BIGINT;
BEGIN
    -- Insert courses
    INSERT INTO public.course (code, name, is_test_data)
    VALUES
    ('AAA1U', 'Course AAA1U', true),
    ('BBB2U', 'Course BBB2U', true),
    ('CCC3U', 'Course CCC3U', true),
    ('DDD4U', 'Course DDD4U', true),
    ('EEE1U', 'Course EEE1U', true)
    ON CONFLICT (code) DO NOTHING;

    -- Insert sections
    INSERT INTO public.section (section_number, course_code, school_term_id, block_id, is_test_data)
    VALUES 
    ('1', 'AAA1U', term, 2, true),
    ('2', 'AAA1U', term, 3, true),
    ('1', 'BBB2U', term, 5, true),
    ('2', 'BBB2U', term, 2, true),
    ('1', 'CCC3U', term, 4, true),
    ('2', 'CCC3U', term, 6, true);

    -- Assign the existing tag to every section
    WITH tag_info AS (
        SELECT id FROM public.tag WHERE uid = '04576490780000'
    )
    INSERT INTO public.tag_assignment (section_id, tag_id, is_test_data)
    SELECT s.id, t.id, true
    FROM public.section s, tag_info t;

    -- Retrieve section IDs
    SELECT ARRAY(SELECT id FROM public.section WHERE course_code IN ('AAA1U', 'BBB2U', 'CCC3U') AND school_term_id = term) 
    INTO section_ids;

    -- Insert students
    FOR i IN 1..150 LOOP
        unique_id := gen_random_uuid();
        first_name := names[(random() * array_length(names, 1))::integer + 1];
        last_name := names[(random() * array_length(names, 1))::integer + 1];
        student_email := concat(unique_id, '@example.com');

        -- Insert student and retrieve ID
        INSERT INTO public.student (first_name, last_name, email, student_number, is_test_data) 
        VALUES (first_name, last_name, student_email, unique_id::varchar, true)
        RETURNING id INTO student_id;

        -- Assign student to a section, cycling through available sections
        INSERT INTO public.student_enrolment (student_id, section_id, school_term_id, is_test_data)
        VALUES (student_id, section_ids[(i % array_length(section_ids, 1)) + 1], term, true);
    END LOOP;

    -- Insert test students
    INSERT INTO public.student (first_name, last_name, email, student_number, is_test_data) 
    VALUES 
    ('Test', 'Student', 'dev.codepet@gmail.com', '123456789', true),
    ('Test', 'Student', 'test.codepet@gmail.com', '987654321', true);

    -- Assign test students to sections
    FOR i IN 1..5 LOOP
        INSERT INTO public.student_enrolment (student_id, section_id, school_term_id, is_test_data)
        VALUES 
        ((SELECT id FROM public.student WHERE email = 'dev.codepet@gmail.com' LIMIT 1), section_ids[i], term, true),
        ((SELECT id FROM public.student WHERE email = 'test.codepet@gmail.com' LIMIT 1), section_ids[i], term, true);
    END LOOP;

    -- Insert a test teacher
    INSERT INTO public.teacher (first_name, last_name, email, is_test_data) 
    VALUES ('Test', 'Teacher', 'codepetproject@gmail.com', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO teacher_id;

    -- Assign teacher to sections
    IF teacher_id IS NOT NULL THEN
        FOR i IN 1..3 LOOP
            INSERT INTO public.teacher_assignment (section_id, teacher_id, school_term_id, is_test_data)
            VALUES (section_ids[i], teacher_id, term, true);
        END LOOP;
    END IF;
END;
$$;


ALTER FUNCTION "public"."create_test_data"("term" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_guest_accounts"() RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Delete users from user_role table where role is 'guest'
    DELETE FROM public.user_role WHERE role = 'guest';

    -- Delete users from auth.users table who are guests
    DELETE FROM auth.users WHERE id IN (
        SELECT user_id FROM public.user_role WHERE role = 'guest'
    );
END;
$$;


ALTER FUNCTION "public"."delete_guest_accounts"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_test_data"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Delete from attendance
    DELETE FROM public.attendance WHERE is_test_data = true;

    -- Delete from student_enrolment first to avoid foreign key constraint issues
    DELETE FROM public.student_enrolment WHERE is_test_data = true;

    -- Delete from teacher_assignment
    DELETE FROM public.teacher_assignment WHERE is_test_data = true;

    -- Delete from student
    DELETE FROM public.student WHERE is_test_data = true;

    -- Delete from teacher
    DELETE FROM public.teacher WHERE is_test_data = true;

    -- Delete from section
    DELETE FROM public.section WHERE is_test_data = true;

    -- Delete from course
    DELETE FROM public.course WHERE is_test_data = true;

    -- Delete from tag_assignment if applicable
    DELETE FROM public.tag_assignment WHERE is_test_data = true;

    -- Optionally, delete from any other tables that may have test data
    -- DELETE FROM public.other_table WHERE is_test_data = true;
    DELETE FROM public.tag_scan WHERE is_test_data = true;
    DELETE FROM public.tag WHERE is_test_data = true;
    DELETE FROM public.messages WHERE is_test_data = true;
    DELETE FROM public.event WHERE is_test_data = true;
    DELETE FROM public.school_day_type WHERE is_test_data = true;
    DELETE FROM public.school_term WHERE is_test_data = true;
    DELETE FROM public.block WHERE is_test_data = true;
    DELETE FROM public.calendar WHERE is_test_data = true;
    DELETE FROM public.user_role WHERE is_test_data = true;
END;
$$;


ALTER FUNCTION "public"."delete_test_data"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."enrol_students"("term_id" integer, "section_code" "text", "student_numbers" "text"[]) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    section_id_var integer;
    term_id_var integer; -- Renamed to avoid conflict with the column name
    missing_students text[];
BEGIN
    -- Retrieve the school_term_id
    SELECT id INTO term_id_var
    FROM school_term
    WHERE id = term_id;

    -- If the school term doesn't exist, raise an exception
    IF term_id_var IS NULL THEN
        RAISE EXCEPTION 'School term with ID % does not exist', term_id;
    END IF;

    -- Retrieve the section ID
    SELECT id INTO section_id_var
    FROM section
    WHERE code = enrol_students.section_code;

    -- If the section doesn't exist, raise an exception
    IF section_id_var IS NULL THEN  -- Changed to section_id_var
        RAISE EXCEPTION 'Section with code % does not exist', section_code;
    END IF;

    -- Insert enrollments while avoiding duplicates
    INSERT INTO student_enrolment(student_id, school_term_id, section_id)
    SELECT s.id, term_id_var, section_id_var -- Use section_id_var
    FROM student s
    WHERE s.student_number = ANY(student_numbers)
    AND NOT EXISTS (
        SELECT 1 FROM student_enrolment se
        WHERE se.student_id = s.id
        AND se.school_term_id = term_id_var
        AND se.section_id = section_id_var -- Use section_id_var
    );

    -- Identify missing students
    SELECT ARRAY_AGG(sn) INTO missing_students
    FROM (SELECT unnest(student_numbers) AS sn EXCEPT SELECT student_number FROM student) AS missing;

    -- Raise notice if any students were not found
    IF missing_students IS NOT NULL THEN
        RAISE NOTICE 'Some student numbers do not exist: %', missing_students;
    END IF;
END;
$$;


ALTER FUNCTION "public"."enrol_students"("term_id" integer, "section_code" "text", "student_numbers" "text"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_attendance_report_per_teacher"("date_param" "text", "teacher_ids" "text"[] DEFAULT '{}'::"text"[]) RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $_$
DECLARE
    result jsonb;
    target_date date;
BEGIN
    -- Convert the date_param to a date and validate format
    target_date := to_date(date_param, 'YYYY-MM-DD');

    -- Build the attendance report
    SELECT jsonb_agg(
        jsonb_build_object(
            'teacher', jsonb_build_object(
                'firstName', t.first_name,
                'lastName', t.last_name
            ),
            'sections', COALESCE(
                (
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'code', regexp_replace(s.code, '-0+([1-9])$', '-\1'),  -- Format section code
                            'startTime', to_char(
                                make_timestamp(
                                    extract(year FROM target_date)::integer,  -- Cast to integer
                                    extract(month FROM target_date)::integer,  -- Cast to integer
                                    extract(day FROM target_date)::integer,  -- Cast to integer
                                    extract(hour FROM b.start_time)::integer,  -- Cast to integer
                                    extract(minute FROM b.start_time)::integer,  -- Cast to integer
                                    extract(second FROM b.start_time)::integer  -- Cast to integer
                                ),
                                'YYYY-MM-DD HH24:MI:SS'  -- Format as string
                            ),
                            'block', b.name,  -- Add block name
                            'students', COALESCE(
                                (
                                    SELECT jsonb_agg(
                                        jsonb_build_object(
                                            'firstName', st.first_name,
                                            'lastName', st.last_name,
                                            'fullName', st.last_name || ', ' || st.first_name,  -- Full name in "LastName, FirstName" format
                                            'entryTime', (
                                                SELECT to_char(a.entry_time, 'YYYY-MM-DD HH24:MI:SS')  -- Format entry_time as a string
                                                FROM public.attendance a
                                                WHERE a.student_enrolment_id = se.id
                                                AND a.date = target_date  -- Use target_date instead of parsing again
                                            ),
                                            'timeDiff', (
                                                SELECT CASE 
                                                    WHEN a.entry_time IS NULL THEN NULL
                                                    ELSE ROUND(
                                                        EXTRACT(EPOCH FROM (
                                                            a.entry_time - make_timestamp(
                                                                extract(year FROM target_date)::integer,
                                                                extract(month FROM target_date)::integer,
                                                                extract(day FROM target_date)::integer,
                                                                extract(hour FROM b.start_time)::integer,
                                                                extract(minute FROM b.start_time)::integer,
                                                                extract(second FROM b.start_time)::integer
                                                            )
                                                        )) / 60.0, 2  -- Convert seconds to minutes and round to 2 decimal places
                                                    )
                                                END
                                                FROM public.attendance a
                                                WHERE a.student_enrolment_id = se.id
                                                AND a.date = target_date
                                            )
                                        )
                                    )
                                    FROM public.student_enrolment se
                                    JOIN public.student st ON se.student_id = st.id
                                    WHERE se.section_id = s.id
                                ),
                                '[]'::jsonb  -- Return an empty array if no students found
                            )
                        )
                    )
                    FROM public.section s
                    JOIN public.teacher_assignment ta ON s.id = ta.section_id
                    JOIN public.block b ON s.block_id = b.id  -- Join with block table to get start_time and block name
                    WHERE ta.teacher_id = t.id
                ),
                '[]'::jsonb  -- Return an empty array if no sections found
            )
        )
    ) INTO result
    FROM public.teacher t
    WHERE (teacher_ids IS NULL OR t.id = ANY (teacher_ids::uuid[]));  -- Fetch specific teachers or all if teacher_ids is empty

    RETURN result;

EXCEPTION
    WHEN others THEN
        RAISE EXCEPTION 'Error occurred while generating report: %', SQLERRM;
END;
$_$;


ALTER FUNCTION "public"."get_attendance_report_per_teacher"("date_param" "text", "teacher_ids" "text"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    user_email TEXT;              -- Variable to store the user's email
    is_test_data_flag BOOLEAN := false; -- Default value for test data flag
    user_id UUID;                 -- Variable to store the user ID
    user_role public.role_enum := 'guest';    -- Default role is 'guest'
BEGIN
    -- Get the email of the new user
    SELECT email INTO user_email FROM auth.users WHERE id = NEW.id;

    -- Validate email presence
    IF user_email IS NULL THEN
        RAISE EXCEPTION 'User email is NULL. Cannot assign role.';
    END IF;

    -- Check if the user exists in the student table
    SELECT id, is_test_data INTO user_id, is_test_data_flag
    FROM public.student
    WHERE email = user_email
    LIMIT 1;

    IF FOUND THEN
        user_role := 'student';
    ELSE
        -- Check if the user exists in the teacher table
        SELECT id, is_test_data INTO user_id, is_test_data_flag
        FROM public.teacher
        WHERE email = user_email
        LIMIT 1;

        IF FOUND THEN
            user_role := 'teacher';
        ELSE
            -- Use NEW.id as the user_id for guests
            user_id := NEW.id;
        END IF;
    END IF;

    -- Insert into user_role table
    INSERT INTO public.user_role (user_id, role, created_at, is_test_data)
    VALUES (NEW.id, user_role, now(), is_test_data_flag); -- Use NEW.id for user_id

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."populate_attendance_from_student_enrolment"("termid" bigint) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Populate attendance from student enrolment including is_test_data
    INSERT INTO attendance (student_enrolment_id, date, is_test_data)
    SELECT 
        e.id AS student_enrolment_id,  -- Use the student_enrolment ID
        d.date,
        e.is_test_data  -- Include the is_test_data field
    FROM 
        student_enrolment e
    CROSS JOIN 
        generate_series(
            (SELECT MIN(start_date) FROM school_term WHERE id = termId),  -- Start from the term's start date
            (SELECT MAX(end_date) FROM school_term WHERE id = termId),    -- End at the term's end date
            '1 day'
        ) AS d(date)
    LEFT JOIN 
        calendar c 
        ON c.date = d.date AND c.term_id = e.school_term_id
    WHERE 
        (c.id IS NULL OR c.is_school_day = TRUE)  -- Include only school days or null calendar entries
        AND e.school_term_id = termId;           -- Match the term ID
END;
$$;


ALTER FUNCTION "public"."populate_attendance_from_student_enrolment"("termid" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."populate_initial_term_calendar"("termid" integer) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Insert every day from the term's start_date to end_date into the calendar table
    INSERT INTO calendar (term_id, date, is_school_day, reason)
    SELECT 
        termId,  -- Use the function parameter
        d.date,
        CASE 
            WHEN EXTRACT(DOW FROM d.date) IN (0, 6) THEN FALSE  -- Mark weekends as non-school days
            ELSE TRUE  -- Weekdays are school days
        END AS is_school_day,
        CASE 
            WHEN EXTRACT(DOW FROM d.date) IN (0, 6) THEN 'Weekend'  -- Mark weekends specifically
            ELSE NULL  -- No reason for weekdays
        END AS reason
    FROM 
        generate_series(
            (SELECT start_date FROM school_term WHERE id = termId),  -- Start from the term's start date
            (SELECT end_date FROM school_term WHERE id = termId),    -- End at the term's end date
            '1 day'::interval  -- Increment by 1 day
        ) AS d(date);
END;
$$;


ALTER FUNCTION "public"."populate_initial_term_calendar"("termid" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_attendance_with_tag_scan"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    enrolment_id bigint;
    section_id_from_enrolment bigint;
    section_id_from_tag bigint;
    attendance_record attendance%ROWTYPE;
BEGIN
    -- Find the correct enrolment using scan time constraints
    SELECT se.id, se.section_id, ta.section_id
    INTO enrolment_id, section_id_from_enrolment, section_id_from_tag
    FROM public.student_enrolment se
    JOIN public.tag_assignment ta ON ta.tag_id = NEW.tag_id
    JOIN public.v_attendance_section_tags_times v 
        ON v.section_id = se.section_id 
    WHERE se.student_id = NEW.student_id
      AND ta.section_id = v.section_id  -- Match section from tag
      AND NEW.scan_time::time >= v.start_time  -- Ensure scan is within the class period
      AND NEW.scan_time::time <= v.end_time
    ORDER BY v.start_time DESC  -- Prioritize the closest valid match
    LIMIT 1;  -- Get the most relevant record

    -- Show attendance and tag info
    RAISE LOG 'Student ID: %, Tag ID: %, Enrolment ID: %, Section ID (from enrolment): %, Section ID (from tag): %',
        NEW.student_id, NEW.tag_id, enrolment_id, section_id_from_enrolment, section_id_from_tag;

    -- Ensure we have a valid enrolment record
    IF enrolment_id IS NULL THEN
        RAISE LOG 'No valid section found for Student ID: % at scan time: %', NEW.student_id, NEW.scan_time;
        RETURN NEW;
    END IF;

    -- Check if both section_ids match
    IF section_id_from_enrolment = section_id_from_tag THEN
        RAISE LOG 'Tag scan section id matches attendance records';

        -- Check if scan record already exists for the student on the scan's date
        SELECT *
        INTO attendance_record
        FROM public.attendance
        WHERE student_enrolment_id = enrolment_id
          AND date = NEW.scan_time::date;

        IF FOUND THEN
            -- Check if the tag_scan_id is NULL
            IF attendance_record.tag_scan_id IS NULL THEN
                RAISE LOG 'Updating attendance record for student % on date %', NEW.student_id, NEW.scan_time::date;
                UPDATE public.attendance
                SET tag_scan_id = NEW.id,
                    entry_time = NEW.scan_time
                WHERE student_enrolment_id = enrolment_id
                  AND date = NEW.scan_time::date;
            ELSE
                RAISE LOG 'Tag scan ID already recorded for student % on date %', NEW.student_id, NEW.scan_time::date;
            END IF;
        END IF;
    ELSE
        RAISE LOG 'Section IDs do not match for student_id: % and tag_id: %', NEW.student_id, NEW.tag_id;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_attendance_with_tag_scan"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."attendance" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "event_id" bigint DEFAULT '1'::bigint,
    "tag_scan_id" bigint,
    "entry_time" timestamp with time zone,
    "date" "date" NOT NULL,
    "student_enrolment_id" bigint NOT NULL,
    "is_test_data" boolean DEFAULT false
);


ALTER TABLE "public"."attendance" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."tag_scan" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "scan_time" timestamp with time zone NOT NULL,
    "tag_id" bigint,
    "student_id" "uuid" NOT NULL,
    "is_test_data" boolean DEFAULT false
);


ALTER TABLE "public"."tag_scan" OWNER TO "postgres";


ALTER TABLE "public"."tag_scan" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."attendance_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE "public"."attendance" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."attendance_id_seq1"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."block" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" character varying NOT NULL,
    "start_time" time without time zone DEFAULT '08:10:00'::time without time zone NOT NULL,
    "end_time" time without time zone DEFAULT '09:30:00'::time without time zone NOT NULL,
    "day_type_id" bigint,
    "is_test_data" boolean DEFAULT false
);


ALTER TABLE "public"."block" OWNER TO "postgres";


ALTER TABLE "public"."block" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."block_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."calendar" (
    "id" integer NOT NULL,
    "term_id" integer NOT NULL,
    "date" "date" NOT NULL,
    "is_school_day" boolean DEFAULT true NOT NULL,
    "reason" "text",
    "is_test_data" boolean DEFAULT false
);


ALTER TABLE "public"."calendar" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."calendar_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."calendar_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."calendar_id_seq" OWNED BY "public"."calendar"."id";



CREATE TABLE IF NOT EXISTS "public"."course" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "code" character varying NOT NULL,
    "name" "text" DEFAULT ''::"text",
    "is_test_data" boolean DEFAULT false
);


ALTER TABLE "public"."course" OWNER TO "postgres";


ALTER TABLE "public"."course" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."course_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."event" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" character varying DEFAULT ''::character varying NOT NULL,
    "is_test_data" boolean DEFAULT false
);


ALTER TABLE "public"."event" OWNER TO "postgres";


ALTER TABLE "public"."event" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."event_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."messages" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "content" "text" DEFAULT ''::"text",
    "sender" "text",
    "is_test_data" boolean DEFAULT false
);


ALTER TABLE "public"."messages" OWNER TO "postgres";


ALTER TABLE "public"."messages" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."messages_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."school_day_type" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" character varying DEFAULT 'Regular'::character varying NOT NULL,
    "is_test_data" boolean DEFAULT false
);


ALTER TABLE "public"."school_day_type" OWNER TO "postgres";


ALTER TABLE "public"."school_day_type" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."school_day_type_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."school_term" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" character varying DEFAULT ''::character varying NOT NULL,
    "start_date" "date" DEFAULT "now"() NOT NULL,
    "end_date" "date" DEFAULT "now"() NOT NULL,
    "is_test_data" boolean DEFAULT false
);


ALTER TABLE "public"."school_term" OWNER TO "postgres";


ALTER TABLE "public"."school_term" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."school_term_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."section" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "section_number" character varying DEFAULT '1'::character varying NOT NULL,
    "course_code" character varying NOT NULL,
    "code" character varying(20) GENERATED ALWAYS AS (((("course_code")::"text" || '-'::"text") || "lpad"(("section_number")::"text", 2, '0'::"text"))) STORED NOT NULL,
    "school_term_id" bigint NOT NULL,
    "block_id" bigint NOT NULL,
    "location" character varying DEFAULT ''::character varying,
    "is_test_data" boolean DEFAULT false
);


ALTER TABLE "public"."section" OWNER TO "postgres";


ALTER TABLE "public"."section" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."section_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."student" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "first_name" "text" DEFAULT ''::"text",
    "last_name" "text" DEFAULT ''::"text",
    "student_number" character varying DEFAULT ''::character varying NOT NULL,
    "email" character varying NOT NULL,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "is_test_data" boolean DEFAULT false
);


ALTER TABLE "public"."student" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."student_enrolment" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "section_id" bigint NOT NULL,
    "school_term_id" bigint NOT NULL,
    "student_id" "uuid" NOT NULL,
    "is_test_data" boolean DEFAULT false
);


ALTER TABLE "public"."student_enrolment" OWNER TO "postgres";


ALTER TABLE "public"."student_enrolment" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."student_enrolment_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."tag" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "note" "text",
    "uid" character varying DEFAULT ''::character varying NOT NULL,
    "is_test_data" boolean DEFAULT false
);


ALTER TABLE "public"."tag" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."tag_assignment" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "tag_id" bigint,
    "section_id" bigint,
    "valid_until" timestamp with time zone DEFAULT ("now"() + '1 day'::interval),
    "is_test_data" boolean DEFAULT false
);


ALTER TABLE "public"."tag_assignment" OWNER TO "postgres";


ALTER TABLE "public"."tag_assignment" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."tag_assignment_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE "public"."tag" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."tags_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."teacher" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "first_name" "text" DEFAULT 'Placeholder'::"text",
    "last_name" "text" DEFAULT 'Placeholder'::"text",
    "email" character varying NOT NULL,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "is_test_data" boolean DEFAULT false
);


ALTER TABLE "public"."teacher" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."teacher_assignment" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "section_id" bigint NOT NULL,
    "school_term_id" bigint NOT NULL,
    "teacher_id" "uuid" NOT NULL,
    "is_test_data" boolean DEFAULT false
);


ALTER TABLE "public"."teacher_assignment" OWNER TO "postgres";


ALTER TABLE "public"."teacher_assignment" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."teacher_assignment_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."user_role" (
    "id" bigint NOT NULL,
    "user_id" "uuid" NOT NULL,
    "role" "public"."role_enum" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "is_test_data" boolean DEFAULT false
);


ALTER TABLE "public"."user_role" OWNER TO "postgres";


ALTER TABLE "public"."user_role" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."user_role_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE OR REPLACE VIEW "public"."v_attendance_section_tags_times" AS
 SELECT "a"."id" AS "attendance_id",
    "a"."date",
    "se"."student_id",
    "st"."student_number",
    "ta"."tag_id",
    "t"."uid" AS "tag_uid",
    "s"."code" AS "section_code",
    "se"."section_id",
    "b"."start_time",
    "b"."end_time"
   FROM (((((("public"."attendance" "a"
     JOIN "public"."student_enrolment" "se" ON (("a"."student_enrolment_id" = "se"."id")))
     JOIN "public"."student" "st" ON (("se"."student_id" = "st"."id")))
     JOIN "public"."section" "s" ON (("se"."section_id" = "s"."id")))
     LEFT JOIN "public"."tag_assignment" "ta" ON (("s"."id" = "ta"."section_id")))
     LEFT JOIN "public"."tag" "t" ON (("ta"."tag_id" = "t"."id")))
     LEFT JOIN "public"."block" "b" ON (("s"."block_id" = "b"."id")));


ALTER TABLE "public"."v_attendance_section_tags_times" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."v_for_student_home" AS
 SELECT "a"."date",
    "se"."student_id",
    "st"."student_number",
    "s"."code" AS "section_code",
    "b"."name" AS "block",
    "b"."start_time",
    "b"."end_time",
    "a"."entry_time"
   FROM (((("public"."attendance" "a"
     JOIN "public"."student_enrolment" "se" ON (("a"."student_enrolment_id" = "se"."id")))
     JOIN "public"."student" "st" ON (("se"."student_id" = "st"."id")))
     JOIN "public"."section" "s" ON (("se"."section_id" = "s"."id")))
     JOIN "public"."block" "b" ON (("s"."block_id" = "b"."id")));


ALTER TABLE "public"."v_for_student_home" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."v_for_teacher_home" WITH ("security_invoker"='false') AS
 SELECT "ta"."teacher_id",
    "s"."code" AS "section_code",
    "a"."date",
    "st"."id" AS "student_id",
    "st"."first_name",
    "st"."last_name",
    "st"."student_number",
    "a"."entry_time",
    "b"."name" AS "block"
   FROM ((((("public"."attendance" "a"
     JOIN "public"."student_enrolment" "se" ON (("a"."student_enrolment_id" = "se"."id")))
     JOIN "public"."section" "s" ON (("se"."section_id" = "s"."id")))
     JOIN "public"."teacher_assignment" "ta" ON (("s"."id" = "ta"."section_id")))
     JOIN "public"."student" "st" ON (("se"."student_id" = "st"."id")))
     JOIN "public"."block" "b" ON (("s"."block_id" = "b"."id")));


ALTER TABLE "public"."v_for_teacher_home" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."v_profile" AS
 SELECT
        CASE
            WHEN ("r"."role" = 'student'::"public"."role_enum") THEN "s"."id"
            WHEN ("r"."role" = 'teacher'::"public"."role_enum") THEN "t"."id"
            ELSE NULL::"uuid"
        END AS "id",
    "u"."id" AS "user_id",
    "u"."email",
        CASE
            WHEN ("r"."role" = 'student'::"public"."role_enum") THEN "s"."first_name"
            WHEN ("r"."role" = 'teacher'::"public"."role_enum") THEN "t"."first_name"
            ELSE NULL::"text"
        END AS "first_name",
        CASE
            WHEN ("r"."role" = 'student'::"public"."role_enum") THEN "s"."last_name"
            WHEN ("r"."role" = 'teacher'::"public"."role_enum") THEN "t"."last_name"
            ELSE NULL::"text"
        END AS "last_name",
    "s"."student_number",
    "r"."role"
   FROM ((("auth"."users" "u"
     JOIN "public"."user_role" "r" ON (("u"."id" = "r"."user_id")))
     LEFT JOIN "public"."student" "s" ON ((("s"."email")::"text" = ("u"."email")::"text")))
     LEFT JOIN "public"."teacher" "t" ON ((("t"."email")::"text" = ("u"."email")::"text")));


ALTER TABLE "public"."v_profile" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."v_tag_details" AS
 SELECT "ta"."id" AS "tag_assignment_id",
    "t"."uid" AS "tag_uid",
    "s"."id" AS "section_id",
    "s"."code" AS "section_code"
   FROM (("public"."tag_assignment" "ta"
     JOIN "public"."tag" "t" ON (("ta"."tag_id" = "t"."id")))
     JOIN "public"."section" "s" ON (("ta"."section_id" = "s"."id")));


ALTER TABLE "public"."v_tag_details" OWNER TO "postgres";


ALTER TABLE ONLY "public"."calendar" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."calendar_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."tag_scan"
    ADD CONSTRAINT "attendance_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."attendance"
    ADD CONSTRAINT "attendance_pkey1" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."block"
    ADD CONSTRAINT "block_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."block"
    ADD CONSTRAINT "block_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."calendar"
    ADD CONSTRAINT "calendar_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."course"
    ADD CONSTRAINT "course_course_id_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."course"
    ADD CONSTRAINT "course_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."event"
    ADD CONSTRAINT "event_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."event"
    ADD CONSTRAINT "event_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."school_day_type"
    ADD CONSTRAINT "schedule_schedule_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."school_day_type"
    ADD CONSTRAINT "schedules_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."school_term"
    ADD CONSTRAINT "school_term_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."school_term"
    ADD CONSTRAINT "school_term_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."section"
    ADD CONSTRAINT "section_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."section"
    ADD CONSTRAINT "section_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."student_enrolment"
    ADD CONSTRAINT "student_enrolment_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."student"
    ADD CONSTRAINT "student_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."student"
    ADD CONSTRAINT "student_student_id_key" UNIQUE ("student_number");



ALTER TABLE ONLY "public"."tag_assignment"
    ADD CONSTRAINT "tag_assignment_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."tag"
    ADD CONSTRAINT "tags_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."tag"
    ADD CONSTRAINT "tags_tag_id_key" UNIQUE ("uid");



ALTER TABLE ONLY "public"."teacher_assignment"
    ADD CONSTRAINT "teacher_assignment_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."teacher"
    ADD CONSTRAINT "teacher_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."section"
    ADD CONSTRAINT "unique_course_section" UNIQUE ("course_code", "section_number");



ALTER TABLE ONLY "public"."student"
    ADD CONSTRAINT "unique_student_email" UNIQUE ("email");



ALTER TABLE ONLY "public"."teacher"
    ADD CONSTRAINT "unique_teacher_email" UNIQUE ("email");



ALTER TABLE ONLY "public"."calendar"
    ADD CONSTRAINT "unique_term_date" UNIQUE ("term_id", "date");



ALTER TABLE ONLY "public"."user_role"
    ADD CONSTRAINT "user_role_pkey" PRIMARY KEY ("id");



CREATE OR REPLACE TRIGGER "tag_scan_insert_trigger" AFTER INSERT ON "public"."tag_scan" FOR EACH ROW EXECUTE FUNCTION "public"."update_attendance_with_tag_scan"();



ALTER TABLE ONLY "public"."attendance"
    ADD CONSTRAINT "attendance_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "public"."event"("id") ON UPDATE CASCADE;



ALTER TABLE ONLY "public"."attendance"
    ADD CONSTRAINT "attendance_student_enrolment_fkey" FOREIGN KEY ("student_enrolment_id") REFERENCES "public"."student_enrolment"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."attendance"
    ADD CONSTRAINT "attendance_tag_scan_id_fkey" FOREIGN KEY ("tag_scan_id") REFERENCES "public"."tag_scan"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."block"
    ADD CONSTRAINT "block_day_type_id_fkey" FOREIGN KEY ("day_type_id") REFERENCES "public"."school_day_type"("id") ON UPDATE CASCADE ON DELETE SET DEFAULT;



ALTER TABLE ONLY "public"."calendar"
    ADD CONSTRAINT "calendar_term_id_fkey" FOREIGN KEY ("term_id") REFERENCES "public"."school_term"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."section"
    ADD CONSTRAINT "section_block_id_fkey" FOREIGN KEY ("block_id") REFERENCES "public"."block"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."section"
    ADD CONSTRAINT "section_course_code_fkey" FOREIGN KEY ("course_code") REFERENCES "public"."course"("code") ON UPDATE CASCADE;



ALTER TABLE ONLY "public"."section"
    ADD CONSTRAINT "section_school_term_id_fkey" FOREIGN KEY ("school_term_id") REFERENCES "public"."school_term"("id") ON UPDATE CASCADE;



ALTER TABLE ONLY "public"."student_enrolment"
    ADD CONSTRAINT "student_enrolment_school_term_id_fkey" FOREIGN KEY ("school_term_id") REFERENCES "public"."school_term"("id") ON UPDATE CASCADE;



ALTER TABLE ONLY "public"."student_enrolment"
    ADD CONSTRAINT "student_enrolment_section_id_fkey" FOREIGN KEY ("section_id") REFERENCES "public"."section"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."student_enrolment"
    ADD CONSTRAINT "student_enrolment_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "public"."student"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tag_assignment"
    ADD CONSTRAINT "tag_assignment_section_id_fkey" FOREIGN KEY ("section_id") REFERENCES "public"."section"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tag_assignment"
    ADD CONSTRAINT "tag_assignment_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "public"."tag"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tag_scan"
    ADD CONSTRAINT "tag_scan_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "public"."student"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tag_scan"
    ADD CONSTRAINT "tag_scan_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "public"."tag"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."teacher_assignment"
    ADD CONSTRAINT "teacher_assignment_school_term_id_fkey" FOREIGN KEY ("school_term_id") REFERENCES "public"."school_term"("id") ON UPDATE CASCADE;



ALTER TABLE ONLY "public"."teacher_assignment"
    ADD CONSTRAINT "teacher_assignment_section_id_fkey" FOREIGN KEY ("section_id") REFERENCES "public"."section"("id") ON UPDATE CASCADE ON DELETE SET DEFAULT;



ALTER TABLE ONLY "public"."teacher_assignment"
    ADD CONSTRAINT "teacher_assignment_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "public"."teacher"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_role"
    ADD CONSTRAINT "user_role_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



CREATE POLICY "Allow authenticated users to read" ON "public"."attendance" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Allow authenticated users to read" ON "public"."block" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Allow authenticated users to read" ON "public"."calendar" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Allow authenticated users to read" ON "public"."course" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Allow authenticated users to read" ON "public"."event" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Allow authenticated users to read" ON "public"."messages" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Allow authenticated users to read" ON "public"."school_day_type" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Allow authenticated users to read" ON "public"."school_term" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Allow authenticated users to read" ON "public"."section" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Allow authenticated users to read" ON "public"."student" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Allow authenticated users to read" ON "public"."student_enrolment" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Allow authenticated users to read" ON "public"."tag" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Allow authenticated users to read" ON "public"."tag_assignment" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Allow authenticated users to read" ON "public"."tag_scan" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Allow authenticated users to read" ON "public"."teacher" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Allow authenticated users to read" ON "public"."teacher_assignment" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Allow authenticated users to read" ON "public"."user_role" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



ALTER TABLE "public"."attendance" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."block" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."calendar" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."course" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."event" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."messages" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."school_day_type" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."school_term" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."section" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."student" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."student_enrolment" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."tag" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."tag_assignment" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."tag_scan" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."teacher" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."teacher_assignment" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_role" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";





GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";


















































































































































































































GRANT ALL ON FUNCTION "public"."assign_tag"("tag_uid" "text", "section_code" "text", "max_tags" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."assign_tag"("tag_uid" "text", "section_code" "text", "max_tags" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."assign_tag"("tag_uid" "text", "section_code" "text", "max_tags" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."create_small_test_data"("term" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."create_small_test_data"("term" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_small_test_data"("term" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."create_test_data"("term" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."create_test_data"("term" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_test_data"("term" integer) TO "service_role";



REVOKE ALL ON FUNCTION "public"."delete_guest_accounts"() FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."delete_guest_accounts"() TO "anon";
GRANT ALL ON FUNCTION "public"."delete_guest_accounts"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_guest_accounts"() TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_test_data"() TO "anon";
GRANT ALL ON FUNCTION "public"."delete_test_data"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_test_data"() TO "service_role";



GRANT ALL ON FUNCTION "public"."enrol_students"("term_id" integer, "section_code" "text", "student_numbers" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."enrol_students"("term_id" integer, "section_code" "text", "student_numbers" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."enrol_students"("term_id" integer, "section_code" "text", "student_numbers" "text"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_attendance_report_per_teacher"("date_param" "text", "teacher_ids" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."get_attendance_report_per_teacher"("date_param" "text", "teacher_ids" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_attendance_report_per_teacher"("date_param" "text", "teacher_ids" "text"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."populate_attendance_from_student_enrolment"("termid" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."populate_attendance_from_student_enrolment"("termid" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."populate_attendance_from_student_enrolment"("termid" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."populate_initial_term_calendar"("termid" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."populate_initial_term_calendar"("termid" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."populate_initial_term_calendar"("termid" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."update_attendance_with_tag_scan"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_attendance_with_tag_scan"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_attendance_with_tag_scan"() TO "service_role";
























GRANT ALL ON TABLE "public"."attendance" TO "anon";
GRANT ALL ON TABLE "public"."attendance" TO "authenticated";
GRANT ALL ON TABLE "public"."attendance" TO "service_role";



GRANT ALL ON TABLE "public"."tag_scan" TO "anon";
GRANT ALL ON TABLE "public"."tag_scan" TO "authenticated";
GRANT ALL ON TABLE "public"."tag_scan" TO "service_role";



GRANT ALL ON SEQUENCE "public"."attendance_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."attendance_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."attendance_id_seq" TO "service_role";



GRANT ALL ON SEQUENCE "public"."attendance_id_seq1" TO "anon";
GRANT ALL ON SEQUENCE "public"."attendance_id_seq1" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."attendance_id_seq1" TO "service_role";



GRANT ALL ON TABLE "public"."block" TO "anon";
GRANT ALL ON TABLE "public"."block" TO "authenticated";
GRANT ALL ON TABLE "public"."block" TO "service_role";



GRANT ALL ON SEQUENCE "public"."block_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."block_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."block_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."calendar" TO "anon";
GRANT ALL ON TABLE "public"."calendar" TO "authenticated";
GRANT ALL ON TABLE "public"."calendar" TO "service_role";



GRANT ALL ON SEQUENCE "public"."calendar_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."calendar_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."calendar_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."course" TO "anon";
GRANT ALL ON TABLE "public"."course" TO "authenticated";
GRANT ALL ON TABLE "public"."course" TO "service_role";



GRANT ALL ON SEQUENCE "public"."course_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."course_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."course_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."event" TO "anon";
GRANT ALL ON TABLE "public"."event" TO "authenticated";
GRANT ALL ON TABLE "public"."event" TO "service_role";



GRANT ALL ON SEQUENCE "public"."event_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."event_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."event_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."messages" TO "anon";
GRANT ALL ON TABLE "public"."messages" TO "authenticated";
GRANT ALL ON TABLE "public"."messages" TO "service_role";



GRANT ALL ON SEQUENCE "public"."messages_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."messages_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."messages_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."school_day_type" TO "anon";
GRANT ALL ON TABLE "public"."school_day_type" TO "authenticated";
GRANT ALL ON TABLE "public"."school_day_type" TO "service_role";



GRANT ALL ON SEQUENCE "public"."school_day_type_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."school_day_type_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."school_day_type_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."school_term" TO "anon";
GRANT ALL ON TABLE "public"."school_term" TO "authenticated";
GRANT ALL ON TABLE "public"."school_term" TO "service_role";



GRANT ALL ON SEQUENCE "public"."school_term_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."school_term_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."school_term_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."section" TO "anon";
GRANT ALL ON TABLE "public"."section" TO "authenticated";
GRANT ALL ON TABLE "public"."section" TO "service_role";



GRANT ALL ON SEQUENCE "public"."section_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."section_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."section_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."student" TO "anon";
GRANT ALL ON TABLE "public"."student" TO "authenticated";
GRANT ALL ON TABLE "public"."student" TO "service_role";



GRANT ALL ON TABLE "public"."student_enrolment" TO "anon";
GRANT ALL ON TABLE "public"."student_enrolment" TO "authenticated";
GRANT ALL ON TABLE "public"."student_enrolment" TO "service_role";



GRANT ALL ON SEQUENCE "public"."student_enrolment_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."student_enrolment_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."student_enrolment_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."tag" TO "anon";
GRANT ALL ON TABLE "public"."tag" TO "authenticated";
GRANT ALL ON TABLE "public"."tag" TO "service_role";



GRANT ALL ON TABLE "public"."tag_assignment" TO "anon";
GRANT ALL ON TABLE "public"."tag_assignment" TO "authenticated";
GRANT ALL ON TABLE "public"."tag_assignment" TO "service_role";



GRANT ALL ON SEQUENCE "public"."tag_assignment_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."tag_assignment_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."tag_assignment_id_seq" TO "service_role";



GRANT ALL ON SEQUENCE "public"."tags_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."tags_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."tags_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."teacher" TO "anon";
GRANT ALL ON TABLE "public"."teacher" TO "authenticated";
GRANT ALL ON TABLE "public"."teacher" TO "service_role";



GRANT ALL ON TABLE "public"."teacher_assignment" TO "anon";
GRANT ALL ON TABLE "public"."teacher_assignment" TO "authenticated";
GRANT ALL ON TABLE "public"."teacher_assignment" TO "service_role";



GRANT ALL ON SEQUENCE "public"."teacher_assignment_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."teacher_assignment_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."teacher_assignment_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."user_role" TO "anon";
GRANT ALL ON TABLE "public"."user_role" TO "authenticated";
GRANT ALL ON TABLE "public"."user_role" TO "service_role";



GRANT ALL ON SEQUENCE "public"."user_role_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."user_role_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."user_role_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."v_attendance_section_tags_times" TO "anon";
GRANT ALL ON TABLE "public"."v_attendance_section_tags_times" TO "authenticated";
GRANT ALL ON TABLE "public"."v_attendance_section_tags_times" TO "service_role";



GRANT ALL ON TABLE "public"."v_for_student_home" TO "anon";
GRANT ALL ON TABLE "public"."v_for_student_home" TO "authenticated";
GRANT ALL ON TABLE "public"."v_for_student_home" TO "service_role";



GRANT ALL ON TABLE "public"."v_for_teacher_home" TO "anon";
GRANT ALL ON TABLE "public"."v_for_teacher_home" TO "authenticated";
GRANT ALL ON TABLE "public"."v_for_teacher_home" TO "service_role";



GRANT ALL ON TABLE "public"."v_profile" TO "anon";
GRANT ALL ON TABLE "public"."v_profile" TO "authenticated";
GRANT ALL ON TABLE "public"."v_profile" TO "service_role";



GRANT ALL ON TABLE "public"."v_tag_details" TO "anon";
GRANT ALL ON TABLE "public"."v_tag_details" TO "authenticated";
GRANT ALL ON TABLE "public"."v_tag_details" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























RESET ALL;
