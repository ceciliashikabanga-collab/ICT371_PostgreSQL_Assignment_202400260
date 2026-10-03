-- Scenario 5: Engineering Workshop Tool Loans
-- Student Number: 202400260

CREATE TABLE tools (
    tool_id SERIAL PRIMARY KEY,
    tool_name VARCHAR(50),
    available_quantity INT
);

CREATE TABLE tool_loans (
    loan_id SERIAL PRIMARY KEY,
    student_number VARCHAR(20),
    tool_id INT REFERENCES tools(tool_id),
    quantity INT,
    status VARCHAR(20)
);

-- Insert sample tools
INSERT INTO tools (tool_name, available_quantity)
VALUES ('Hammer', 5), ('Screwdriver', 3), ('Wrench', 2);

-- Procedure to issue tool
CREATE OR REPLACE PROCEDURE issue_tool(p_student VARCHAR, p_tool INT, p_qty INT)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_qty <= 0 THEN
        RAISE EXCEPTION 'Invalid tool quantity requested';
    END IF;

    IF (SELECT available_quantity FROM tools WHERE tool_id = p_tool) < p_qty THEN
        INSERT INTO tool_loans (student_number, tool_id, quantity, status)
        VALUES (p_student, p_tool, p_qty, 'FAILED');
    ELSE
        UPDATE tools SET available_quantity = available_quantity - p_qty
        WHERE tool_id = p_tool;
        INSERT INTO tool_loans (student_number, tool_id, quantity, status)
        VALUES (p_student, p_tool, p_qty, 'ISSUED');
    END IF;
END;
$$;

-- Test calls
CALL issue_tool('202400260', 1, 2);
CALL issue_tool('202400261', 2, 1);
CALL issue_tool('202400262', 3, 5); -- exceeds stock
-- Cursor to display tools with low availability
DO $$
DECLARE
    rec RECORD;
    cur CURSOR FOR SELECT tool_name, available_quantity
                   FROM tools
                   WHERE available_quantity <= 1;
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Tool: %, Remaining: %', rec.tool_name, rec.available_quantity;
    END LOOP;
    CLOSE cur;
END;
$$;
