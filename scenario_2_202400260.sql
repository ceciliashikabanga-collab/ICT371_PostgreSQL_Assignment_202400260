-- Scenario 2: Computer Laboratory Reservations
-- Student Number: 202400260

CREATE TABLE lab_sessions (
    session_id SERIAL PRIMARY KEY,
    session_name VARCHAR(50),
    available_workstations INT
);

CREATE TABLE reservations (
    reservation_id SERIAL PRIMARY KEY,
    lecturer VARCHAR(50),
    session_id INT REFERENCES lab_sessions(session_id),
    num_workstations INT,
    status VARCHAR(20)
);

-- Insert sample sessions
INSERT INTO lab_sessions (session_name, available_workstations)
VALUES ('Networking Basics', 10), ('Database Systems', 5), ('Operating Systems', 8);

-- Procedure to reserve workstations
CREATE OR REPLACE PROCEDURE reserve_workstations(p_lecturer VARCHAR, p_session INT, p_num INT)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_num <= 0 THEN
        RAISE EXCEPTION 'Invalid number of workstations requested';
    END IF;

    IF (SELECT available_workstations FROM lab_sessions WHERE session_id = p_session) < p_num THEN
        INSERT INTO reservations (lecturer, session_id, num_workstations, status)
        VALUES (p_lecturer, p_session, p_num, 'FAILED');
    ELSE
        UPDATE lab_sessions SET available_workstations = available_workstations - p_num
        WHERE session_id = p_session;
        INSERT INTO reservations (lecturer, session_id, num_workstations, status)
        VALUES (p_lecturer, p_session, p_num, 'CONFIRMED');
    END IF;
END;
$$;

-- Test calls
CALL reserve_workstations('Dr. Banda', 1, 3);
CALL reserve_workstations('Prof. Mwila', 2, 5);
CALL reserve_workstations('Dr. Chanda', 3, 10); -- exceeds capacity
DROP TABLE IF EXISTS lab_sessions CASCADE;
DROP TABLE IF EXISTS reservations CASCADE;

-- Then rerun your full script from the top

-- Scenario 2: Computer Laboratory Reservations
-- Student Number: 202400260

CREATE TABLE lab_sessions (
    session_id SERIAL PRIMARY KEY,
    session_name VARCHAR(50),
    available_workstations INT
);

CREATE TABLE reservations (
    reservation_id SERIAL PRIMARY KEY,
    lecturer VARCHAR(50),
    session_id INT REFERENCES lab_sessions(session_id),
    num_workstations INT,
    status VARCHAR(20)
);

-- Insert sample sessions
INSERT INTO lab_sessions (session_name, available_workstations)
VALUES ('Networking Basics', 10), ('Database Systems', 5), ('Operating Systems', 8);

-- Procedure to reserve workstations
CREATE OR REPLACE PROCEDURE reserve_workstations(p_lecturer VARCHAR, p_session INT, p_num INT)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_num <= 0 THEN
        RAISE EXCEPTION 'Invalid number of workstations requested';
    END IF;

    IF (SELECT available_workstations FROM lab_sessions WHERE session_id = p_session) < p_num THEN
        INSERT INTO reservations (lecturer, session_id, num_workstations, status)
        VALUES (p_lecturer, p_session, p_num, 'FAILED');
    ELSE
        UPDATE lab_sessions SET available_workstations = available_workstations - p_num
        WHERE session_id = p_session;
        INSERT INTO reservations (lecturer, session_id, num_workstations, status)
        VALUES (p_lecturer, p_session, p_num, 'CONFIRMED');
    END IF;
END;
$$;

-- Test calls
CALL reserve_workstations('Dr. Banda', 1, 3);
CALL reserve_workstations('Prof. Mwila', 2, 5);
CALL reserve_workstations('Dr. Chanda', 3, 10); -- exceeds capacity
-- Cursor to display sessions with few workstations remaining
DO $$
DECLARE
    rec RECORD;
    cur CURSOR FOR SELECT session_name, available_workstations
                   FROM lab_sessions
                   WHERE available_workstations <= 2;
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Session: %, Remaining: %', rec.session_name, rec.available_workstations;
    END LOOP;
    CLOSE cur;
END;
$$;

