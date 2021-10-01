1)

a.SELECT * FROM course WHERE credits > 3;

b.SELECT * FROM classroom WHERE building = 'Watson' or building = 'Packard';

c.SELECT * FROM course WHERE dept_name = 'Comp. Sci.';

d.SELECT course_id FROM teaches WHERE semester = 'Fall';

e.SELECT * FROM student WHERE tot_cred BETWEEN 45 and 90;

f.SELECT * FROM student WHERE name
SIMILAR TO '%[aeioy]';

g.SELECT * FROM course WHERE course_id in
(SELECT prereq.course_id from prereq WHERE prereq_id = 'CS-101');

---
2)

a.SELECT dept_name, avg(salary) as avg_salary FROM instructor
GROUP BY dept_name order by avg_salary asc;

b.SELECT building from (SELECT building, count(building) as course_num FROM section GROUP BY building) as foo
WHERE course_num = (SELECT max(course_num) FROM (SELECT building, count(building)
as course_num FROM section GROUP BY building) as foo);

c.SELECT dept_name from (SELECT dept_name, count(dept_name) as course_num from course GROUP BY dept_name) as foo
WHERE course_num = (SELECT max(course_num) FROM (SELECT dept_name, count(course)
as course_num FROM course GROUP BY dept_name) as foo);

d.SELECT student.name, student.id, lol.course_num FROM (SELECT id, count(course_id) as course_num FROM
(SELECT id, course.course_id FROM takes, course
WHERE takes.course_id = course.course_id and course.dept_name = 'Comp. Sci.') as foo GROUP BY id) as lol, student
WHERE lol.id = student.id and course_num > 3;

e.SELECT * FROM instructor WHERE dept_name = 'Biology' or dept_name = 'Music' or dept_name = 'Physics';

f.SELECT distinct id FROM teaches WHERE year != '2017';

---
3)

a.SELECT distinct student.id, name FROM (SELECT id, course.course_id, grade FROM takes, course
WHERE takes.course_id = course.course_id and course.dept_name = 'Comp. Sci.' and (grade = 'A' or grade = 'A-'))
as foo, student WHERE student.id = foo.id order by name asc;

b.SELECT distinct teaches.id FROM (SELECT id, course_id, sec_id, semester, year FROM takes
WHERE grade = 'C' or grade = 'C+' or grade = 'C-')
as foo, teaches WHERE
(teaches.semester, teaches.course_id, teaches.year, teaches.sec_id) =
(foo.semester, foo.course_id, foo.year, foo.sec_id);

c.(SELECT student.dept_name FROM student) EXCEPT
(SELECT distinct dept_name FROM (SELECT id FROM takes
WHERE grade = 'C' or grade = 'C+' or grade = 'C-' or grade = 'F') as foo, student
WHERE foo.id = student.id);

d.(SELECT instructor.id FROM instructor) EXCEPT
(SELECT distinct teaches.id FROM(SELECT course_id, sec_id, semester, year FROM takes
WHERE grade = 'A' or grade = 'A-' or grade = 'A+') as foo, teaches
WHERE (foo.course_id, foo.sec_id, foo.semester, foo.year) =
      (teaches.course_id, teaches.sec_id, teaches.semester, teaches.year));

e.SELECT * FROM section WHERE section.time_slot_id not in
(SELECT distinct time_slot_id FROM time_slot WHERE end_hr < 13);