-- Scenario 3: Hostel Room Allocation
-- Student Number: 202400260

CREATE TABLE hostel_rooms (
    room_id SERIAL PRIMARY KEY,
    room_name VARCHAR(50),
    available_spaces INT
);

CREATE TABLE allocations (
    allocation_id SERIAL PRIMARY KEY,
    student_number VARCHAR(20),
    room_id INT REFERENCES hostel_rooms(room_id),
    status VARCHAR(20)
);

-- Insert sample rooms
INSERT INTO hostel_rooms (room_name, available_spaces)
VALUES ('Room A', 2), ('Room B', 1), ('Room C', 3);

-- Procedure to allocate room
CREATE OR REPLACE PROCEDURE allocate_room(p_student VARCHAR, p_room INT)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_student IS NULL OR p_student = '' THEN
        RAISE EXCEPTION 'Invalid student number';
    END IF;

    IF (SELECT available_spaces FROM hostel_rooms WHERE room_id = p_room) < 1 THEN
        INSERT INTO allocations (student_number, room_id, status)
        VALUES (p_student, p_room, 'FAILED');
    ELSE
        UPDATE hostel_rooms SET available_spaces = available_spaces - 1
        WHERE room_id = p_room;
        INSERT INTO allocations (student_number, room_id, status)
        VALUES (p_student, p_room, 'ALLOCATED');
    END IF;
END;
$$;

-- Test calls
CALL allocate_room('202400260', 1);
CALL allocate_room('202400261', 2);
CALL allocate_room('202400262', 2); -- room full
-- Cursor to display full or nearly full rooms
DO $$
DECLARE
    rec RECORD;
    cur CURSOR FOR SELECT room_name, available_spaces
                   FROM hostel_rooms
                   WHERE available_spaces <= 1;
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Room: %, Spaces left: %', rec.room_name, rec.available_spaces;
    END LOOP;
    CLOSE cur;
END;
$$;

