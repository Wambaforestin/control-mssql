CREATE TRIGGER TRG_COMPLETE_TOUR
ON turns
AFTER UPDATE
AS
BEGIN
    DECLARE @tour_id INT;
    DECLARE @party_id INT;
    
    -- Récupétion de l'identifiant du tour
    SELECT @tour_id = id_turn FROM inserted;
    
    -- Récupétion de l'identifiant de la partie
    SELECT @party_id = id_party
    FROM turns
    WHERE id_turn = @tour_id;

    -- Appel de la procédure
    EXEC COMPLETE_TOUR @tour_id, @party_id;
END;
/*
Test du trigger
-- UPDATE turns SET end_time = GETDATE() WHERE id_turn = 1;
*/
CREATE TRIGGER trg_username_lowercase
ON players
AFTER INSERT
AS
BEGIN
    EXEC USERNAME_TO_LOWER;
END;

/*
Test du trigger
-- INSERT INTO players (pseudo) VALUES ('Joueur 1');
*/
