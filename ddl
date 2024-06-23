CREATE TABLE Gudang (
    KodeGudang INT AUTO_INCREMENT PRIMARY KEY,
    NamaGudang VARCHAR(100) NOT NULL
);

CREATE TABLE Barang (
    KodeBarang INT AUTO_INCREMENT PRIMARY KEY,
    NamaBarang VARCHAR(100) NOT NULL,
    HargaBarang DECIMAL(10, 2) NOT NULL,
    JumlahBarang INT NOT NULL,
    ExpiredBarang DATE NOT NULL,
    KodeGudang INT,
    FOREIGN KEY (KodeGudang) REFERENCES Gudang(KodeGudang),
    INDEX (KodeGudang)
);

DELIMITER //

CREATE PROCEDURE GetBarangPaged (
    IN start INT,
    IN limit INT
)
BEGIN
    SET @sql = CONCAT(
        'SELECT g.KodeGudang, g.NamaGudang, b.KodeBarang, b.NamaBarang, b.HargaBarang, b.JumlahBarang, b.ExpiredBarang ',
        'FROM Gudang g ',
        'JOIN Barang b ON g.KodeGudang = b.KodeGudang ',
        'LIMIT ', start, ', ', limit
    );
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER BarangKadaluarsa
AFTER INSERT ON Barang
FOR EACH ROW
BEGIN
    DECLARE msg VARCHAR(255);
    IF NEW.ExpiredBarang < CURDATE() THEN
        SET msg = CONCAT('Barang dengan Kode: ', NEW.KodeBarang, ' dan Nama: ', NEW.NamaBarang, ' di Gudang ', NEW.KodeGudang, ' sudah kadaluarsa.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
    END IF;
END //

DELIMITER ;
