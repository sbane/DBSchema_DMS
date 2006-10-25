/****** Object:  Table [T_Analysis_Tool] ******/
/****** RowCount: 16 ******/
/****** Columns: AJT_toolID, AJT_toolName, AJT_paramFileType, AJT_parmFileStoragePath, AJT_parmFileStoragePathLocal, AJT_allowedInstClass, AJT_defaultSettingsFileName, AJT_resultType, AJT_autoScanFolderFlag, AJT_active, AJT_searchEngineInputFileFormats, AJT_orgDbReqd, AJT_extractionRequired ******/
INSERT INTO [T_Analysis_Tool] VALUES (0,'(none)',1,'(na)','(na)','(na)','(na)','','no ',0,'(na)',0,'N')
INSERT INTO [T_Analysis_Tool] VALUES (1,'Sequest',1000,'\\gigasax\DMS_Parameter_Files\Sequest\','C:\DMS_Parameter_Files\Sequest\','Finnigan_Ion_Trap, LTQ_FT','LCQDefSettings.txt','Peptide_Hit','no ',1,'Individual_DTA',1,'Y')
INSERT INTO [T_Analysis_Tool] VALUES (2,'ICR2LS',1003,'\\gigasax\DMS_Parameter_Files\icr2ls\','C:\DMS_Parameter_Files\icr2ls\','Finnigan_FTICR, BRUKERFTMS','FTICRDefSettings.txt','HMMA_Peak','yes',1,'(na)',0,'N')
INSERT INTO [T_Analysis_Tool] VALUES (3,'TurboSequest',1000,'\\gigasax\DMS_Parameter_Files\Sequest\','C:\DMS_Parameter_Files\Sequest\','Finnigan_Ion_Trap','LCQDefSettings.txt','Peptide_Hit','yes',0,'Individual_DTA',1,'Y')
INSERT INTO [T_Analysis_Tool] VALUES (4,'TIC_ICR',1003,'\\gigasax\DMS_Parameter_Files\icr2ls\','C:\DMS_Parameter_Files\icr2ls\','Finnigan_FTICR, BRUKERFTMS','(na)','TIC','yes',1,'(na)',0,'N')
INSERT INTO [T_Analysis_Tool] VALUES (5,'TIC_LCQ',1,'\\gigasax\DMS_Parameter_Files\Sequest\','C:\DMS_Parameter_Files\Sequest\','Finnigan_Ion_Trap','(na)','TIC','yes',1,'(na)',0,'N')
INSERT INTO [T_Analysis_Tool] VALUES (6,'QTOFSequest',1000,'\\gigasax\DMS_Parameter_Files\Sequest\','C:\DMS_Parameter_Files\Sequest\','QStar_QTOF','LCQDefSettings.txt','Peptide_Hit','yes',0,'(na)',1,'Y')
INSERT INTO [T_Analysis_Tool] VALUES (7,'QTOFPek',1001,'\\gigasax\DMS_Parameter_Files\QTOFPek\','C:\DMS_Parameter_Files\QTOFPek\','QStar_QTOF','QTOFPekDefSettings.txt','HMMA_Peak','yes',0,'(na)',1,'N')
INSERT INTO [T_Analysis_Tool] VALUES (8,'DeNovoID',1002,'\\gigasax\DMS_Parameter_Files\DeNovoPeak\','C:\DMS_Parameter_Files\DeNovoPeak\','Finnigan_Ion_Trap','DeNovo_Default.xml','','yes',0,'(na)',1,'N')
INSERT INTO [T_Analysis_Tool] VALUES (9,'AgilentSequest',1000,'\\gigasax\DMS_Parameter_Files\Sequest\','C:\DMS_Parameter_Files\Sequest\','Agilent_Ion_Trap','AgilentDefSettings.xml','Peptide_Hit','yes',1,'(na)',1,'Y')
INSERT INTO [T_Analysis_Tool] VALUES (10,'MLynxPek',1004,'\\gigasax\DMS_Parameter_Files\MLynxPek\','C:\DMS_Parameter_Files\MLynxPek\','Micromass_QTOF','MMTofDefSettings.xml','HMMA_Peak','yes',1,'(na)',0,'N')
INSERT INTO [T_Analysis_Tool] VALUES (11,'AgilentTOFPek',1005,'\\gigasax\DMS_Parameter_Files\AgilentTOFPek\','C:\DMS_Parameter_Files\AgilentTOFPek\','Agilent_TOF','AgTofDefSettings.xml','HMMA_Peak','yes',1,'(na)',0,'N')
INSERT INTO [T_Analysis_Tool] VALUES (12,'LTQ_FTPek',1006,'\\gigasax\DMS_Parameter_Files\LTQ_FTPek\','C:\DMS_Parameter_Files\LTQ_FTPek\','LTQ_FT','LTQ_FTDefSettings.txt','HMMA_Peak','yes',1,'(na)',0,'N')
INSERT INTO [T_Analysis_Tool] VALUES (13,'MASIC_Finnigan',1007,'\\gigasax\DMS_Parameter_Files\MASIC\','C:\DMS_Parameter_Files\MASIC\','Finnigan_Ion_Trap, LTQ_FT','(na)','SIC','yes',1,'(na)',0,'N')
INSERT INTO [T_Analysis_Tool] VALUES (14,'MASIC_Agilent',1007,'\\gigasax\DMS_Parameter_Files\MASIC\','C:\DMS_Parameter_Files\MASIC\','Agilent_Ion_Trap','(na)','SIC','yes',1,'(na)',0,'N')
INSERT INTO [T_Analysis_Tool] VALUES (15,'XTandem',1008,'\\gigasax\DMS_Parameter_Files\XTandem\','C:\DMS_Parameter_Files\XTandem\','Finnigan_Ion_Trap, LTQ_FT','??','XT_Peptide_Hit','no ',1,'Concat_DTA, MGF, PKL, MzXML',1,'Y')
