-- PL060
-- author: Matt Noblett
-- -----------------------------------------------------------------
SET SERVEROUTPUT ON
SET VERIFY OFF
-- ----------------------------------
ACCEPT rateDec NUMBER PROMPT 'Enter an increment for rental rate: '
ACCEPT allowedMinRate NUMBER PROMPT 'Enter the min allowed rentral rate: '
DECLARE
   br 	boats%ROWTYPE;
   CURSOR bCursor IS
      SELECT B.bid, B.bname, B.color, B.rate, B.length, B.logkeeper
      FROM Boats B
      WHERE B.bid NOT IN (SELECT R.bid
   		   	FROM Reservations R);
BEGIN
   OPEN bCursor;
   LOOP
FETCH bCursor INTO br;
EXIT WHEN bCursor%NOTFOUND;
DBMS_OUTPUT.PUT_LINE ('+++++ Boat: '||br.bid||': old rate = '||br.rate);
  	br.rate := br.rate - &rateDec;
  	DECLARE
     	belowAllowedMin EXCEPTION;
  	BEGIN
     	IF   br.rate < &allowedMinRate
     	THEN RAISE belowAllowedMin;
     	ELSE UPDATE boats
SET rate = br.rate
WHERE boats.bid = br.bid;
DBMS_OUTPUT.PUT_LINE ('----- Boat: '||br.bid||': new rate = '||br.rate);
END IF;
  	EXCEPTION
    	WHEN belowAllowedMin THEN
       	DBMS_OUTPUT.PUT_LINE('----- Boat: '||br.bid||' Update rejected. The new rate would have been '||br.rate);
    	WHEN OTHERS THEN
       	DBMS_OUTPUT.PUT_LINE('----- update rejected: ');
END;
END LOOP;
COMMIT;
   CLOSE bCursor;
END;
/
/*
SELECT B.bid, B.rate
FROM   Boats B
WHERE  B.bid NOT IN (SELECT R.bid
   	  	FROM Reservations R);
*/
--
UNDEFINE allowedMinRate
UNDEFINE rateDec
