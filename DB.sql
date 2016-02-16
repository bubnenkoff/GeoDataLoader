-- --------------------------------------------------------
-- Хост:                         127.0.0.1
-- Версия сервера:               5.5.5-10.0.15-MariaDB - mariadb.org binary distribution
-- ОС Сервера:                   Win32
-- HeidiSQL Версия:              8.3.0.4694
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Дамп структуры для таблица test.desp
CREATE TABLE IF NOT EXISTS `desp` (
  `Date` date DEFAULT NULL,
  `Time` time DEFAULT NULL,
  `S0` varchar(10) DEFAULT NULL,
  `S1` varchar(10) DEFAULT NULL,
  `S2` varchar(10) DEFAULT NULL,
  `S3` varchar(10) DEFAULT NULL,
  `S4` varchar(10) DEFAULT NULL,
  `S5` varchar(10) DEFAULT NULL,
  `S6` varchar(10) DEFAULT NULL,
  `S7` varchar(10) DEFAULT NULL,
  `S8` varchar(10) DEFAULT NULL,
  `S9` varchar(10) DEFAULT NULL,
  `S10` varchar(10) DEFAULT NULL,
  `S11` varchar(10) DEFAULT NULL,
  `S12` varchar(10) DEFAULT NULL,
  `S13` varchar(10) DEFAULT NULL,
  `S14` varchar(10) DEFAULT NULL,
  `S15` varchar(10) DEFAULT NULL,
  `S16` varchar(10) DEFAULT NULL,
  `S17` varchar(10) DEFAULT NULL,
  `S18` varchar(10) DEFAULT NULL,
  `S19` varchar(10) DEFAULT NULL,
  `S20` varchar(10) DEFAULT NULL,
  `S21` varchar(10) DEFAULT NULL,
  `S22` varchar(10) DEFAULT NULL,
  `S23` varchar(10) DEFAULT NULL,
  `S24` varchar(10) DEFAULT NULL,
  `S25` varchar(10) DEFAULT NULL,
  `S26` varchar(10) DEFAULT NULL,
  `S27` varchar(10) DEFAULT NULL,
  `S28` varchar(10) DEFAULT NULL,
  `S29` varchar(10) DEFAULT NULL,
  `S30` varchar(10) DEFAULT NULL,
  `S31` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.


-- Дамп структуры для таблица test.desp_uz
CREATE TABLE IF NOT EXISTS `desp_uz` (
  `Date` date DEFAULT NULL,
  `Time` time DEFAULT NULL,
  `S0` varchar(10) DEFAULT NULL,
  `S1` varchar(10) DEFAULT NULL,
  `S2` varchar(10) DEFAULT NULL,
  `S3` varchar(10) DEFAULT NULL,
  `S4` varchar(10) DEFAULT NULL,
  `S5` varchar(10) DEFAULT NULL,
  `S6` varchar(10) DEFAULT NULL,
  `S7` varchar(10) DEFAULT NULL,
  `S8` varchar(10) DEFAULT NULL,
  `S9` varchar(10) DEFAULT NULL,
  `S10` varchar(10) DEFAULT NULL,
  `S11` varchar(10) DEFAULT NULL,
  `S12` varchar(10) DEFAULT NULL,
  `S13` varchar(10) DEFAULT NULL,
  `S14` varchar(10) DEFAULT NULL,
  `S15` varchar(10) DEFAULT NULL,
  `S16` varchar(10) DEFAULT NULL,
  `S17` varchar(10) DEFAULT NULL,
  `S18` varchar(10) DEFAULT NULL,
  `S19` varchar(10) DEFAULT NULL,
  `S20` varchar(10) DEFAULT NULL,
  `S21` varchar(10) DEFAULT NULL,
  `S22` varchar(10) DEFAULT NULL,
  `S23` varchar(10) DEFAULT NULL,
  `S24` varchar(10) DEFAULT NULL,
  `S25` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.


-- Дамп структуры для таблица test.dgd
CREATE TABLE IF NOT EXISTS `dgd` (
  `Date` date DEFAULT NULL,
  `Fredericksburg` char(50) DEFAULT NULL,
  `College` char(50) DEFAULT NULL,
  `Planetary` char(50) DEFAULT NULL,
  `Boulder` char(50) DEFAULT NULL,
  UNIQUE KEY `Date` (`Date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.


-- Дамп структуры для таблица test.eq
CREATE TABLE IF NOT EXISTS `eq` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `DateTime` datetime NOT NULL,
  `Lat` float NOT NULL,
  `Lon` float NOT NULL,
  `Magnitude` int(11) NOT NULL,
  `Depth` int(11) NOT NULL,
  `Region` tinytext NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `DateTime` (`DateTime`),
  KEY `ID` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.


-- Дамп структуры для таблица test.ftplogfiles
CREATE TABLE IF NOT EXISTS `ftplogfiles` (
  `ID` int(11) DEFAULT NULL,
  `Name` char(50) DEFAULT NULL,
  `Status` char(50) DEFAULT NULL,
  `Date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.


-- Дамп структуры для таблица test.geomagnetic2
CREATE TABLE IF NOT EXISTS `geomagnetic2` (
  `date` date DEFAULT NULL,
  `a_fredericksburg` char(5) DEFAULT NULL,
  `fredericksburg` char(50) DEFAULT NULL,
  `a_college` char(5) DEFAULT NULL,
  `college` char(50) DEFAULT NULL,
  `a_planetary` char(5) DEFAULT NULL,
  `planetary` char(50) DEFAULT NULL,
  UNIQUE KEY `date` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.


-- Дамп структуры для таблица test.ifpet
CREATE TABLE IF NOT EXISTS `ifpet` (
  `Date` date DEFAULT NULL,
  `Time` time DEFAULT NULL,
  `S0` varchar(10) DEFAULT NULL,
  `S1` varchar(10) DEFAULT NULL,
  `S2` varchar(10) DEFAULT NULL,
  `S3` varchar(10) DEFAULT NULL,
  `S4` varchar(10) DEFAULT NULL,
  `S5` varchar(10) DEFAULT NULL,
  `S6` varchar(10) DEFAULT NULL,
  `S7` varchar(10) DEFAULT NULL,
  `S8` varchar(10) DEFAULT NULL,
  `S9` varchar(10) DEFAULT NULL,
  `S10` varchar(10) DEFAULT NULL,
  `S11` varchar(10) DEFAULT NULL,
  `S12` varchar(10) DEFAULT NULL,
  `S13` varchar(10) DEFAULT NULL,
  `S14` varchar(10) DEFAULT NULL,
  `S15` varchar(10) DEFAULT NULL,
  `S16` varchar(10) DEFAULT NULL,
  `S17` varchar(10) DEFAULT NULL,
  `S18` varchar(10) DEFAULT NULL,
  `S19` varchar(10) DEFAULT NULL,
  `S20` varchar(10) DEFAULT NULL,
  `S21` varchar(10) DEFAULT NULL,
  `S22` varchar(10) DEFAULT NULL,
  `S23` varchar(10) DEFAULT NULL,
  `S24` varchar(10) DEFAULT NULL,
  `S25` varchar(10) DEFAULT NULL,
  `S26` varchar(10) DEFAULT NULL,
  `S27` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.


-- Дамп структуры для таблица test.imgs
CREATE TABLE IF NOT EXISTS `imgs` (
  `src` varchar(250) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `status` char(10) DEFAULT NULL,
  UNIQUE KEY `src` (`src`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.


-- Дамп структуры для таблица test.kakioka_plots
CREATE TABLE IF NOT EXISTS `kakioka_plots` (
  `name` char(60) DEFAULT NULL,
  `type` char(40) DEFAULT NULL,
  `status` char(50) DEFAULT NULL,
  UNIQUE KEY `name` (`name`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.


-- Дамп структуры для таблица test.nadisa_plots
CREATE TABLE IF NOT EXISTS `nadisa_plots` (
  `name` char(50) DEFAULT NULL,
  `date_start` date DEFAULT NULL,
  `date_end` date DEFAULT NULL,
  `status` char(50) DEFAULT NULL,
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.


-- Дамп структуры для таблица test.obsmpplots
CREATE TABLE IF NOT EXISTS `obsmpplots` (
  `DateStart` date DEFAULT NULL,
  `DateEnd` date DEFAULT NULL,
  `Name` char(50) DEFAULT NULL,
  `Type` char(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.


-- Дамп структуры для таблица test.s1_elisovo
CREATE TABLE IF NOT EXISTS `s1_elisovo` (
  `Date` date DEFAULT NULL,
  `Time` time DEFAULT NULL,
  `S0` varchar(10) DEFAULT NULL,
  `S1` varchar(10) DEFAULT NULL,
  `S2` varchar(10) DEFAULT NULL,
  `S3` varchar(10) DEFAULT NULL,
  `S4` varchar(10) DEFAULT NULL,
  `S5` varchar(10) DEFAULT NULL,
  `S6` varchar(10) DEFAULT NULL,
  `S7` varchar(10) DEFAULT NULL,
  `S8` varchar(10) DEFAULT NULL,
  `S9` varchar(10) DEFAULT NULL,
  `S10` varchar(10) DEFAULT NULL,
  `S11` varchar(10) DEFAULT NULL,
  `S12` varchar(10) DEFAULT NULL,
  `S13` varchar(10) DEFAULT NULL,
  `S14` varchar(10) DEFAULT NULL,
  `S15` varchar(10) DEFAULT NULL,
  `S16` varchar(10) DEFAULT NULL,
  `S17` varchar(10) DEFAULT NULL,
  `S18` varchar(10) DEFAULT NULL,
  `S19` varchar(10) DEFAULT NULL,
  `S20` varchar(10) DEFAULT NULL,
  `S21` varchar(10) DEFAULT NULL,
  `S22` varchar(10) DEFAULT NULL,
  `S23` varchar(10) DEFAULT NULL,
  `S24` varchar(10) DEFAULT NULL,
  `S25` varchar(10) DEFAULT NULL,
  `S26` varchar(10) DEFAULT NULL,
  `S27` varchar(10) DEFAULT NULL,
  `S28` varchar(10) DEFAULT NULL,
  `S29` varchar(10) DEFAULT NULL,
  `S30` varchar(10) DEFAULT NULL,
  `S31` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.


-- Дамп структуры для таблица test.s3_okean
CREATE TABLE IF NOT EXISTS `s3_okean` (
  `Date` date DEFAULT NULL,
  `Time` time DEFAULT NULL,
  `S0` varchar(10) DEFAULT NULL,
  `S1` varchar(10) DEFAULT NULL,
  `S2` varchar(10) DEFAULT NULL,
  `S3` varchar(10) DEFAULT NULL,
  `S4` varchar(10) DEFAULT NULL,
  `S5` varchar(10) DEFAULT NULL,
  `S6` varchar(10) DEFAULT NULL,
  `S7` varchar(10) DEFAULT NULL,
  `S8` varchar(10) DEFAULT NULL,
  `S9` varchar(10) DEFAULT NULL,
  `S10` varchar(10) DEFAULT NULL,
  `S11` varchar(10) DEFAULT NULL,
  `S12` varchar(10) DEFAULT NULL,
  `S13` varchar(10) DEFAULT NULL,
  `S14` varchar(10) DEFAULT NULL,
  `S15` varchar(10) DEFAULT NULL,
  `S16` varchar(10) DEFAULT NULL,
  `S17` varchar(10) DEFAULT NULL,
  `S18` varchar(10) DEFAULT NULL,
  `S19` varchar(10) DEFAULT NULL,
  `S20` varchar(10) DEFAULT NULL,
  `S21` varchar(10) DEFAULT NULL,
  `S22` varchar(10) DEFAULT NULL,
  `S23` varchar(10) DEFAULT NULL,
  `S24` varchar(10) DEFAULT NULL,
  `S25` varchar(10) DEFAULT NULL,
  `S26` varchar(10) DEFAULT NULL,
  `S27` varchar(10) DEFAULT NULL,
  `S28` varchar(10) DEFAULT NULL,
  `S29` varchar(10) DEFAULT NULL,
  `S30` varchar(10) DEFAULT NULL,
  `S31` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.


-- Дамп структуры для таблица test.s4_esso
CREATE TABLE IF NOT EXISTS `s4_esso` (
  `Date` date DEFAULT NULL,
  `Time` time DEFAULT NULL,
  `S0` varchar(10) DEFAULT NULL,
  `S1` varchar(10) DEFAULT NULL,
  `S2` varchar(10) DEFAULT NULL,
  `S3` varchar(10) DEFAULT NULL,
  `S4` varchar(10) DEFAULT NULL,
  `S5` varchar(10) DEFAULT NULL,
  `S6` varchar(10) DEFAULT NULL,
  `S7` varchar(10) DEFAULT NULL,
  `S8` varchar(10) DEFAULT NULL,
  `S9` varchar(10) DEFAULT NULL,
  `S10` varchar(10) DEFAULT NULL,
  `S11` varchar(10) DEFAULT NULL,
  `S12` varchar(10) DEFAULT NULL,
  `S13` varchar(10) DEFAULT NULL,
  `S14` varchar(10) DEFAULT NULL,
  `S15` varchar(10) DEFAULT NULL,
  `S16` varchar(10) DEFAULT NULL,
  `S17` varchar(10) DEFAULT NULL,
  `S18` varchar(10) DEFAULT NULL,
  `S19` varchar(10) DEFAULT NULL,
  `S20` varchar(10) DEFAULT NULL,
  `S21` varchar(10) DEFAULT NULL,
  `S22` varchar(10) DEFAULT NULL,
  `S23` varchar(10) DEFAULT NULL,
  `S24` varchar(10) DEFAULT NULL,
  `S25` varchar(10) DEFAULT NULL,
  `S26` varchar(10) DEFAULT NULL,
  `S27` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.


-- Дамп структуры для таблица test.s5_altai
CREATE TABLE IF NOT EXISTS `s5_altai` (
  `Date` date DEFAULT NULL,
  `Time` time DEFAULT NULL,
  `S0` varchar(10) DEFAULT NULL,
  `S1` varchar(10) DEFAULT NULL,
  `S2` varchar(10) DEFAULT NULL,
  `S3` varchar(10) DEFAULT NULL,
  `S4` varchar(10) DEFAULT NULL,
  `S5` varchar(10) DEFAULT NULL,
  `S6` varchar(10) DEFAULT NULL,
  `S7` varchar(10) DEFAULT NULL,
  `S8` varchar(10) DEFAULT NULL,
  `S9` varchar(10) DEFAULT NULL,
  `S10` varchar(10) DEFAULT NULL,
  `S11` varchar(10) DEFAULT NULL,
  `S12` varchar(10) DEFAULT NULL,
  `S13` varchar(10) DEFAULT NULL,
  `S14` varchar(10) DEFAULT NULL,
  `S15` varchar(10) DEFAULT NULL,
  `S16` varchar(10) DEFAULT NULL,
  `S17` varchar(10) DEFAULT NULL,
  `S18` varchar(10) DEFAULT NULL,
  `S19` varchar(10) DEFAULT NULL,
  `S20` varchar(10) DEFAULT NULL,
  `S21` varchar(10) DEFAULT NULL,
  `S22` varchar(10) DEFAULT NULL,
  `S23` varchar(10) DEFAULT NULL,
  `S24` varchar(10) DEFAULT NULL,
  `S25` varchar(10) DEFAULT NULL,
  `S26` varchar(10) DEFAULT NULL,
  `S27` varchar(10) DEFAULT NULL,
  `S28` varchar(10) DEFAULT NULL,
  `S29` varchar(10) DEFAULT NULL,
  `S30` varchar(10) DEFAULT NULL,
  `S31` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.


-- Дамп структуры для таблица test.s6_chieti
CREATE TABLE IF NOT EXISTS `s6_chieti` (
  `Date` date DEFAULT NULL,
  `Time` time DEFAULT NULL,
  `S0` varchar(10) DEFAULT NULL,
  `S1` varchar(10) DEFAULT NULL,
  `S2` varchar(10) DEFAULT NULL,
  `S3` varchar(10) DEFAULT NULL,
  `S4` varchar(10) DEFAULT NULL,
  `S5` varchar(10) DEFAULT NULL,
  `S6` varchar(10) DEFAULT NULL,
  `S7` varchar(10) DEFAULT NULL,
  `S8` varchar(10) DEFAULT NULL,
  `S9` varchar(10) DEFAULT NULL,
  `S10` varchar(10) DEFAULT NULL,
  `S11` varchar(10) DEFAULT NULL,
  `S12` varchar(10) DEFAULT NULL,
  `S13` varchar(10) DEFAULT NULL,
  `S14` varchar(10) DEFAULT NULL,
  `S15` varchar(10) DEFAULT NULL,
  `S16` varchar(10) DEFAULT NULL,
  `S17` varchar(10) DEFAULT NULL,
  `S18` varchar(10) DEFAULT NULL,
  `S19` varchar(10) DEFAULT NULL,
  `S20` varchar(10) DEFAULT NULL,
  `S21` varchar(10) DEFAULT NULL,
  `S22` varchar(10) DEFAULT NULL,
  `S23` varchar(10) DEFAULT NULL,
  `S24` varchar(10) DEFAULT NULL,
  `S25` varchar(10) DEFAULT NULL,
  `S26` varchar(10) DEFAULT NULL,
  `S27` varchar(10) DEFAULT NULL,
  `S28` varchar(10) DEFAULT NULL,
  `S29` varchar(10) DEFAULT NULL,
  `S30` varchar(10) DEFAULT NULL,
  `S31` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.


-- Дамп структуры для таблица test.s7_okean
CREATE TABLE IF NOT EXISTS `s7_okean` (
  `Date` date DEFAULT NULL,
  `Time` time DEFAULT NULL,
  `S0` varchar(10) DEFAULT NULL,
  `S1` varchar(10) DEFAULT NULL,
  `S2` varchar(10) DEFAULT NULL,
  `S3` varchar(10) DEFAULT NULL,
  `S4` varchar(10) DEFAULT NULL,
  `S5` varchar(10) DEFAULT NULL,
  `S6` varchar(10) DEFAULT NULL,
  `S7` varchar(10) DEFAULT NULL,
  `S8` varchar(10) DEFAULT NULL,
  `S9` varchar(10) DEFAULT NULL,
  `S10` varchar(10) DEFAULT NULL,
  `S11` varchar(10) DEFAULT NULL,
  `S12` varchar(10) DEFAULT NULL,
  `S13` varchar(10) DEFAULT NULL,
  `S14` varchar(10) DEFAULT NULL,
  `S15` varchar(10) DEFAULT NULL,
  `S16` varchar(10) DEFAULT NULL,
  `S17` varchar(10) DEFAULT NULL,
  `S18` varchar(10) DEFAULT NULL,
  `S19` varchar(10) DEFAULT NULL,
  `S20` varchar(10) DEFAULT NULL,
  `S21` varchar(10) DEFAULT NULL,
  `S22` varchar(10) DEFAULT NULL,
  `S23` varchar(10) DEFAULT NULL,
  `S24` varchar(10) DEFAULT NULL,
  `S25` varchar(10) DEFAULT NULL,
  `S26` varchar(10) DEFAULT NULL,
  `S27` varchar(10) DEFAULT NULL,
  `S28` varchar(10) DEFAULT NULL,
  `S29` varchar(10) DEFAULT NULL,
  `S30` varchar(10) DEFAULT NULL,
  `S31` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.


-- Дамп структуры для таблица test.shgm3
CREATE TABLE IF NOT EXISTS `shgm3` (
  `Date` date DEFAULT NULL,
  `Time` time DEFAULT NULL,
  `S1` char(20) DEFAULT NULL,
  `S2` char(20) DEFAULT NULL,
  `S3` char(20) DEFAULT NULL,
  `S4` char(20) DEFAULT NULL,
  UNIQUE KEY `Date` (`Date`,`Time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.


-- Дамп структуры для таблица test.shgm3_stat
CREATE TABLE IF NOT EXISTS `shgm3_stat` (
  `name` char(50) DEFAULT NULL,
  `status` char(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.


-- Дамп структуры для таблица test.solarindex_
CREATE TABLE IF NOT EXISTS `solarindex_` (
  `date` date DEFAULT NULL,
  `ghz` char(10) DEFAULT NULL,
  `magnetic_2K` char(10) DEFAULT NULL,
  `magnetic_1K` char(10) DEFAULT NULL,
  `noaa` char(10) DEFAULT NULL,
  `star` char(10) DEFAULT NULL,
  `potsdam` char(10) DEFAULT NULL,
  `daily` char(10) DEFAULT NULL,
  `planetary` char(10) DEFAULT NULL,
  `boulder` char(10) DEFAULT NULL,
  `solarwind` char(10) DEFAULT NULL,
  `number_c` char(10) DEFAULT NULL,
  `number_m` char(10) DEFAULT NULL,
  `number_x` char(10) DEFAULT NULL,
  UNIQUE KEY `date` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.


-- Дамп структуры для таблица test.stat
CREATE TABLE IF NOT EXISTS `stat` (
  `Kakioka_Plots_Last_time` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Экспортируемые данные не выделены.
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
