DROP DATABASE IF EXISTS fitness_club;
CREATE DATABASE fitness_club CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE fitness_club;


CREATE TABLE КЛУБ (
                      КК INT AUTO_INCREMENT PRIMARY KEY,
                      Название VARCHAR(50) NOT NULL,
                      Адрес VARCHAR(100) NOT NULL,
                      Количество_залов INT,
                      Общее_число_членов INT
);

CREATE TABLE ТЕЛЕФОН_КЛУБА (
                               КК INT NOT NULL,
                               Телефон VARCHAR(20) NOT NULL,
                               PRIMARY KEY (КК, Телефон),
                               FOREIGN KEY (КК) REFERENCES КЛУБ(КК) ON DELETE CASCADE
);

CREATE TABLE ЗАЛ (
                     КК INT NOT NULL,
                     НЗ INT NOT NULL,
                     Название VARCHAR(50),
                     Вместимость INT,
                     Тип_зала VARCHAR(50),
                     PRIMARY KEY (КК, НЗ),
                     FOREIGN KEY (КК) REFERENCES КЛУБ(КК) ON DELETE CASCADE
);

CREATE TABLE ПЕРСОНАЛ (
                          КК INT NOT NULL,
                          НЗ INT,
                          Фамилия VARCHAR(50),
                          Должность ENUM('администратор','тренер','инструктор','уборщик','менеджер') NOT NULL,
                          Смена ENUM('утренняя','дневная','вечерняя'),
                          Зарплата DECIMAL(10,2),
                          PRIMARY KEY (КК, НЗ, Фамилия),
                          FOREIGN KEY (КК) REFERENCES КЛУБ(КК) ON DELETE CASCADE,
                          FOREIGN KEY (КК, НЗ) REFERENCES ЗАЛ(КК, НЗ) ON DELETE CASCADE
);

CREATE TABLE ТРЕНЕР (
                        КТ INT AUTO_INCREMENT PRIMARY KEY,
                        КК INT NOT NULL,
                        Фамилия VARCHAR(50),
                        Специализация VARCHAR(50),
                        Стаж INT,
                        FOREIGN KEY (КК) REFERENCES КЛУБ(КК) ON DELETE CASCADE
);

CREATE TABLE ЧЛЕН_КЛУБА (
                            РН INT AUTO_INCREMENT PRIMARY KEY,
                            Фамилия VARCHAR(50),
                            Имя VARCHAR(50),
                            Адрес VARCHAR(100),
                            Дата_рождения DATE,
                            Пол ENUM('мужской','женский'),
                            Дата_регистрации DATE,
                            Код_тренера INT,
                            FOREIGN KEY (Код_тренера) REFERENCES ТРЕНЕР(КТ) ON DELETE SET NULL
);

CREATE TABLE ДОГОВОР_ЧЛЕНСТВА (
                                  Номер_договора INT AUTO_INCREMENT PRIMARY KEY,
                                  РН INT NOT NULL,
                                  КК INT NOT NULL,
                                  Дата_заключения DATE,
                                  Дата_окончания DATE,
                                  Текущее_состояние ENUM('действующий','приостановлен','завершён'),
                                  FOREIGN KEY (РН) REFERENCES ЧЛЕН_КЛУБА(РН) ON DELETE CASCADE,
                                  FOREIGN KEY (КК) REFERENCES КЛУБ(КК) ON DELETE CASCADE
);


CREATE TABLE АБОНЕМЕНТ (
                           Номер_абонемента INT AUTO_INCREMENT PRIMARY KEY,
                           Регистрационный_номер INT NOT NULL,
                           Название_типа VARCHAR(50) NOT NULL,
                           Описание TEXT,
                           Максимальная_длительность INT,
                           Базовая_стоимость DECIMAL(10,2),
                           Дата_начала DATE,
                           Дата_окончания DATE,
                           Стоимость DECIMAL(10,2),
                           Состояние ENUM('действующий', 'завершён', 'приостановлен') NOT NULL DEFAULT 'действующий',
                           FOREIGN KEY (Регистрационный_номер) REFERENCES ЧЛЕН_КЛУБА(РН) ON DELETE CASCADE
);

CREATE TABLE ПОСЕЩЕНИЕ (
                           РН INT NOT NULL,
                           КК INT NOT NULL,
                           НЗ INT NOT NULL,
                           Дата_посещения DATE,
                           Время_входа TIME,
                           Время_выхода TIME,
                           PRIMARY KEY (РН, Дата_посещения, НЗ),
                           FOREIGN KEY (РН) REFERENCES ЧЛЕН_КЛУБА(РН) ON DELETE CASCADE,
                           FOREIGN KEY (КК, НЗ) REFERENCES ЗАЛ(КК, НЗ) ON DELETE CASCADE
);

