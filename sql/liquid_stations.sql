CREATE TABLE IF NOT EXISTS `bl_water_stations` (
  `id` varchar(128) NOT NULL,
  `owner` varchar(80) NOT NULL,
  `tank_type` varchar(60) NOT NULL,
  `x` double NOT NULL,
  `y` double NOT NULL,
  `z` double NOT NULL,
  `heading` float NOT NULL,
  `health` float NOT NULL DEFAULT 100,
  `liquid_type` varchar(40) NOT NULL DEFAULT 'water',
  `amount` float NOT NULL DEFAULT 0,
  `is_fixed` tinyint(1) NOT NULL DEFAULT 0,
  `updated_at` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
