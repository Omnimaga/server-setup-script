<?php
	/* Servers configuration */
	$i = 0;

	/* Local server */
	$i++;
	$cfg['Servers'][$i]['auth_type'] = 'cookie';
	$cfg['Servers'][$i]['host'] = 'localhost';
	$cfg['Servers'][$i]['connect_type'] = 'tcp';
	$cfg['Servers'][$i]['compress'] = true;
	$cfg['Servers'][$i]['verbose'] = gethostname();
	$cfg['Servers'][$i]['port'] = '';
	$cfg['Servers'][$i]['socket'] = '';
	$cfg['Servers'][$i]['ssl'] = true;
	$cfg['Servers'][$i]['user'] = 'root';
	$cfg['Servers'][$i]['password'] = '';
	$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';
	$cfg['Servers'][$i]['relation'] = 'pma__relation';
	$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
	$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
	$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
	$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
	$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
	$cfg['Servers'][$i]['history'] = 'pma__history';
	$cfg['Servers'][$i]['designer_coords'] = 'pma__designer_coords';
	$cfg['Servers'][$i]['recent'] = 'pma__recent';
	$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
	$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
	$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
	$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
	$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
	$cfg['Servers'][$i]['users'] = 'pma__users';
	$cfg['Servers'][$i]['controluser']   = 'pma';
	$cfg['Servers'][$i]['controlpass']   = 'pmapass';

	/* End of servers configuration */

	$cfg['blowfish_secret'] = 'sEF45WT2LQEcxzUj$';
	$cfg['UploadDir'] = '';
	$cfg['SaveDir'] = '';
	$cfg['ShowDbStructureCreation'] = true;
	$cfg['ShowDbStructureLastUpdate'] = true;
	$cfg['ShowDbStructureLastCheck'] = true;
	$cfg['DefaultLang'] = 'en';
	$cfg['ServerDefault'] = 1;
?>