CREATE TABLE УСЛУГА (
                        КУ INT AUTO_INCREMENT PRIMARY KEY,
                        Название VARCHAR(50),
                        Описание TEXT,
                        Стоимость DECIMAL(10,2),
                        Тип_услуги VARCHAR(50)
);

CREATE TABLE ЗАКАЗ_УСЛУГИ (
                              РН INT NOT NULL,
                              КУ INT NOT NULL,
                              Дата_заказа DATE,
                              Время_заказа TIME,
                              Количество INT,
                              Состояние ENUM('в процессе','выполнен','отменён'),
                              PRIMARY KEY (РН, КУ, Дата_заказа),
                              FOREIGN KEY (РН) REFERENCES ЧЛЕН_КЛУБА(РН) ON DELETE CASCADE,
                              FOREIGN KEY (КУ) REFERENCES УСЛУГА(КУ) ON DELETE CASCADE
);

CREATE TABLE БОНУСНАЯ_СИСТЕМА (
                                  РН INT PRIMARY KEY,
                                  Количество_бонусов INT,
                                  Уровень_участника VARCHAR(50),
                                  FOREIGN KEY (РН) REFERENCES ЧЛЕН_КЛУБА(РН) ON DELETE CASCADE
);



DELIMITER $$

CREATE TRIGGER trg_договор_insert
    BEFORE INSERT ON ДОГОВОР_ЧЛЕНСТВА
    FOR EACH ROW
BEGIN
    IF NEW.Дата_окончания <= NEW.Дата_заключения THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Дата окончания должна быть больше даты заключения';
    END IF;
END$$

CREATE TRIGGER trg_договор_update
    BEFORE UPDATE ON ДОГОВОР_ЧЛЕНСТВА
    FOR EACH ROW
BEGIN
    IF NEW.Дата_окончания <= NEW.Дата_заключения THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Дата окончания должна быть больше даты заключения';
    END IF;
END$$

CREATE TRIGGER trg_абонемент_insert
    BEFORE INSERT ON АБОНЕМЕНТ
    FOR EACH ROW
BEGIN
    IF NEW.Дата_окончания <= NEW.Дата_начала THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Дата окончания должна быть позже даты начала';
    END IF;
END$$

CREATE TRIGGER trg_абонемент_update
    BEFORE UPDATE ON АБОНЕМЕНТ
    FOR EACH ROW
BEGIN
    IF NEW.Дата_окончания <= NEW.Дата_начала THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Дата окончания должна быть позже даты начала';
    END IF;
END$$

DELIMITER ;



INSERT INTO КЛУБ (Название, Адрес, Количество_залов, Общее_число_членов) VALUES
    ('ФитЛайф', 'Москва, ул. Ленина, 12', 3, 15);

INSERT INTO ТЕЛЕФОН_КЛУБА VALUES (1, '+7-999-111-22-33');

INSERT INTO ЗАЛ VALUES
                    (1, 1, 'Кардиозал', 30, 'фитнес'),
                    (1, 2, 'Силовой зал', 25, 'тренажёрный'),
                    (1, 3, 'Йога зал', 15, 'групповые занятия');

INSERT INTO ПЕРСОНАЛ VALUES
                         (1, 1, 'Иванова', 'администратор', 'утренняя', 35000),
                         (1, 2, 'Смирнов', 'инструктор', 'дневная', 45000),
                         (1, 3, 'Ковалев', 'тренер', 'вечерняя', 50000),
                         (1, 1, 'Петров', 'уборщик', 'вечерняя', 20000);

INSERT INTO ТРЕНЕР (КК, Фамилия, Специализация, Стаж) VALUES
                                                          (1, 'Кузнецов', 'Йога', 5),
                                                          (1, 'Иванов', 'Кардиотренировки', 3),
                                                          (1, 'Полякова', 'Силовой фитнес', 7);

INSERT INTO ЧЛЕН_КЛУБА (Фамилия, Имя, Адрес, Дата_рождения, Пол, Дата_регистрации, Код_тренера) VALUES
                                                                                                    ('Петров', 'Андрей', 'Москва, ул. Горького, 5', '1995-06-10', 'мужской', '2024-01-10', 1),
                                                                                                    ('Сидорова', 'Мария', 'Москва, ул. Кузнецова, 22', '1990-03-15', 'женский', '2024-02-05', 3),
                                                                                                    ('Ким', 'Алексей', 'Москва, ул. Попова, 9', '1998-09-25', 'мужской', '2024-03-12', 2);

