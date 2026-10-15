-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Oct 15, 2026 at 09:44 AM
-- Server version: 8.4.3
-- PHP Version: 8.3.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `firma_pdks`
--

-- --------------------------------------------------------

--
-- Table structure for table `pdks_loglari`
--

CREATE TABLE `pdks_loglari` (
  `id` int NOT NULL,
  `personel_id` int NOT NULL,
  `islem_turu` enum('GIRIS','CIKIS') COLLATE utf8mb4_unicode_ci NOT NULL,
  `tarih_saat` datetime DEFAULT CURRENT_TIMESTAMP,
  `kamera_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'KAMERA_GIRIS veya KAMERA_CIKIS'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `pdks_loglari`
--

INSERT INTO `pdks_loglari` (`id`, `personel_id`, `islem_turu`, `tarih_saat`, `kamera_id`) VALUES
(1, 1, 'GIRIS', '2026-10-13 11:26:00', 'KAMERA_GIRIS'),
(2, 1, 'GIRIS', '2026-10-14 11:02:59', 'KAMERA_GIRIS'),
(3, 1, 'GIRIS', '2026-10-14 11:14:26', 'KAMERA_GIRIS'),
(4, 1, 'CIKIS', '2026-10-14 16:04:45', 'KAMERA_CIKIS');

-- --------------------------------------------------------

--
-- Table structure for table `personeller`
--

CREATE TABLE `personeller` (
  `id` int NOT NULL,
  `ad_soyad` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sicil` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `vardiya` enum('Gündüz Personeli (08:30 - 17:30)','Gündüz Vardiyası (08:30 - 19:00)','Gece Vardiyası (19:00 - 08:30)','Özel / Esnek Vardiya') COLLATE utf8mb4_unicode_ci DEFAULT 'Gündüz Personeli (08:30 - 17:30)',
  `yuz_vektoru` text COLLATE utf8mb4_unicode_ci COMMENT 'AI Yüz kodlaması verisi (JSON string formatında vector embedding)',
  `kayit_tarihi` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personeller`
--

INSERT INTO `personeller` (`id`, `ad_soyad`, `sicil`, `vardiya`, `yuz_vektoru`, `kayit_tarihi`) VALUES
(1, 'Tamer ERKAN', '', 'Gündüz Personeli (08:30 - 17:30)', NULL, '2026-10-13 11:14:26');

-- --------------------------------------------------------

--
-- Table structure for table `per_user`
--

CREATE TABLE `per_user` (
  `id` int NOT NULL,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'IK',
  `aktif_mi` tinyint(1) DEFAULT '1',
  `son_giris` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `per_user`
--

INSERT INTO `per_user` (`id`, `username`, `email`, `password_hash`, `role`, `aktif_mi`, `son_giris`) VALUES
(1, 'admin', 'admin@firma.com', '$2b$12$7kP.WshV.j9P0j339zN7E.lZ.BvVlZgU6P8Wd9n1mJ6B4eZ8v8V22', 'ADMIN', 1, '2026-10-15 11:48:06');

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_optimum_pdks_raporu`
-- (See below for the actual view)
--
CREATE TABLE `v_optimum_pdks_raporu` (
`Calistigi_Vardiya` enum('Gündüz Personeli (08:30 - 17:30)','Gündüz Vardiyası (08:30 - 19:00)','Gece Vardiyası (19:00 - 08:30)','Özel / Esnek Vardiya')
,`En_Uygun_Cikis` time
,`En_Uygun_Giris` time
,`Gecikme_Suresi` varchar(17)
,`Personel_Adi_Soyadi` varchar(100)
,`Tarih` date
);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `pdks_loglari`
--
ALTER TABLE `pdks_loglari`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_personel_tarih` (`personel_id`,`tarih_saat`);

--
-- Indexes for table `personeller`
--
ALTER TABLE `personeller`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_ad_soyad` (`ad_soyad`);

--
-- Indexes for table `per_user`
--
ALTER TABLE `per_user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `pdks_loglari`
--
ALTER TABLE `pdks_loglari`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `personeller`
--
ALTER TABLE `personeller`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `per_user`
--
ALTER TABLE `per_user`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

-- --------------------------------------------------------

--
-- Structure for view `v_optimum_pdks_raporu`
--
DROP TABLE IF EXISTS `v_optimum_pdks_raporu`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_optimum_pdks_raporu`  AS WITH   `girisloglari` as (select `pdks_loglari`.`personel_id` AS `personel_id`,cast(`pdks_loglari`.`tarih_saat` as date) AS `log_tarihi`,`pdks_loglari`.`tarih_saat` AS `en_uygun_giris_zamani`,row_number() OVER (PARTITION BY `pdks_loglari`.`personel_id`,cast(`pdks_loglari`.`tarih_saat` as date) ORDER BY abs(timestampdiff(MINUTE,`pdks_loglari`.`tarih_saat`,concat(cast(`pdks_loglari`.`tarih_saat` as date),' 08:30:00'))) )  AS `sira` from `pdks_loglari` where (`pdks_loglari`.`islem_turu` = 'GIRIS')), `cikisloglari` as (select `pdks_loglari`.`personel_id` AS `personel_id`,cast(`pdks_loglari`.`tarih_saat` as date) AS `log_tarihi`,`pdks_loglari`.`tarih_saat` AS `en_uygun_cikis_zamani`,row_number() OVER (PARTITION BY `pdks_loglari`.`personel_id`,cast(`pdks_loglari`.`tarih_saat` as date) ORDER BY abs(timestampdiff(MINUTE,`pdks_loglari`.`tarih_saat`,concat(cast(`pdks_loglari`.`tarih_saat` as date),' 17:30:00'))) )  AS `sira` from `pdks_loglari` where (`pdks_loglari`.`islem_turu` = 'CIKIS')) select `g`.`log_tarihi` AS `Tarih`,`p`.`ad_soyad` AS `Personel_Adi_Soyadi`,`p`.`vardiya` AS `Calistigi_Vardiya`,cast(`g`.`en_uygun_giris_zamani` as time) AS `En_Uygun_Giris`,cast(`c`.`en_uygun_cikis_zamani` as time) AS `En_Uygun_Cikis`,(case when (cast(`g`.`en_uygun_giris_zamani` as time) > '08:30:00') then timediff(cast(`g`.`en_uygun_giris_zamani` as time),'08:30:00') else '00:00:00' end) AS `Gecikme_Suresi` from ((`girisloglari` `g` join `personeller` `p` on((`g`.`personel_id` = `p`.`id`))) left join `cikisloglari` `c` on(((`g`.`personel_id` = `c`.`personel_id`) and (`g`.`log_tarihi` = `c`.`log_tarihi`)))) where ((`g`.`sira` = 1) and ((`c`.`sira` is null) or (`c`.`sira` = 1)))  ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `pdks_loglari`
--
ALTER TABLE `pdks_loglari`
  ADD CONSTRAINT `fk_log_personel` FOREIGN KEY (`personel_id`) REFERENCES `personeller` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
