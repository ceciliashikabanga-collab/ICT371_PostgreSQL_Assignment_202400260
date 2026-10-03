-- Scenario 6: University Event Seat Booking
-- Student Number: 202400260

CREATE TABLE events (
    event_id SERIAL PRIMARY KEY,
    event_name VARCHAR(50),
    available_seats INT
);

CREATE TABLE bookings (
    booking_id SERIAL PRIMARY KEY,
    student_number VARCHAR(20),
    event_id INT REFERENCES events(event_id),
    num_seats INT,
    status VARCHAR(20)
);

-- Insert sample events
INSERT INTO events (event_name, available_seats)
VALUES ('Tech Fair', 20), ('Graduation', 10), ('Sports Gala', 15);

-- Procedure to book seats
CREATE OR REPLACE PROCEDURE book_seats(p_student VARCHAR, p_event INT, p_num INT)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_num <= 0 THEN
        RAISE EXCEPTION 'Invalid number of seats requested';
    END IF;

    IF (SELECT available_seats FROM events WHERE event_id = p_event) < p_num THEN
        INSERT INTO bookings (student_number, event_id, num_seats, status)
        VALUES (p_student, p_event, p_num, 'FAILED');
    ELSE
        UPDATE events SET available_seats = available_seats - p_num
        WHERE event_id = p_event;
        INSERT INTO bookings (student_number, event_id, num_seats, status)
        VALUES (p_student, p_event, p_num, 'BOOKED');
    END IF;
END;
$$;

-- Test calls
CALL book_seats('202400260', 1, 5);
CALL book_seats('202400261', 2, 10);
CALL book_seats('202400262', 3, 20); -- exceeds seats
-- Cursor to display full or nearly full events
DO $$
DECLARE
    rec RECORD;
    cur CURSOR FOR SELECT event_name, available_seats
                   FROM events
                   WHERE available_seats <= 2;
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Event: %, Seats left: %', rec.event_name, rec.available_seats;
    END LOOP;
    CLOSE cur;
END;
$$;

