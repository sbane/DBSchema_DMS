/****** Object:  Table [T_Step_Tools] ******/
/****** RowCount: 11 ******/
SET IDENTITY_INSERT [T_Step_Tools] ON
INSERT INTO [T_Step_Tools] (ID, Name, Description, Bionet_Required, Only_On_Storage_Server, Instrument_Capacity_Limited, Holdoff_Interval_Minutes, Number_Of_Retries, Processor_Assignment_Applies) VALUES (13,'ArchiveStatusCheck','Verify that all of the ingest steps associated with the given job are complete (look for task_percent = 100 at https://ingestdms.my.emsl.pnl.gov/get_state?job_id=1300940)','N','N','N',20,90,'N')
INSERT INTO [T_Step_Tools] (ID, Name, Description, Bionet_Required, Only_On_Storage_Server, Instrument_Capacity_Limited, Holdoff_Interval_Minutes, Number_Of_Retries, Processor_Assignment_Applies) VALUES (3,'ArchiveUpdate','Create specific analysis results folder in dataset folder in archive and copy contents of results folder in storage to it.','N','Y','N',60,4,'N')
INSERT INTO [T_Step_Tools] (ID, Name, Description, Bionet_Required, Only_On_Storage_Server, Instrument_Capacity_Limited, Holdoff_Interval_Minutes, Number_Of_Retries, Processor_Assignment_Applies) VALUES (11,'ArchiveUpdateTest','Test instance of the ArchiveUpdate tool','N','Y','N',1,10,'N')
INSERT INTO [T_Step_Tools] (ID, Name, Description, Bionet_Required, Only_On_Storage_Server, Instrument_Capacity_Limited, Holdoff_Interval_Minutes, Number_Of_Retries, Processor_Assignment_Applies) VALUES (12,'ArchiveVerify','Verify that checksums reported by MyEMSL match those of the ingested data (using https://metadata.my.emsl.pnl.gov/fileinfo/files_for_keyvalue/omics.dms.dataset_id/598409)','N','N','N',10,90,'N')
INSERT INTO [T_Step_Tools] (ID, Name, Description, Bionet_Required, Only_On_Storage_Server, Instrument_Capacity_Limited, Holdoff_Interval_Minutes, Number_Of_Retries, Processor_Assignment_Applies) VALUES (2,'DatasetArchive','Create dataset folder on archive and copy everything from storage dataset folder into it','N','Y','N',60,1,'N')
INSERT INTO [T_Step_Tools] (ID, Name, Description, Bionet_Required, Only_On_Storage_Server, Instrument_Capacity_Limited, Holdoff_Interval_Minutes, Number_Of_Retries, Processor_Assignment_Applies) VALUES (1,'DatasetCapture','Create dataset folder on storage server and copy instrument data into it','Y','N','Y',0,0,'Y')
INSERT INTO [T_Step_Tools] (ID, Name, Description, Bionet_Required, Only_On_Storage_Server, Instrument_Capacity_Limited, Holdoff_Interval_Minutes, Number_Of_Retries, Processor_Assignment_Applies) VALUES (4,'DatasetInfo','Creatse QC graphics','N','N','N',0,0,'N')
INSERT INTO [T_Step_Tools] (ID, Name, Description, Bionet_Required, Only_On_Storage_Server, Instrument_Capacity_Limited, Holdoff_Interval_Minutes, Number_Of_Retries, Processor_Assignment_Applies) VALUES (8,'DatasetIntegrity','Makes sure that captured file is valid (not too small, required files/folders are present). For IMS08, converts the .D folder to .UIMF. For Agilent GC, converts the .D folder to CDF using OpenChrom','N','N','N',0,0,'N')
INSERT INTO [T_Step_Tools] (ID, Name, Description, Bionet_Required, Only_On_Storage_Server, Instrument_Capacity_Limited, Holdoff_Interval_Minutes, Number_Of_Retries, Processor_Assignment_Applies) VALUES (9,'DatasetQuality','Creates the metadata.xml file and runs Quameter','N','N','N',0,0,'N')
INSERT INTO [T_Step_Tools] (ID, Name, Description, Bionet_Required, Only_On_Storage_Server, Instrument_Capacity_Limited, Holdoff_Interval_Minutes, Number_Of_Retries, Processor_Assignment_Applies) VALUES (10,'ImsDeMultiplex','DeMux IMS data','N','N','N',5,4,'N')
INSERT INTO [T_Step_Tools] (ID, Name, Description, Bionet_Required, Only_On_Storage_Server, Instrument_Capacity_Limited, Holdoff_Interval_Minutes, Number_Of_Retries, Processor_Assignment_Applies) VALUES (5,'SourceFileRename','Put "x_" prefix on source files in instrument xfer directory','Y','N','N',120,75,'N')
SET IDENTITY_INSERT [T_Step_Tools] OFF