INSERT INTO ДОГОВОР_ЧЛЕНСТВА (РН, КК, Дата_заключения, Дата_окончания, Текущее_состояние) VALUES
                                                                                              (1, 1, '2024-01-10', '2025-01-10', 'действующий'),
                                                                                              (2, 1, '2024-02-10', '2025-02-10', 'действующий'),
                                                                                              (3, 1, '2024-03-15', '2024-09-15', 'приостановлен');

INSERT INTO АБОНЕМЕНТ
(Регистрационный_номер, Название_типа, Описание, Максимальная_длительность, Базовая_стоимость, Дата_начала, Дата_окончания, Стоимость, Состояние)
VALUES
    (1, 'Безлимит', 'Неограниченное количество посещений в течение 6 месяцев', 180, 15000, '2024-01-10', '2024-07-10', 15000, 'действующий'),
    (2, '12 посещений', '12 посещений в течение 3 месяцев', 90, 9000, '2024-02-10', '2024-08-10', 9000, 'завершён'),
    (3, 'Разовое', 'Один визит без ограничений по времени', 1, 700, '2024-03-15', '2024-09-15', 16000, 'приостановлен');



-- тренеры и количество их клиентов
SELECT ТРЕНЕР.Фамилия AS Тренер,
       COUNT(ЧЛЕН_КЛУБА.РН) AS Количество_клиентов
FROM ТРЕНЕР
         LEFT JOIN ЧЛЕН_КЛУБА ON ТРЕНЕР.КТ = ЧЛЕН_КЛУБА.Код_тренера
GROUP BY ТРЕНЕР.КТ, ТРЕНЕР.Фамилия;

-- средняя зарплата по должности
SELECT Должность,
       AVG(Зарплата) AS Средняя_зарплата
FROM ПЕРСОНАЛ
GROUP BY Должность;

-- количество посещений каждого члена
SELECT ЧЛЕН_КЛУБА.Фамилия,
       ЧЛЕН_КЛУБА.Имя,
       COUNT(ПОСЕЩЕНИЕ.Дата_посещения) AS Количество_посещений
FROM ЧЛЕН_КЛУБА
         LEFT JOIN ПОСЕЩЕНИЕ ON ЧЛЕН_КЛУБА.РН = ПОСЕЩЕНИЕ.РН
GROUP BY ЧЛЕН_КЛУБА.РН, ЧЛЕН_КЛУБА.Фамилия, ЧЛЕН_КЛУБА.Имя
ORDER BY Количество_посещений DESC;

-- список членов с текущими абонементами
SELECT ЧЛЕН_КЛУБА.Фамилия,
       ЧЛЕН_КЛУБА.Имя,
       АБОНЕМЕНТ.Название_типа AS Тип_абонемента,
       АБОНЕМЕНТ.Состояние
FROM АБОНЕМЕНТ
         INNER JOIN ЧЛЕН_КЛУБА
                    ON АБОНЕМЕНТ.Регистрационный_номер = ЧЛЕН_КЛУБА.РН
WHERE АБОНЕМЕНТ.Состояние = 'действующий'
ORDER BY ЧЛЕН_КЛУБА.Фамилия;

-- топ тренеров по количеству клиентов
SELECT ТРЕНЕР.Фамилия AS Тренер,
       COUNT(ЧЛЕН_КЛУБА.РН) AS Количество_клиентов
FROM ТРЕНЕР
         LEFT JOIN ЧЛЕН_КЛУБА ON ТРЕНЕР.КТ = ЧЛЕН_КЛУБА.Код_тренера
GROUP BY ТРЕНЕР.КТ, ТРЕНЕР.Фамилия
ORDER BY Количество_клиентов DESC
LIMIT 2;

-- топ посещаемости по залам
SELECT КЛУБ.Название AS Клуб,
       ЗАЛ.Название AS Зал,
       COUNT(ПОСЕЩЕНИЕ.Дата_посещения) AS Количество_посещений
FROM ПОСЕЩЕНИЕ
         INNER JOIN ЗАЛ ON ПОСЕЩЕНИЕ.КК = ЗАЛ.КК AND ПОСЕЩЕНИЕ.НЗ = ЗАЛ.НЗ
         INNER JOIN КЛУБ ON ЗАЛ.КК = КЛУБ.КК
GROUP BY ЗАЛ.КК, ЗАЛ.НЗ
ORDER BY Количество_посещений DESC
LIMIT 5;

-- абонементы истекающие через .. дней
SELECT COUNT(*) AS Количество_абонементов
FROM АБОНЕМЕНТ
WHERE Дата_окончания = DATE_ADD(CURDATE(), INTERVAL 15 DAY);
