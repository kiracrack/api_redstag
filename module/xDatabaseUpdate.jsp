<%!public void ExecuteDatabaseUpgrade() {
    try {
        String updateVersion = "";
        /*
        if(CountRecord("tblupdatelogs") == 0){
            ExecuteQuery("insert into tblupdatelogs set databaseversion='2022-03-07',dateupdate=current_timestamp,appliedquery='beginning update'");
        }

        updateVersion = "2022-03-22";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblgeneralsettings` ADD COLUMN `firebasemode` VARCHAR(10) NOT NULL DEFAULT 'live' AFTER `maxbet`;");
        }

        updateVersion = "2022-04-13";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` ADD COLUMN `series_fight_bet` INTEGER(10) UNSIGNED NOT NULL DEFAULT 0 AFTER `series_credit_transfer`;");
        }

        updateVersion = "2022-04-15";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblsubscriber` ADD COLUMN `isvideoallowed` BOOLEAN NOT NULL DEFAULT 0 AFTER `maxbet`;");
            ExecuteUpdateDB(updateVersion, "update `tblsubscriber` set isvideoallowed=1 where creditbal >= (select minbet from tblgeneralsettings);");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblgeneralsettings` ADD COLUMN `windrawunit` INTEGER UNSIGNED NOT NULL DEFAULT 0 AFTER `commission`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblgeneralsettings` CHANGE COLUMN `commission` `ge_com_rate` DOUBLE NOT NULL DEFAULT 0, ADD COLUMN `op_com_rate` DOUBLE NOT NULL DEFAULT 0 AFTER `ge_com_rate`, ADD COLUMN `be_com_rate` DOUBLE NOT NULL DEFAULT 0 AFTER `op_com_rate`;");
            ExecuteUpdateDB(updateVersion, "update `tblgeneralsettings` set op_com_rate='0.04', be_com_rate='0.01';");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblgeneralsettings` ADD COLUMN `series_result` INTEGER UNSIGNED NOT NULL DEFAULT 0 AFTER `series_event`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblevent` ADD COLUMN `fight_result` VARCHAR(1) NOT NULL DEFAULT '' AFTER `fightnumber`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblgeneralsettings` ADD COLUMN `video_min_credit` DOUBLE NOT NULL DEFAULT 5 AFTER `maxbet`;");
        }

        updateVersion = "2022-07-26";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblgeneralsettings` ADD COLUMN `timer_lastcall` INTEGER UNSIGNED NOT NULL DEFAULT 40 AFTER `series_result`, ADD COLUMN `timer_closed` INTEGER UNSIGNED NOT NULL DEFAULT 35 AFTER `timer_lastcall`;");
        }

        updateVersion = "2022-07-27";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblcontroller` ADD COLUMN `lastlogin` DATETIME NOT NULL AFTER `approved`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblversioncontrol` ADD COLUMN `controllerupdateurl` VARCHAR(200) NOT NULL DEFAULT '' AFTER `appversion`, ADD COLUMN `controllerversion` DOUBLE NOT NULL DEFAULT 0 AFTER `controllerupdateurl`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblgeneralsettings` ADD COLUMN `hostdirectory` VARCHAR(45) NOT NULL DEFAULT '' AFTER `firebasedb`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblgeneralsettings` ADD COLUMN `hostprotocol` VARCHAR(10) NOT NULL DEFAULT 'https://' AFTER `hostdirectory`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblsubscriber` DROP COLUMN `minbet`, DROP COLUMN `maxbet`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` ADD COLUMN `minbet` DOUBLE NOT NULL DEFAULT 5 AFTER `mobile`, ADD COLUMN `maxbet` DOUBLE NOT NULL DEFAULT 1000 AFTER `minbet`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblevent` ADD COLUMN `event_reminders_message` VARCHAR(200) NOT NULL DEFAULT '' AFTER `event_standby_message`, ADD COLUMN `event_reminders_warning` VARCHAR(200) NOT NULL DEFAULT '' AFTER `event_reminders_message`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblevent` DROP COLUMN `total_fight`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` ADD COLUMN `series_deposit` INTEGER UNSIGNED NOT NULL DEFAULT 0 AFTER `series_credit_transfer`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblsubscriber` ADD COLUMN `deposit_instruction` VARCHAR(500) NOT NULL DEFAULT '' AFTER `referralcode`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` ADD COLUMN `enablebetwatcher` BOOLEAN NOT NULL DEFAULT 0 AFTER `enable_agent_commission`;");
        }

        updateVersion = "2022-07-28";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "update `tblcreditledger` set description=replace(description,'post bet - M', 'choose bet meron') where description like '%post bet - M%';");
            ExecuteUpdateDB(updateVersion, "update `tblcreditledger` set description=replace(description,'post bet - D', 'choose bet draw') where description like '%post bet - D%';");
            ExecuteUpdateDB(updateVersion, "update `tblcreditledger` set description=replace(description,'post bet - D', 'choose bet wala') where description like '%post bet - W%';");
        }

        updateVersion = "2022-07-29";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` ADD COLUMN `betwacherid` VARCHAR(45) NOT NULL DEFAULT '' AFTER `enablebetwatcher`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblsubscriber` DROP COLUMN `betwatcher`;");
        }

        updateVersion = "2022-07-30";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` ADD COLUMN `mintransfer` DOUBLE NOT NULL DEFAULT 0 AFTER `maxbet`, ADD COLUMN `maxtransfer` DOUBLE NOT NULL DEFAULT 0 AFTER `mintransfer`, ADD COLUMN `mindeposit` DOUBLE NOT NULL DEFAULT 0 AFTER `maxtransfer`, ADD COLUMN `maxdeposit` DOUBLE NOT NULL DEFAULT 0 AFTER `mindeposit`, ADD COLUMN `minwithdraw` DOUBLE NOT NULL DEFAULT 0 AFTER `maxdeposit`, ADD COLUMN `maxwithdraw` DOUBLE NOT NULL DEFAULT 0 AFTER `minwithdraw`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` ADD COLUMN `video_min_credit` DOUBLE NOT NULL DEFAULT 5 AFTER `maxwithdraw`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator`ADD COLUMN `op_com_rate` DOUBLE NOT NULL DEFAULT 3 AFTER `mobile`, ADD COLUMN `be_com_rate` DOUBLE NOT NULL DEFAULT 2 AFTER `op_com_rate`, ADD COLUMN `draw_rate` DOUBLE NOT NULL DEFAULT 8 AFTER `be_com_rate`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblgeneralsettings` ADD COLUMN `fight_commission` DOUBLE NOT NULL DEFAULT 5 AFTER `mobile`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblsubscriber` DROP COLUMN `isvideoallowed`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblfightbets` ADD COLUMN `banker` BOOLEAN NOT NULL DEFAULT 0 AFTER `accountid`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblfightbets2` ADD COLUMN `banker` BOOLEAN NOT NULL DEFAULT 0 AFTER `accountid`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblremittance` ADD COLUMN `isbank` BOOLEAN NOT NULL DEFAULT 0 AFTER `remittancename`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblremittance` ADD COLUMN `logourl` VARCHAR(500) NOT NULL DEFAULT '' AFTER `isbank`;");
            ExecuteUpdateDB(updateVersion, "CREATE TABLE tblbankaccounts` (  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,  `accountid` varchar(15) NOT NULL DEFAULT '',  `accountnumber` varchar(45) NOT NULL DEFAULT '',  `accountname` varchar(100) NOT NULL DEFAULT '',  `remittanceid` varchar(45) NOT NULL DEFAULT '',  `preferred` tinyint(1) NOT NULL DEFAULT '0',  `dateadded` datetime NOT NULL,  `deleted` tinyint(1) NOT NULL DEFAULT '0',  `datedeleted` datetime DEFAULT NULL,  PRIMARY KEY (`id`)) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` ADD COLUMN `series_withdrawal` INTEGER UNSIGNED NOT NULL DEFAULT 0 AFTER `series_deposit`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbldeposits` CHANGE COLUMN `attachment` `attachment` VARCHAR(1000) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL after amount;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbldeposits` ADD COLUMN `cancelledreason` VARCHAR(100) NOT NULL DEFAULT '' AFTER `datecancelled`;");
            ExecuteUpdateDB(updateVersion, "CREATE TABLE `tblwithdrawal` (  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,  `refno` varchar(15) NOT NULL DEFAULT '',  `accountid` varchar(15) NOT NULL DEFAULT '',  `agentid` varchar(15) NOT NULL DEFAULT '',  `operatorid` varchar(15) NOT NULL DEFAULT '',  `isbank` tinyint(1) NOT NULL DEFAULT '0',  `remittanceid` varchar(10) NOT NULL DEFAULT '',  `accountno` varchar(45) NOT NULL DEFAULT '',  `accountname` varchar(45) NOT NULL DEFAULT '',  `amount` double NOT NULL DEFAULT '0',  `note` varchar(200) NOT NULL DEFAULT '',  `attachment` varchar(1000) NOT NULL DEFAULT '',  `datetrn` datetime NOT NULL,  `confirmed` tinyint(1) NOT NULL DEFAULT '0',  `dateconfirm` datetime DEFAULT NULL,  `cancelled` tinyint(1) NOT NULL DEFAULT '0',  `datecancelled` datetime DEFAULT NULL,  `cancelledreason` varchar(100) NOT NULL DEFAULT '',  PRIMARY KEY (`id`)) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;");
            ExecuteUpdateDB(updateVersion, "CREATE TABLE `tblvideosource` (  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,  `source_name` varchar(45) NOT NULL DEFAULT '',  `source_url` varchar(1000) NOT NULL DEFAULT '',  `isyoutube` tinyint(1) NOT NULL DEFAULT '0',  PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=latin1;");
        }

        updateVersion = "2022-07-31";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblsubscriber` ADD COLUMN `iscashaccount` BOOLEAN NOT NULL DEFAULT 0 AFTER `accounttype`;");
        }

        updateVersion = "2022-08-01";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblcreditrequest` ADD COLUMN `confirmed` BOOLEAN NOT NULL DEFAULT 0 AFTER `daterequest`, ADD COLUMN `dateconfirmed` DATETIME AFTER `confirmed`, ADD COLUMN `cancelled` BOOLEAN NOT NULL DEFAULT 0 AFTER `dateconfirmed`, ADD COLUMN `datecancelled` DATETIME AFTER `cancelled`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblcreditrequest` ADD COLUMN `refno` VARCHAR(15) NOT NULL DEFAULT '' AFTER `id`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` ADD COLUMN `series_load_request` INT(10) UNSIGNED NOT NULL DEFAULT 0 AFTER `series_subscriber`;");
            ExecuteUpdateDB(updateVersion, "DELETE FROM `tblcreditrequest` where refno='';");
        }

        updateVersion = "2022-08-02";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "DROP TABLE IF EXISTS `tblregistration`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` ADD COLUMN `series_registration` INT(10) UNSIGNED NOT NULL DEFAULT 0 AFTER `betwacherid`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` ADD COLUMN `ownersaccountid` VARCHAR(45) NOT NULL DEFAULT '' AFTER `betwacherid`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblgeneralsettings` ADD COLUMN `defaultoperator` VARCHAR(45) NOT NULL DEFAULT '' AFTER `mobile`;");
            ExecuteUpdateDB(updateVersion, "update `tblgeneralsettings` set defaultoperator='101';");
            ExecuteUpdateDB(updateVersion, "CREATE TABLE `tblregistration` (  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,  `regno` varchar(15) NOT NULL DEFAULT '',  `fullname` varchar(100) NOT NULL DEFAULT '',  `mobilenumber` varchar(12) NOT NULL DEFAULT '',  `username` varchar(15) NOT NULL DEFAULT '',  `password` varchar(50) NOT NULL DEFAULT '',  `referralcode` varchar(12) NOT NULL DEFAULT '',  `operatorid` varchar(5) NOT NULL DEFAULT '',  `masteragentid` varchar(10) NOT NULL DEFAULT '',  `agentid` varchar(10) NOT NULL DEFAULT '',  `photourl` varchar(1000) NOT NULL DEFAULT '',  `photobase64_large` text,  `photobase64_thumb` text,  `deviceid` varchar(45) NOT NULL DEFAULT '',  `devicename` varchar(45) NOT NULL DEFAULT '',  `dateregister` datetime NOT NULL,  `approved` tinyint(1) NOT NULL DEFAULT '0',  `dateapproved` datetime DEFAULT NULL,  `deleted` tinyint(1) NOT NULL DEFAULT '0',  `datedeleted` datetime DEFAULT NULL,  PRIMARY KEY (`id`)) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;");
        }

        updateVersion = "2022-08-03";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblsubscriber` DROP COLUMN `photobase64_large`, DROP COLUMN `photobase64_thumb`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblregistration` DROP COLUMN `photobase64_large`, DROP COLUMN `photobase64_thumb`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblregistration` ADD COLUMN `location` VARCHAR(200) NOT NULL DEFAULT '' AFTER `devicename`, ADD COLUMN `latitude` VARCHAR(45) NOT NULL DEFAULT '' AFTER `location`, ADD COLUMN `longitude` VARCHAR(45) NOT NULL DEFAULT '' AFTER `latitude`;");
        }

        updateVersion = "2022-08-04";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblsubscriber` ADD COLUMN `codename` VARCHAR(15) NOT NULL DEFAULT '' AFTER `displayname`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblcredittransfer` ADD COLUMN `reference` VARCHAR(100) NOT NULL DEFAULT '' AFTER `admin`;");
            ExecuteUpdateDB(updateVersion, "CREATE TABLE `tbldummyname` (  `id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,  `dummyname` VARCHAR(45) NOT NULL DEFAULT '',  PRIMARY KEY (`id`))ENGINE = InnoDB;");
            ExecuteUpdateDB(updateVersion, "INSERT INTO `tbldummyname` (`dummyname`) VALUES ('*******4259'),('*******2365'),('*******9638'),('*******2567'),('*******3349'),('*******1802'),('*******3307'),('*******1110'),('*******6699'),('*******1257'),('*******0049'),('*******5598'),('*******6693'),('*******9989'),('*******2899'),('*******0369'),('****ward'),('****man'),('****nkie'),('****gku'),('****ment'),('****ong'),('****ony'),('****mad'),('****mond'),('****mas'),('****eph'),('****dam'),('****rul'),('****yang'),('****han'),('****oon'),('****nder');");
            ExecuteUpdateDB(updateVersion, "CREATE TABLE `tblbetwatcher` (  `id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,  `eventid` VARCHAR(5) NOT NULL DEFAULT '',  `operatorid` VARCHAR(5) NOT NULL DEFAULT '',  `fightkey` VARCHAR(45) NOT NULL DEFAULT '',  `total_meron` DOUBLE NOT NULL DEFAULT 0,  `total_wala` DOUBLE NOT NULL DEFAULT 0,  `total_difference` DOUBLE NOT NULL DEFAULT 0,  `auto_bet_choice` VARCHAR(1) NOT NULL DEFAULT '',  `auto_bet_percent` DOUBLE NOT NULL DEFAULT 0,  `auto_bet_amount` DOUBLE NOT NULL DEFAULT 0,  PRIMARY KEY (`id`))ENGINE = InnoDB;");
            ExecuteUpdateDB(updateVersion, "CREATE TABLE `tblotp` ( `id` int(10) unsigned NOT NULL AUTO_INCREMENT,  `appreference` varchar(100) NOT NULL DEFAULT '',  `mobilenumber` varchar(12) NOT NULL DEFAULT '',  `otpcode` varchar(6) NOT NULL DEFAULT '',  `message` varchar(100) NOT NULL DEFAULT '',  `daterequested` datetime NOT NULL,  `dateexpired` datetime NOT NULL,  `confirmed` tinyint(1) NOT NULL DEFAULT '0',  PRIMARY KEY (`id`)) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;");
        }

        updateVersion = "2022-08-05";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblotp` ADD COLUMN `server_response` VARCHAR(500) NOT NULL DEFAULT '' AFTER `message`;");
        }

        updateVersion = "2022-08-06";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbltemplate` CHANGE COLUMN `en` `template` VARCHAR(1000) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL, DROP COLUMN `my`, DROP COLUMN `cn`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbltemplate` MODIFY COLUMN `code` VARCHAR(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '', MODIFY COLUMN `template` VARCHAR(1000) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '', ADD COLUMN `mode` VARCHAR(45) NOT NULL DEFAULT '' AFTER `template`;");
        }

        updateVersion = "2022-08-07";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "CREATE TABLE `tblscorereport` (  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,  `query_by` varchar(45) NOT NULL DEFAULT '',  `accountid` varchar(45) NOT NULL DEFAULT '',  `agentid` varchar(45) NOT NULL DEFAULT '',  `baseagent` varchar(45) NOT NULL DEFAULT '',  `fullname` varchar(100) NOT NULL DEFAULT '',  `total` double NOT NULL DEFAULT '0',  `level` int(10) unsigned NOT NULL DEFAULT '0',  `isagent` tinyint(1) NOT NULL DEFAULT '0',  PRIMARY KEY (`id`)) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;");
        }

        updateVersion = "2022-08-08";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` ADD COLUMN `betwatchermaxamount` DOUBLE NOT NULL DEFAULT 0 AFTER `betwacherid`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblvideosource` ADD COLUMN `source_working` BOOLEAN NOT NULL DEFAULT 0 AFTER `isyoutube`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblbetwatcher` ADD COLUMN `fightnumber` VARCHAR(10) NOT NULL AFTER `fightkey`;");
            ExecuteUpdateDB(updateVersion, "update tblbetwatcher set fightnumber=SUBSTRING_INDEX(SUBSTRING_INDEX(fightkey,'-',2),'-',-1);");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblbetwatcher` ADD COLUMN `datetrn` DATETIME NOT NULL AFTER `auto_bet_amount`;");
            ExecuteUpdateDB(updateVersion, "UPDATE tblbetwatcher set datetrn=current_timestamp;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblscorereport` MODIFY COLUMN `fullname` TEXT CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL;");
        }

        updateVersion = "2022-08-09";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblcontroller` ADD COLUMN `blocked` BOOLEAN NOT NULL DEFAULT 0 AFTER `lastlogin`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblcontroller` ADD COLUMN `devicename` VARCHAR(100) NOT NULL DEFAULT '' AFTER `deviceid`;");
        }

        updateVersion = "2022-08-10";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblsubscriber` ADD COLUMN `operator_blocked` BOOLEAN NOT NULL DEFAULT 0 AFTER `lastlogindate`, ADD COLUMN `operator_blocked_message` VARCHAR(1000) NOT NULL DEFAULT '' AFTER `operator_blocked`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` ADD COLUMN `enable_dummy_player` BOOLEAN NOT NULL DEFAULT 0 AFTER `ownersaccountid`, ADD COLUMN `dummy_player_1` VARCHAR(45) NOT NULL DEFAULT '' AFTER `enable_dummy_player`, ADD COLUMN `dummy_player_2` VARCHAR(45) NOT NULL DEFAULT '' AFTER `dummy_player_1`, ADD COLUMN `dummy_amount_from` DOUBLE NOT NULL DEFAULT 0 AFTER `dummy_player_2`, ADD COLUMN `dummy_amount_to` DOUBLE NOT NULL DEFAULT 0 AFTER `dummy_amount_from`;");
        }

        updateVersion = "2022-08-11";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbldummyname` ADD COLUMN `accountno` VARCHAR(45) NOT NULL AFTER `id`;");
        }

        updateVersion = "2022-08-12";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblfightbets` ADD COLUMN `dummy` BOOLEAN NOT NULL DEFAULT 0 AFTER `banker`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblfightbets2` ADD COLUMN `dummy` BOOLEAN NOT NULL DEFAULT 0 AFTER `banker`;");
        }

        updateVersion = "2022-08-13";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` DROP COLUMN `enable_dummy_player`, DROP COLUMN `dummy_player_1`, DROP COLUMN `dummy_player_2`, DROP COLUMN `dummy_amount_from`, DROP COLUMN `dummy_amount_to`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` ADD COLUMN `dummy_enable` BOOLEAN NOT NULL DEFAULT 0 AFTER `ownersaccountid`, ADD COLUMN `dummy_account_1` VARCHAR(45) NOT NULL DEFAULT '' AFTER `dummy_enable`, ADD COLUMN `dummy_account_2` VARCHAR(45) NOT NULL DEFAULT '' AFTER `dummy_account_1`, ADD COLUMN `dummy_am_amt_from` DOUBLE NOT NULL DEFAULT 0 AFTER `dummy_account_2`, ADD COLUMN `dummy_am_amt_to` DOUBLE NOT NULL DEFAULT 0 AFTER `dummy_am_amt_from`, ADD COLUMN `dummy_am_amt_time` TIME AFTER `dummy_am_amt_to`, ADD COLUMN `dummy_pm_amt_from` DOUBLE NOT NULL DEFAULT 0 AFTER `dummy_am_amt_time`, ADD COLUMN `dummy_pm_amt_to` DOUBLE NOT NULL DEFAULT 0 AFTER `dummy_pm_amt_from`, ADD COLUMN `dummy_pm_amt_time` TIME AFTER `dummy_pm_amt_to`, ADD COLUMN `dummy_eve_amt_from` DOUBLE NOT NULL DEFAULT 0 AFTER `dummy_pm_amt_time`, ADD COLUMN `dummy_eve_amt_to` DOUBLE NOT NULL DEFAULT 0 AFTER `dummy_eve_amt_from`, ADD COLUMN `dummy_eve_amt_time` TIME AFTER `dummy_eve_amt_to`, ADD COLUMN `dummy_mid_amt_from` DOUBLE NOT NULL DEFAULT 0 AFTER `dummy_eve_amt_time`, ADD COLUMN `dummy_mid_amt_to` DOUBLE NOT NULL DEFAULT 0 AFTER `dummy_mid_amt_from`, ADD COLUMN `dummy_mid_amt_time` TIME AFTER `dummy_mid_amt_to`;");
        }

        updateVersion = "2022-08-14";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` ADD COLUMN `betwatcherpercentdifference` DOUBLE NOT NULL DEFAULT 10 AFTER `betwatchermaxamount`, ADD COLUMN `betwatcherincludedummybets` BOOLEAN NOT NULL DEFAULT 0 AFTER `betwatcherpercentdifference`;");
        }

        updateVersion = "2022-08-15";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblfightbets` ADD COLUMN `display_id` VARCHAR(45) NOT NULL DEFAULT '' AFTER `dummy`, ADD COLUMN `display_name` VARCHAR(50) NOT NULL DEFAULT '' AFTER `display_id`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblfightbets2` ADD COLUMN `display_id` VARCHAR(45) NOT NULL DEFAULT '' AFTER `dummy`, ADD COLUMN `display_name` VARCHAR(50) NOT NULL DEFAULT '' AFTER `display_id`;");
            ExecuteUpdateDB(updateVersion, "DROP TABLE IF EXISTS `tblcommissionledger`;");
            ExecuteUpdateDB(updateVersion, "DROP TABLE IF EXISTS `tblcommissionlogs`;");
            ExecuteUpdateDB(updateVersion, "DROP TABLE IF EXISTS `tblcommissionsetup`;");
        }

        updateVersion = "2022-08-16";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "CREATE TABLE `tblpromotion` (  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,  `operatorid` varchar(5) NOT NULL DEFAULT '',  `sortorder` int(10) unsigned NOT NULL DEFAULT '0',  `title` varchar(100) NOT NULL DEFAULT '',  `push_message` varchar(200) NOT NULL DEFAULT '',  `validity` tinyint(1) NOT NULL DEFAULT '0',  `valid_date` date DEFAULT NULL,  `filename` varchar(45) NOT NULL DEFAULT '',  `banner_url` varchar(200) NOT NULL DEFAULT '',  `featured` tinyint(1) NOT NULL DEFAULT '0',  `datetrn` datetime NOT NULL,  `addedby` varchar(5) NOT NULL DEFAULT '',  PRIMARY KEY (`id`)) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;");
        }

        updateVersion = "2022-08-17";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "CREATE TABLE `tbldummysettings` (  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,  `time_am` time NOT NULL,  `range_am` int(10) unsigned NOT NULL DEFAULT '0',  `time_pm` time NOT NULL,  `range_pm` int(10) unsigned NOT NULL DEFAULT '0',  `time_eve` time NOT NULL,  `range_eve` int(10) unsigned NOT NULL DEFAULT '0',  `time_mid` time NOT NULL,  `range_mid` int(10) unsigned NOT NULL DEFAULT '0',  PRIMARY KEY (`id`)) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;");
        }

        updateVersion = "2022-08-18";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "DROP TABLE IF EXISTS `tbldummysettings`;");
            ExecuteUpdateDB(updateVersion, "CREATE TABLE `tbldummysettings` (  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,  `time_am` time NOT NULL,  `range_am_from` int(10) unsigned NOT NULL DEFAULT '0',  `range_am_to` int(10) unsigned NOT NULL DEFAULT '0',  `time_pm` time NOT NULL,  `range_pm_from` int(10) unsigned NOT NULL DEFAULT '0',  `range_pm_to` int(10) unsigned NOT NULL DEFAULT '0',  `time_eve` time NOT NULL,  `range_eve_from` int(10) unsigned NOT NULL DEFAULT '0',  `range_eve_to` int(10) unsigned NOT NULL DEFAULT '0',  `time_mid` time NOT NULL,  `range_mid_from` int(10) unsigned NOT NULL DEFAULT '0',  `range_mid_to` int(10) unsigned NOT NULL DEFAULT '0',  PRIMARY KEY (`id`)) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;");
        }

        updateVersion = "2022-08-19";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbldeposits` ADD COLUMN `deposit_type` VARCHAR(5) NOT NULL DEFAULT '' AFTER `agentid`, ADD COLUMN `sender_name` VARCHAR(50) NOT NULL DEFAULT '' AFTER `remittanceid`, ADD COLUMN `date_deposit` DATE NOT NULL AFTER `sender_name`, ADD COLUMN `time_deposit` TIME NOT NULL AFTER `date_deposit`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbldeposits` MODIFY COLUMN `note` VARCHAR(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '', MODIFY COLUMN `attachment` VARCHAR(1000) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '';");
        }

        updateVersion = "2022-08-20";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` ADD COLUMN `currency` VARCHAR(5) NOT NULL DEFAULT '' AFTER `mobile`;");
        }

        updateVersion = "2022-08-22";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblsubscriber` MODIFY COLUMN `accounttype` VARCHAR(20) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '';");
            ExecuteUpdateDB(updateVersion, "CREATE TABLE `tbloperatorbank` (  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,  `operatorid` varchar(5) NOT NULL DEFAULT '',  `bankid` varchar(5) NOT NULL DEFAULT '',  `accountno` varchar(20) NOT NULL DEFAULT '',  `accountname` varchar(50) NOT NULL DEFAULT '',  `deleted` tinyint(1) NOT NULL DEFAULT '0',  `datedeleted` datetime DEFAULT NULL,  PRIMARY KEY (`id`)) ENGINE=InnoDB AUTO_INCREMENT=1000 DEFAULT CHARSET=latin1;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblsubscriber` ADD COLUMN `displayoperatorbank` BOOLEAN NOT NULL DEFAULT 0 AFTER `iscashaccount`;");
            ExecuteUpdateDB(updateVersion, "update `tblsubscriber` set accounttype='player_cash' where accounttype='player' and iscashaccount='1';");
            ExecuteUpdateDB(updateVersion, "update `tblsubscriber` set accounttype='player_non_cash' where accounttype='player' and iscashaccount='0';");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblscorereport` ADD COLUMN `creditbal` DOUBLE NOT NULL DEFAULT 0 AFTER `total`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbldeposits` ADD COLUMN `operatoraccount` BOOLEAN NOT NULL DEFAULT 0 AFTER `operatorid`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbldeposits` ADD COLUMN `operatorbankid` VARCHAR(10) NOT NULL DEFAULT '' AFTER `operatoraccount`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblscorereport` ADD COLUMN `sort` INTEGER UNSIGNED NOT NULL DEFAULT 0  AFTER `isagent`;");
        }
        
        updateVersion = "2022-08-24";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblscorereport` ADD COLUMN `sort` INTEGER UNSIGNED NOT NULL DEFAULT 0  AFTER `isagent`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbltemplate` ADD COLUMN `imageurl` VARCHAR(500) NOT NULL DEFAULT '';");
        }

        updateVersion = "2022-08-25";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbldeposits` ADD COLUMN `iscashaccount` BOOLEAN NOT NULL DEFAULT 0 AFTER `deposit_type`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblwithdrawal` ADD COLUMN `iscashaccount` BOOLEAN NOT NULL DEFAULT 0 AFTER `isbank`;");
        }

        updateVersion = "2022-08-26";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblbankaccounts` ADD COLUMN `isoperator` BOOLEAN NOT NULL DEFAULT 0 AFTER `id`");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblbankaccounts` ADD COLUMN `depository` BOOLEAN NOT NULL DEFAULT 0 AFTER `preferred`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbldeposits` CHANGE COLUMN `operatorbankid` `bankid` VARCHAR(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblbankaccounts` AUTO_INCREMENT = 1000;");
            ExecuteUpdateDB(updateVersion, "DROP TABLE IF EXISTS `tbloperatorbank`;");
        }

        updateVersion = "2022-08-27";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblvideosource` ADD COLUMN `player_type` VARCHAR(45) NOT NULL DEFAULT '' AFTER `source_working`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblvideosource` MODIFY COLUMN `source_url` VARCHAR(5000) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '';");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblevent` ADD COLUMN `live_stream_title` VARCHAR(1000) NOT NULL DEFAULT '' AFTER `live_mode`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblversioncontrol` ADD COLUMN `dashboardinstaller` VARCHAR(200) NOT NULL DEFAULT '';");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblvideosource` ADD COLUMN `deleted` BOOLEAN NOT NULL DEFAULT 0 AFTER `player_type`;");
        }

        updateVersion = "2022-08-28";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblscorereport` ADD COLUMN `ismasteragent` BOOLEAN NOT NULL DEFAULT 0 AFTER `level`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblfightbets` ADD COLUMN `cancelledreason` VARCHAR(200) NOT NULL DEFAULT '' AFTER `cancelled`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblfightbets2` ADD COLUMN `cancelledreason` VARCHAR(200) NOT NULL DEFAULT '' AFTER `cancelled`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblcreditledger` ADD INDEX `accountid`(`accountid`), ADD INDEX `appreference`(`appreference`), ADD INDEX `description`(`description`), ADD INDEX `debit`(`debit`), ADD INDEX `credit`(`credit`);");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblsubscriber` ADD INDEX `accountid`(`accountid`), ADD INDEX `fullname`(`fullname`), ADD INDEX `username`(`username`), ADD INDEX `mobilenumber`(`mobilenumber`), ADD INDEX `operatorid`(`operatorid`), ADD INDEX `masteragentid`(`masteragentid`), ADD INDEX `agentid`(`agentid`);");
            ExecuteUpdateDB(updateVersion, "CREATE TABLE `tblfightlogs` (  `id` int(11) NOT NULL AUTO_INCREMENT,  `accountid` varchar(50) NOT NULL DEFAULT '',  `sessionid` varchar(45) NOT NULL DEFAULT '',  `eventid` varchar(45) NOT NULL DEFAULT '',  `fightkey` varchar(50) NOT NULL DEFAULT '',  `description` varchar(1000) NOT NULL DEFAULT '',  `amount` double NOT NULL DEFAULT '0',  PRIMARY KEY (`id`)) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;");
            ExecuteUpdateDB(updateVersion, "CREATE TABLE `tblfightbetslogs` (  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,  `operatorid` varchar(3) NOT NULL DEFAULT '',  `accountid` varchar(45) NOT NULL DEFAULT '',  `banker` tinyint(1) NOT NULL DEFAULT '0',  `dummy` tinyint(1) NOT NULL DEFAULT '0',  `display_id` varchar(45) NOT NULL DEFAULT '',  `display_name` varchar(50) NOT NULL DEFAULT '',  `sessionid` varchar(45) NOT NULL DEFAULT '',  `appreference` varchar(45) NOT NULL DEFAULT '',  `masteragentid` varchar(45) NOT NULL DEFAULT '',  `agentid` varchar(45) NOT NULL DEFAULT '',  `eventid` varchar(45) NOT NULL DEFAULT '',  `eventkey` varchar(45) NOT NULL DEFAULT '',  `fightkey` varchar(45) NOT NULL DEFAULT '',  `fightnumber` int(10) unsigned NOT NULL DEFAULT '0',  `postingdate` date NOT NULL,  `transactionno` varchar(45) NOT NULL DEFAULT '',  `bet_choice` varchar(1) NOT NULL DEFAULT '',  `bet_amount` double NOT NULL DEFAULT '0',  `result` varchar(1) NOT NULL DEFAULT '',  `win` tinyint(1) NOT NULL DEFAULT '0',  `odd` double NOT NULL DEFAULT '0',  `win_amount` double NOT NULL DEFAULT '0',  `lose_amount` double NOT NULL DEFAULT '0',  `payout_amount` double NOT NULL DEFAULT '0',  `gros_ge_rate` double NOT NULL DEFAULT '0',  `gros_ge_total` double NOT NULL DEFAULT '0',  `gros_op_rate` double NOT NULL DEFAULT '0',  `gros_op_total` double NOT NULL DEFAULT '0',  `gros_be_rate` double NOT NULL DEFAULT '0',  `gros_be_total` double NOT NULL DEFAULT '0',  `prof_op_rate` double NOT NULL DEFAULT '0',  `prof_op_total` double NOT NULL DEFAULT '0',  `prof_ag_rate` double NOT NULL DEFAULT '0',  `prof_ag_total` double NOT NULL DEFAULT '0',  `datetrn` datetime NOT NULL,  `cancelled` tinyint(1) NOT NULL DEFAULT '0',  `cancelledreason` varchar(200) NOT NULL DEFAULT '',  PRIMARY KEY (`id`),  KEY `operatorid` (`operatorid`),  KEY `accountid` (`accountid`),  KEY `masteragentid` (`masteragentid`),  KEY `agentid` (`agentid`),  KEY `eventid` (`eventid`),  KEY `eventkey` (`eventkey`),  KEY `fightkey` (`fightkey`)) ENGINE=InnoDB DEFAULT CHARSET=latin1;");
        }

        updateVersion = "2022-08-29";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "DROP TABLE IF EXISTS `tblannouncement`;");
            ExecuteUpdateDB(updateVersion, "CREATE TABLE `tblannouncement` (  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,  `category` varchar(5) NOT NULL DEFAULT '',  `operatorid` varchar(5) NOT NULL DEFAULT '',  `sortorder` int(10) unsigned NOT NULL DEFAULT '0',  `title` varchar(100) NOT NULL DEFAULT '',  `push_message` varchar(200) NOT NULL DEFAULT '',  `validity` tinyint(1) NOT NULL DEFAULT '0',  `valid_date` date DEFAULT NULL,  `filename` varchar(45) NOT NULL DEFAULT '',  `banner_url` varchar(200) NOT NULL DEFAULT '',  `featured` tinyint(1) NOT NULL DEFAULT '0',  `datetrn` datetime NOT NULL,  `addedby` varchar(5) NOT NULL DEFAULT '',  PRIMARY KEY (`id`)) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1;");
        }

        updateVersion = "2022-08-30";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblscorereport` ADD COLUMN `masteragentid` VARCHAR(45) NOT NULL DEFAULT '' AFTER `accountid`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` ADD COLUMN `testaccountid` VARCHAR(45) NOT NULL DEFAULT '' AFTER `ownersaccountid`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblfightbets` ADD COLUMN `test` BOOLEAN NOT NULL DEFAULT 0 AFTER `dummy`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblfightbets2` ADD COLUMN `test` BOOLEAN NOT NULL DEFAULT 0 AFTER `dummy`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblfightbetslogs` ADD COLUMN `test` BOOLEAN NOT NULL DEFAULT 0 AFTER `dummy`;");
            ExecuteUpdateDB(updateVersion, "update `tblfightbets2` set test=1 where masteragentid='101-00022';");
            ExecuteUpdateDB(updateVersion, "update `tblfightbetslogs` set test=1 where masteragentid='101-00022';");
            ExecuteUpdateDB(updateVersion, "DROP TABLE IF EXISTS `tblannouncement`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblpromotion` ADD COLUMN `category` VARCHAR(45) NOT NULL DEFAULT '' AFTER `operatorid`;");
            ExecuteUpdateDB(updateVersion, "update `tblpromotion` set category='PROMO';");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblpromotion` ADD COLUMN `visible` BOOLEAN NOT NULL DEFAULT 0 AFTER `featured`;");
        }

        updateVersion = "2022-10-09";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbladminaccounts` DROP COLUMN `address`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbladminaccounts` ADD COLUMN `deleted` BOOLEAN NOT NULL DEFAULT 0 AFTER `blocked`, ADD COLUMN `datedeleted` DATETIME AFTER `deleted`, ADD COLUMN `deletedby` VARCHAR(10) NOT NULL DEFAULT '' AFTER `datedeleted`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbladminaccounts` ADD COLUMN `operatoradmin` BOOLEAN NOT NULL DEFAULT 0 AFTER `superadmin`, ADD COLUMN `operatorid` VARCHAR(5) NOT NULL DEFAULT '' AFTER `operatoradmin`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbladminaccounts` ADD COLUMN `lastlogin` DATETIME AFTER `deletedby`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbladminaccounts` ADD COLUMN `blockedreason` VARCHAR(200) NOT NULL DEFAULT '' AFTER `blocked`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbladminaccounts` ADD COLUMN `dateblocked` DATETIME AFTER `blockedreason`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbladminaccounts` ADD COLUMN `allow_dashboard` BOOLEAN NOT NULL DEFAULT 0 AFTER `operatorid`, ADD COLUMN `allow_controller` BOOLEAN NOT NULL DEFAULT 0 AFTER `allow_dashboard`, ADD COLUMN `allow_operator` BOOLEAN NOT NULL DEFAULT 0 AFTER `allow_controller`, ADD COLUMN `allow_agent` BOOLEAN NOT NULL DEFAULT 0 AFTER `allow_operator`, ADD COLUMN `allow_score` BOOLEAN NOT NULL DEFAULT 0 AFTER `allow_agent`, ADD COLUMN `allow_event` BOOLEAN NOT NULL DEFAULT 0 AFTER `allow_score`,ADD COLUMN `allow_video` BOOLEAN NOT NULL DEFAULT 0 AFTER `allow_event`, ADD COLUMN `allow_reports` BOOLEAN NOT NULL DEFAULT 0 AFTER `allow_video`, ADD COLUMN `allow_profit` BOOLEAN NOT NULL DEFAULT 0 AFTER `allow_reports`, ADD COLUMN `allow_promo` BOOLEAN NOT NULL DEFAULT 0 AFTER `allow_profit`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbladminaccounts` ADD COLUMN `allow_add` BOOLEAN NOT NULL DEFAULT 0 AFTER `operatorid`, ADD COLUMN `allow_edit` BOOLEAN NOT NULL DEFAULT 0 AFTER `allow_add`, ADD COLUMN `allow_delete` BOOLEAN NOT NULL DEFAULT 0 AFTER `allow_edit`, ADD COLUMN `allow_dummy` BOOLEAN NOT NULL DEFAULT 0 AFTER `allow_delete`, ADD COLUMN `allow_bet_watcher` BOOLEAN NOT NULL DEFAULT 0 AFTER `allow_dummy`, ADD COLUMN `allow_banker` BOOLEAN NOT NULL DEFAULT 0 AFTER `allow_bet_watcher`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbladminaccounts` ADD COLUMN `dateupdated` DATETIME NOT NULL AFTER `dateregistered`;");
            ExecuteUpdateDB(updateVersion, "UPDATE `tbladminaccounts` set dateupdated=current_timestamp;");
            ExecuteUpdateDB(updateVersion, "update `tbladminaccounts` set operatorid='101';");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` ADD COLUMN `dummy_master` VARCHAR(45) NOT NULL DEFAULT '' AFTER `dummy_enable`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblsubscriber` ADD COLUMN `deleted` BOOLEAN NOT NULL DEFAULT 0 AFTER `operator_blocked_message`, ADD COLUMN `datedeleted` DATETIME AFTER `deleted`, ADD COLUMN `deletedby` VARCHAR(10) NOT NULL DEFAULT '' AFTER `datedeleted`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblsubscriber` ADD COLUMN `game_win_streak_log` INTEGER UNSIGNED NOT NULL DEFAULT 0 AFTER `creditbal`, ADD COLUMN `game_lose_streak_log` INTEGER UNSIGNED NOT NULL DEFAULT 0 AFTER `game_win_streak_log`;"); 
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblsubscriber` ADD COLUMN `game_win_streak_count` INTEGER UNSIGNED NOT NULL DEFAULT 0 AFTER `game_win_streak_log`, ADD COLUMN `game_lose_streak_count` INTEGER UNSIGNED NOT NULL DEFAULT 0 AFTER `game_lose_streak_log`;"); 
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblsubscriber` ADD COLUMN `game_streak_update` DATETIME AFTER `game_lose_streak_count`;");
            ExecuteUpdateDB(updateVersion, "CREATE TABLE `tblfightlogs2` (  `id` int(11) NOT NULL AUTO_INCREMENT,  `accountid` varchar(50) NOT NULL DEFAULT '',  `sessionid` varchar(45) NOT NULL DEFAULT '',  `eventid` varchar(45) NOT NULL DEFAULT '',  `fightkey` varchar(50) NOT NULL DEFAULT '',  `description` varchar(1000) NOT NULL DEFAULT '',  `amount` double NOT NULL DEFAULT '0',  PRIMARY KEY (`id`)) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;"); 
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblcreditloadlogs` ADD COLUMN `reference` VARCHAR(200) NOT NULL DEFAULT '' AFTER `amount`;");
            ExecuteUpdateDB(updateVersion, "CREATE TABLE `tblreporttemplate` (  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,  `reportcode` varchar(45) NOT NULL DEFAULT '',  `reportname` varchar(45) NOT NULL DEFAULT '',  `enable_menu` tinyint(1) NOT NULL DEFAULT '0',  PRIMARY KEY (`id`)) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;");
        }

        updateVersion = "2022-10-10";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "CREATE TABLE `tblcreditledgerlogs` (  `id` int(11) NOT NULL AUTO_INCREMENT,  `accountid` varchar(50) NOT NULL DEFAULT '',  `sessionid` varchar(45) NOT NULL DEFAULT '',  `appreference` varchar(50) NOT NULL DEFAULT '',  `description` varchar(100) NOT NULL DEFAULT '',  `debit` double NOT NULL DEFAULT '0',  `credit` double NOT NULL DEFAULT '0',  `trnby` varchar(45) NOT NULL DEFAULT '',  PRIMARY KEY (`id`),  KEY `accountid` (`accountid`),  KEY `appreference` (`appreference`),  KEY `description` (`description`),  KEY `debit` (`debit`),  KEY `credit` (`credit`),  KEY `sessionid` (`sessionid`),  KEY `trnby` (`trnby`)) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;");
        }

        updateVersion = "2022-10-11";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` CHANGE COLUMN `betwatcherpercentdifference` `betwatcherodds` DOUBLE NOT NULL DEFAULT 0;");
        }

        updateVersion = "2022-11-24";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` ADD COLUMN `country` VARCHAR(3) NOT NULL DEFAULT '' AFTER `mobile`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblremittance` ADD COLUMN `operatorid` VARCHAR(5) NOT NULL DEFAULT '' AFTER `code`;");
            ExecuteUpdateDB(updateVersion, "update `tbloperator` set country='MY' where companyid='101';");
            ExecuteUpdateDB(updateVersion, "update `tblremittance` set operatorid='101';");
            
            ExecuteUpdateDB(updateVersion, "CREATE TABLE `tblfightbetsdummy` (  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,  `operatorid` varchar(3) NOT NULL DEFAULT '',  `accountid` varchar(45) NOT NULL DEFAULT '',  `banker` tinyint(1) NOT NULL DEFAULT '0',  `dummy` tinyint(1) NOT NULL DEFAULT '0',  `test` tinyint(1) NOT NULL DEFAULT '0',  `display_id` varchar(45) NOT NULL DEFAULT '',  `display_name` varchar(50) NOT NULL DEFAULT '',  `sessionid` varchar(45) NOT NULL DEFAULT '',  `appreference` varchar(45) NOT NULL DEFAULT '',  `masteragentid` varchar(45) NOT NULL DEFAULT '',  `agentid` varchar(45) NOT NULL DEFAULT '',  `eventid` varchar(45) NOT NULL DEFAULT '',  `eventkey` varchar(45) NOT NULL DEFAULT '',  `fightkey` varchar(45) NOT NULL DEFAULT '',  `fightnumber` int(10) unsigned NOT NULL DEFAULT '0',  `postingdate` date NOT NULL,  `transactionno` varchar(45) NOT NULL DEFAULT '',  `bet_choice` varchar(1) NOT NULL DEFAULT '',  `bet_amount` double NOT NULL DEFAULT '0',  `result` varchar(1) NOT NULL DEFAULT '',  `win` tinyint(1) NOT NULL DEFAULT '0',  `odd` double NOT NULL DEFAULT '0',  `win_amount` double NOT NULL DEFAULT '0',  `lose_amount` double NOT NULL DEFAULT '0',  `payout_amount` double NOT NULL DEFAULT '0',  `gros_ge_rate` double NOT NULL DEFAULT '0',  `gros_ge_total` double NOT NULL DEFAULT '0',  `gros_op_rate` double NOT NULL DEFAULT '0',  `gros_op_total` double NOT NULL DEFAULT '0',  `gros_be_rate` double NOT NULL DEFAULT '0',  `gros_be_total` double NOT NULL DEFAULT '0',  `prof_op_rate` double NOT NULL DEFAULT '0',  `prof_op_total` double NOT NULL DEFAULT '0',  `prof_ag_rate` double NOT NULL DEFAULT '0',  `prof_ag_total` double NOT NULL DEFAULT '0',  `datetrn` datetime NOT NULL,  `cancelled` tinyint(1) NOT NULL DEFAULT '0',  `cancelledreason` varchar(200) NOT NULL DEFAULT '',  PRIMARY KEY (`id`),  KEY `operatorid` (`operatorid`),  KEY `accountid` (`accountid`),  KEY `masteragentid` (`masteragentid`),  KEY `agentid` (`agentid`),  KEY `eventid` (`eventid`),  KEY `eventkey` (`eventkey`),  KEY `fightkey` (`fightkey`)) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` ADD COLUMN `cs_whatsapp` VARCHAR(100) NOT NULL DEFAULT '' AFTER `currency`, ADD COLUMN `cs_messenger` VARCHAR(100) NOT NULL DEFAULT '' AFTER `cs_whatsapp`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbladminaccounts` ADD COLUMN `allow_tools` BOOLEAN NOT NULL DEFAULT 0 AFTER `allow_dashboard`;");
        }

        updateVersion = "2022-11-25";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` ADD COLUMN `enablebetbalancer` VARCHAR(45) NOT NULL DEFAULT 0 AFTER `testaccountid`, ADD COLUMN `betbalanceramount` DOUBLE NOT NULL DEFAULT 500 AFTER `enablebetbalancer`;");
        }

        updateVersion = "2023-01-06";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblvideosource` ADD COLUMN `web_player` VARCHAR(45) NOT NULL DEFAULT 'swarmcloud' AFTER `player_type`;");
        }

        updateVersion = "2023-02-13";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblgeneralsettings` ADD COLUMN `pusher_app_id` VARCHAR(45) NOT NULL DEFAULT '' AFTER `firebasedb`, ADD COLUMN `pusher_app_key` VARCHAR(45) NOT NULL DEFAULT '' AFTER `pusher_app_id`, ADD COLUMN `pusher_app_secret` VARCHAR(45) NOT NULL DEFAULT '' AFTER `pusher_app_key`, ADD COLUMN `pusher_app_cluster` VARCHAR(5) NOT NULL DEFAULT '' AFTER `pusher_app_secret`, ADD COLUMN `pusher_app_channel` VARCHAR(45) NOT NULL DEFAULT '' AFTER `pusher_app_cluster`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblfightbets` ADD COLUMN `platform` VARCHAR(10) NOT NULL DEFAULT 'android' AFTER `appreference`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblfightbets2` ADD COLUMN `platform` VARCHAR(10) NOT NULL DEFAULT 'android' AFTER `appreference`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblfightbetslogs` ADD COLUMN `platform` VARCHAR(10) NOT NULL DEFAULT 'android' AFTER `appreference`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblfightbetserror` ADD COLUMN `platform` VARCHAR(10) NOT NULL DEFAULT 'android' AFTER `appreference`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblvideosource` ADD COLUMN `web_url` VARCHAR(5000) NOT NULL DEFAULT '' AFTER `player_type`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblevent` ADD COLUMN `live_sourceid` VARCHAR(45) NOT NULL DEFAULT '' AFTER `live_mode`;");
        }

        updateVersion = "2023-02-24";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblgeneralsettings` ADD COLUMN `firebaseauth` VARCHAR(200) NOT NULL DEFAULT '' AFTER `firebaseapi`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tbloperator` ADD COLUMN `totalonline` INTEGER UNSIGNED NOT NULL DEFAULT 0 AFTER `actived`;");
        }

        updateVersion = "2023-03-01";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "CREATE TABLE `tblapiwhitelist` (  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,  `operatorid` varchar(45) NOT NULL DEFAULT '',  `accountid` varchar(45) NOT NULL DEFAULT '',  `domainname` varchar(100) NOT NULL DEFAULT '',  PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=latin1;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblsubscriber` ADD COLUMN `api_enabled` BOOLEAN NOT NULL DEFAULT 0 AFTER `agentid`;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblsubscriber` ADD COLUMN `api_player` BOOLEAN NOT NULL DEFAULT 0 AFTER `api_enabled`, ADD COLUMN `api_userid` VARCHAR(50) NOT NULL DEFAULT '' AFTER `api_player`;");
            ExecuteUpdateDB(updateVersion, " CREATE TABLE `tblapideniedaccess` (  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,  `apikey` varchar(100) NOT NULL DEFAULT '',  `domain` varchar(45) NOT NULL DEFAULT '',  `datelogs` datetime NOT NULL,  PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=latin1;");
        }

        updateVersion = "2023-03-02";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblcreditloadlogs` ADD COLUMN `masteragentid` VARCHAR(45) NOT NULL DEFAULT '' AFTER `accountid`, ADD COLUMN `agentid` VARCHAR(45) NOT NULL DEFAULT '' AFTER `masteragentid`;");
            ExecuteUpdateDB(updateVersion, "UPDATE `tblcreditloadlogs` as c inner join tblsubscriber as a on c.accountid=a.accountid set c.masteragentid = a.masteragentid, c.agentid=a.agentid;");
        }

        updateVersion = "2023-03-07";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblcreditledgerlogs` ADD COLUMN `datetrn` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER `trnby`");
        }

        updateVersion = "2023-04-10";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "CREATE TABLE `tblarena` (  `arenaid` int(10) unsigned NOT NULL AUTO_INCREMENT,  `arenaname` varchar(45) NOT NULL DEFAULT '',  `main_banner_url` varchar(500) NOT NULL DEFAULT '',  `main_banner_name` varchar(100) NOT NULL DEFAULT '',  `vertical_banner_url` varchar(500) NOT NULL DEFAULT '',  `vertical_banner_name` varchar(100) NOT NULL DEFAULT '',  `auto_lastcall` tinyint(1) NOT NULL DEFAULT '0',  `timer_lastcall` int(10) unsigned NOT NULL DEFAULT '120',  `auto_closed` tinyint(1) NOT NULL DEFAULT '0',  `timer_closed` int(10) unsigned NOT NULL DEFAULT '120',  `active` tinyint(1) NOT NULL DEFAULT '0',  PRIMARY KEY (`arenaid`)) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=latin1;");
            ExecuteUpdateDB(updateVersion, "ALTER TABLE `tblvideosource` ADD COLUMN `web_available` BOOLEAN NOT NULL DEFAULT 1 AFTER `player_type`;");
        }

        updateVersion = "2023-08-24";
        if(QuerySingleData("if(databaseversion < '" + updateVersion + "','YES','NO')", "proceedupdate", "tblupdatelogs where id > 0 order by databaseversion desc limit 1").equals("YES")) {
            ExecuteUpdateDB(updateVersion, "ALTER TABLE  `tblsubscriber` ADD COLUMN `api_identifier` VARCHAR(100) NOT NULL DEFAULT '' AFTER `api_userid`;");
        }*/

    }catch(Exception e){
        logError("ExecuteDatabaseUpgrade",e.toString());
    }
}
%>

<%!public void ExecuteUpdateDB(String nVersions, String strQuery) {
    ExecuteQuery(strQuery);
    ExecuteQuery("insert into tblupdatelogs set databaseversion='" + nVersions + "',dateupdate=current_timestamp,appliedquery='" + rchar(strQuery) + "'");
}
%>